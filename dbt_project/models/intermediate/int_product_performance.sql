-- Purpose: Calculate product-level performance metrics
-- Business logic: Aggregate revenue, quantity, and review scores by product

with order_items as (
    select
        product_id,
        order_id,
        price,
        freight_value,
        (price + freight_value) as total_item_value
    from {{ ref('stg_order_items') }}
),

order_revenue as (
    select
        order_id,
        total_revenue
    from {{ ref('int_order_revenue') }}
),

reviews as (
    select
        order_id,
        review_score
    from {{ ref('stg_order_reviews') }}
),

product_metrics as (
    select
        oi.product_id,
        count(distinct oi.order_id) as order_count,
        sum(oi.price) as total_revenue,
        sum(oi.freight_value) as total_freight,
        sum(oi.total_item_value) as total_value,
        avg(oi.price) as avg_price,
        avg(r.review_score) as avg_review_score
    from order_items oi
    left join reviews r on oi.order_id = r.order_id
    group by oi.product_id
)

select * from product_metrics
