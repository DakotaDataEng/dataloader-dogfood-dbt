{{ config(materialized='incremental', unique_key='event_id', on_schema_change='append_new_columns') }}
-- One row per order event. Each run adds the events at or after the latest one already loaded; the merge on event_id keeps them unique.
select
    event_id,
    order_id,
    event_type,
    event_at,
    note
from {{ ref('stg_order_events') }}
{% if is_incremental() %}
where event_at >= (select max(event_at) from {{ this }})
{% endif %}
