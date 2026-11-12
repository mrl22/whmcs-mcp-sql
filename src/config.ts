import { readFileSync } from "node:fs";

export interface Config {
  host: string;
  port: number;
  user: string;
  password: string;
  database: string;
  sslCa?: string;
  ssl: boolean;
  transport: "http" | "stdio";
  httpHost: string;
  httpPort: number;
  maxRows: number;
  timeoutMs: number;
  maxBytes: number;
  maxCellChars: number;
  poolSize: number;
  reportTimezone: string;
  allowedHosts: string[];
  allowedOrigins: string[];
}
function input(
  env: NodeJS.ProcessEnv,
  name: string,
  fallback?: string,
): string {
  if (env[`${name}_FILE`])
    return readFileSync(env[`${name}_FILE`]!, "utf8").replace(/\r?\n$/, "");
  const value = env[name] ?? fallback;
  if (value === undefined || (value === "" && name !== "MYSQL_PASSWORD"))
    throw new Error(`${name} is required`);
  return value;
}
function integer(
  env: NodeJS.ProcessEnv,
  name: string,
  fallback: number,
  min: number,
  max: number,
): number {
  const n = Number(env[name] ?? fallback);
  if (!Number.isInteger(n) || n < min || n > max)
    throw new Error(`${name} must be an integer from ${min} to ${max}`);
  return n;
}
export function loadConfig(env = process.env): Config {
  const transport = env.MCP_TRANSPORT ?? "http";
  if (transport !== "http" && transport !== "stdio")
    throw new Error("MCP_TRANSPORT must be http or stdio");
  const reportTimezone = env.REPORT_TIMEZONE ?? "Europe/London";
  new Intl.DateTimeFormat("en-GB", { timeZone: reportTimezone }).format();
  return {
    host: input(env, "MYSQL_HOST", "127.0.0.1"),
    port: integer(env, "MYSQL_PORT", 3306, 1, 65535),
    user: input(env, "MYSQL_USER"),
    password: input(env, "MYSQL_PASSWORD", ""),
    database: input(env, "MYSQL_DATABASE"),
    ssl: env.MYSQL_SSL === "true",
    sslCa: env.MYSQL_SSL_CA_FILE
      ? readFileSync(env.MYSQL_SSL_CA_FILE, "utf8")
      : undefined,
    transport,
    httpHost: env.MCP_HTTP_HOST ?? "127.0.0.1",
    httpPort: integer(env, "MCP_HTTP_PORT", 3100, 1, 65535),
    maxRows: integer(env, "MCP_MAX_ROWS", 500, 1, 5000),
    timeoutMs: integer(env, "MCP_QUERY_TIMEOUT_MS", 15000, 100, 60000),
    maxBytes: integer(env, "MCP_MAX_RESPONSE_BYTES", 1048576, 1024, 10485760),
    maxCellChars: integer(env, "MCP_MAX_CELL_CHARS", 8192, 256, 65536),
    poolSize: integer(env, "MYSQL_POOL_SIZE", 5, 1, 20),
    reportTimezone,
    allowedHosts: (env.MCP_ALLOWED_HOSTS ?? "localhost,127.0.0.1,[::1]")
      .split(",")
      .map((s) => s.trim())
      .filter(Boolean),
    allowedOrigins: (env.MCP_ALLOWED_ORIGINS ?? "")
      .split(",")
      .map((s) => s.trim())
      .filter(Boolean),
  };
}
