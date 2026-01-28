-- Purpose: Clean and standardize raw seller data
-- Light cleaning only: rename columns, convert data types

with source as (
    select * from {{ source('ecommerce', 'olist_sellers_dataset') }}
),

cleaned as (
    select
        seller_id,
        seller_zip_code_prefix,
        seller_city,
        seller_state
    from source
)

select * from cleaned
