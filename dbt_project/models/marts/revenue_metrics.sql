-- Purpose: Revenue aggregations by various dimensions for dashboard consumption
-- Materialization: table (for better performance in Metabase)

{{ config(materialized='table') }}

with orders as (
    select
        order_id,
        order_date,
        customer_state,
        total_revenue
    from {{ ref('fct_orders') }}
),

order_items as (
    select
        order_id,
        product_id,
        seller_id,
        total_item_value
    from {{ ref('fct_order_items') }}
),

products as (
    select
        product_id,
        product_category_name
    from {{ ref('dim_products') }}
),

revenue_by_date as (
    select
        order_date,
        sum(total_revenue) as daily_revenue,
        count(distinct order_id) as daily_orders
    from orders
    group by order_date
),

revenue_by_state as (
    select
        customer_state,
        sum(total_revenue) as state_revenue,
        count(distinct order_id) as state_orders
    from orders
    group by customer_state
),

revenue_by_category as (
    select
        p.product_category_name,
        sum(oi.total_item_value) as category_revenue,
        count(distinct oi.order_id) as category_orders
    from order_items oi
    left join products p on oi.product_id = p.product_id
    group by p.product_category_name
)

select
    'date' as dimension_type,
    order_date::text as dimension_value,
    daily_revenue as revenue,
    daily_orders as order_count
from revenue_by_date

union all

select
    'state' as dimension_type,
    customer_state as dimension_value,
    state_revenue as revenue,
    state_orders as order_count
from revenue_by_state

union all

select
    'category' as dimension_type,
    coalesce(product_category_name, 'Unknown') as dimension_value,
    category_revenue as revenue,
    category_orders as order_count
from revenue_by_category
