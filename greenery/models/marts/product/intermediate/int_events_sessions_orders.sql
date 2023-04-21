-- intermediate model to determine daily orders per session

{{ 
    config(
        materialized='table'
) 
}}

WITH events AS (
    SELECT * FROM {{ ref('stg_events') }}
)

--need to determine only for checkout (not looking at order_id) otherwise we might duplicate orders when the sam order is checked out on one day and shipped on another day 
SELECT 
    session_id
    , DATE(created_at) AS created_day
    , COUNT(DISTINCT CASE WHEN event_type = 'checkout' THEN order_id END) AS total_orders
FROM events
GROUP BY 1, 2
