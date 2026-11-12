import mysql, { type Pool as CorePool, type PoolConnection } from "mysql2";
import type { Pool, RowDataPacket } from "mysql2/promise";
import type { Config } from "./config.js";
import { FIELD_POLICY, type Schema } from "./schema.js";
import { compileRead } from "./sql.js";
import { AccessError } from "./errors.js";

export interface ReadResult {
  rows: Record<string, unknown>[];
  rowCount: number;
  truncated: boolean;
  truncationReasons: string[];
  tables: string[];
  observedAt: string;
  consistency: string;
}
export class Database {
  private pool: Pool;
  private corePool: CorePool;
  schema: Schema = new Map();
  mysqlVersion = "";
  constructor(public readonly config: Config) {
    this.corePool = mysql.createPool({
      host: config.host,
      port: config.port,
      user: config.user,
      password: config.password,
      database: config.database,
      connectionLimit: config.poolSize,
      waitForConnections: true,
      queueLimit: 50,
      connectTimeout: 5000,
      multipleStatements: false,
      enableKeepAlive: true,
      dateStrings: true,
      supportBigNumbers: true,
      bigNumberStrings: true,
      decimalNumbers: false,
      timezone: "Z",
      ssl:
        config.ssl || config.sslCa
          ? {
              rejectUnauthorized: true,
              ...(config.sslCa ? { ca: config.sslCa } : {}),
            }
          : undefined,
    });
    this.pool = this.corePool.promise();
  }
  async initialize(): Promise<void> {
    const connection = await this.pool.getConnection();
    try {
      const [v] = await connection.query<RowDataPacket[]>(
        "SELECT VERSION() AS version",
      );
      this.mysqlVersion = String(v[0].version);
      if (!/^8\./.test(this.mysqlVersion) || /MariaDB/i.test(this.mysqlVersion))
        throw new AccessError(
          "This release requires MySQL 8.x. MariaDB and other versions have not been validated.",
          "UNSUPPORTED_DATABASE",
        );
      const [rows] = await connection.execute<RowDataPacket[]>(
        "SELECT c.TABLE_NAME, c.COLUMN_NAME, c.DATA_TYPE, t.ENGINE FROM information_schema.COLUMNS c JOIN information_schema.TABLES t ON c.TABLE_SCHEMA=t.TABLE_SCHEMA AND c.TABLE_NAME=t.TABLE_NAME WHERE c.TABLE_SCHEMA=? ORDER BY c.TABLE_NAME,c.ORDINAL_POSITION",
        [this.config.database],
      );
      const schema: Schema = new Map();
      for (const r of rows) {
        const allowed = FIELD_POLICY[r.TABLE_NAME];
        if (!allowed?.includes(r.COLUMN_NAME)) continue;
        if (!schema.has(r.TABLE_NAME))
          schema.set(r.TABLE_NAME, {
            name: r.TABLE_NAME,
            engine: r.ENGINE,
            columns: [],
          });
        schema
          .get(r.TABLE_NAME)!
          .columns.push({ name: r.COLUMN_NAME, type: r.DATA_TYPE });
      }
      this.schema = schema;
      if (!schema.has("tblclients"))
        throw new AccessError(
          "tblclients is not accessible; verify the WHMCS database and SELECT privileges.",
          "SCHEMA_UNAVAILABLE",
        );
    } finally {
      connection.release();
    }
  }
  async read(sql: string, limit = this.config.maxRows): Promise<ReadResult> {
    const cap = Math.min(limit, this.config.maxRows);
    if (!Number.isInteger(cap) || cap < 1)
      throw new AccessError("Row limit must be a positive integer.");
    const compiled = compileRead(
      sql,
      this.schema,
      cap,
      this.config.maxCellChars,
    );
    const connection = await new Promise<PoolConnection>((resolve, reject) => {
      this.corePool.getConnection((error, value) =>
        error ? reject(error) : resolve(value),
      );
    });
    try {
      const session = connection.promise();
      await session.query(
        "SET SESSION sql_mode = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION'",
      );
      await session.query("SET SESSION TRANSACTION READ ONLY");
      await session.query(
        `SET SESSION max_execution_time = ${this.config.timeoutMs}`,
      );
      await session.query("SET SESSION time_zone = '+00:00'");
      const reasons = new Set<string>();
      const rows: Record<string, unknown>[] = [];
      let bytes = 256;
      // Consume row events rather than buffering an unbounded result before applying byte limits.
      await new Promise<void>((resolve, reject) => {
        let settled = false;
        let names: string[] = [];
        const finish = (error?: unknown, discardConnection = false) => {
          if (settled) return;
          settled = true;
          clearTimeout(timer);
          if (discardConnection) connection.destroy();
          if (error) reject(error);
          else resolve();
        };
        const timer = setTimeout(
          () =>
            finish(
              Object.assign(new Error("Deadline exceeded"), {
                code: "MCP_QUERY_TIMEOUT",
              }),
              true,
            ),
          this.config.timeoutMs + 1000,
        );
        const query = connection.query({
          sql: compiled.sql,
          rowsAsArray: true,
        });
        query.on("fields", (fields) => {
          // mysql2 emits an array here; its event declaration currently types one packet.
          if (!Array.isArray(fields)) {
            finish(new AccessError("Invalid database result metadata."), true);
            return;
          }
          names = fields.map((f) => f.name);
          if (new Set(names).size !== names.length)
            finish(
              new AccessError(
                "Use unique aliases for duplicate result columns.",
              ),
              true,
            );
        });
        query.on("result", (source: unknown[]) => {
          if (settled) return;
          if (rows.length >= cap) {
            reasons.add("row_limit");
            finish(undefined, true);
            return;
          }
          const row: Record<string, unknown> = Object.create(null);
          for (let index = 0; index < names.length; index++) {
            let value = source[index];
            if (Buffer.isBuffer(value)) value = "[binary excluded]";
            if (typeof value === "string") {
              if (value.length >= this.config.maxCellChars)
                reasons.add("cell_limit");
              value = value.slice(0, this.config.maxCellChars);
            }
            row[names[index]] = value;
          }
          const size = Buffer.byteLength(JSON.stringify(row));
          if (bytes + size > this.config.maxBytes) {
            reasons.add("response_bytes");
            finish(undefined, true);
            return;
          }
          bytes += size;
          rows.push(row);
        });
        query.on("error", (error) => finish(error, true));
        query.on("end", () => finish());
      });
      return {
        rows,
        rowCount: rows.length,
        truncated: reasons.size > 0,
        truncationReasons: [...reasons],
        tables: compiled.tables,
        observedAt: new Date().toISOString(),
        consistency:
          "Live reads; no atomic snapshot across MyISAM tables. Text columns are bounded at source; use narrow indexed filters.",
      };
    } finally {
      connection.release();
    }
  }
  async close() {
    await this.pool.end();
  }
}
export const literal = mysql.escape;
