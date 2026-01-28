"""
E-Commerce Analytics Pipeline DAG

This DAG orchestrates the complete data pipeline:
1. Ingest CSV data into PostgreSQL
2. Run dbt staging models
3. Run dbt intermediate models
4. Run dbt marts models
5. Run dbt tests
6. Generate dbt documentation
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.utils.dates import days_ago
import sys
import os

# Add ingestion directory to path
sys.path.insert(0, '/opt/airflow/ingestion')

default_args = {
    'owner': 'analytics',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'ecommerce_analytics_pipeline',
    default_args=default_args,
    description='E-Commerce Analytics Pipeline - Ingestion to Marts',
    schedule_interval='0 2 * * *',  # Daily at 2 AM UTC
    start_date=days_ago(1),
    catchup=False,
    tags=['ecommerce', 'analytics', 'dbt'],
)


def run_ingestion():
    """Run the data ingestion script"""
    from load_to_postgres import main
    main()


# Task 1: Ingest data from CSV files
ingest_data = PythonOperator(
    task_id='ingest_data',
    python_callable=run_ingestion,
    dag=dag,
)

# Task 2: Run dbt staging models
dbt_staging = BashOperator(
    task_id='dbt_staging',
    bash_command='cd /opt/airflow/dbt_project && dbt run --select staging.*',
    dag=dag,
)

# Task 3: Run dbt intermediate models
dbt_intermediate = BashOperator(
    task_id='dbt_intermediate',
    bash_command='cd /opt/airflow/dbt_project && dbt run --select intermediate.*',
    dag=dag,
)

# Task 4: Run dbt marts models
dbt_marts = BashOperator(
    task_id='dbt_marts',
    bash_command='cd /opt/airflow/dbt_project && dbt run --select marts.*',
    dag=dag,
)

# Task 5: Run dbt tests
dbt_tests = BashOperator(
    task_id='dbt_tests',
    bash_command='cd /opt/airflow/dbt_project && dbt test',
    dag=dag,
)

# Task 6: Generate dbt documentation
dbt_docs = BashOperator(
    task_id='dbt_docs',
    bash_command='cd /opt/airflow/dbt_project && dbt docs generate',
    dag=dag,
)

# Define task dependencies
ingest_data >> dbt_staging >> dbt_intermediate >> dbt_marts >> dbt_tests >> dbt_docs
