#!/bin/bash
# Creates the Airflow metadata database on first Postgres startup.
# Only runs when the Postgres data volume is first created (empty).
set -e
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE airflow;
EOSQL
