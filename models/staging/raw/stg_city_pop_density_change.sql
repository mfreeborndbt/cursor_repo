{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from {{ source('raw', 'city_pop_density_change') }}
),

final as (
    select
        CITY as city,
        STATE as state,
        POPULATION_DENSITY_CHANGE as pop_density_change_pct
    from source
)

select * from final

