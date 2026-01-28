-- Purpose: Aggregate customer order history and metrics
-- Business logic: Calculate customer-level order statistics

with orders as (
    select
        customer_id,
        order_id,
        purchased_at,
        order_status
    from {{ ref('stg_orders') }}
),

customer_orders as (
    select
        customer_id,
        count(distinct order_id) as total_orders,
        min(purchased_at) as first_order_date,
        max(purchased_at) as last_order_date,
        count(distinct case when order_status = 'delivered' then order_id end) as delivered_orders
    from orders
    group by customer_id
)

select * from customer_orders
