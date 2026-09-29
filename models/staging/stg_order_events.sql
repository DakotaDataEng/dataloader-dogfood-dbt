select
    cast(event_id as int) as event_id,
    cast(order_id as bigint) as order_id,
    cast(event_type as string) as event_type,
    cast(event_at as timestamp) as event_at,
    cast(note as string) as note
from {{ source('dl_test', 'order_events') }}
