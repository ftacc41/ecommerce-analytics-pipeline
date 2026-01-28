-- Purpose: Order item-level fact table with item metrics
-- Grain: One row per order item
-- Materialization: table (for better performance in Metabase)

{{ config(materialized='table') }}

with order_items as (
    select
        order_id,
        order_item_id,
        product_id,
        seller_id,
        price,
        freight_value,
        (price + freight_value) as total_item_value,
        shipping_limit_at
    from {{ ref('stg_order_items') }}
),

orders as (
    select
        order_id,
        customer_id,
        purchased_at
    from {{ ref('stg_orders') }}
),

final as (
    select
        oi.order_id,
        oi.order_item_id,
        oi.product_id,
        oi.seller_id,
        o.customer_id,
        -- Item metrics
        oi.price,
        oi.freight_value,
        oi.total_item_value,
        -- Order context
        o.purchased_at as order_date,
        oi.shipping_limit_at,
        -- Date dimension key
        date(o.purchased_at) as order_date_key
    from order_items oi
    left join orders o on oi.order_id = o.order_id
)

select * from final
