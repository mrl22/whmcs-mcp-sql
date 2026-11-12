import express from "express";
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamableHttp.js";
import { Database } from "./database.js";
import { createServer } from "./server.js";
import { publicError } from "./errors.js";

export function createApp(db: Database) {
  const app = express();
  app.disable("x-powered-by");
  app.use((req, res, next) => {
    const host = req.hostname.toLowerCase();
    if (
      !db.config.allowedHosts.includes("*") &&
      !db.config.allowedHosts.includes(host)
    ) {
      res.status(403).json({ error: "HOST_NOT_ALLOWED" });
      return;
    }
    const origin = req.headers.origin;
    if (origin && !db.config.allowedOrigins.includes(origin)) {
      res.status(403).json({ error: "ORIGIN_NOT_ALLOWED" });
      return;
    }
    if (origin) {
      res.setHeader("Access-Control-Allow-Origin", origin);
      res.setHeader("Vary", "Origin");
      res.setHeader(
        "Access-Control-Allow-Headers",
        "Content-Type,Accept,MCP-Protocol-Version,Mcp-Session-Id",
      );
      res.setHeader("Access-Control-Expose-Headers", "Mcp-Session-Id");
      res.setHeader("Access-Control-Allow-Methods", "GET,POST,DELETE,OPTIONS");
    }
    res.setHeader("X-Content-Type-Options", "nosniff");
    res.setHeader("Cache-Control", "no-store");
    if (req.method === "OPTIONS") {
      res.sendStatus(204);
      return;
    }
    next();
  });
  app.use(express.json({ limit: "128kb" }));
  app.get("/health", (_req, res) =>
    res.json({
      status: "ok",
      server: "whmcs-mcp-sql",
      readOnly: true,
      authentication: "none",
    }),
  );
  app.get("/ready", async (_req, res) => {
    try {
      await db.read("SELECT 1 AS ok", 1);
      res.json({ status: "ready" });
    } catch (error) {
      res.status(503).json(publicError(error));
    }
  });
  let active = 0;
  app.post("/mcp", async (req, res) => {
    if (active >= 20) {
      res.status(429).json({ error: "SERVER_BUSY" });
      return;
    }
    active++;
    const server = createServer(db);
    const transport = new StreamableHTTPServerTransport({
      sessionIdGenerator: undefined,
      enableJsonResponse: true,
    });
    let closed = false;
    const cleanup = () => {
      if (closed) return;
      closed = true;
      active--;
      void transport.close();
      void server.close();
    };
    res.on("close", cleanup);
    try {
      await server.connect(transport);
      await transport.handleRequest(req, res, req.body);
    } catch {
      if (!res.headersSent)
        res.status(500).json({
          jsonrpc: "2.0",
          id: null,
          error: { code: -32603, message: "MCP request failed" },
        });
      cleanup();
    }
  });
  app.all("/mcp", (_req, res) =>
    res.status(405).setHeader("Allow", "POST, OPTIONS").end(),
  );
  app.use(
    (
      error: unknown,
      _req: express.Request,
      res: express.Response,
      _next: express.NextFunction,
    ) => {
      res
        .status((error as { status?: number }).status ?? 400)
        .json({ error: "INVALID_REQUEST" });
    },
  );
  return app;
}
