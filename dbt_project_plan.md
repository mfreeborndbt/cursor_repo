# TPC-H Data Pipeline Implementation Plan

## Instructions

Execute every step in order. Create all files exactly as shown. Use `dbtf` (dbt Fusion) for all CLI commands — never `dbt`. The `sources.yml` and `packages.yml` are already in place. Run `dbtf build` at the end to build and test everything.

---

## Step 1: Create Staging Models

All files go in `models/staging/tpch/`.

### Create `models/staging/tpch/stg_tpch_customers.sql`

```sql
with source as (
    select * from {{ source('tpch', 'customer') }}
),

renamed as (
    select
        c_custkey as customer_key,
        c_name as customer_name,
        c_address as address,
        c_nationkey as nation_key,
        c_phone as phone_number,
        c_acctbal as account_balance,
        c_mktsegment as market_segment,
        c_comment as comment
    from source
)

select * from renamed
```

### Create `models/staging/tpch/stg_tpch_nations.sql`

```sql
with source as (
    select * from {{ source('tpch', 'nation') }}
),

renamed as (
    select
        n_nationkey as nation_key,
        n_name as nation_name,
        n_regionkey as region_key,
        n_comment as comment
    from source
)

select * from renamed
```

### Create `models/staging/tpch/stg_tpch_regions.sql`

```sql
with source as (
    select * from {{ source('tpch', 'region') }}
),

renamed as (
    select
        r_regionkey as region_key,
        r_name as region_name,
        r_comment as comment
    from source
)

select * from renamed
```

### Create `models/staging/tpch/stg_tpch_orders.sql`

```sql
with source as (
    select * from {{ source('tpch', 'orders') }}
),

renamed as (
    select
        o_orderkey as order_key,
        o_custkey as customer_key,
        o_orderstatus as order_status,
        o_totalprice as total_price,
        o_orderdate as order_date,
        o_orderpriority as order_priority,
        o_clerk as clerk,
        o_shippriority as ship_priority,
        o_comment as comment
    from source
)

select * from renamed
```

### Create `models/staging/tpch/stg_tpch_order_items.sql`

```sql
with source as (
    select * from {{ source('tpch', 'lineitem') }}
),

renamed as (
    select
        l_orderkey as order_key,
        l_partkey as part_key,
        l_suppkey as supplier_key,
        l_linenumber as line_number,
        l_quantity as quantity,
        l_extendedprice as extended_price,
        l_discount as discount,
        l_tax as tax,
        l_returnflag as return_flag,
        l_linestatus as line_status,
        l_shipdate as ship_date,
        l_commitdate as commit_date,
        l_receiptdate as receipt_date,
        l_shipinstruct as ship_instructions,
        l_shipmode as ship_mode,
        l_comment as comment
    from source
)

select * from renamed
```

### Create `models/staging/tpch/stg_tpch_part_suppliers.sql`

```sql
with source as (
    select * from {{ source('tpch', 'partsupp') }}
),

renamed as (
    select
        ps_partkey as part_key,
        ps_suppkey as supplier_key,
        ps_availqty as available_quantity,
        ps_supplycost as supply_cost,
        ps_comment as comment
    from source
)

select * from renamed
```

### Create `models/staging/tpch/stg_tpch_parts.sql`

```sql
with source as (
    select * from {{ source('tpch', 'part') }}
),

renamed as (
    select
        p_partkey as part_key,
        p_name as part_name,
        p_mfgr as manufacturer,
        p_brand as brand,
        p_type as part_type,
        p_size as part_size,
        p_container as container,
        p_retailprice as retail_price,
        p_comment as comment
    from source
)

select * from renamed
```

### Create `models/staging/tpch/stg_tpch_suppliers.sql`

```sql
with source as (
    select * from {{ source('tpch', 'supplier') }}
),

renamed as (
    select
        s_suppkey as supplier_key,
        s_name as supplier_name,
        s_address as address,
        s_nationkey as nation_key,
        s_phone as phone_number,
        s_acctbal as account_balance,
        s_comment as comment
    from source
)

select * from renamed
```

### Create `models/staging/tpch/_tpch__models.yml`

```yaml
version: 2

models:
  - name: stg_tpch_customers
    description: "Staged customer records from TPC-H, one row per customer"
    columns:
      - name: customer_key
        description: "Primary key - unique customer identifier"
        tests:
          - unique
          - not_null

  - name: stg_tpch_nations
    description: "Staged nation reference records from TPC-H"
    columns:
      - name: nation_key
        description: "Primary key - unique nation identifier"
        tests:
          - unique
          - not_null

  - name: stg_tpch_regions
    description: "Staged region reference records from TPC-H"
    columns:
      - name: region_key
        description: "Primary key - unique region identifier"
        tests:
          - unique
          - not_null

  - name: stg_tpch_orders
    description: "Staged order header records from TPC-H, one row per order"
    columns:
      - name: order_key
        description: "Primary key - unique order identifier"
        tests:
          - unique
          - not_null

  - name: stg_tpch_order_items
    description: "Staged order line item records from TPC-H LINEITEM table"
    columns:
      - name: order_key
        description: "Foreign key to orders"
        tests:
          - not_null
      - name: line_number
        description: "Line number within an order"
        tests:
          - not_null
    tests:
      - dbt_utils.unique_combination_of_columns:
          arguments:
            combination_of_columns:
              - order_key
              - line_number

  - name: stg_tpch_part_suppliers
    description: "Staged part-supplier relationship records from TPC-H"
    columns:
      - name: part_key
        description: "Foreign key to parts"
        tests:
          - not_null
      - name: supplier_key
        description: "Foreign key to suppliers"
        tests:
          - not_null
    tests:
      - dbt_utils.unique_combination_of_columns:
          arguments:
            combination_of_columns:
              - part_key
              - supplier_key

  - name: stg_tpch_parts
    description: "Staged part/product records from TPC-H"
    columns:
      - name: part_key
        description: "Primary key - unique part identifier"
        tests:
          - unique
          - not_null

  - name: stg_tpch_suppliers
    description: "Staged supplier records from TPC-H"
    columns:
      - name: supplier_key
        description: "Primary key - unique supplier identifier"
        tests:
          - unique
          - not_null
```

---

## Step 2: Create Intermediate Models

Create directory `models/intermediate/` if it doesn't exist.

### Create `models/intermediate/int_dim_customers.sql`

```sql
with customers as (
    select * from {{ ref('stg_tpch_customers') }}
),

nations as (
    select * from {{ ref('stg_tpch_nations') }}
),

regions as (
    select * from {{ ref('stg_tpch_regions') }}
),

joined as (
    select
        customers.customer_key,
        customers.customer_name,
        customers.address,
        customers.phone_number,
        customers.account_balance,
        customers.market_segment,
        nations.nation_name,
        regions.region_name
    from customers
    left join nations on customers.nation_key = nations.nation_key
    left join regions on nations.region_key = regions.region_key
)

select * from joined
```

### Create `models/intermediate/int_order_items.sql`

```sql
with order_items as (
    select * from {{ ref('stg_tpch_order_items') }}
),

orders as (
    select * from {{ ref('stg_tpch_orders') }}
),

parts as (
    select * from {{ ref('stg_tpch_parts') }}
),

joined as (
    select
        order_items.order_key,
        order_items.line_number,
        orders.customer_key,
        orders.order_date,
        orders.order_status,
        order_items.part_key,
        parts.part_name,
        parts.part_type,
        parts.manufacturer,
        parts.brand,
        order_items.supplier_key,
        order_items.quantity,
        order_items.extended_price,
        order_items.discount,
        order_items.tax,
        order_items.extended_price * (1 - order_items.discount) as discounted_price,
        order_items.extended_price * (1 - order_items.discount) * (1 + order_items.tax) as gross_amount,
        order_items.ship_date,
        order_items.ship_mode,
        order_items.return_flag,
        order_items.line_status
    from order_items
    inner join orders on order_items.order_key = orders.order_key
    left join parts on order_items.part_key = parts.part_key
)

select * from joined
```

### Create `models/intermediate/_int__models.yml`

```yaml
version: 2

models:
  - name: int_dim_customers
    description: "Customer dimension enriched with nation and region names"
    columns:
      - name: customer_key
        description: "Primary key - unique customer identifier"
        tests:
          - unique
          - not_null

  - name: int_order_items
    description: "Order line items enriched with order header and part details, including calculated gross amounts"
    columns:
      - name: order_key
        description: "Foreign key to orders"
        tests:
          - not_null
      - name: line_number
        description: "Line number within an order"
        tests:
          - not_null
    tests:
      - dbt_utils.unique_combination_of_columns:
          arguments:
            combination_of_columns:
              - order_key
              - line_number
```

---

## Step 3: Create Mart Models

Create directory `models/marts/` if it doesn't exist.

### Create `models/marts/fct_order_items.sql`

```sql
with order_items as (
    select * from {{ ref('int_order_items') }}
),

part_suppliers as (
    select * from {{ ref('stg_tpch_part_suppliers') }}
),

final as (
    select
        order_items.order_key,
        order_items.line_number,
        order_items.customer_key,
        order_items.order_date,
        order_items.order_status,
        order_items.part_key,
        order_items.part_name,
        order_items.supplier_key,
        order_items.quantity,
        order_items.extended_price,
        order_items.discount,
        order_items.tax,
        order_items.discounted_price,
        order_items.gross_amount,
        part_suppliers.supply_cost,
        order_items.quantity * part_suppliers.supply_cost as total_cost,
        order_items.discounted_price - (order_items.quantity * part_suppliers.supply_cost) as profit,
        order_items.ship_date,
        order_items.ship_mode,
        order_items.return_flag,
        order_items.line_status
    from order_items
    left join part_suppliers
        on order_items.part_key = part_suppliers.part_key
        and order_items.supplier_key = part_suppliers.supplier_key
)

select * from final
```

### Create `models/marts/fct_monthly_gross_revenue.sql`

```sql
with order_items as (
    select * from {{ ref('fct_order_items') }}
),

customers as (
    select * from {{ ref('int_dim_customers') }}
),

monthly_revenue as (
    select
        date_trunc('month', order_items.order_date) as order_month,
        customers.customer_key,
        customers.customer_name,
        customers.nation_name,
        customers.region_name,
        customers.market_segment,
        sum(order_items.gross_amount) as gross_revenue,
        sum(order_items.discounted_price) as net_revenue,
        sum(order_items.total_cost) as total_cost,
        sum(order_items.profit) as total_profit,
        count(distinct order_items.order_key) as order_count,
        sum(order_items.quantity) as total_quantity
    from order_items
    inner join customers on order_items.customer_key = customers.customer_key
    group by 1, 2, 3, 4, 5, 6
)

select * from monthly_revenue
```

### Create `models/marts/_marts__models.yml`

```yaml
version: 2

models:
  - name: fct_order_items
    description: "Fact table of order line items with supply cost and profit calculations"
    columns:
      - name: order_key
        description: "Foreign key to orders"
        tests:
          - not_null
      - name: line_number
        description: "Line number within an order"
        tests:
          - not_null
    tests:
      - dbt_utils.unique_combination_of_columns:
          arguments:
            combination_of_columns:
              - order_key
              - line_number

  - name: fct_monthly_gross_revenue
    description: "Monthly gross revenue aggregated by customer with regional context"
    columns:
      - name: order_month
        description: "Truncated month of the order"
        tests:
          - not_null
      - name: customer_key
        description: "Foreign key to customer"
        tests:
          - not_null
    tests:
      - dbt_utils.unique_combination_of_columns:
          arguments:
            combination_of_columns:
              - order_month
              - customer_key
```

---

## Step 4: Build and Validate

Run the full build (models + tests + project evaluator):

```bash
dbtf build
```

Expected result: 112 tasks, all passing. 55 models, 56 tests, 1 seed.

Then spot-check data quality:

```bash
dbtf show --inline "select count(*) as row_count from {{ ref('fct_order_items') }}"
dbtf show --inline "select count(*) as row_count from {{ ref('fct_monthly_gross_revenue') }}"
dbtf show --inline "select order_month, round(sum(gross_revenue), 2) as total_revenue from {{ ref('fct_monthly_gross_revenue') }} group by 1 order by 1 limit 5"
```

Expected: ~60K order items, ~13.6K monthly revenue rows, ~$25-30M/month revenue.
