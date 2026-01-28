-- Purpose: Clean and standardize raw product data
-- Light cleaning only: rename columns, convert data types, standardize categories

with source as (
    select * from {{ source('ecommerce', 'olist_products_dataset') }}
),

cleaned as (
    select
        product_id,
        product_category_name,
        product_name_lenght as product_name_length,
        product_description_lenght as product_description_length,
        product_photos_qty as product_photos_quantity,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm
    from source
)

select * from cleaned
