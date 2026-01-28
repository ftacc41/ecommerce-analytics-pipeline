-- Purpose: Geographic dimension (city, state, region)
-- Materialization: table (for better performance in Metabase)
-- Deduplicates geolocation data by zip code prefix

{{ config(materialized='table') }}

with geolocation as (
    select
        geolocation_zip_code_prefix,
        latitude,
        longitude,
        geolocation_city,
        geolocation_state
    from {{ ref('stg_geolocation') }}
),

deduplicated as (
    select
        geolocation_zip_code_prefix,
        avg(latitude) as latitude,
        avg(longitude) as longitude,
        -- Take the most common city/state for each zip code
        mode() within group (order by geolocation_city) as city,
        mode() within group (order by geolocation_state) as state
    from geolocation
    group by geolocation_zip_code_prefix
),

final as (
    select
        geolocation_zip_code_prefix as zip_code_prefix,
        city,
        state,
        latitude,
        longitude,
        -- Region classification (simplified - could be enhanced with actual Brazilian regions)
        case
            when state in ('SP', 'RJ', 'MG', 'ES') then 'Southeast'
            when state in ('RS', 'SC', 'PR') then 'South'
            when state in ('BA', 'CE', 'PE', 'RN', 'PB', 'AL', 'SE', 'MA', 'PI') then 'Northeast'
            when state in ('GO', 'MT', 'MS', 'DF') then 'Central-West'
            when state in ('AM', 'PA', 'AC', 'RO', 'RR', 'AP', 'TO') then 'North'
            else 'Unknown'
        end as region
    from deduplicated
)

select * from final
