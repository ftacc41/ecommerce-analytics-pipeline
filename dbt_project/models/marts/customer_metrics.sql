-- Purpose: Customer metrics for cohort analysis and retention
-- Materialization: table (for better performance in Metabase)

{{ config(materialized='table') }}

with customers as (
    select
        customer_unique_id,
        total_orders,
        first_order_date,
        last_order_date,
        lifetime_value,
        customer_segment
    from {{ ref('dim_customers') }}
),

orders as (
    select
        customer_id,
        order_id,
        order_date,
        total_revenue
    from {{ ref('fct_orders') }}
),

customer_cohorts as (
    select
        c.customer_unique_id,
        c.total_orders,
        c.first_order_date,
        c.last_order_date,
        c.lifetime_value,
        c.customer_segment,
        -- Cohort month (first order month)
        date_trunc('month', c.first_order_date) as cohort_month,
        -- Months since first order
        extract(epoch from (c.last_order_date - c.first_order_date)) / (86400 * 30) as months_since_first_order,
        -- Is repeat customer
        case when c.total_orders > 1 then true else false end as is_repeat_customer
    from customers c
)

select * from customer_cohorts
