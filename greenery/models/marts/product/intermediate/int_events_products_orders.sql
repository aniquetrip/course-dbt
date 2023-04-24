-- intermediate model to determine which products belong to which order

{{ 
    config(
        materialized='table'
) 
}}

WITH events AS (
    SELECT * FROM {{ ref('stg_events') }}
)

--determine for each session what the order was (if any)
, orders_sessions AS (
SELECT 
    DISTINCT(session_id) AS session_id
    , order_id
FROM DEV_DB.DBT_ANIQUETRIPMOLLIECOM.STG_EVENTS      
WHERE order_id is not null
ORDER BY session_id
)

--
SELECT 
    events.* EXCLUDE(order_id) 
    , orders_sessions.* EXCLUDE (session_id)
FROM DEV_DB.DBT_ANIQUETRIPMOLLIECOM.STG_EVENTS AS events 
LEFT JOIN orders_sessions
    ON events.session_id = orders_sessions.session_id