import { test } from "node:test";
import assert from "node:assert/strict";
import { mkdtempSync, writeFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { loadConfig } from "../src/config.js";
import { FIELD_POLICY } from "../src/schema.js";
import { buildTools } from "../src/tools.js";
import { RESOURCES, PROMPTS } from "../src/server.js";

test("config validates limits, requires credentials, supports blank test password and Docker secrets", () => {
  assert.throws(() => loadConfig({}), /MYSQL_USER/);
  const env = {
    MYSQL_USER: "reader",
    MYSQL_DATABASE: "billing",
    MYSQL_PASSWORD: "",
  };
  assert.equal(loadConfig(env).password, "");
  assert.throws(() => loadConfig({ ...env, MCP_MAX_ROWS: "0" }));
  assert.throws(() => loadConfig({ ...env, MCP_QUERY_TIMEOUT_MS: "999999" }));
  const dir = mkdtempSync(join(tmpdir(), "whmcs-config-"));
  try {
    const path = join(dir, "secret");
    writeFileSync(path, "example-password\n");
    assert.equal(
      loadConfig({ ...env, MYSQL_PASSWORD_FILE: path }).password,
      "example-password",
    );
  } finally {
    rmSync(dir, { recursive: true });
  }
});
test("policy excludes credential columns and opaque stores by default", () => {
  for (const table of [
    "tblsessions",
    "tblapilog",
    "tblgatewaylog",
    "tblmodulelog",
    "tbljobs_queue",
    "tblrsakeypairs",
    "tbldeviceauth",
  ])
    assert.equal(FIELD_POLICY[table], undefined);
  for (const [table, columns] of Object.entries(FIELD_POLICY))
    for (const col of columns)
      assert.doesNotMatch(
        col,
        /password|secret|token|session|security.?question.?answer|accesshash|cardnum|bankacct|authdata|configoption\d+/i,
        `${table}.${col}`,
      );
  assert.deepEqual(FIELD_POLICY.tblregistrars, ["registrar"]);
});
test("read-only tools and all 24 resource URIs exist without any mutation tools", () => {
  const tools = buildTools({} as any);
  const names = tools.map((t) => t.name);
  assert.equal(new Set(names).size, names.length);
  for (const name of names)
    assert.doesNotMatch(
      name,
      /^(add_|create_|update_|delete_|send_|apply_|module_|accept_|cancel_|register_|renew_|transfer_|activate_|start_|end_|log_)/,
    );
  for (const name of [
    "get_invoice",
    "get_ticket",
    "list_clients",
    "get_client_details",
    "query_database",
    "describe_schema",
    "get_capabilities",
    "revenue_report",
  ])
    assert.ok(names.includes(name));
  assert.equal(Object.keys(RESOURCES).length, 24);
  for (const name of Object.values(RESOURCES)) assert.ok(names.includes(name));
  assert.ok(Object.keys(PROMPTS).length >= 10);
});
