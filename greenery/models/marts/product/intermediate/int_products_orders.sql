-- intermediate model to determine which products belong to which order

{{ 
    config(
        materialized='table'
) 
}}

WITH events AS (
    SELECT * FROM {{ ref('stg_events') }}
)

, order_items as (
    SELECT * FROM {{ ref('stg_order_items')}}
)


SELECT 
    events.* EXCLUDE (order_id, product_id)
    , order_items.* EXCLUDE (order_id, product_id)
    , COALESCE(events.order_id, order_items.order_id) AS order_id
    , COALESCE(events.product_id, order_items.product_id) AS product_id
FROM events
LEFT JOIN order_items
    ON events.order_id = order_items.order_id


