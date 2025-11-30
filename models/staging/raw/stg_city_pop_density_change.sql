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
        -- Clean the percentage value: remove '%', '!', and other non-numeric characters, then convert to number
        try_cast(
            regexp_replace(POPULATION_DENSITY_CHANGE, '[^0-9.-]', '') 
            as decimal(10,2)
        ) as pop_density_change_pct
    from source
)

select * from final

