# dataloader-dogfood-dbt

A small dbt project that DataLoader's internal instance runs over its own test tables.
It exists to show dbt runs, the asset graph and automation conditions working on real data.

**Every table here is invented test data.** Nothing in this repository or in the tables it reads is real.

## What is in it

- `models/sources.yml`: the source `dl_test` (`dataloader_v2_dogfood.dl_test`) with `customers`, `orders`, `order_events` and `products`. `orders` has a freshness check on `modified_at` (warn after 26 hours, error after 50).
- `models/staging/`: one view per source table. They cast types and rename nothing else, with no business logic.
- `models/marts/fct_daily_orders_by_customer.sql`: a table with orders, delivered orders, cancelled orders and total amount per customer, order date and currency.
- `models/intermediate/int_order_lifecycle.sql`: a view with one row per order, joining `stg_orders` to `stg_order_events`. It carries a timestamp for each lifecycle step, the latest event and the event count.
- `models/marts/mart_customer_360.sql`: a table with one row per customer. Order counts by status, order amounts, first and last order times and days with orders.
- Tests in each `schema.yml`: unique and not null on keys, relationships (orders to customers, order events to orders), and accepted values for `status`, `event_type`, `currency`, `country` and `segment`.

## Layers and the fan-in

Four source tables feed four staging views. Three of them meet in `mart_customer_360`:

```
customers    -> stg_customers ------------------------------------+
orders       -> stg_orders -+-> int_order_lifecycle ---------------+-> mart_customer_360
order_events -> stg_order_events -+                                |
                    stg_orders ---> fct_daily_orders_by_customer --+
products     -> stg_products   (no key links it to orders or customers)
```

`products` has no column that ties it to an order or a customer, so it stays a standalone branch.

Models build into the schema `dl_dbt`, which comes from the project's target in DataLoader.

## How DataLoader runs it

The instance loads the four source tables from a SQL Server sandbox into Databricks once a day at 06:00 America/Denver.
The project is added in DataLoader under Connections, dbt projects, with this repository's URL and the branch `main`.
The repository is public, so no credential is needed.
DataLoader syncs the project from this repository and generates the dbt profile from the destination the target is mapped to.

There is no `profiles.yml` here, on purpose. DataLoader writes the profile (named `dataloader`) for each run, so no host, path or secret is stored in the repository.
The project has no packages, so `dbt deps` needs no network.

To run it yourself, create your own `profiles.yml` with a profile named `dataloader` that points at a Databricks catalog holding the four tables.
