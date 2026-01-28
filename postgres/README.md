# PostgreSQL Initialization Scripts

## What does this do?

This directory contains initialization scripts that run automatically when the PostgreSQL container is first created. These scripts set up databases and perform one-time configuration tasks.

## Why does it exist?

PostgreSQL Docker containers support initialization scripts that run only on first startup (when the data volume is empty). This ensures databases are created automatically without manual intervention.

## Contents

- **`init-airflow-db.sh`** - Creates the `airflow` database for Airflow metadata storage

## How it works

When Docker Compose starts PostgreSQL for the first time, it:
1. Checks if the data volume is empty
2. Runs all `.sh` scripts in `/docker-entrypoint-initdb.d/` (mapped from `postgres/`)
3. Executes scripts in alphabetical order
4. Only runs once - subsequent starts skip initialization

## Important Notes

- **One-time execution**: These scripts only run when the Postgres volume is first created
- **If Postgres already exists**: If you already have a running Postgres container with data, you'll need to create the `airflow` database manually:
  ```bash
  docker exec ecommerce_postgres psql -U analytics -d ecommerce -c "CREATE DATABASE airflow;"
  ```
- **Script requirements**: Scripts must be executable and use bash syntax
- **Error handling**: Scripts use `set -e` to stop on errors

## Adding New Scripts

To add new initialization scripts:
1. Create a `.sh` file in this directory
2. Ensure it's executable: `chmod +x script_name.sh`
3. The script will run automatically on next container creation (requires volume deletion)

## Related Files

- `docker-compose.yml` - Maps this directory to `/docker-entrypoint-initdb.d/`
- `airflow/README.md` - Explains Airflow database setup
