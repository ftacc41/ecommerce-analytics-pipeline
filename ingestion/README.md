# Data Ingestion

## What does this do?

This module contains scripts to load the Brazilian E-Commerce dataset (Kaggle) CSV files into PostgreSQL. The ingestion script reads all 8 CSV files from `data/raw/` and loads them into PostgreSQL tables with appropriate data types and schema.

## Why does it exist?

Raw CSV files need to be loaded into a database before they can be transformed with dbt. This script provides a reliable, automated way to:
- Read CSV files with proper data type inference
- Handle date/timestamp conversions
- Create PostgreSQL tables automatically
- Support incremental loads (replace existing data)

## How do I run it?

### Prerequisites

1. Ensure PostgreSQL is running (via Docker Compose)
2. Download the Kaggle dataset and place CSV files in `data/raw/`
3. Create `.env` file from `.env.example` with database credentials

### Setup

```bash
# Install dependencies
pip install -r requirements.txt
```

### Run ingestion

```bash
# From project root
python ingestion/load_to_postgres.py
```

The script will:
1. Connect to PostgreSQL using credentials from `.env`
2. Read all CSV files from `data/raw/`
3. Create tables and load data
4. Log progress and any errors

### Expected CSV files

The script expects these 8 CSV files in `data/raw/`:
- `olist_orders_dataset.csv`
- `olist_order_items_dataset.csv`
- `olist_order_payments_dataset.csv`
- `olist_customers_dataset.csv`
- `olist_products_dataset.csv`
- `olist_sellers_dataset.csv`
- `olist_order_reviews_dataset.csv`
- `olist_geolocation_dataset.csv`

## What are the dependencies?

See `requirements.txt` for full list:
- `pandas` - CSV reading and data manipulation
- `psycopg2-binary` - PostgreSQL adapter
- `sqlalchemy` - Database connection and operations
- `python-dotenv` - Environment variable management

## Error Handling

The script includes comprehensive error handling:
- Validates environment variables are set
- Checks if data directory and CSV files exist
- Handles database connection errors
- Logs all operations for debugging

If you encounter errors, check the logs for specific error messages and ensure:
- PostgreSQL is running and accessible
- `.env` file has correct credentials
- CSV files are in `data/raw/` directory
