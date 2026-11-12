#!/bin/bash
# Applies every migration to a fresh local database and checks the server's quest and
# reward rules. Needs a local Postgres server, for example `brew install postgresql@17`
# then `brew services start postgresql@17`. Run from anywhere:
#   zsh scripts/db-tests/run.sh    (bash works too)
# Connection settings come from the usual PGHOST, PGPORT and PGUSER variables.
set -eo pipefail
cd "$(dirname "$0")/../.."
db="asphyr_test_$$"
createdb "$db"
trap 'dropdb --if-exists "$db"' EXIT
run() { psql -X -q -v ON_ERROR_STOP=1 -d "$db" -f "$1"; }
run supabase/tests/supabase-stub.sql
for migration in supabase/migrations/*.sql; do run "$migration"; done
run supabase/tests/quest_functions.test.sql 2>&1 | sed 's/^psql:[^ ]* WARNING:  //'
