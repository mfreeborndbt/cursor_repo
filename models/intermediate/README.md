# Intermediate Models

This folder contains intermediate models that perform transformations and aggregations on staging data before creating final mart models.

## Models

### int_zillow_city_yearly_avg

Aggregates Zillow home price data by city for comparison years:
- **2010**: Full year average (12 months)
- **2025**: Year-to-date average (10 months)

Each city in the dataset will have two columns:
- `avg_home_price_2010`: Average home price across all months in 2010
- `avg_home_price_2025`: Average home price across available months in 2025

This intermediate table can be used to calculate price changes, percentage increases, and other comparative metrics between these two time periods.

