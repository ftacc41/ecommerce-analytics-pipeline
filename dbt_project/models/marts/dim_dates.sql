-- Purpose: Date dimension for time-based analysis
-- Materialization: table (for better performance in Metabase)
-- Generates date dimension for date range in the dataset

{{ config(materialized='table') }}

with date_spine as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2016-01-01' as date)",
        end_date="cast('2018-12-31' as date)"
    )}}
),

final as (
    select
        date_day as date_key,
        date_day,
        extract(year from date_day) as year,
        extract(quarter from date_day) as quarter,
        extract(month from date_day) as month,
        extract(week from date_day) as week,
        extract(day from date_day) as day,
        extract(dow from date_day) as day_of_week,
        extract(doy from date_day) as day_of_year,
        -- Month name
        to_char(date_day, 'Month') as month_name,
        -- Day name
        to_char(date_day, 'Day') as day_name,
        -- Quarter name
        'Q' || extract(quarter from date_day) as quarter_name,
        -- Fiscal year (assuming calendar year for simplicity)
        extract(year from date_day) as fiscal_year,
        -- Is weekend
        case when extract(dow from date_day) in (0, 6) then true else false end as is_weekend,
        -- Is month end
        case when date_day = date_trunc('month', date_day) + interval '1 month' - interval '1 day' then true else false end as is_month_end
    from date_spine
)

select * from final
