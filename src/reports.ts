import { Database, literal } from "./database.js";
import { AccessError } from "./errors.js";

export const MRR_SQL = `SELECT c.currency AS currencyId, SUM(h.amount / CASE h.billingcycle
  WHEN 'Monthly' THEN 1 WHEN 'Quarterly' THEN 3 WHEN 'Semi-Annually' THEN 6
  WHEN 'Annually' THEN 12 WHEN 'Biennially' THEN 24 WHEN 'Triennially' THEN 36 END) AS serviceMrr
  FROM tblhosting h JOIN tblclients c ON c.id=h.userid
  WHERE h.domainstatus='Active' AND h.billingcycle IN ('Monthly','Quarterly','Semi-Annually','Annually','Biennially','Triennially')
  GROUP BY c.currency`;
export const ADDON_MRR_SQL = `SELECT c.currency AS currencyId, SUM(a.recurring / CASE a.billingcycle
  WHEN 'Monthly' THEN 1 WHEN 'Quarterly' THEN 3 WHEN 'Semi-Annually' THEN 6
  WHEN 'Annually' THEN 12 WHEN 'Biennially' THEN 24 WHEN 'Triennially' THEN 36 END) AS addonMrr
  FROM tblhostingaddons a JOIN tblclients c ON c.id=a.userid
  WHERE a.status='Active' AND a.billingcycle IN ('Monthly','Quarterly','Semi-Annually','Annually','Biennially','Triennially')
  GROUP BY c.currency`;
// Payment transactions are preaggregated to avoid multiplying invoice totals by item/payment joins.
export const INVOICE_BALANCES_SQL = `SELECT i.id, i.userid AS clientId, c.currency AS currencyId,
  i.date, i.duedate, i.status, i.total, i.credit,
  CASE WHEN COALESCE(p.minCurrency<>c.currency OR p.maxCurrency<>c.currency,0) THEN NULL ELSE COALESCE(p.netPayments,0) END AS netPayments,
  COALESCE(p.minCurrency<>c.currency OR p.maxCurrency<>c.currency,0) AS paymentCurrencyMismatch,
  CASE WHEN COALESCE(p.minCurrency<>c.currency OR p.maxCurrency<>c.currency,0) THEN NULL ELSE GREATEST(0,i.total-i.credit-COALESCE(p.netPayments,0)) END AS outstanding
  FROM tblinvoices i JOIN tblclients c ON c.id=i.userid
  LEFT JOIN (SELECT invoiceid, SUM(amountin-amountout) AS netPayments, MIN(NULLIF(currency,0)) AS minCurrency, MAX(NULLIF(currency,0)) AS maxCurrency FROM tblaccounts GROUP BY invoiceid) p ON p.invoiceid=i.id`;

export function today(timezone: string): string {
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone: timezone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(new Date());
  return ["year", "month", "day"]
    .map((k) => parts.find((p) => p.type === k)!.value)
    .join("-");
}
export async function stats(db: Database) {
  const day = today(db.config.reportTimezone);
  return {
    clients: await db.read(
      "SELECT status, COUNT(*) AS count FROM tblclients GROUP BY status",
    ),
    services: await db.read(
      "SELECT domainstatus AS status, COUNT(*) AS count FROM tblhosting GROUP BY domainstatus",
    ),
    invoices: await db.read(
      `SELECT c.currency AS currencyId,i.status,COUNT(*) AS count,SUM(i.total) AS invoiceTotal FROM tblinvoices i JOIN tblclients c ON c.id=i.userid GROUP BY c.currency,i.status`,
    ),
    receivables: await db.read(
      `SELECT currencyId,SUM(outstanding) AS outstanding, SUM(CASE WHEN duedate > '0000-00-00' AND duedate < ${literal(day)} THEN outstanding ELSE 0 END) AS overdue, SUM(paymentCurrencyMismatch) AS unresolvedCurrencyBalances FROM (${INVOICE_BALANCES_SQL}) b WHERE status IN ('Unpaid','Payment Pending','Collections') GROUP BY currencyId`,
    ),
    serviceMrr: await db.read(MRR_SQL),
    addonMrr: await db.read(ADDON_MRR_SQL),
    definitions:
      "Currencies are never combined. MRR uses Active recurring service/addon amounts normalized by billing cycle, excluding domains and one-off charges; no tax adjustment is made to stored recurring amounts. Invoice totals are not cash received or recognized revenue. Outstanding=max(0,total-credit-net invoice payments); cancelled/refunded/draft invoices excluded from receivables. Mismatched nonzero payment currencies produce NULL balances and a separate unresolvedCurrencyBalances count, not a conversion. Current client currency is used for invoices/services; historical currency changes cannot be reconstructed reliably.",
  };
}
export async function revenueReport(db: Database, from?: string, to?: string) {
  const end = to ?? today(db.config.reportTimezone);
  const start = from ?? end.slice(0, 8) + "01";
  if (start > end)
    throw new AccessError("dateFrom must be on or before dateTo.");
  const condition = `a.date >= ${literal(start)} AND a.date < DATE_ADD(${literal(end)}, INTERVAL 1 DAY)`;
  return {
    dateFrom: start,
    dateTo: end,
    timezone: db.config.reportTimezone,
    cash: await db.read(`SELECT COALESCE(NULLIF(a.currency,0),c.currency) AS currencyId,
      SUM(a.amountin) AS receipts,SUM(a.amountout) AS refundsAndOutgoings,SUM(a.fees) AS gatewayFees,
      SUM(a.amountin-a.amountout) AS netReceipts, SUM(a.amountin-a.amountout-a.fees) AS netAfterFees
      FROM tblaccounts a LEFT JOIN tblclients c ON c.id=a.userid WHERE ${condition}
      GROUP BY COALESCE(NULLIF(a.currency,0),c.currency)`),
    invoices:
      await db.read(`SELECT c.currency AS currencyId,i.status,SUM(i.subtotal) AS subtotal,SUM(i.tax+i.tax2) AS taxes,SUM(i.total) AS total,COUNT(*) AS count
      FROM tblinvoices i JOIN tblclients c ON c.id=i.userid WHERE i.date >= ${literal(start)} AND i.date <= ${literal(end)} GROUP BY c.currency,i.status`),
    serviceMrr: await db.read(MRR_SQL),
    addonMrr: await db.read(ADDON_MRR_SQL),
    definitions:
      "Date filters use stored WHMCS date/datetime values as wall-clock dates; UTC session rendering is used for TIMESTAMP columns. MRR is current and is not filtered by historical report dates. Transaction currency=nonzero tblaccounts.currency, otherwise current client currency; unknown currency remains NULL. Outgoings may include more than refunds. No currency conversion or historical FX reconstruction.",
  };
}
