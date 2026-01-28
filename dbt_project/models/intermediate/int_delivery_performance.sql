-- Purpose: Calculate delivery time and performance metrics
-- Business logic: Compute time differences between order milestones

with orders as (
    select
        order_id,
        purchased_at,
        approved_at,
        delivered_carrier_at,
        delivered_customer_at,
        estimated_delivery_at
    from {{ ref('stg_orders') }}
),

delivery_metrics as (
    select
        order_id,
        purchased_at,
        approved_at,
        delivered_carrier_at,
        delivered_customer_at,
        estimated_delivery_at,
        -- Calculate time differences in days
        case
            when approved_at is not null and purchased_at is not null
            then extract(epoch from (approved_at - purchased_at)) / 86400
            else null
        end as approval_time_days,
        case
            when delivered_carrier_at is not null and approved_at is not null
            then extract(epoch from (delivered_carrier_at - approved_at)) / 86400
            else null
        end as carrier_handoff_time_days,
        case
            when delivered_customer_at is not null and delivered_carrier_at is not null
            then extract(epoch from (delivered_customer_at - delivered_carrier_at)) / 86400
            else null
        end as delivery_time_days,
        case
            when delivered_customer_at is not null and purchased_at is not null
            then extract(epoch from (delivered_customer_at - purchased_at)) / 86400
            else null
        end as total_delivery_time_days,
        case
            when delivered_customer_at is not null and estimated_delivery_at is not null
            then extract(epoch from (delivered_customer_at - estimated_delivery_at)) / 86400
            else null
        end as delivery_delay_days
    from orders
)

select * from delivery_metrics
