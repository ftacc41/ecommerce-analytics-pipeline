-- Purpose: Product performance rankings for dashboard consumption
-- Materialization: table (for better performance in Metabase)

{{ config(materialized='table') }}

with products as (
    select
        product_id,
        product_category_name,
        order_count,
        total_revenue,
        avg_review_score,
        product_value_tier
    from {{ ref('dim_products') }}
),

product_rankings as (
    select
        product_id,
        product_category_name,
        order_count,
        total_revenue,
        avg_review_score,
        product_value_tier,
        -- Rankings
        rank() over (order by total_revenue desc) as revenue_rank,
        rank() over (order by order_count desc) as popularity_rank,
        rank() over (order by avg_review_score desc nulls last) as review_rank
    from products
    where total_revenue > 0
)

select * from product_rankings
