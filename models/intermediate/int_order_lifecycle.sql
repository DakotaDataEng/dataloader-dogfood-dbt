-- One row per order, with the time of each lifecycle step its events carry.
with events as (
    select
        order_id,
        min(case when event_type = 'created' then event_at end) as placed_at,
        min(case when event_type = 'payment_received' then event_at end) as paid_at,
        min(case when event_type = 'shipped' then event_at end) as shipped_at,
        min(case when event_type = 'delivered' then event_at end) as delivered_at,
        max_by(event_type, event_at) as latest_event_type,
        max(event_at) as latest_event_at,
        count(*) as event_count
    from {{ ref('stg_order_events') }}
    group by order_id
)

select
    o.order_id,
    o.customer_id,
    o.order_date,
    o.status,
    o.amount,
    o.currency,
    e.placed_at,
    e.paid_at,
    e.shipped_at,
    e.delivered_at,
    e.latest_event_type,
    e.latest_event_at,
    coalesce(e.event_count, 0) as event_count
from {{ ref('stg_orders') }} as o
left join events as e
    on o.order_id = e.order_id
