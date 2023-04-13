 
SELECT
    event_id,
    session_id,
    user_id,
    order_id,
    product_id,
    page_url,
    created_at,
    event_type
FROM {{ source('postgres', 'events') }}