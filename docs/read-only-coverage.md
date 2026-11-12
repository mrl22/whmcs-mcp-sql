# Read-only feature coverage

The server exposes 57 tool descriptors: 52 usable database read/analysis tools and five explicit capability limitations. It also provides 24 resources and 12 analytical prompts. No mutation or operational action tools are provided.

Database implementations use detected tables/columns, safe field selection, and independently defined input/output schemas. Missing core tables produce unavailable-feature diagnostics; missing optional addons are distinguished from incomplete core schemas. See [tool reference](tools.md) for filters and [README](../README.md) for semantic boundaries.

## Read tools

| Tool                               | SQL-only coverage assessment                                                                                                         |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `get_client`                       | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `list_clients`                     | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_client_details`               | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_client_groups`                | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_client_emails`                | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_client_domains`               | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_client_addons`                | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_clients_online`               | Recent-login report only; does not establish active sessions.                                                                        |
| `get_invoice`                      | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `list_invoices`                    | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_overdue_invoices`             | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_transactions`                 | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_orders`                       | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_order_statuses`               | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `list_services`                    | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_cancelled_packages`           | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_ticket`                       | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `list_tickets`                     | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_support_departments`          | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_support_statuses`             | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_ticket_counts`                | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_ticket_predefined_categories` | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_quotes`                       | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_contacts`                     | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_credits`                      | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_payment_methods`              | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_currencies`                   | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_email_templates`              | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_products`                     | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_product_groups`               | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_domain_whois`                 | Live WHOIS is outside SQL-only access; history is not authoritative current WHOIS.                                                   |
| `get_domain_nameservers`           | Registrar state is outside SQL-only access. Hosting nameserver fields must not be presented as authoritative domain delegation.      |
| `get_domain_lock_status`           | Authoritative registrar locking state is outside SQL-only access.                                                                    |
| `get_tld_pricing`                  | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_admin_users`                  | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_staff_online`                 | Recent staff activity from available metadata; does not establish active sessions.                                                   |
| `get_whmcs_details`                | Only persisted installation metadata and database details; no inferred PHP/runtime information.                                      |
| `get_activity_log`                 | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_affiliates`                   | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_promotions`                   | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_servers`                      | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_health_status`                | Database reachability/schema health can be reported under an explicit database-health contract; WHMCS runtime health is unavailable. |
| `get_todo_items`                   | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_todo_item_statuses`           | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_announcements`                | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_registrars`                   | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `get_stats`                        | Implemented database read; inputs and limits are documented in the tool reference.                                                   |
| `list_projects`                    | Conditional on a separately verified Project Management addon schema; not currently supported.                                       |
| `get_project`                      | Conditional on a separately verified Project Management addon schema; not currently supported.                                       |

Additional tools: `query_database`, `describe_schema`, `get_capabilities`, `revenue_report`, `get_quote`, `get_client_notes`, `get_billable_items`, and `get_pricing`. See the [tool reference](tools.md) for their inputs.

## Resources

All 24 names are inventoried below. Runtime health and installation information need explicit database-only descriptions. No exact runtime health or live subscription guarantee is implied.

- `whmcs://stats`
- `whmcs://health`
- `whmcs://system/info`
- `whmcs://products`
- `whmcs://product-groups`
- `whmcs://tld-pricing`
- `whmcs://promotions`
- `whmcs://order-statuses`
- `whmcs://currencies`
- `whmcs://payment-methods`
- `whmcs://registrars`
- `whmcs://servers`
- `whmcs://client-groups`
- `whmcs://affiliates`
- `whmcs://email-templates`
- `whmcs://announcements`
- `whmcs://support/departments`
- `whmcs://support/statuses`
- `whmcs://support/ticket-counts`
- `whmcs://support/predefined-categories`
- `whmcs://admin/users`
- `whmcs://admin/todo`
- `whmcs://admin/todo-statuses`
- `whmcs://admin/staff-online`

## Workflows

Analytical workflows cover revenue and receivables, client health, domain expiry records, churn indicators, support queues, affiliate performance, service renewal forecasts, addon opportunities, and promotion usage. Account creation, orders, invoice/quote creation, message delivery, and product setup workflows are excluded. Analytical recommendations must not invoke write actions.

## Scope boundary

All interfaces, including general SQL analysis, must exclude credentials, tokens, authentication material, session contents, and payment secrets. The sensitive-field policy also applies to predicates, joins, ordering, and aggregates, not just returned columns. Free-text business content can contain embedded secrets; any supported redaction rules and their limits must be explicit.
