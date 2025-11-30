{{
    config(
        materialized='view'
    )
}}

with filtered_data as (
    select * from {{ ref('stg_zillow_city_data_filtered') }}
),

unpivoted as (
    {{
        dbt_utils.unpivot(
            relation=ref('stg_zillow_city_data_filtered'),
            cast_to='decimal(18,2)',
            exclude=['REGIONNAME', 'STATE', 'SIZERANK'],
            field_name='date_str',
            value_name='home_price'
        )
    }}
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
