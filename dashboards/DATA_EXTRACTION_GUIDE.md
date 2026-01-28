# Metabase Dashboard Data Extraction Guide

This guide maps each dashboard component to the specific database tables and columns needed in Metabase.

## Database Schema Reference

All tables are in the `public_marts` schema. Use schema-qualified names: `public_marts.table_name`

---

## 1. Executive Summary Dashboard

### 1.1 Total Revenue KPI
**Data Source**: `public_marts.fct_orders`
- **Query**: `SELECT SUM(total_revenue) FROM public_marts.fct_orders`
- **Column**: `total_revenue` (sum)

### 1.2 Monthly Revenue Trend (Line Chart)
**Data Source**: `public_marts.revenue_metrics` (filtered) OR `public_marts.fct_orders` (with aggregation)
- **Option A (Recommended)**: Use `revenue_metrics` table
  - Filter: `dimension_type = 'date'`
  - X-axis: `dimension_value` (cast to date)
  - Y-axis: `revenue`
  - Group by: Month (extract month from dimension_value)
- **Option B**: Use `fct_orders` directly
  - X-axis: `order_date` (group by month using `date_trunc('month', order_date)`)
  - Y-axis: `SUM(total_revenue)`

### 1.3 Revenue by Category (Bar Chart)
**Data Source**: `public_marts.revenue_metrics` (filtered)
- Filter: `dimension_type = 'category'`
- X-axis: `dimension_value` (product_category_name)
- Y-axis: `revenue`
- Order by: `revenue DESC`

### 1.4 Top 10 Products by Revenue (Table)
**Data Source**: `public_marts.dim_products` OR `public_marts.product_metrics`
- **Columns needed**:
  - `product_id`
  - `product_category_name`
  - `total_revenue`
  - `order_count`
- **Query**: 
  ```sql
  SELECT 
    product_id,
    product_category_name,
    total_revenue,
    order_count
  FROM public_marts.dim_products
  ORDER BY total_revenue DESC
  LIMIT 10
  ```

### 1.5 Geographic Distribution (Map/Bar Chart)
**Data Source**: `public_marts.revenue_metrics` (filtered) OR `public_marts.fct_orders`
- **Option A**: Use `revenue_metrics`
  - Filter: `dimension_type = 'state'`
  - X-axis: `dimension_value` (customer_state)
  - Y-axis: `revenue`
- **Option B**: Use `fct_orders` directly
  - Group by: `customer_state`
  - Aggregate: `SUM(total_revenue)`

---

## 2. Customer Analytics Dashboard

### 2.1 Customer Cohort Retention (Cohort Table)
**Data Source**: `public_marts.customer_metrics`
- **Key Columns**:
  - `customer_unique_id`
  - `cohort_month` (first order month)
  - `months_since_first_order`
  - `total_orders`
- **Additional Join**: May need `public_marts.fct_orders` for order dates
- **Note**: Metabase cohort analysis requires:
  - Cohort date: `cohort_month`
  - Period: `months_since_first_order`
  - Metric: `total_orders` or count of customers

### 2.2 CLV Distribution (Histogram)
**Data Source**: `public_marts.dim_customers`
- **Column**: `lifetime_value`
- **Query**: 
  ```sql
  SELECT lifetime_value 
  FROM public_marts.dim_customers
  WHERE lifetime_value > 0
  ```
- **Visualization**: Histogram with `lifetime_value` as the metric

### 2.3 New vs Returning Customers (Pie/Bar Chart)
**Data Source**: `public_marts.customer_metrics`
- **Column**: `is_repeat_customer` (boolean)
- **Query**:
  ```sql
  SELECT 
    CASE 
      WHEN is_repeat_customer = true THEN 'Returning'
      ELSE 'New'
    END as customer_type,
    COUNT(*) as customer_count
  FROM public_marts.customer_metrics
  GROUP BY is_repeat_customer
  ```

### 2.4 Customer Segmentation Breakdown (Bar Chart)
**Data Source**: `public_marts.dim_customers`
- **Column**: `customer_segment`
- **Query**:
  ```sql
  SELECT 
    customer_segment,
    COUNT(*) as customer_count
  FROM public_marts.dim_customers
  GROUP BY customer_segment
  ORDER BY customer_count DESC
  ```
- **Values**: `single_purchase`, `repeat_customer`, `loyal_customer`

---

## 3. Product Performance Dashboard

### 3.1 Best Selling Products (Bar Chart)
**Data Source**: `public_marts.product_metrics` OR `public_marts.dim_products`
- **Recommended**: Use `product_metrics` (has rankings)
- **Columns**:
  - `product_id`
  - `product_category_name`
  - `total_revenue` OR `order_count`
  - `revenue_rank`
- **Query**:
  ```sql
  SELECT 
    product_id,
    product_category_name,
    total_revenue,
    order_count
  FROM public_marts.product_metrics
  WHERE revenue_rank <= 20
  ORDER BY revenue_rank ASC
  ```

### 3.2 Worst Selling Products (Bar Chart)
**Data Source**: `public_marts.product_metrics`
- **Query**:
  ```sql
  SELECT 
    product_id,
    product_category_name,
    total_revenue,
    order_count
  FROM public_marts.product_metrics
  ORDER BY revenue_rank DESC
  LIMIT 20
  ```

### 3.3 Category Breakdown (Bar Chart)
**Data Source**: `public_marts.dim_products` (aggregated)
- **Query**:
  ```sql
  SELECT 
    product_category_name,
    COUNT(DISTINCT product_id) as product_count,
    SUM(total_revenue) as category_revenue,
    SUM(order_count) as category_orders
  FROM public_marts.dim_products
  GROUP BY product_category_name
  ORDER BY category_revenue DESC
  ```

### 3.4 Review Score vs Sales Correlation (Scatter Plot)
**Data Source**: `public_marts.dim_products`
- **X-axis**: `avg_review_score`
- **Y-axis**: `total_revenue` OR `order_count`
- **Query**:
  ```sql
  SELECT 
    product_id,
    product_category_name,
    avg_review_score,
    total_revenue,
    order_count
  FROM public_marts.dim_products
  WHERE avg_review_score IS NOT NULL
    AND total_revenue > 0
  ```

---

## 4. Operational Insights Dashboard

### 4.1 Delivery Performance by Region (Bar Chart)
**Data Source**: `public_marts.fct_orders` (joined with customer state)
- **Query**:
  ```sql
  SELECT 
    customer_state,
    AVG(total_delivery_time_days) as avg_delivery_days,
    AVG(delivery_delay_days) as avg_delay_days,
    COUNT(*) as order_count
  FROM public_marts.fct_orders
  WHERE total_delivery_time_days IS NOT NULL
  GROUP BY customer_state
  ORDER BY avg_delivery_days ASC
  ```
- **Columns**: `customer_state`, `total_delivery_time_days`, `delivery_delay_days`

### 4.2 Average Delivery Time Trend (Line Chart)
**Data Source**: `public_marts.fct_orders`
- **Query**:
  ```sql
  SELECT 
    DATE_TRUNC('month', order_date) as month,
    AVG(total_delivery_time_days) as avg_delivery_days
  FROM public_marts.fct_orders
  WHERE total_delivery_time_days IS NOT NULL
  GROUP BY DATE_TRUNC('month', order_date)
  ORDER BY month ASC
  ```
- **X-axis**: `month` (order_date grouped by month)
- **Y-axis**: `AVG(total_delivery_time_days)`

### 4.3 Seller Performance Metrics (Table)
**Data Source**: `public_marts.dim_sellers`
- **Columns**:
  - `seller_id`
  - `seller_city`
  - `seller_state`
  - `total_orders`
  - `total_revenue`
  - `unique_products_sold`
  - `avg_item_price`
  - `seller_tier`
- **Query**:
  ```sql
  SELECT 
    seller_id,
    seller_city,
    seller_state,
    total_orders,
    total_revenue,
    unique_products_sold,
    avg_item_price,
    seller_tier
  FROM public_marts.dim_sellers
  ORDER BY total_revenue DESC
  ```

### 4.4 Payment Method Distribution (Bar Chart)
**Data Source**: `public_marts.stg_order_payments` (in `public_staging` schema) OR join through fact table
- **Note**: Payment data is in staging. Need to join or query staging:
- **Query**:
  ```sql
  SELECT 
    payment_type,
    COUNT(*) as payment_count,
    SUM(payment_value) as total_payment_value
  FROM public_staging.stg_order_payments
  GROUP BY payment_type
  ORDER BY total_payment_value DESC
  ```
- **Alternative**: If you need order-level context, join with `fct_orders`:
  ```sql
  SELECT 
    op.payment_type,
    COUNT(DISTINCT op.order_id) as order_count,
    SUM(op.payment_value) as total_payment_value
  FROM public_staging.stg_order_payments op
  INNER JOIN public_marts.fct_orders fo ON op.order_id = fo.order_id
  GROUP BY op.payment_type
  ```

### 4.5 Order Status Funnel (Funnel Chart)
**Data Source**: `public_marts.fct_orders`
- **Query**:
  ```sql
  SELECT 
    order_status,
    COUNT(*) as order_count
  FROM public_marts.fct_orders
  GROUP BY order_status
  ORDER BY 
    CASE order_status
      WHEN 'created' THEN 1
      WHEN 'approved' THEN 2
      WHEN 'invoiced' THEN 3
      WHEN 'shipped' THEN 4
      WHEN 'delivered' THEN 5
      ELSE 6
    END
  ```
- **Columns**: `order_status`, count of `order_id`

---

## Quick Reference: Table Locations

| Table Name | Schema | Primary Use |
|------------|--------|-------------|
| `fct_orders` | `public_marts` | Order-level metrics, revenue, delivery |
| `fct_order_items` | `public_marts` | Item-level details |
| `dim_customers` | `public_marts` | Customer attributes, CLV, segments |
| `dim_products` | `public_marts` | Product catalog, performance |
| `dim_sellers` | `public_marts` | Seller performance |
| `dim_dates` | `public_marts` | Date dimension for time analysis |
| `revenue_metrics` | `public_marts` | Pre-aggregated revenue by dimension |
| `customer_metrics` | `public_marts` | Customer cohort and retention data |
| `product_metrics` | `public_marts` | Product rankings and performance |
| `stg_order_payments` | `public_staging` | Payment method data |

---

## Tips for Metabase

1. **Schema Qualification**: Always use `public_marts.table_name` or `public_staging.table_name`
2. **Date Grouping**: Use Metabase's built-in date grouping or `DATE_TRUNC()` in SQL
3. **Filters**: Add date range filters using `order_date` from `fct_orders`
4. **Joins**: Most metrics tables are pre-aggregated; joins usually only needed for payment data
5. **Performance**: All marts tables are materialized as tables (not views) for better performance
