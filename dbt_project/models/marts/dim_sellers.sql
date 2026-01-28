-- Purpose: Seller dimension with information and performance metrics
-- Materialization: table (for better performance in Metabase)

{{ config(materialized='table') }}

with sellers as (
    select
        seller_id,
        seller_zip_code_prefix,
        seller_city,
        seller_state
    from {{ ref('stg_sellers') }}
),

seller_performance as (
    select
        oi.seller_id,
        count(distinct oi.order_id) as total_orders,
        count(distinct oi.product_id) as unique_products_sold,
        sum(oi.price) as total_revenue,
        sum(oi.freight_value) as total_freight,
        avg(oi.price) as avg_item_price
    from {{ ref('stg_order_items') }} oi
    group by oi.seller_id
),

final as (
    select
        s.seller_id,
        s.seller_city,
        s.seller_state,
        s.seller_zip_code_prefix,
        -- Performance metrics
        coalesce(sp.total_orders, 0) as total_orders,
        coalesce(sp.unique_products_sold, 0) as unique_products_sold,
        coalesce(sp.total_revenue, 0) as total_revenue,
        coalesce(sp.total_freight, 0) as total_freight,
        sp.avg_item_price,
        -- Seller classification
        case
            when coalesce(sp.total_revenue, 0) > 50000 then 'top_seller'
            when coalesce(sp.total_revenue, 0) > 10000 then 'active_seller'
            else 'small_seller'
        end as seller_tier
    from sellers s
    left join seller_performance sp on s.seller_id = sp.seller_id
)

select * from final
