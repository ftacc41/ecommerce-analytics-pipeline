-- Purpose: Customer dimension with attributes and calculated fields
-- Materialization: table (for better performance in Metabase)

{{ config(materialized='table') }}

with customers as (
    select
        customer_id,
        customer_unique_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state
    from {{ ref('stg_customers') }}
),

customer_orders as (
    select
        customer_id,
        total_orders,
        first_order_date,
        last_order_date,
        delivered_orders
    from {{ ref('int_customer_orders') }}
),

order_revenue as (
    select
        o.customer_id,
        sum(or_rev.total_revenue) as lifetime_value
    from {{ ref('stg_orders') }} o
    left join {{ ref('int_order_revenue') }} or_rev on o.order_id = or_rev.order_id
    group by o.customer_id
),

final as (
    select
        c.customer_unique_id,
        c.customer_id,
        c.customer_city,
        c.customer_state,
        c.customer_zip_code_prefix,
        -- Calculated fields
        coalesce(co.total_orders, 0) as total_orders,
        co.first_order_date,
        co.last_order_date,
        coalesce(co.delivered_orders, 0) as delivered_orders,
        coalesce(lv.lifetime_value, 0) as lifetime_value,
        -- Customer segmentation
        case
            when coalesce(co.total_orders, 0) = 1 then 'single_purchase'
            when coalesce(co.total_orders, 0) between 2 and 4 then 'repeat_customer'
            else 'loyal_customer'
        end as customer_segment
    from customers c
    left join customer_orders co on c.customer_id = co.customer_id
    left join order_revenue lv on c.customer_id = lv.customer_id
)

select * from final
