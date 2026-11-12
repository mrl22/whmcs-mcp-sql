# WHMCS MCP SQL

**Read and analyse WHMCS data from your AI client, using direct MySQL access.**

WHMCS MCP SQL connects Codex, Claude, ChatGPT and other MCP-compatible clients to your WHMCS database. Explore client accounts, investigate invoices, review support queues and build financial reports without installing anything in WHMCS.

- **52 read and analysis tools** covering billing, clients, services, support and administration.
- **24 MCP resources** for database-backed snapshots.
- **12 workflow prompts** for common analytical tasks.
- **Docker deployment**, configurable MySQL credentials and Docker secrets support.
- **Streamable HTTP and stdio** transports.
- **Read-only by design**, with restricted SQL and a shared field-access policy.

> “Which clients have overdue balances, and what active services do they have?”
>
> “Summarise the support queue by department and priority.”
>
> “Compare this month's receipts and refunds, keeping currencies separate.”

The development release has no MCP authentication or per-staff roles. Compose binds HTTP to localhost by default. Every caller who can reach the endpoint has the same permitted read access.

## Contents

- [Quick start](#quick-start)
- [Features](#features)
- [Configuration](#configuration)
- [Connect your AI client](#connect-your-ai-client)
- [SQL analysis](#sql-analysis)
- [Financial reports](#financial-reports)
- [Read-only access and data handling](#read-only-access-and-data-handling)
- [Development and testing](#development-and-testing)
- [Documentation](#documentation)

## Quick start

### Requirements

- Docker with Docker Compose.
- A reachable WHMCS database running **MySQL 8.x**.
- A database account with **SELECT-only privileges** on the required WHMCS tables.

Validation covers WHMCS 9.0 schema on MySQL 8.3 and synthetic integration tests on MySQL 8.4. MariaDB and other database versions are not currently supported. No WHMCS API credentials, plugins, hooks or filesystem access are required.

### Start the server

From the repository root:

```sh
cp .env.example .env
```

Edit `.env` with your database connection settings:

```dotenv
MYSQL_HOST=host.docker.internal
MYSQL_PORT=3306
MYSQL_DATABASE=whmcs_database
MYSQL_USER=whmcs_reader
MYSQL_PASSWORD=replace-with-your-database-password
```

Then build and start the container:

```sh
docker compose up -d --build --wait
```

The MCP endpoint is **`http://127.0.0.1:3100/mcp`**. Confirm database readiness:

```sh
curl http://127.0.0.1:3100/ready
```

A ready server returns `{"status":"ready"}`. Connect an AI client, then ask it to call `get_capabilities` and `describe_schema`.

### Manage the container

```sh
docker compose ps
docker compose logs --tail 30
docker compose down
```

Each container connects to one WHMCS installation. For multiple installations, use separate Compose project names, environment files and published ports.

## Features

### 52 read and analysis tools

All tools read stored data or compute analysis. Available tools depend on the accessible database schema. Use `get_capabilities` to inspect availability and the [tool reference](docs/tools.md) for input parameters.

| Category           | Tools                                                                                                                               | What you can inspect                                                                                         |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| **Clients**        | `get_client` `list_clients` `get_client_details` `get_client_groups` `get_clients_online` `get_client_notes`                        | Client profiles, contacts and user links, groups, staff notes and recent logins.                             |
| **Invoices**       | `get_invoice` `list_invoices` `get_overdue_invoices`                                                                                | Invoices, line items, recorded payments and overdue balances after credit and net payments.                  |
| **Transactions**   | `get_transactions`                                                                                                                  | Recorded receipts, outgoings, gateway fees and invoice associations.                                         |
| **Orders**         | `get_orders` `get_order_statuses`                                                                                                   | Stored orders and configured order statuses.                                                                 |
| **Services**       | `list_services` `get_client_addons` `get_cancelled_packages`                                                                        | Service instances, stored usage, addon subscriptions and cancellation requests.                              |
| **Tickets**        | `get_ticket` `list_tickets` `get_support_departments` `get_support_statuses` `get_ticket_counts` `get_ticket_predefined_categories` | Tickets, replies, private staff notes, departments, statuses, queue counts and reply categories.             |
| **Quotes**         | `get_quotes` `get_quote`                                                                                                            | Quotations, stages, totals and line items.                                                                   |
| **Contacts**       | `get_contacts`                                                                                                                      | Client billing and support contacts.                                                                         |
| **Credits**        | `get_credits`                                                                                                                       | Client credit ledger entries.                                                                                |
| **Billing**        | `get_billable_items` `get_payment_methods` `get_currencies`                                                                         | Scheduled billable items, public gateway settings and configured currencies.                                 |
| **Email**          | `get_client_emails` `get_email_templates`                                                                                           | Stored outbound email history and template definitions.                                                      |
| **Products**       | `get_products` `get_product_groups` `get_pricing`                                                                                   | Product catalog, group counts and stored product/addon/domain pricing.                                       |
| **Domains**        | `get_client_domains` `get_tld_pricing` `get_registrars`                                                                             | Stored domain records, expiry and due dates, TLD pricing and configured registrar identifiers.               |
| **Administration** | `get_admin_users` `get_staff_online` `get_activity_log`                                                                             | Staff identities, recent admin activity and the WHMCS activity log.                                          |
| **Affiliates**     | `get_affiliates`                                                                                                                    | Affiliate accounts, balances and commission settings.                                                        |
| **Promotions**     | `get_promotions`                                                                                                                    | Promotion definitions and stored usage counts.                                                               |
| **Servers**        | `get_servers`                                                                                                                       | Provisioning server metadata with login credentials excluded.                                                |
| **System**         | `get_health_status` `get_whmcs_details` `get_todo_items` `get_todo_item_statuses` `get_announcements`                               | Database health, persisted installation metadata, to-do items and announcements.                             |
| **Reporting**      | `get_stats` `revenue_report`                                                                                                        | Client/service counts, invoice totals, receivables, receipts, outgoings, fees and current recurring revenue. |
| **SQL analysis**   | `query_database` `describe_schema` `get_capabilities`                                                                               | Restricted SELECT/CTE queries, permitted tables/columns and per-tool availability.                           |

`get_clients_online` reports recent logins; `get_staff_online` reports recent admin activity. Neither proves that a session is currently connected. `get_health_status` checks the database, not the WHMCS PHP application or provisioning modules.

### Capability limitations

Five additional descriptors return `FEATURE_UNAVAILABLE`, bringing the total registered tool count to **57**. They are not included in the 52 usable tools above.

| Descriptor               | Limitation                                                                                                                                       |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| `get_domain_whois`       | Live WHOIS results require an external lookup; stored lookup history is not authoritative current data.                                          |
| `get_domain_nameservers` | Authoritative registrar nameservers are not available from the WHMCS domain table. Hosting nameserver fields do not establish domain delegation. |
| `get_domain_lock_status` | Current registrar locking state cannot be established from the database.                                                                         |
| `list_projects`          | Project Management addon reads require a separately verified addon schema and are not currently implemented.                                     |
| `get_project`            | Individual project reads have the same addon-schema limitation.                                                                                  |

Missing core tables also produce explicit unavailable-feature diagnostics rather than empty results. The server does not create or edit records, send messages, capture payments, provision hosting or change domains.

### 24 MCP resources

Resources expose fresh, read-only JSON snapshots through `whmcs://` URIs. Results are bounded; use the associated tools to filter and paginate. Resources do not provide push subscriptions.

| URI                                     | Data                                                                                       |
| --------------------------------------- | ------------------------------------------------------------------------------------------ |
| `whmcs://stats`                         | Client/service counts, invoice totals, receivables and current MRR, separated by currency. |
| `whmcs://health`                        | Database connectivity health.                                                              |
| `whmcs://system/info`                   | Permitted persisted installation settings and MySQL version.                               |
| `whmcs://products`                      | Product catalog.                                                                           |
| `whmcs://product-groups`                | Product groups and product counts.                                                         |
| `whmcs://tld-pricing`                   | Stored domain registration, transfer and renewal pricing rows.                             |
| `whmcs://promotions`                    | Promotion definitions and recorded use counts.                                             |
| `whmcs://order-statuses`                | Configured order statuses.                                                                 |
| `whmcs://currencies`                    | Currencies and stored exchange rates.                                                      |
| `whmcs://payment-methods`               | Gateway identifiers and public name/type/visibility settings.                              |
| `whmcs://registrars`                    | Configured registrar identifiers.                                                          |
| `whmcs://servers`                       | Provisioning server metadata without credentials.                                          |
| `whmcs://client-groups`                 | Client group definitions.                                                                  |
| `whmcs://affiliates`                    | Affiliate account records.                                                                 |
| `whmcs://email-templates`               | Stored email template definitions.                                                         |
| `whmcs://announcements`                 | Published announcements.                                                                   |
| `whmcs://support/departments`           | Support departments without mailbox credentials.                                           |
| `whmcs://support/statuses`              | Configured ticket statuses.                                                                |
| `whmcs://support/ticket-counts`         | Ticket counts by department, status and urgency.                                           |
| `whmcs://support/predefined-categories` | Predefined reply categories.                                                               |
| `whmcs://admin/users`                   | Staff accounts with authentication material excluded.                                      |
| `whmcs://admin/todo`                    | Admin to-do items.                                                                         |
| `whmcs://admin/todo-statuses`           | Distinct stored to-do statuses.                                                            |
| `whmcs://admin/staff-online`            | Recent admin activity.                                                                     |

### 12 analytical workflow prompts

Prompts guide the AI through an investigation or report. Each accepts an optional `context` argument for record IDs, a date range or an analytical focus. They do not execute changes or send communications.

| Prompt                       | Analysis                                                                                                 |
| ---------------------------- | -------------------------------------------------------------------------------------------------------- |
| `client_onboarding`          | Review an existing account's information, contacts, services, domains, billing and support history.      |
| `fraud_investigation`        | Examine order, client, service and payment evidence, with uncertainty stated explicitly.                 |
| `bulk_invoice_reminder`      | Identify overdue invoices and clients who may need follow-up; produces a list without sending reminders. |
| `revenue_report`             | Explain receipts, outgoings, fees, invoice totals, balances and current MRR by currency.                 |
| `client_health_check`        | Review a client's services, billing, domains and support, identifying evidence-backed concerns.          |
| `domain_expiry_audit`        | Inspect stored expiry dates, billing dates and Do Not Renew flags.                                       |
| `churn_risk_report`          | Identify cancellation, service, overdue-payment and support indicators using transparent criteria.       |
| `support_queue_triage`       | Review queue age, priority, department and status to suggest staff priorities.                           |
| `affiliate_performance`      | Examine affiliate balances, referrals and earned/pending/withdrawn commissions in permitted tables.      |
| `service_renewal_forecast`   | Estimate upcoming service/addon billing from active records, cycles and due dates.                       |
| `addon_upsell_opportunities` | Compare services and addon selections to identify potential gaps for staff review.                       |
| `promo_effectiveness`        | Examine promotion usage and associated orders/services without claiming unsupported causal effects.      |

### Deployment and operational features

- Direct MySQL access with configurable connection pooling and optional verified TLS.
- Environment-variable configuration and mounted Docker secret files.
- Stateless Streamable HTTP and process-launched stdio transports.
- MCP read-only tool annotations and structured results alongside JSON text.
- A shared SELECT parser and field-projection layer for named tools and custom analysis.
- Host allowlists, explicit browser-origin allowlists and bounded concurrent HTTP requests.
- Configurable row, execution-time, response-byte and text-cell limits.
- Streaming result consumption with early byte-limit termination.
- Observation timestamps and truncation diagnostics on database read results.
- Tool-name, outcome and duration logging without SQL, arguments, results or credentials.
- Separate `/health` liveness and `/ready` database-readiness endpoints.
- A multi-stage Docker build, non-root runtime, read-only Compose filesystem and dropped capabilities.
- Dependency locking, synthetic integration fixtures and HTTP/stdio smoke checks.

## Configuration

Copy [.env.example](.env.example) to `.env` and supply the connection settings for your installation.

| Variable                 | Default                     | Purpose                                                          |
| ------------------------ | --------------------------- | ---------------------------------------------------------------- |
| `MYSQL_HOST`             | `127.0.0.1`                 | MySQL hostname; the Compose example uses `host.docker.internal`. |
| `MYSQL_PORT`             | `3306`                      | MySQL port.                                                      |
| `MYSQL_DATABASE`         | Required                    | WHMCS database name.                                             |
| `MYSQL_USER`             | Required                    | Dedicated SELECT-only database account.                          |
| `MYSQL_PASSWORD`         | Empty                       | Database password; supply the appropriate deployment value.      |
| `MYSQL_SSL`              | `false`                     | Enable verified MySQL TLS.                                       |
| `MYSQL_SSL_CA_FILE`      | Unset                       | Path to a mounted private CA certificate; also enables TLS.      |
| `MYSQL_POOL_SIZE`        | `5`                         | Connection limit, from 1 to 20.                                  |
| `MCP_TRANSPORT`          | `http`                      | `http` or `stdio`; Compose starts HTTP.                          |
| `MCP_HTTP_HOST`          | `127.0.0.1`                 | Listener address; the container uses `0.0.0.0`.                  |
| `MCP_HTTP_PORT`          | `3100`                      | HTTP listener port inside the container.                         |
| `MCP_BIND_ADDRESS`       | `127.0.0.1`                 | Compose host address for the published port.                     |
| `MCP_PUBLISH_PORT`       | `3100`                      | Compose host port.                                               |
| `MCP_ALLOWED_HOSTS`      | `localhost,127.0.0.1,[::1]` | Accepted HTTP hostnames, separated by commas.                    |
| `MCP_ALLOWED_ORIGINS`    | Empty                       | Exact permitted browser origins, separated by commas.            |
| `MCP_MAX_ROWS`           | `500`                       | Maximum rows per read, configurable from 1 to 5,000.             |
| `MCP_QUERY_TIMEOUT_MS`   | `15000`                     | Execution timeout, configurable from 100 to 60,000 ms.           |
| `MCP_MAX_RESPONSE_BYTES` | `1048576`                   | Per-read row-payload budget in bytes.                            |
| `MCP_MAX_CELL_CHARS`     | `8192`                      | Text-cell character limit, configurable from 256 to 65,536.      |
| `REPORT_TIMEZONE`        | `Europe/London`             | Reporting timezone for default date boundaries.                  |

`MYSQL_HOST`, `MYSQL_DATABASE`, `MYSQL_USER` and `MYSQL_PASSWORD` also accept corresponding `_FILE` settings for mounted Docker secrets. File values take precedence over direct values. Credential files and the CA certificate must be readable by the container's non-root user.

For MySQL on the Docker host, use `host.docker.internal`; Compose includes the Linux host-gateway mapping. For another container, use its service hostname on a shared network. For a remote database, use its reachable hostname. Container loopback does not refer to the Docker host.

For an HTTPS reverse proxy, add the external hostname to `MCP_ALLOWED_HOSTS`. Browser-based callers that send an Origin header also need their exact origin in `MCP_ALLOWED_ORIGINS`. Neither setting enables authentication. See the [connection guide](docs/client-connections.md#https-reverse-proxy) for routing details.

## Connect your AI client

| Client                | Connection options                                      | Setup                                                                                                                                                   |
| --------------------- | ------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Codex**             | Local or remote HTTP; Docker stdio                      | [Codex guide](docs/client-connections.md#codex)                                                                                                         |
| **Claude Desktop**    | Local Docker stdio; remote HTTP connector               | [Local setup](docs/client-connections.md#claude-desktop-local-stdio) · [Remote setup](docs/client-connections.md#claude-web--desktop-remote-connectors) |
| **Claude Code**       | HTTP or stdio                                           | [Claude Code guide](docs/client-connections.md#claude-code)                                                                                             |
| **ChatGPT**           | Reachable HTTPS endpoint or supported Secure MCP Tunnel | [ChatGPT guide](docs/client-connections.md#chatgpt)                                                                                                     |
| **Other MCP clients** | Compatible Streamable HTTP or stdio                     | Use `/mcp` for HTTP or launch the container with `MCP_TRANSPORT=stdio`.                                                                                 |

The client guides include configuration examples and troubleshooting. Cloud clients need a reachable endpoint or supported tunnel; they cannot access your computer's localhost directly. No authentication is enabled in this development release.

## SQL analysis

Start with `describe_schema` to discover permitted tables and columns, then use `query_database` for custom analysis:

```sql
SELECT c.id, c.companyname, c.currency, COUNT(h.id) AS activeServices
FROM tblclients c
LEFT JOIN tblhosting h ON h.userid = c.id AND h.domainstatus = 'Active'
GROUP BY c.id, c.companyname, c.currency
ORDER BY activeServices DESC
```

Supported query features include non-recursive CTEs, joins, subqueries, unions, aggregation, CASE expressions, common date/math/string functions and common window functions. One SELECT or WITH…SELECT statement is permitted per call.

Writes, procedures, comments/hints, variables, locking reads, file access, cross-database references, arbitrary/stored functions and recursive CTEs are rejected. Unknown syntax fails closed.

Named list tools support documented filters and pagination. Read results include `rowCount`, `truncated`, `truncationReasons`, `observedAt` and consistency information. Composite tools contain individually bounded component reads. Use `offset` or explicit SQL pagination to retrieve subsequent pages, and use unique aliases for duplicate result column names.

## Financial reports

`get_stats` provides current counts, invoice totals, receivables and MRR. `revenue_report` adds date-filtered cash movements and invoice summaries, defaulting to the current calendar month. `dateFrom` and `dateTo` are inclusive.

- **Currencies stay separate.** No automatic FX conversion occurs.
- **Cash movements** come from recorded receipts, outgoings and fees. Outgoings are not necessarily all refunds.
- **Invoice totals** are distinct from cash received and recognized accounting revenue.
- **Outstanding balances** deduct applied invoice credit and net recorded payments. Payments are preaggregated to avoid multiplication across invoice items. Cancelled, refunded and draft invoices are excluded from receivables; zero due dates are not overdue.
- **Currency mismatches** produce flagged NULL balances and separate unresolved counts rather than false converted totals.
- **Current MRR** normalizes active service/addon recurring amounts over their billing cycles. One-off/free items, suspended/terminated services, domains and setup charges are excluded. Stored amounts receive no additional quantity multiplier or tax adjustment.
- **Historical limits** are explicit: current client currency is used where needed; historical currency changes, FX rates and historical MRR cannot be reconstructed reliably.

Decimal amounts and BIGINT expressions may be returned as strings to preserve precision. Date filters interpret stored DATE/DATETIME values as wall-clock dates; TIMESTAMP values are rendered in UTC. Check your installation's date and tax-inclusive pricing conventions when comparing reports. Full formulae and assumptions are returned with the report results.

## Read-only access and data handling

Every physical table access is rewritten to a projection of permitted fields before execution. Secret columns cannot be selected, filtered, joined, grouped or sorted. Wildcards expand only the approved projection. New or unknown columns and tables are not automatically exposed, and configuration/gateway/custom-field records have additional row restrictions.

Passwords, authentication material, security answers, payment secrets, session contents, opaque integration payloads and infrastructure login credentials are excluded. **Allowed business text in emails, tickets and notes can still contain embedded secrets.** Arbitrary free-text secret detection is not guaranteed; treat those records as sensitive, untrusted data.

Text is bounded at source, so filters and aggregations on very long text operate on its prefix. Results are live reads, and MyISAM tables cannot provide an atomic multi-table snapshot. Use narrow indexed numeric/date filters for large installations.

Use a dedicated SELECT-only database account. The application does not create database users, initialize tables, run migrations or alter the WHMCS schema. Read-only tool annotations supplement the query boundary; database privileges provide a separate enforcement layer.

## Development and testing

Source development requires **Node.js 22+**, npm and Python 3. Docker is required for integration tests.

```sh
npm ci
npm run check
npm run test:docker
```

`npm run check` runs formatting checks, the TypeScript build and unit tests. `npm run test:docker` creates a disposable MySQL 8.4 instance on port 13316, loads the checked-in synthetic schema/records, creates a SELECT-only test account, runs the checks and removes the test container/network. It does not require a customer database export. Fixture credentials are synthetic and belong only to that disposable container.

With the application container running:

```sh
npm run smoke
SMOKE_STDIO=docker npm run smoke
```

The smoke checks exercise all tool descriptors, resources and prompts over actual HTTP and Docker stdio transports. They print summary counts without customer records.

Build the self-contained distribution:

```sh
npm run package
```

This creates and verifies `whmcs-mcp-sql-1.0.0.tgz`, including source, compiled code, dependency lock, deployment files, synthetic tests and documentation. Extract it for Docker/source use or install it as a local npm tarball. Docker and package inputs use explicit file lists; local credentials, database dumps, IDE settings and generated dependencies are excluded.

## Documentation

- [Client connection guide](docs/client-connections.md) — Codex, Claude and ChatGPT configuration and troubleshooting.
- [Tool reference](docs/tools.md) — inputs, filters and result contracts.
- [Feature coverage](docs/read-only-coverage.md) — database-backed capabilities and limits.
- [Architecture](docs/design.md) — query boundary, deployment and data semantics.
- [Architecture decisions](docs/adr/) — the main design trade-offs.
- [Verification record](docs/verification.md) — validation evidence and untested environments.
