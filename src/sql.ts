import sqlParser from "node-sql-parser";
import { AccessError } from "./errors.js";
import { requireTable, tableProjection, type Schema } from "./schema.js";

const parser = new sqlParser.Parser();
const functions = new Set(
  "ABS CEIL CEILING FLOOR ROUND TRUNCATE MOD POW POWER SQRT SIGN COALESCE IFNULL NULLIF IF GREATEST LEAST CONCAT CONCAT_WS LOWER UPPER LENGTH CHAR_LENGTH CHARACTER_LENGTH LEFT RIGHT SUBSTRING SUBSTR TRIM LTRIM RTRIM REPLACE LOCATE INSTR LPAD RPAD DATE DATE_FORMAT DATE_ADD DATE_SUB DATEDIFF TIMESTAMPDIFF TIMESTAMPADD YEAR MONTH DAY DAYOFMONTH DAYOFWEEK WEEK WEEKDAY QUARTER LAST_DAY CURDATE CURRENT_DATE NOW CURRENT_TIMESTAMP UTC_TIMESTAMP EXTRACT STR_TO_DATE CAST CONVERT COUNT SUM AVG MIN MAX STDDEV STDDEV_POP STDDEV_SAMP VAR_POP VAR_SAMP ROW_NUMBER RANK DENSE_RANK LAG LEAD FIRST_VALUE LAST_VALUE NTILE ROUND".split(
    " ",
  ),
);
const allowedTypes = new Set(
  "select column_ref binary_expr unary_expr number single_quote_string double_quote_string string bool null function aggr_func expr_list star interval case when else cast dataType datatype default origin window_func window specification frame_bound frame interval_expr ASC DESC".split(
    " ",
  ),
);

// Comments are deliberately unsupported, including executable MySQL comments/hints.
function rejectComments(sql: string) {
  let quote = "";
  for (let i = 0; i < sql.length; i++) {
    const c = sql[i];
    if (quote) {
      if (c === "\\" && quote !== "`") {
        i++;
        continue;
      }
      if (c === quote) {
        if (sql[i + 1] === quote) i++;
        else quote = "";
      }
    } else if (c === "'" || c === '"' || c === "`") quote = c;
    else if (
      c === "#" ||
      (c === "/" && sql[i + 1] === "*") ||
      (c === "-" && sql[i + 1] === "-")
    )
      throw new AccessError(
        "SQL comments and optimizer hints are not permitted.",
      );
  }
}
export function compileRead(
  sql: string,
  schema: Schema,
  maxRows: number,
  maxChars: number,
): { sql: string; tables: string[] } {
  if (sql.length > 32768) throw new AccessError("SQL is limited to 32 KiB.");
  rejectComments(sql);
  let root: any;
  try {
    root = parser.astify(sql, { database: "MySQL" });
  } catch {
    throw new AccessError(
      "Unsupported SQL syntax. Use one SELECT or non-recursive WITH ... SELECT.",
    );
  }
  if (Array.isArray(root)) {
    if (root.length !== 1)
      throw new AccessError("Exactly one SELECT is permitted.");
    root = root[0];
  }
  if (root?.type !== "select")
    throw new AccessError("Only SELECT queries are permitted.");
  const used = new Set<string>();
  let count = 0;
  function walk(node: any, ctes: Set<string>) {
    if (!node || typeof node !== "object") return;
    if (++count > 8000) throw new AccessError("Query is too complex.");
    if (Array.isArray(node)) {
      for (const item of node) walk(item, ctes);
      return;
    }
    if (node.type && !allowedTypes.has(node.type))
      throw new AccessError(
        `SQL construct ${String(node.type)} is not permitted.`,
      );
    if (node.type === "select") {
      if (
        node.locking_read ||
        node.into?.position ||
        node.options?.length ||
        node.procedure
      )
        throw new AccessError(
          "Locks, INTO, SELECT options, and procedures are not permitted.",
        );
      if (node.with?.some((c: any) => c.recursive))
        throw new AccessError("Recursive CTEs are not permitted.");
      const scope = new Set(ctes);
      // Validate each CTE before making its name available: no self-recursion/forward references.
      for (const c of node.with ?? []) {
        const name = String(c.name?.value ?? "").toLowerCase();
        if (
          !/^[a-z][a-z0-9_]*$/.test(name) ||
          schema.has(name) ||
          scope.has(name)
        )
          throw new AccessError(
            "CTE names must be unique and must not shadow permitted tables.",
          );
        walk(c.stmt, scope);
        scope.add(name);
      }
      for (const from of node.from ?? []) {
        if (from.db)
          throw new AccessError("Cross-database access is not permitted.");
        if (from.table) {
          const name = String(from.table).toLowerCase();
          if (!scope.has(name)) {
            const t = requireTable(schema, name);
            if (name === "tblcustomfieldsvalues")
              requireTable(schema, "tblcustomfields");
            used.add(name);
            const safe = parser.astify(tableProjection(t, maxChars), {
              database: "MySQL",
            });
            const replacement = {
              ...from,
              db: undefined,
              table: undefined,
              expr: { ast: safe, parentheses: true },
              as: from.as ?? from.table,
            };
            // Only this generated projection may access the physical table directly.
            if (from.on) walk(from.on, scope);
            Object.keys(from).forEach((k) => delete from[k]);
            Object.assign(from, replacement);
          } else {
            if (from.on) walk(from.on, scope);
          }
        } else walk(from, scope);
      }
      for (const [key, value] of Object.entries(node))
        if (key !== "from" && key !== "with") walk(value, scope);
      return;
    }
    if (node.type === "column_ref" && node.db)
      throw new AccessError("Qualified database columns are not permitted.");
    if (
      node.type === "function" ||
      node.type === "aggr_func" ||
      node.type === "window_func"
    ) {
      const parts =
        typeof node.name === "string"
          ? [node.name]
          : (node.name?.name ?? []).map((p: any) => p.value);
      if (
        node.name?.schema ||
        node.name?.db ||
        parts.length !== 1 ||
        !functions.has(String(parts[0]).toUpperCase())
      )
        throw new AccessError(
          "This function is not in the read-only analysis function allowlist.",
        );
    }
    for (const [key, value] of Object.entries(node))
      if (key !== "tableList" && key !== "columnList") walk(value, ctes);
  }
  walk(root, new Set());
  let generated: string;
  try {
    generated = parser.sqlify(root, { database: "MySQL" });
  } catch {
    throw new AccessError("Unable to compile this SELECT safely.");
  }
  // The outer cap also applies to unions and user LIMITs. Duplicate labels require explicit aliases.
  return {
    sql: `SELECT * FROM (${generated}) AS mcp_result LIMIT ${maxRows + 1}`,
    tables: [...used],
  };
}
