-- intermediate model to determine  daily page views for each session and product 
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
, product_id
, DATE(created_at) AS created_day
, SUM(CASE WHEN event_type = 'page_view' THEN 1 ELSE 0 END) AS total_page_views
, SUM(CASE WHEN event_type = 'add_to_cart' THEN 1 ELSE 0 END) AS total_add_to_carts
FROM DEV_DB.DBT_ANIQUETRIPMOLLIECOM.STG_EVENTS AS events
GROUP BY 1,2,3


