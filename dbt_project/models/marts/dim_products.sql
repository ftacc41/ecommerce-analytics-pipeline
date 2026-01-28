-- Purpose: Product dimension with catalog information and category hierarchy
-- Materialization: table (for better performance in Metabase)

{{ config(materialized='table') }}

with products as (
    select
        product_id,
        product_category_name,
        product_name_length,
        product_description_length,
        product_photos_quantity,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm
    from {{ ref('stg_products') }}
),

product_performance as (
    select
        product_id,
        order_count,
        total_revenue,
        avg_review_score
    from {{ ref('int_product_performance') }}
),

final as (
    select
        p.product_id,
        p.product_category_name,
        p.product_name_length,
        p.product_description_length,
        p.product_photos_quantity,
        -- Physical dimensions
        p.product_weight_g,
        p.product_length_cm,
        p.product_height_cm,
        p.product_width_cm,
        -- Performance metrics
        coalesce(pp.order_count, 0) as order_count,
        coalesce(pp.total_revenue, 0) as total_revenue,
        pp.avg_review_score,
        -- Product classification
        case
            when coalesce(pp.total_revenue, 0) > 10000 then 'high_value'
            when coalesce(pp.total_revenue, 0) > 1000 then 'medium_value'
            else 'low_value'
        end as product_value_tier
    from products p
    left join product_performance pp on p.product_id = pp.product_id
)

select * from final
