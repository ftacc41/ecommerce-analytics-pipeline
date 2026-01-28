# dbt Project - E-Commerce Analytics

## What does this do?

This dbt project transforms raw e-commerce data from PostgreSQL into dimensional models optimized for analytics. It follows a medallion architecture with three layers: staging, intermediate, and marts.

## Why does it exist?

dbt provides:
- Version-controlled SQL transformations
- Automated testing and data quality checks
- Documentation generation
- Modular, reusable data models
- Dependency management between models

## How do I run it?

### Prerequisites

1. PostgreSQL running (via Docker Compose)
2. Data loaded into PostgreSQL (run ingestion script first)
3. dbt Core installed: `pip install dbt-postgres`
4. Environment variables set in `.env` file

### Setup

1. Install dbt packages:
```bash
cd dbt_project
dbt deps
```

2. Run models:
```bash
# Run all models
dbt run

# Run specific layer
dbt run --select staging.*
dbt run --select intermediate.*
dbt run --select marts.*
```

3. Run tests:
```bash
dbt test
```

4. Generate documentation:
```bash
dbt docs generate
dbt docs serve
```

### Project Structure

```
models/
├── staging/          # One model per source table, light cleaning
├── intermediate/     # Business logic and reusable components
└── marts/           # Final dimensional models (facts & dimensions)
```

### Key Models

**Staging Layer:**
- `stg_orders` - Order data
- `stg_order_items` - Order line items
- `stg_order_payments` - Payment information
- `stg_customers` - Customer data
- `stg_products` - Product catalog
- `stg_sellers` - Seller information
- `stg_order_reviews` - Review data
- `stg_geolocation` - Geographic data

**Marts Layer:**
- `fct_orders` - Order-level fact table
- `fct_order_items` - Item-level fact table
- `dim_customers` - Customer dimension
- `dim_products` - Product dimension
- `dim_sellers` - Seller dimension
- `dim_dates` - Date dimension
- `dim_geolocation` - Geographic dimension

## What are the dependencies?

- dbt-core>=1.5.0
- dbt-postgres>=1.5.0
- dbt-utils (via packages.yml)
- dbt-expectations (via packages.yml)

Install with: `pip install dbt-postgres`

## Testing

All models have tests defined in `schema.yml` files:
- Primary key tests (unique, not_null)
- Foreign key tests (relationships)
- Business rule tests (accepted_values)
- Data quality tests (custom tests)

Run tests: `dbt test`

## Documentation

Generate and view documentation:
```bash
dbt docs generate
dbt docs serve
```

This opens an interactive documentation site with:
- Model descriptions
- Column documentation
- Data lineage graphs
- Test results
