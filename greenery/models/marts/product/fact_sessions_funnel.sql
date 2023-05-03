-- mart model to determine overall stats
{{ 
    config(
        materialized='table'
) 
}}

WITH sessions_event_types AS (
   SELECT * FROM {{ ref('int_sessions_event_types') }}
)


SELECT *
FROM sessions_event_types


-- SELECT COUNT(DISTINCT CASE WHEN TOTAL_CHECKOUTS > 0 THEN session_id END) AS count_checkouts
--         , COUNT(DISTINCT session_id) AS count_sessions
--         , count_checkouts/count_sessions AS conversion_rate
-- FROM DEV_DB.DBT_ANIQUETRIPMOLLIECOM.FACT_SESSIONS
