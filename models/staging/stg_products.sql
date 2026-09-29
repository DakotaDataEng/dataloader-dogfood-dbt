select
    cast(product_code as string) as product_code,
    cast(product_name as string) as product_name,
    cast(category as string) as category,
    cast(list_price as decimal(19, 4)) as list_price,
    cast(is_active as boolean) as is_active,
    cast(updated_at as timestamp) as updated_at
from {{ source('dl_test', 'products') }}
