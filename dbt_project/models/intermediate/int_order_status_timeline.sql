-- Purpose: Track order status progression and timeline
-- Business logic: Identify order status transitions and durations

with orders as (
    select
        order_id,
        order_status,
        purchased_at,
        approved_at,
        delivered_carrier_at,
        delivered_customer_at
    from {{ ref('stg_orders') }}
),

status_timeline as (
    select
        order_id,
        order_status,
        purchased_at,
        approved_at,
        delivered_carrier_at,
        delivered_customer_at,
        -- Determine current status stage
        case
            when delivered_customer_at is not null then 'delivered'
            when delivered_carrier_at is not null then 'shipped'
            when approved_at is not null then 'approved'
            when purchased_at is not null then 'purchased'
            else 'unknown'
        end as current_stage,
        -- Check if order is complete
        case
            when order_status = 'delivered' then true
            else false
        end as is_complete
    from orders
)

select * from status_timeline
