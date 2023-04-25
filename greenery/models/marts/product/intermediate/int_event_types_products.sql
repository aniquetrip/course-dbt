-- intermediate model to aggregate daily event types per product
{{ 
    config(
        materialized='table'
) 
}}

WITH events AS (
    SELECT * FROM {{ ref('stg_events') }}
)

SELECT
    product_id
    , DATE(created_at) AS created_day
    {{ agg_event_types() }}
FROM events
GROUP BY 1,2