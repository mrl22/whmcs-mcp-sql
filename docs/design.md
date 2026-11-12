# Architecture

WHMCS MCP SQL is a read-only MCP server for querying and analysing WHMCS data directly through MySQL. It runs in Docker and connects to one installation per container using environment settings or mounted Docker secrets. It requires no WHMCS API credentials, installed plugin, hook, or filesystem access.

## Query boundary

Named tools and the SQL analysis tool share one parser and execution layer. The layer accepts a restricted SELECT grammar, rewrites physical table access to approved field projections, and rejects mutation statements, cross-database access, variables, locking reads, file access, and unapproved functions. Dedicated SELECT-only database credentials provide an additional enforcement boundary.

A checked-in field policy determines exposed tables and columns. Schema detection intersects that policy with the accessible installation schema; new or unknown fields are denied by default. Configuration, gateway, and custom-field records have additional row restrictions. Passwords, authentication material, session contents, payment secrets, and infrastructure login credentials are excluded. Business free text remains readable and can contain embedded sensitive information.

## MCP interface

- 57 tool descriptors: 52 database read/analysis tools and five explicit capability limitations.
- 24 resources serving fresh, bounded snapshots.
- 12 analytical workflow prompts.
- Streamable HTTP for remote or local clients and stdio for process-launched clients.
- Configuration guides for Codex, Claude, and ChatGPT.

Live registrar state cannot be reconstructed from stored records. Project Management addon reads need a verified addon schema. Database health is distinguished from WHMCS application/runtime health. Unavailable features return explicit diagnostics rather than empty results.

## Deployment

The development interface is unauthenticated, with the same permitted read access for every caller. Compose publishes HTTP on localhost by default. Network routing, HTTPS proxies and supported tunnels control remote reachability. One container serves one WHMCS installation; deploy separate containers for additional installations.

The Node.js runtime runs as a non-root user, with a read-only filesystem and dropped capabilities in Compose. Credentials are deployment inputs. Query arguments, SQL text, results and customer records are not written to application logs. No WHMCS data is persisted by the package.

## Read semantics

Rows, execution time, response bytes and text lengths are bounded. Results include observation time and truncation diagnostics. Byte limits are enforced while consuming rows. MyISAM tables do not provide an atomic multi-table snapshot, so live reports can observe concurrent changes.

Financial outputs keep currencies separate and distinguish invoices, cash movements, receivables and current recurring revenue. Mismatched payment currencies produce unresolved balances. The README documents formulae, tax treatment, date conventions and historical limitations.

## Compatibility and verification

MySQL 8.x is supported, with WHMCS 9.0 schema checks and MySQL 8.3/8.4 validation. Compatibility is determined from detected tables and columns, not a version string alone. Restart after an import or schema change.

Tests use a checked-in representative schema and synthetic records in a disposable database, including a SELECT-only account. They cover query restrictions, field access, financial calculations, resource bounds and MCP transports. See [verification](verification.md), [coverage](read-only-coverage.md) and the [tool reference](tools.md).
