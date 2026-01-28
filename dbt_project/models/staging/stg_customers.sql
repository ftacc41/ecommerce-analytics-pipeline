-- Purpose: Clean and standardize raw customer data
-- Light cleaning only: rename columns, convert data types

with source as (
    select * from {{ source('ecommerce', 'olist_customers_dataset') }}
),

cleaned as (
    select
        customer_id,
        customer_unique_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state
    from source
)

select * from cleaned
