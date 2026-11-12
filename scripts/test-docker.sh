#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
fixture_compose=(docker compose -f compose.test.yaml -p whmcs-mcp-sql-test)
cleanup() { "${fixture_compose[@]}" down >/dev/null; }
trap cleanup EXIT
# This project is reserved for disposable synthetic fixtures; billing is never a target.
"${fixture_compose[@]}" down
"${fixture_compose[@]}" up -d --wait --wait-timeout 120
python3 scripts/make-fixture.py | "${fixture_compose[@]}" exec -T fixture-db mysql -uroot -pfixture-only whmcs_fixture
"${fixture_compose[@]}" exec -T fixture-db mysql -uroot -pfixture-only -e "CREATE USER 'reader'@'%' IDENTIFIED BY 'fixture-reader'; GRANT SELECT ON whmcs_fixture.* TO 'reader'@'%';"
npm run check
npm run test:integration
