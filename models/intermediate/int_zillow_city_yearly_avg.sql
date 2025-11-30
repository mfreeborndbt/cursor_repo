{{
    config(
        materialized='table'
    )
}}

with zillow_data as (
    select * from {{ ref('stg_zillow_city_data') }}
),

filtered_years as (
    select
        city,
        state,
        year(price_date) as price_year,
        home_price
    from zillow_data
    where year(price_date) in (2010, 2025)
),

yearly_averages as (
    select
        city,
        state,
        price_year,
        avg(home_price) as avg_home_price
    from filtered_years
    group by
        city,
        state,
        price_year
),

final as (
    select
        city,
        state,
        max(case when price_year = 2010 then avg_home_price end) as avg_home_price_2010,
        max(case when price_year = 2025 then avg_home_price end) as avg_home_price_2025,
        ((max(case when price_year = 2025 then avg_home_price end) - 
          max(case when price_year = 2010 then avg_home_price end)) / 
          max(case when price_year = 2010 then avg_home_price end)) * 100 as home_value_pct_change
    from yearly_averages
    group by city, state
)

select * from final

