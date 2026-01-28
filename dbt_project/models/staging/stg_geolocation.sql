-- Purpose: Clean and standardize raw geolocation data
-- Light cleaning only: rename columns, convert data types
-- Note: This dataset has duplicate zip codes, will be deduplicated in intermediate layer

with source as (
    select * from {{ source('ecommerce', 'olist_geolocation_dataset') }}
),

cleaned as (
    select
        geolocation_zip_code_prefix,
        geolocation_lat as latitude,
        geolocation_lng as longitude,
        geolocation_city,
        geolocation_state
    from source
)

select * from cleaned
