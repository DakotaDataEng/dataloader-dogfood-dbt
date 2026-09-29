select
    cast(order_id as bigint) as order_id,
    cast(customer_id as int) as customer_id,
    cast(order_date as date) as order_date,
    cast(status as string) as status,
    cast(amount as decimal(18, 2)) as amount,
    cast(currency as string) as currency,
    cast(modified_at as timestamp) as modified_at
from {{ source('dl_test', 'orders') }}
