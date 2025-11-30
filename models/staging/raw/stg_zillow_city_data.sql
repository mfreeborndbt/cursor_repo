{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from {{ ref('stg_zillow_city_data_filtered') }}
),

unpivoted as (
    select REGIONNAME, STATE, SIZERANK, '2010-01-31' as date_str, "2010-01-31" as home_price from source
    union all
    select REGIONNAME, STATE, SIZERANK, '2010-02-28' as date_str, "2010-02-28" as home_price from source
    union all
    select REGIONNAME, STATE, SIZERANK, '2010-03-31' as date_str, "2010-03-31" as home_price from source
    union all
    select REGIONNAME, STATE, SIZERANK, '2010-04-30' as date_str, "2010-04-30" as home_price from source
    union all
    select REGIONNAME, STATE, SIZERANK, '2010-05-31' as date_str, "2010-05-31" as home_price from source
    union all
    select REGIONNAME, STATE, SIZERANK, '2010-06-30' as date_str, "2010-06-30" as home_price from source
    union all
    select REGIONNAME, STATE, SIZERANK, '2010-07-31' as date_str, "2010-07-31" as home_price from source
    union all
    select REGIONNAME, STATE, SIZERANK, '2010-08-31' as date_str, "2010-08-31" as home_price from source
    union all
    select REGIONNAME, STATE, SIZERANK, '2010-09-30' as date_str, "2010-09-30" as home_price from source
    union all
    select REGIONNAME, STATE, SIZERANK, '2010-10-31' as date_str, "2010-10-31" as home_price from source
    union all
    select REGIONNAME, STATE, SIZERANK, '2010-11-30' as date_str, "2010-11-30" as home_price from source
    union all
    select REGIONNAME, STATE, SIZERANK, '2010-12-31' as date_str, "2010-12-31" as home_price from source
    union all
    select REGIONNAME, STATE, SIZERANK, '2025-01-31' as date_str, "2025-01-31" as home_price from source
    union all
    select REGIONNAME, STATE, SIZERANK, '2025-02-28' as date_str, "2025-02-28" as home_price from source
    union all
    select REGIONNAME, STATE, SIZERANK, '2025-03-31' as date_str, "2025-03-31" as home_price from source
    union all
    select REGIONNAME, STATE, SIZERANK, '2025-04-30' as date_str, "2025-04-30" as home_price from source
    union all
    select REGIONNAME, STATE, SIZERANK, '2025-05-31' as date_str, "2025-05-31" as home_price from source
    union all
    select REGIONNAME, STATE, SIZERANK, '2025-06-30' as date_str, "2025-06-30" as home_price from source
    union all
    select REGIONNAME, STATE, SIZERANK, '2025-07-31' as date_str, "2025-07-31" as home_price from source
    union all
    select REGIONNAME, STATE, SIZERANK, '2025-08-31' as date_str, "2025-08-31" as home_price from source
    union all
    select REGIONNAME, STATE, SIZERANK, '2025-09-30' as date_str, "2025-09-30" as home_price from source
    union all
    select REGIONNAME, STATE, SIZERANK, '2025-10-31' as date_str, "2025-10-31" as home_price from source
),

final as (
    select
        REGIONNAME as city,
        STATE as state,
        to_date(date_str, 'YYYY-MM-DD') as price_date,
        home_price
    from unpivoted
    where home_price is not null
)

select * from final
