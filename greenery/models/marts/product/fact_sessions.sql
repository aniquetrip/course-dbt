-- mart model to determine overall stats
{{ 
    config(
        materialized='table'
) 
}}

WITH products_orders AS (
   SELECT * FROM {{ ref('int_products_orders') }}
)

SELECT
    session_id
     {{ agg_event_types() }}
FROM products_orders
GROUP BY 1

-- SELECT COUNT(DISTINCT CASE WHEN TOTAL_CHECKOUTS > 0 THEN session_id END) AS count_checkouts
--         , COUNT(DISTINCT session_id) AS count_sessions
--         , count_checkouts/count_sessions AS conversion_rate
-- FROM DEV_DB.DBT_ANIQUETRIPMOLLIECOM.FACT_SESSIONS
