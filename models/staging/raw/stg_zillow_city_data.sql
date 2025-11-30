{{
    config(
        materialized='view'
    )
}}

with unpivoted as (
    {{
        dbt_utils.unpivot(
            relation=source('raw', 'zillow_city_data'),
            cast_to='decimal(18,2)',
            exclude=['COUNTYNAME', 'METRO', 'REGIONID', 'REGIONNAME', 'REGIONTYPE', 'SIZERANK', 'STATE', 'STATENAME'],
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
        and SIZERANK <= 150
)

select * from final
