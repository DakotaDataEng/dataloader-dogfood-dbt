-- One row per customer, order date and currency.
select
    customer_id,
    order_date,
    currency,
    count(*) as orders,
    count_if(status = 'delivered') as delivered_orders,
    count_if(status = 'cancelled') as cancelled_orders,
    sum(amount) as total_amount
from {{ ref('stg_orders') }}
group by customer_id, order_date, currency
