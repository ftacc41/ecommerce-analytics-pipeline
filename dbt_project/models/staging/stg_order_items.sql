-- Purpose: Clean and standardize raw order items data
-- Light cleaning only: rename columns, convert data types

with source as (
    select * from {{ source('ecommerce', 'olist_order_items_dataset') }}
),

cleaned as (
    select
        order_id,
        order_item_id,
        product_id,
        seller_id,
        shipping_limit_date::timestamp as shipping_limit_at,
        price,
        freight_value
    from source
)

select * from cleaned
