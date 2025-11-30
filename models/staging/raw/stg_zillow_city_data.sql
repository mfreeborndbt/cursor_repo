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
        COUNTYNAME as county_name,
        METRO as metro,
        REGIONID as region_id,
        REGIONNAME as region_name,
        REGIONTYPE as region_type,
        SIZERANK as size_rank,
        STATE as state_code,
        STATENAME as state_name,
        to_date(date_str, 'YYYY-MM-DD') as price_date,
        home_price
    from unpivoted
    where home_price is not null
)

select * from final

