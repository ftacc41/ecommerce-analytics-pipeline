-- Purpose: Calculate order-level revenue from payment data
-- Business logic: Sum all payments for each order to get total revenue

with order_payments as (
    select
        order_id,
        payment_value
    from {{ ref('stg_order_payments') }}
),

order_revenue as (
    select
        order_id,
        sum(payment_value) as total_revenue,
        count(*) as payment_count
    from order_payments
    group by order_id
)

select * from order_revenue
