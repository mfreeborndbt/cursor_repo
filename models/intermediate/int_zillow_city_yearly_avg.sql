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
        region_name,
        state_code,
        state_name,
        county_name,
        metro,
        region_id,
        region_type,
        size_rank,
        year(price_date) as price_year,
        home_price
    from zillow_data
    where year(price_date) in (2010, 2025)
),

yearly_averages as (
    select
        region_name,
        state_code,
        state_name,
        county_name,
        metro,
        region_id,
        region_type,
        size_rank,
        price_year,
        avg(home_price) as avg_home_price
    from filtered_years
    group by
        region_name,
        state_code,
        state_name,
        county_name,
        metro,
        region_id,
        region_type,
        size_rank,
        price_year
),

final as (
    select
        region_name,
        state_code,
        state_name,
        county_name,
        metro,
        region_id,
        region_type,
        size_rank,
        max(case when price_year = 2010 then avg_home_price end) as avg_home_price_2010,
        max(case when price_year = 2025 then avg_home_price end) as avg_home_price_2025
    from yearly_averages
    group by
        region_name,
        state_code,
        state_name,
        county_name,
        metro,
        region_id,
        region_type,
        size_rank
)

select * from final

