# Airflow Orchestration

## What does this do?

This directory contains Airflow DAGs that orchestrate the e-commerce analytics pipeline. The main DAG (`ecommerce_pipeline.py`) automates the complete data flow from CSV ingestion through dbt transformations to final marts.

## Why does it exist?

Automated orchestration ensures:
- Data pipeline runs on a schedule without manual intervention
- Tasks execute in the correct order with proper dependencies
- Failures are tracked and can be retried automatically
- Pipeline execution is visible and auditable

## How do I run it?

### Prerequisites

1. Docker and Docker Compose installed
2. `.env` file configured (see First-time setup below)
3. Airflow uses a **dedicated database** (`airflow`) on the same Postgres instance as the ecommerce data

### First-time setup

1. **Copy environment file and set required variables:**
   ```bash
   cp .env.example .env
   ```
   In `.env`, ensure you have:
   - `POSTGRES_USER` and `POSTGRES_PASSWORD` (e.g. `analytics` / `analytics` for local dev)
   - `AIRFLOW__CORE__FERNET_KEY` – generate with:
     ```bash
     python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
     ```
   - Optional: `AIRFLOW_DB=airflow` (default is `airflow`)
   - Optional on Linux: `AIRFLOW_UID=$(id -u)` to avoid file permission warnings

2. **Create the Airflow database (one-time, if Postgres already has data):**
   The init script in `postgres/init-airflow-db.sh` creates the `airflow` database only when the Postgres volume is **first** created. If you already have a running Postgres with the `ecommerce` database, create the Airflow DB manually:
   ```bash
   docker exec ecommerce_postgres psql -U analytics -d ecommerce -c "CREATE DATABASE airflow;"
   ```
   (Use the same user as `POSTGRES_USER`; if you get "permission denied", connect as superuser: `psql -U postgres -d postgres -c "CREATE DATABASE airflow;"`.)

3. **Start services:**
   ```bash
   docker-compose up -d
   ```
   This starts Postgres, then `airflow-init` (migrates DB, creates admin user), then the webserver and scheduler.

4. **Access Airflow UI:**
   - Open http://localhost:8080
   - Login: `airflow` / `airflow` (default; change in production)

5. **Enable the DAG:**
   - Find `ecommerce_analytics_pipeline` in the DAG list
   - Toggle it ON
   - Trigger manually with the play button, or wait for the schedule (daily at 2 AM UTC)

### DAG Tasks

The pipeline consists of 6 tasks:

1. **ingest_data** – Loads CSV files into PostgreSQL
2. **dbt_staging** – Runs dbt staging models
3. **dbt_intermediate** – Runs dbt intermediate models
4. **dbt_marts** – Runs dbt marts models
5. **dbt_tests** – Runs all dbt tests
6. **dbt_docs** – Generates dbt documentation

### Monitoring

- View task status in Airflow UI
- Check logs for each task
- Monitor DAG runs in Graph View
- Review task duration and success rates

## What are the dependencies?

- Apache Airflow 2.8.2 (via Docker)
- PostgreSQL (Airflow metadata in `airflow` database; ecommerce data in `ecommerce` database)
- dbt Core (installed in Airflow container)
- Python ingestion script (in `/opt/airflow/ingestion`)

## Configuration

The DAG is configured to:
- Run daily at 2 AM UTC
- Retry failed tasks once after 5 minutes
- Not send email alerts (configure if needed)
- Skip catchup (won't backfill past dates)

To modify the schedule, edit `schedule_interval` in `ecommerce_pipeline.py`.

## Troubleshooting

| Problem | Solution |
|--------|----------|
| **"password authentication failed for user analytics"** | Ensure Postgres accepts TCP connections with your `.env` password. Run once: `docker exec ecommerce_postgres psql -U analytics -d postgres -c "ALTER USER analytics WITH PASSWORD 'analytics';"` (use the same password as in `.env`). |
| **"database airflow does not exist"** | Create it: `docker exec ecommerce_postgres psql -U analytics -d ecommerce -c "CREATE DATABASE airflow;"` |
| **airflow-init fails or webserver never starts** | Check init logs: `docker logs ecommerce_airflow_init`. Ensure `airflow` DB exists and credentials in `.env` match. |
| **Internal Server Error when opening UI** | Clear session table: `docker exec ecommerce_postgres psql -U analytics -d airflow -c "TRUNCATE TABLE session CASCADE;"` then restart: `docker-compose restart airflow-webserver`. |
| **FERNET_KEY error on startup** | Generate a key and set it in `.env`: `AIRFLOW__CORE__FERNET_KEY=<output of Fernet.generate_key().decode()>`. |
| **500 error / "NoneType has no attribute 'sign'"** | Set `AIRFLOW__WEBSERVER__SECRET_KEY` in `.env` (or use the default in docker-compose for local dev). |

## Manual pipeline (without Airflow)

If Airflow is not running, you can run the pipeline manually:

```bash
python ingestion/load_to_postgres.py
cd dbt_project && dbt run && dbt test
```
