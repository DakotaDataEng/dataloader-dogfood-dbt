select
    cast(customer_id as int) as customer_id,
    cast(customer_name as string) as customer_name,
    cast(email as string) as email,
    cast(country as string) as country,
    cast(segment as string) as segment,
    cast(created_at as timestamp) as created_at,
    cast(modified_at as timestamp) as modified_at
from {{ source('dl_test', 'customers') }}
