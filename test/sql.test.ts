import { test } from "node:test";
import assert from "node:assert/strict";
import { compileRead } from "../src/sql.js";
import type { Schema } from "../src/schema.js";

const schema: Schema = new Map([
  [
    "tblclients",
    {
      name: "tblclients",
      engine: "MyISAM",
      columns: [
        { name: "id", type: "int" },
        { name: "email", type: "text" },
      ],
    },
  ],
  [
    "tblinvoices",
    {
      name: "tblinvoices",
      engine: "MyISAM",
      columns: [
        { name: "id", type: "int" },
        { name: "userid", type: "int" },
        { name: "total", type: "decimal" },
      ],
    },
  ],
]);
const compile = (q: string) => compileRead(q, schema, 10, 8192);
test("joins, subqueries, aggregates, CTEs, unions, CASE, dates and windows compile through safe projections", () => {
  for (const q of [
    "SELECT c.id, SUM(i.total) AS balance FROM tblclients c LEFT JOIN tblinvoices i ON i.userid=c.id GROUP BY c.id ORDER BY balance DESC",
    "WITH a AS (SELECT id FROM tblclients), b AS (SELECT * FROM a) SELECT * FROM b",
    "SELECT * FROM (SELECT id FROM tblclients) x",
    "SELECT id FROM tblclients UNION ALL SELECT userid FROM tblinvoices",
    "SELECT CASE WHEN total>0 THEN total ELSE 0 END AS amount FROM tblinvoices",
    "SELECT DATE_FORMAT(NOW(),'%Y-%m'), DATE_SUB(CURDATE(),INTERVAL 1 MONTH)",
    "SELECT ROW_NUMBER() OVER(ORDER BY id DESC) AS n FROM tblclients",
    "SELECT CAST(id AS CHAR), CONVERT(id,CHAR) AS other FROM tblclients",
  ])
    assert.match(compile(q).sql, /LIMIT 11$/);
  const output = compile("SELECT * FROM tblclients").sql;
  assert.match(output, /LEFT\(`email`, 8192\)/);
  assert.doesNotMatch(output, /password/);
});
test("all mutation and dangerous SELECT paths are rejected before execution", () => {
  for (const q of [
    "UPDATE tblclients SET email='x'",
    "DELETE FROM tblclients",
    "INSERT INTO tblclients(id) VALUES(1)",
    "DROP TABLE tblclients",
    "TRUNCATE tblclients",
    "ALTER TABLE tblclients ADD n INT",
    "CALL p()",
    "SET @x=1",
    "SHOW TABLES",
    "EXPLAIN SELECT * FROM tblclients",
    "SELECT 1; DELETE FROM tblclients",
    "SELECT * FROM tblclients INTO OUTFILE '/tmp/leak'",
    "SELECT * FROM tblclients INTO DUMPFILE '/tmp/leak'",
    "SELECT * FROM tblclients FOR UPDATE",
    "SELECT * FROM tblclients LOCK IN SHARE MODE",
    "SELECT SQL_CALC_FOUND_ROWS * FROM tblclients",
    "SELECT @x := 1",
    "SELECT @@version",
    "SELECT @x",
    "SELECT SLEEP(10)",
    "SELECT BENCHMARK(1000,1)",
    "SELECT LOAD_FILE('/etc/passwd')",
    "SELECT GET_LOCK('x',10)",
    "SELECT RELEASE_ALL_LOCKS()",
    "SELECT mysql.ABS(1)",
    "SELECT billing.ROUND(1)",
    "SELECT evil()",
    "SELECT * FROM mysql.user",
    "SELECT * FROM information_schema.COLUMNS",
    "SELECT * FROM billing.tblclients",
    "SELECT billing.tblclients.id FROM tblclients",
    "SELECT * FROM tblsessions",
    "SELECT * FROM tblapilog",
    "SELECT * FROM not_a_permitted_table",
    "SELECT 1 /* hidden */",
    "SELECT /*!50000 SLEEP(10) */ 1",
    "SELECT 1 -- comment",
    "SELECT 1 # comment",
    "WITH RECURSIVE t AS (SELECT 1 UNION ALL SELECT * FROM t) SELECT * FROM t",
    "WITH tblclients AS (SELECT 1) SELECT * FROM tblclients",
    "SELECT (SELECT SLEEP(1)) AS x",
    "SELECT 1 UNION SELECT SLEEP(1)",
    "WITH a AS (SELECT SLEEP(1)) SELECT * FROM a",
  ])
    assert.throws(() => compile(q), undefined, q);
});
test("SQL string literals containing comment markers do not become executable comments", () => {
  for (const s of [
    "SELECT 'a--b' AS value",
    "SELECT '/*text*/' AS value",
    "SELECT 'a#b' AS value",
  ])
    assert.match(compile(s).sql, /mcp_result/);
});
test("hidden fields remain absent from source even when used in predicates or nested expressions", () => {
  for (const q of [
    "SELECT password FROM tblclients",
    "SELECT id FROM tblclients WHERE password='x'",
    "SELECT COUNT(*) FROM tblclients GROUP BY password",
    "SELECT (SELECT password FROM tblclients LIMIT 1) AS p",
  ]) {
    const result = compile(q).sql;
    // MySQL must resolve the secret reference against this safe derived projection, never the physical table.
    assert.match(
      result,
      /FROM \(SELECT `id` AS `id`, LEFT\(`email`, 8192\) AS `email` FROM `tblclients`\) AS `tblclients`/,
    );
  }
});
