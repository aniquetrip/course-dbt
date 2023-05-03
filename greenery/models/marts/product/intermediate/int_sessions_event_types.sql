-- intermediate model to aggregate event types per session
{{ 
    config(
        materialized='table'
) 
}}

WITH events AS (
    SELECT * FROM {{ ref('stg_events') }}
)

SELECT
    session_id
    , MIN(DATE(created_at)) AS session_start_date
     {{ agg_event_types() }}
FROM events
GROUP BY 1