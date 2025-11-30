{{
    config(
        materialized='table'
    )
}}

with zillow_yearly as (
    select * from {{ ref('int_zillow_city_yearly_avg') }}
),

pop_density as (
    select * from {{ ref('stg_city_pop_density_change') }}
),

final as (
    select
        z.city,
        z.state,
        z.avg_home_price_2010,
        z.avg_home_price_2025,
        p.pop_density_change_pct
    from zillow_yearly z
    inner join pop_density p
        on z.city = p.city
)

select * from final

