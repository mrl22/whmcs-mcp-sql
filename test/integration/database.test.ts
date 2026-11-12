import { test, before, after } from "node:test";
import assert from "node:assert/strict";
import mysql from "mysql2/promise";
import { loadConfig } from "../../src/config.js";
import { Database } from "../../src/database.js";
import { buildTools, executeTool } from "../../src/tools.js";
import { publicError } from "../../src/errors.js";

// Deliberately ignore production MYSQL_* variables: this suite only targets its isolated fixture.
const config = loadConfig({
  MYSQL_HOST: "127.0.0.1",
  MYSQL_PORT: "13316",
  MYSQL_USER: "reader",
  MYSQL_PASSWORD: "fixture-reader",
  MYSQL_DATABASE: "whmcs_fixture",
});
const db = new Database(config);
const tools = buildTools(db);
const call = (name: string, args: unknown = {}) =>
  executeTool(
    db,
    tools.find((t) => t.name === name)!,
    args,
  ) as Promise<any>;
before(() => db.initialize());
after(() => db.close());

test("SELECT-only credentials can inspect schema and read all available named tools without returning canary secrets", async () => {
  const args: Record<string, unknown> = {
    get_client: { clientId: 1 },
    get_client_details: { clientId: 1 },
    get_invoice: { invoiceId: 1 },
    get_ticket: { ticketId: 1 },
    get_project: { projectId: 1 },
    get_quote: { quoteId: 1 },
    query_database: { sql: "SELECT COUNT(*) AS count FROM tblclients" },
  };
  const expectedUnavailable = new Set([
    "get_domain_whois",
    "get_domain_nameservers",
    "get_domain_lock_status",
    "list_projects",
    "get_project",
  ]);
  for (const tool of tools) {
    if (expectedUnavailable.has(tool.name)) {
      await assert.rejects(
        () => call(tool.name, args[tool.name]),
        (e: any) => e.code === "FEATURE_UNAVAILABLE",
        tool.name,
      );
      continue;
    }
    const result = await call(tool.name, args[tool.name]);
    assert.doesNotMatch(JSON.stringify(result), /CANARY_/, tool.name);
  }
  const c = await mysql.createConnection({
    host: config.host,
    port: config.port,
    user: config.user,
    password: config.password,
    database: config.database,
  });
  try {
    await assert.rejects(
      () => c.query("UPDATE tblclients SET id=id WHERE 1=0"),
      (e: any) => e.code === "ER_TABLEACCESS_DENIED_ERROR",
    );
  } finally {
    await c.end();
  }
});
test("sensitive columns cannot be read, filtered, grouped, joined or used in scalar subqueries", async () => {
  for (const sql of [
    "SELECT password FROM tblclients",
    "SELECT id FROM tblclients WHERE password LIKE 'CANARY%'",
    "SELECT COUNT(*) FROM tblclients GROUP BY password",
    "SELECT (SELECT password FROM tblusers LIMIT 1) AS hidden",
    "SELECT c.id FROM tblclients c JOIN tblusers u ON c.password=u.password",
    "SELECT security_question_answer FROM tblusers",
    "WITH a AS (SELECT password FROM tblclients) SELECT * FROM a",
    "SELECT username FROM tblhosting",
  ])
    await assert.rejects(
      () => db.read(sql),
      (e: any) => publicError(e).error === "COLUMN_UNAVAILABLE",
      sql,
    );
  const configs = await db.read("SELECT * FROM tblconfiguration");
  assert.equal(configs.rows.length, 2);
  assert.doesNotMatch(JSON.stringify(configs), /CANARY/);
  const fields = await db.read("SELECT * FROM tblcustomfieldsvalues");
  assert.equal(fields.rows.length, 1);
  assert.equal(fields.rows[0].value, "Synthetic label");
  assert.equal(
    Number(
      (
        await db.read(
          "SELECT COUNT(*) AS n FROM tblcustomfieldsvalues WHERE value LIKE 'CANARY%'",
        )
      ).rows[0].n,
    ),
    0,
  );
  assert.equal(
    Number(
      (
        await db.read(
          "SELECT COUNT(*) AS n FROM tblpaymentgateways WHERE value LIKE 'CANARY%'",
        )
      ).rows[0].n,
    ),
    0,
  );
});
test("invoice balances subtract credit and net payments without multiplying multiple line items and transactions", async () => {
  const result = await call("get_overdue_invoices", { asOf: "2026-01-01" });
  assert.deepEqual(
    result.rows.map((r: any) => [
      Number(r.id),
      r.outstanding === null ? null : Number(r.outstanding),
    ]),
    [
      [1, 45],
      [3, 175],
      [6, null],
    ],
  );
  assert.equal(Number(result.rows[2].paymentCurrencyMismatch), 1);
  const invoice = await call("get_invoice", { invoiceId: 1 });
  assert.equal(invoice.items.rows.length, 2);
  assert.equal(invoice.payments.rows.length, 3);
  const s = await call("get_stats");
  assert.equal(
    Number(
      s.serviceMrr.rows.find((r: any) => Number(r.currencyId) === 1).serviceMrr,
    ),
    10,
  );
  assert.equal(
    Number(
      s.serviceMrr.rows.find((r: any) => Number(r.currencyId) === 2).serviceMrr,
    ),
    20,
  );
  assert.equal(Number(s.addonMrr.rows[0].addonMrr), 2);
  const receivables = s.receivables.rows.find(
    (r: any) => Number(r.currencyId) === 1,
  );
  assert.equal(Number(receivables.outstanding), 95);
  assert.equal(Number(receivables.overdue), 45);
  assert.equal(Number(receivables.unresolvedCurrencyBalances), 1);
});
test("cash reporting keeps currencies separate and reports refunds and fees independently", async () => {
  const r = await call("revenue_report", {
    dateFrom: "2020-01-01",
    dateTo: "2020-01-31",
  });
  const gbp = r.cash.rows.find((r: any) => Number(r.currencyId) === 1);
  assert.equal(Number(gbp.receipts), 150);
  assert.equal(Number(gbp.refundsAndOutgoings), 5);
  assert.equal(Number(gbp.gatewayFees), 3);
  assert.equal(Number(gbp.netReceipts), 145);
  assert.equal(Number(gbp.netAfterFees), 142);
  assert.equal(r.cash.rows.length, 2);
});
test("row limits, pagination, byte limits, source text bounds and string escaping are real MySQL behavior", async () => {
  const first = await call("list_invoices", { limit: 2 });
  assert.equal(first.rows.length, 2);
  assert.equal(first.truncated, true);
  assert.ok(first.truncationReasons.includes("row_limit"));
  const next = await call("list_invoices", { limit: 2, offset: 2 });
  assert.deepEqual(
    next.rows.map((r: any) => Number(r.id)),
    [3, 4],
  );
  const raw = await db.read(
    "SELECT id FROM tblinvoices UNION ALL SELECT id FROM tblinvoices LIMIT 99999",
    2,
  );
  assert.equal(raw.rows.length, 2);
  assert.equal(raw.truncated, true);
  for (const value of [
    "O'Reilly",
    "' UNION SELECT password FROM tblclients -- ",
    "x\\';DROP TABLE tblclients;--",
    "a\u0000b",
  ]) {
    const r = await db.read(`SELECT ${mysql.escape(value)} AS value`);
    assert.equal(r.rows[0].value, value);
  }
  const small = new Database({ ...config, maxBytes: 1024, maxCellChars: 256 });
  try {
    await small.initialize();
    const r = await small.read("SELECT LPAD('x',5000,'x') AS text");
    assert.equal(String(r.rows[0].text).length, 256);
    assert.equal(r.truncated, true);
    const boundedRows = await small.read(
      "SELECT LPAD('x',250,'x') AS text FROM tblinvoices",
    );
    assert.ok(boundedRows.rowCount < 6);
    assert.ok(boundedRows.truncationReasons.includes("response_bytes"));
    assert.equal((await small.read("SELECT 1 AS ok")).rows[0].ok, 1);
  } finally {
    await small.close();
  }
});
test("application rejects mutations even when configured with broad development-style credentials", async () => {
  const root = new Database({
    ...config,
    user: "root",
    password: "fixture-only",
  });
  try {
    await root.initialize();
    for (const sql of [
      "UPDATE tblclients SET firstname='changed'",
      "DELETE FROM tblclients",
      "SELECT 1 INTO OUTFILE '/tmp/whmcs-test'",
      "SELECT whmcs_fixture.ABS(1)",
    ])
      await assert.rejects(() => root.read(sql));
    assert.equal(
      (await root.read("SELECT firstname FROM tblclients WHERE id=1")).rows[0]
        .firstname,
      "Synthetic",
    );
  } finally {
    await root.close();
  }
});
test("schema omissions report unavailable features and schema discovery never invents missing tables", async () => {
  const table = db.schema.get("tbltickets")!;
  db.schema.delete("tbltickets");
  try {
    await assert.rejects(
      () => call("list_tickets"),
      (e: any) => e.code === "FEATURE_UNAVAILABLE",
    );
    const caps = await call("get_capabilities");
    assert.equal(
      caps.tools.find((t: any) => t.name === "list_tickets").available,
      false,
    );
  } finally {
    db.schema.set("tbltickets", table);
  }
});
test("expensive allowed SELECT is terminated by MySQL execution deadline and the pool remains usable", async () => {
  const bounded = new Database({ ...config, timeoutMs: 100 });
  try {
    await bounded.initialize();
    const from = Array.from({ length: 26 }, (_, i) => `tblclients a${i}`).join(
      " CROSS JOIN ",
    );
    const sum = Array.from({ length: 26 }, (_, i) => `a${i}.id`).join("+");
    await assert.rejects(
      () => bounded.read(`SELECT SUM(${sum}) AS total FROM ${from}`),
      (e: any) => publicError(e).error === "QUERY_TIMEOUT",
    );
    assert.equal((await bounded.read("SELECT 1 AS ok")).rows[0].ok, 1);
  } finally {
    await bounded.close();
  }
});
