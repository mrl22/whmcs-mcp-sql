# Open development access with one enforced read boundary

The development release exposes the same read-only tools over HTTP and stdio without MCP authentication or per-staff roles; Compose publishes HTTP on localhost by default. A shared parser and field-projection layer handles every named and arbitrary SQL read, preventing secret-column access in predicates and aggregates as well as result columns. Dedicated SELECT-only database credentials provide a separate boundary against writes. The package never provisions database accounts, changes schemas, or enables write operations.
