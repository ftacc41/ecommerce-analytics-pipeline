-- Purpose: Order-level fact table with metrics and foreign keys to dimensions
-- Grain: One row per order
-- Materialization: table (for better performance in Metabase)

{{ config(materialized='table') }}

with orders as (
    select
        order_id,
        customer_id,
        order_status,
        purchased_at,
        estimated_delivery_at
    from {{ ref('stg_orders') }}
),

order_revenue as (
    select
        order_id,
        total_revenue,
        payment_count
    from {{ ref('int_order_revenue') }}
),

delivery_metrics as (
    select
        order_id,
        total_delivery_time_days,
        delivery_delay_days,
        approval_time_days
    from {{ ref('int_delivery_performance') }}
),

order_items_summary as (
    select
        order_id,
        count(*) as item_count,
        sum(price) as items_total,
        sum(freight_value) as freight_total
    from {{ ref('stg_order_items') }}
    group by order_id
),

customers as (
    select
        customer_id,
        customer_unique_id,
        customer_state,
        customer_city
    from {{ ref('stg_customers') }}
),

final as (
    select
        o.order_id,
        o.customer_id,
        c.customer_unique_id,
        o.order_status,
        o.purchased_at,
        o.estimated_delivery_at,
        c.customer_state,
        c.customer_city,
        -- Revenue metrics
        coalesce(or_rev.total_revenue, 0) as total_revenue,
        or_rev.payment_count,
        -- Item metrics
        coalesce(oi.item_count, 0) as item_count,
        coalesce(oi.items_total, 0) as items_total,
        coalesce(oi.freight_total, 0) as freight_total,
        -- Delivery metrics
        dm.total_delivery_time_days,
        dm.delivery_delay_days,
        dm.approval_time_days,
        -- Date dimension keys (will be joined in BI tool)
        date(o.purchased_at) as order_date
    from orders o
    left join order_revenue or_rev on o.order_id = or_rev.order_id
    left join delivery_metrics dm on o.order_id = dm.order_id
    left join order_items_summary oi on o.order_id = oi.order_id
    left join customers c on o.customer_id = c.customer_id
)

select * from final
