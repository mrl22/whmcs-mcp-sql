import { test, before, after } from "node:test";
import assert from "node:assert/strict";
import { once } from "node:events";
import type { AddressInfo } from "node:net";
import { request } from "node:http";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StreamableHTTPClientTransport } from "@modelcontextprotocol/sdk/client/streamableHttp.js";
import { InMemoryTransport } from "@modelcontextprotocol/sdk/inMemory.js";
import { loadConfig } from "../../src/config.js";
import { Database } from "../../src/database.js";
import { createServer, RESOURCES, PROMPTS } from "../../src/server.js";
import { createApp } from "../../src/http.js";

const db = new Database(
  loadConfig({
    MYSQL_HOST: "127.0.0.1",
    MYSQL_PORT: "13316",
    MYSQL_USER: "reader",
    MYSQL_PASSWORD: "fixture-reader",
    MYSQL_DATABASE: "whmcs_fixture",
  }),
);
before(() => db.initialize());
after(() => db.close());
test("MCP initializes, discovers tools, reads every resource and obtains every analytical prompt", async () => {
  const server = createServer(db);
  const client = new Client({ name: "integration-test", version: "1.0.0" });
  const [a, b] = InMemoryTransport.createLinkedPair();
  await server.connect(a);
  await client.connect(b);
  try {
    const tools = await client.listTools();
    assert.equal(tools.tools.length, 57);
    assert.ok(
      tools.tools.every(
        (t) =>
          t.annotations?.readOnlyHint === true &&
          t.annotations?.destructiveHint === false,
      ),
    );
    const result = await client.callTool({
      name: "get_client",
      arguments: { clientId: 1 },
    });
    assert.equal(result.isError, undefined);
    assert.doesNotMatch(JSON.stringify(result), /CANARY_/);
    const blocked = await client.callTool({
      name: "query_database",
      arguments: { sql: "DELETE FROM tblclients" },
    });
    assert.equal(blocked.isError, true);
    const invalid = await client.callTool({
      name: "get_invoice",
      arguments: { invoiceId: "1 OR 1=1" },
    });
    assert.equal(invalid.isError, true);
    const resources = await client.listResources();
    assert.equal(resources.resources.length, 24);
    for (const uri of Object.keys(RESOURCES)) {
      const r = await client.readResource({ uri });
      assert.doesNotMatch(JSON.stringify(r), /CANARY_/);
      const text = r.contents[0] as { text: string };
      const body = JSON.parse(text.text);
      assert.equal(body.error, undefined, uri);
    }
    const prompts = await client.listPrompts();
    assert.equal(prompts.prompts.length, Object.keys(PROMPTS).length);
    for (const name of Object.keys(PROMPTS)) {
      const p = await client.getPrompt({
        name,
        arguments: { context: "Client 1" },
      });
      assert.ok(p.messages.length > 0);
    }
  } finally {
    await client.close();
    await server.close();
  }
});
test("real HTTP MCP supports concurrent independent clients, readiness, and host/origin checks", async () => {
  const listener = createApp(db).listen(0, "127.0.0.1");
  await once(listener, "listening");
  const port = (listener.address() as AddressInfo).port;
  const base = `http://127.0.0.1:${port}`;
  try {
    assert.equal((await fetch(base + "/health")).status, 200);
    assert.equal((await fetch(base + "/ready")).status, 200);
    assert.equal((await fetch(base + "/mcp")).status, 405);
    assert.equal(
      (
        await fetch(base + "/mcp", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Origin: "https://unlisted.example",
          },
          body: "{}",
        })
      ).status,
      403,
    );
    const badHost = await new Promise<number | undefined>((resolve, reject) => {
      const r = request(
        base + "/health",
        { headers: { Host: "evil.example" } },
        (res) => {
          res.resume();
          resolve(res.statusCode);
        },
      );
      r.on("error", reject);
      r.end();
    });
    assert.equal(badHost, 403);
    await Promise.all(
      Array.from({ length: 3 }, async () => {
        const c = new Client({ name: "http-test", version: "1.0.0" });
        try {
          await c.connect(
            new StreamableHTTPClientTransport(new URL(base + "/mcp")),
          );
          const r = await c.callTool({
            name: "query_database",
            arguments: { sql: "SELECT COUNT(*) AS count FROM tblclients" },
          });
          assert.equal(r.isError, undefined);
          assert.match(JSON.stringify(r), /count/);
        } finally {
          await c.close();
        }
      }),
    );
  } finally {
    await new Promise<void>((resolve, reject) =>
      listener.close((error) => (error ? reject(error) : resolve())),
    );
  }
});
