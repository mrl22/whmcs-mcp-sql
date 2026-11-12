import assert from "node:assert/strict";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StreamableHTTPClientTransport } from "@modelcontextprotocol/sdk/client/streamableHttp.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";

const client = new Client({ name: "whmcs-smoke", version: "1.0.0" });
let transport;
if (process.env.SMOKE_STDIO === "docker") {
  transport = new StdioClientTransport({
    command: "docker",
    args: [
      "run",
      "--rm",
      "-i",
      "--no-healthcheck",
      "--read-only",
      "--cap-drop=ALL",
      "--security-opt=no-new-privileges",
      "--add-host=host.docker.internal:host-gateway",
      "--env-file",
      process.env.SMOKE_ENV_FILE ?? ".env",
      "-e",
      "MCP_TRANSPORT=stdio",
      "whmcs-mcp-sql:local",
    ],
    stderr: "pipe",
  });
} else
  transport = new StreamableHTTPClientTransport(
    new URL(process.env.MCP_URL ?? "http://127.0.0.1:3100/mcp"),
  );
const expectedUnavailable = new Set([
  "get_domain_whois",
  "get_domain_nameservers",
  "get_domain_lock_status",
  "list_projects",
  "get_project",
]);
const args: Record<string, unknown> = {
  get_client: { clientId: 2147483647 },
  get_client_details: { clientId: 2147483647 },
  get_invoice: { invoiceId: 2147483647 },
  get_ticket: { ticketId: 2147483647 },
  get_project: { projectId: 1 },
  get_quote: { quoteId: 2147483647 },
  query_database: { sql: "SELECT COUNT(*) AS count FROM tblclients" },
};
try {
  await client.connect(transport);
  const tools = await client.listTools();
  assert.equal(tools.tools.length, 57);
  let available = 0,
    unavailable = 0;
  for (const tool of tools.tools) {
    const result = await client.callTool({
      name: tool.name,
      arguments: (args[tool.name] as any) ?? {},
    });
    if (expectedUnavailable.has(tool.name)) {
      assert.equal(result.isError, true, tool.name);
      unavailable++;
    } else {
      assert.notEqual(
        result.isError,
        true,
        tool.name + ": " + JSON.stringify(result),
      );
      available++;
    }
  }
  const resources = await client.listResources();
  assert.equal(resources.resources.length, 24);
  for (const resource of resources.resources) {
    const r = await client.readResource({ uri: resource.uri });
    assert.equal(
      JSON.parse((r.contents[0] as { text: string }).text).error,
      undefined,
      resource.uri,
    );
  }
  const prompts = await client.listPrompts();
  for (const prompt of prompts.prompts) {
    assert.ok((await client.getPrompt({ name: prompt.name })).messages.length);
  }
  for (const sql of [
    "UPDATE tblclients SET id=id",
    "SELECT password FROM tblclients",
    "SELECT * FROM tblconfiguration WHERE setting='SMTPPassword' AND value LIKE '%'",
    "SELECT SLEEP(1)",
  ]) {
    const r = await client.callTool({
      name: "query_database",
      arguments: { sql },
    });
    if (sql.includes("SMTPPassword"))
      assert.equal((r.structuredContent as any).result.rowCount, 0);
    else assert.equal(r.isError, true);
  }
  console.log(
    JSON.stringify({
      transport: process.env.SMOKE_STDIO === "docker" ? "docker-stdio" : "http",
      tools: tools.tools.length,
      available,
      explicitlyUnavailable: unavailable,
      resources: resources.resources.length,
      prompts: prompts.prompts.length,
      result: "passed",
    }),
  );
} finally {
  await client.close();
}
