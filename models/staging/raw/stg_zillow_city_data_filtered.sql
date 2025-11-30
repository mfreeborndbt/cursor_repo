{{
    config(
        materialized='view'
    )
}}

with source as (
    select * 
    from {{ source('raw', 'zillow_city_data') }}
),

filtered as (
    select
        REGIONNAME,
        STATE,
        SIZERANK,
        -- Select only 2010 and 2025 date columns
        "2010-01-31", "2010-02-28", "2010-03-31", "2010-04-30", "2010-05-31", "2010-06-30",
        "2010-07-31", "2010-08-31", "2010-09-30", "2010-10-31", "2010-11-30", "2010-12-31",
        "2025-01-31", "2025-02-28", "2025-03-31", "2025-04-30", "2025-05-31", "2025-06-30",
        "2025-07-31", "2025-08-31", "2025-09-30", "2025-10-31"
    from source
    where SIZERANK <= 150
        and REGIONNAME != 'Rochester'
)

select * from filtered
