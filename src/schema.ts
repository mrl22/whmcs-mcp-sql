import policy from "./field-policy.json" with { type: "json" };
import { AccessError } from "./errors.js";

export const FIELD_POLICY: Readonly<Record<string, readonly string[]>> = policy;
export interface Column {
  name: string;
  type: string;
}
export interface Table {
  name: string;
  engine: string;
  columns: Column[];
}
export type Schema = Map<string, Table>;
export const quoteId = (s: string) => "`" + s.replaceAll("`", "``") + "`";

export function tableProjection(table: Table, maxChars: number): string {
  const fields = table.columns.map(
    (c) =>
      `${/char|text|json|enum|set/i.test(c.type) ? `LEFT(${quoteId(c.name)}, ${maxChars})` : quoteId(c.name)} AS ${quoteId(c.name)}`,
  );
  let where = "";
  if (table.name === "tblconfiguration")
    where =
      " WHERE setting IN ('Version','CompanyName','SystemURL','DateFormat','DefaultCountry','Timezone','TaxEnabled','TaxType','TaxL2Compound','TaxInclusiveDeduct')";
  if (table.name === "tblpaymentgateways")
    where = " WHERE setting IN ('name','type','visible')";
  if (table.name === "tblcustomfieldsvalues")
    where =
      " WHERE fieldid IN (SELECT id FROM tblcustomfields WHERE LOWER(fieldtype) <> 'password' AND LOWER(fieldname) NOT REGEXP 'pass(word|phrase)?|secret|token|api.?key|private|credential|auth|licen[sc]e.?key')";
  if (table.name === "tblcustomfields")
    where =
      " WHERE LOWER(fieldtype) <> 'password' AND LOWER(fieldname) NOT REGEXP 'pass(word|phrase)?|secret|token|api.?key|private|credential|auth|licen[sc]e.?key'";
  return `SELECT ${fields.join(", ")} FROM ${quoteId(table.name)}${where}`;
}
export function requireTable(schema: Schema, name: string): Table {
  const t = schema.get(name);
  if (!t)
    throw new AccessError(
      `Required table ${name} is absent, inaccessible, or excluded. This is not an empty result.`,
      "FEATURE_UNAVAILABLE",
    );
  return t;
}
