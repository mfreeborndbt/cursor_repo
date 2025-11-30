# RAW Schema Staging Models

This directory contains staging models for the RAW schema in the MILES_F_CURSOR database.

## Sources

The `sources.yml` file defines two source tables:
- `zillow_city_data`: Zillow home price data by city with monthly price points
- `city_pop_density_change`: City population density change data

## Models

### stg_zillow_city_data

This model unpivots the wide-format Zillow data into a long format using the `dbt_utils.unpivot()` macro.

**Input format:** Columns like `2000-01-31`, `2000-02-29`, etc. containing home prices
**Output format:** Two columns - `price_date` and `home_price` with one row per date/region combination

**Static columns (preserved):**
- COUNTYNAME → county_name
- METRO → metro
- REGIONID → region_id
- REGIONNAME → region_name
- REGIONTYPE → region_type
- SIZERANK → size_rank
- STATE → state_code
- STATENAME → state_name

**Unpivoted columns:**
- All date columns (YYYY-MM-DD format) → price_date
- Values from date columns → home_price (cast to decimal(18,2))

### stg_city_pop_density_change

This model provides a basic staging layer for the city population density change data.

## Usage

Before running these models for the first time, install the required packages:

```bash
dbt deps
```

Then compile or run the models:

```bash
dbt run --select stg_zillow_city_data
dbt run --select stg_city_pop_density_change
```

## Dependencies

- `dbt_utils` package (defined in `packages.yml`)

