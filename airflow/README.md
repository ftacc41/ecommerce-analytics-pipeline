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
2. `.env` file configured with database credentials
3. Airflow services running (via `docker-compose up`)

### Setup

1. Start all services:
```bash
docker-compose up -d
```

2. Access Airflow UI:
- Open http://localhost:8080
- Login: `airflow` / `airflow` (default, change in production)

3. Enable the DAG:
- Find `ecommerce_analytics_pipeline` in the DAG list
- Toggle it ON

4. Trigger manually (optional):
- Click the play button to run immediately
- Or wait for scheduled run (daily at 2 AM UTC)

### DAG Tasks

The pipeline consists of 6 tasks:

1. **ingest_data** - Loads CSV files into PostgreSQL
2. **dbt_staging** - Runs dbt staging models
3. **dbt_intermediate** - Runs dbt intermediate models
4. **dbt_marts** - Runs dbt marts models
5. **dbt_tests** - Runs all dbt tests
6. **dbt_docs** - Generates dbt documentation

### Monitoring

- View task status in Airflow UI
- Check logs for each task
- Monitor DAG runs in Graph View
- Review task duration and success rates

## What are the dependencies?

- Apache Airflow 2.7.0 (via Docker)
- PostgreSQL (for Airflow metadata and data warehouse)
- dbt Core (installed in Airflow container)
- Python ingestion script (in `/opt/airflow/ingestion`)

## Configuration

The DAG is configured to:
- Run daily at 2 AM UTC
- Retry failed tasks once after 5 minutes
- Not send email alerts (configure if needed)
- Skip catchup (won't backfill past dates)

To modify the schedule, edit `schedule_interval` in `ecommerce_pipeline.py`.
