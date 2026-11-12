export class AccessError extends Error {
  constructor(
    message: string,
    public code = "QUERY_REJECTED",
  ) {
    super(message);
  }
}
export function publicError(error: unknown): {
  error: string;
  message: string;
} {
  if (error instanceof AccessError)
    return { error: error.code, message: error.message };
  const code = (error as { code?: string })?.code;
  if (code === "ER_BAD_FIELD_ERROR")
    return {
      error: "COLUMN_UNAVAILABLE",
      message:
        "A column is unavailable or excluded by the field policy. Use describe_schema to inspect permitted columns.",
    };
  if (
    code === "ER_QUERY_TIMEOUT" ||
    code === "PROTOCOL_SEQUENCE_TIMEOUT" ||
    code === "MCP_QUERY_TIMEOUT"
  )
    return {
      error: "QUERY_TIMEOUT",
      message:
        "The read exceeded the configured execution timeout. Narrow the date range or filters.",
    };
  if (code === "ER_DUP_FIELDNAME")
    return {
      error: "DUPLICATE_COLUMNS",
      message: "Use unique aliases for duplicate result column names.",
    };
  if (code === "ER_NO_SUCH_TABLE")
    return {
      error: "SCHEMA_UNAVAILABLE",
      message:
        "A required table is unavailable. Refresh the schema or check database access.",
    };
  return {
    error: "DATABASE_ERROR",
    message:
      "The database read failed. Check connectivity, schema compatibility, and SELECT privileges. Credentials and SQL details are not returned.",
  };
}
