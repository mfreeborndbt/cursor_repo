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

joined as (
    select
        z.city,
        z.state,
        z.avg_home_price_2010,
        z.avg_home_price_2025,
        z.home_value_pct_change,
        p.pop_density_change_pct
    from zillow_yearly z
    inner join pop_density p
        on z.city = p.city
),

normalized as (
    select
        city,
        state,
        avg_home_price_2010,
        avg_home_price_2025,
        home_value_pct_change,
        pop_density_change_pct,
        -- Normalize home value percent change (0-1 scale)
        case 
            when max(home_value_pct_change) over() - min(home_value_pct_change) over() = 0 then 0
            else (home_value_pct_change - min(home_value_pct_change) over()) / 
                 nullif(max(home_value_pct_change) over() - min(home_value_pct_change) over(), 0)
        end as home_value_pct_change_normalized,
        -- Normalize population density percent change (0-1 scale)
        case 
            when max(pop_density_change_pct) over() - min(pop_density_change_pct) over() = 0 then 0
            else (pop_density_change_pct - min(pop_density_change_pct) over()) / 
                 nullif(max(pop_density_change_pct) over() - min(pop_density_change_pct) over(), 0)
        end as pop_density_pct_change_normalized
    from joined
)

select * from normalized

