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
        *
    from source
)

select * from final

