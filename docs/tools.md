# Tool reference

All tools are read-only. Inputs use the contracts documented below. Discover JSON input schemas through MCP `tools/list`. Omitted `limit` uses the configured cap; `offset` defaults to zero. List results report truncation and component reads have separate limits.

## Identified records

| Tool                 | Inputs                           | Result                                                |
| -------------------- | -------------------------------- | ----------------------------------------------------- |
| `get_client`         | `clientId` or exact `email`      | Matching client account(s), with ambiguity explicit   |
| `get_client_details` | `clientId` or exact `email`      | Client plus bounded contacts, user links, staff notes |
| `get_invoice`        | `invoiceId`                      | Invoice, items, transactions                          |
| `get_ticket`         | `ticketId` (internal numeric ID) | Ticket, replies, staff notes                          |
| `get_quote`          | `quoteId`                        | Quote and items                                       |

Use `query_database` to join `tblusers_clients.auth_user_id` to `tblusers.id` for login-user identities. Client accounts and login users are different entities.

## Lists

All tools in this table accept `limit` and `offset`. Additional accepted filters are listed explicitly; unsupported keys are rejected. Search is a literal substring, not SQL wildcard syntax. Date ranges are inclusive.

| Tool                               | Additional inputs                                                                                                           |
| ---------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| `list_clients`                     | `search`, `status`, `dateFrom`, `dateTo` (account creation date)                                                            |
| `get_client_groups`                | `search`                                                                                                                    |
| `get_client_emails`                | `clientId`, `search` (subject), `dateFrom`, `dateTo`                                                                        |
| `get_client_domains`               | `clientId`, `search` (domain), `status`, `dateFrom`, `dateTo` (expiry)                                                      |
| `get_client_addons`                | `clientId`, `serviceId`, `status`                                                                                           |
| `get_clients_online`               | `minutes` (1–10080, default 60); recent login, not sessions                                                                 |
| `list_invoices`                    | `clientId`, `status`, `dateFrom`, `dateTo` (issue date)                                                                     |
| `get_overdue_invoices`             | `clientId`, `asOf` (YYYY-MM-DD)                                                                                             |
| `get_transactions`                 | `clientId`, `invoiceId`, `search`, `dateFrom`, `dateTo`                                                                     |
| `get_orders`                       | `clientId`, `orderId`, `status`, `dateFrom`, `dateTo`                                                                       |
| `get_order_statuses`               | —                                                                                                                           |
| `list_services`                    | `clientId`, `serviceId`, `productId`, `status`, `search` (domain), `dateFrom`, `dateTo` (next due)                          |
| `get_cancelled_packages`           | `serviceId`, `dateFrom`, `dateTo` (request date)                                                                            |
| `list_tickets`                     | `clientId`, `departmentId`, `priority` (Low/Medium/High), `status`, `search` (title/public ticket ID), `dateFrom`, `dateTo` |
| `get_support_departments`          | `search`                                                                                                                    |
| `get_support_statuses`             | —                                                                                                                           |
| `get_ticket_predefined_categories` | —                                                                                                                           |
| `get_quotes`                       | `clientId`, `quoteId`, `status` (quote stage), `search`, `dateFrom`, `dateTo`                                               |
| `get_contacts`                     | `clientId`, `search`                                                                                                        |
| `get_credits`                      | `clientId`, `dateFrom`, `dateTo`                                                                                            |
| `get_payment_methods`              | —; public gateway settings only, not saved card/bank details                                                                |
| `get_currencies`                   | —                                                                                                                           |
| `get_email_templates`              | `search`                                                                                                                    |
| `get_products`                     | `productId`, `groupId`, `search`                                                                                            |
| `get_product_groups`               | —; includes product counts                                                                                                  |
| `get_tld_pricing`                  | `currencyId`, `tldId`; raw WHMCS domain pricing slots, joined through `relid`                                               |
| `get_admin_users`                  | `search`                                                                                                                    |
| `get_staff_online`                 | `minutes` (1–10080, default 60); recent activity, not sessions                                                              |
| `get_activity_log`                 | `clientId`, `search`, `dateFrom`, `dateTo`                                                                                  |
| `get_affiliates`                   | `clientId`, `dateFrom`, `dateTo`                                                                                            |
| `get_promotions`                   | `search`                                                                                                                    |
| `get_servers`                      | `search`                                                                                                                    |
| `get_todo_items`                   | `status`, `search`, `dateFrom`, `dateTo` (due date)                                                                         |
| `get_announcements`                | `search`, `dateFrom`, `dateTo`, `includeUnpublished` (default false)                                                        |
| `get_client_notes`                 | `clientId`, `search`, `dateFrom`, `dateTo`                                                                                  |
| `get_billable_items`               | `clientId`, `search`, `dateFrom`, `dateTo` (due date)                                                                       |
| `get_pricing`                      | `currencyId`, `relatedId`, `type`                                                                                           |

## Aggregates, metadata and analysis

| Tool                     | Inputs/meaning                                                         |
| ------------------------ | ---------------------------------------------------------------------- |
| `get_ticket_counts`      | Optional `clientId`; group by department, status, urgency              |
| `get_todo_item_statuses` | No inputs; distinct stored statuses                                    |
| `get_registrars`         | No inputs; distinct configured identifiers                             |
| `get_whmcs_details`      | No inputs; allowlisted persisted configuration and MySQL version       |
| `get_health_status`      | No inputs; database connectivity, not PHP/WHMCS runtime health         |
| `get_stats`              | No inputs; counts, currency-separated invoices/receivables/current MRR |
| `revenue_report`         | Optional `dateFrom`, `dateTo`; see financial definitions in README     |
| `describe_schema`        | Optional exact `table`; permitted schema only                          |
| `get_capabilities`       | No inputs; tool availability and configured bounds                     |
| `query_database`         | Required `sql`, optional `limit`; one restricted SELECT/CTE            |

`get_domain_whois`, `get_domain_nameservers`, and `get_domain_lock_status` accept optional `domain`/`domainId` and return an explicit SQL-only limitation. `list_projects`/`get_project` report unavailable Project Management addon schema. These descriptors report capability limitations explicitly; they do not perform external reads.

Tool success is returned in `structuredContent.result` and equivalently as JSON text. Tool errors have `isError: true` with a public error code and message in text content. Resource reads return JSON snapshots; unavailable-resource data contains an explicit error. No raw database errors, SQL statements or credentials are returned on failure.
