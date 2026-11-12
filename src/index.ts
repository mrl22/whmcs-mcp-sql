#!/usr/bin/env node
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { loadConfig } from "./config.js";
import { Database } from "./database.js";
import { createServer } from "./server.js";
import { createApp } from "./http.js";
import { publicError } from "./errors.js";

async function main() {
  let config;
  try {
    config = loadConfig();
  } catch (error) {
    process.stderr.write(
      JSON.stringify({
        error: "CONFIGURATION_ERROR",
        message: (error as Error).message,
      }) + "\n",
    );
    process.exitCode = 1;
    return;
  }
  const db = new Database(config);
  await db.initialize();
  if (config.transport === "stdio") {
    const server = createServer(db);
    await server.connect(new StdioServerTransport());
    const stop = async () => {
      await server.close();
      await db.close();
      process.exit(0);
    };
    process.once("SIGINT", () => void stop());
    process.once("SIGTERM", () => void stop());
    process.stdin.once("end", () => void stop());
  } else {
    const listener = createApp(db).listen(
      config.httpPort,
      config.httpHost,
      () =>
        process.stderr.write(
          JSON.stringify({
            event: "listening",
            host: config.httpHost,
            port: config.httpPort,
            authentication: "none",
            readOnly: true,
          }) + "\n",
        ),
    );
    listener.on("error", () => {
      process.stderr.write(
        JSON.stringify({
          error: "LISTEN_FAILED",
          message: "Cannot bind the configured MCP HTTP address/port.",
        }) + "\n",
      );
      void db.close().then(() => {
        process.exitCode = 1;
      });
    });
    const stop = () => {
      listener.close(() => {
        void db.close().then(() => process.exit(0));
      });
      setTimeout(() => process.exit(0), 5000).unref();
    };
    process.once("SIGINT", stop);
    process.once("SIGTERM", stop);
  }
}
main().catch((error) => {
  process.stderr.write(JSON.stringify(publicError(error)) + "\n");
  process.exit(1);
});
