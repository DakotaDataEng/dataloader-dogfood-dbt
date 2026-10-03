-- One row per customer: their fields, order counts by status, order values and timing.
with orders as (
    select
        customer_id,
        count(*) as order_count,
        count_if(status = 'placed') as placed_orders,
        count_if(status = 'paid') as paid_orders,
        count_if(status = 'shipped') as shipped_orders,
        count_if(status = 'delivered') as delivered_orders,
        count_if(status = 'cancelled') as cancelled_orders,
        sum(amount) as total_order_amount,
        avg(amount) as avg_order_amount,
        min(placed_at) as first_placed_at,
        max(placed_at) as last_placed_at,
        sum(event_count) as event_count
    from {{ ref('int_order_lifecycle') }}
    group by customer_id
),

daily as (
    select
        customer_id,
        count(distinct order_date) as days_with_orders,
        max(order_date) as last_order_date
    from {{ ref('fct_daily_orders_by_customer') }}
    group by customer_id
)

select
    c.customer_id,
    c.customer_name,
    c.email,
    c.country,
    c.segment,
    c.created_at as customer_created_at,
    coalesce(o.order_count, 0) as order_count,
    coalesce(o.placed_orders, 0) as placed_orders,
    coalesce(o.paid_orders, 0) as paid_orders,
    coalesce(o.shipped_orders, 0) as shipped_orders,
    coalesce(o.delivered_orders, 0) as delivered_orders,
    coalesce(o.cancelled_orders, 0) as cancelled_orders,
    o.total_order_amount,
    o.avg_order_amount,
    o.first_placed_at,
    o.last_placed_at,
    coalesce(o.event_count, 0) as event_count,
    coalesce(d.days_with_orders, 0) as days_with_orders,
    d.last_order_date
from {{ ref('stg_customers') }} as c
left join orders as o
    on c.customer_id = o.customer_id
left join daily as d
    on c.customer_id = d.customer_id
