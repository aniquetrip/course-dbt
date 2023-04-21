-- mart model to identify daily statistics per product

{{ 
    config(
        materialized='table'
) 
}}

WITH events_session_orders AS (
    SELECT * FROM {{ ref('int_events_sessions_orders') }}
)

, events_sessions_products AS (
   SELECT * FROM {{ ref('int_events_sessions_products') }}
)

-- joining these together so we can determine which page views resulted in an order
, combined AS (
SELECT 
    events_sessions_products.*
    , CASE WHEN total_add_to_carts = 0 THEN 0 ELSE total_orders END AS total_orders
FROM events_sessions_products
LEFT JOIN events_session_orders
ON events_sessions_products.session_id = events_session_orders.session_id AND events_sessions_products.created_day = events_session_orders.created_day 
WHERE events_sessions_products.product_id is not null
)

-- aggregate and define metrics per day per product 

SELECT 
combined.product_id
, products.name
, created_day
, SUM(total_page_views) AS total_page_views
, SUM(total_add_to_carts) AS total_add_to_carts
, SUM(total_orders) AS total_orders
, ROUND(SUM(total_orders) / SUM(total_page_views),2) AS conversion_rate --this is the conversion rate of page views into orders
FROM combined
LEFT JOIN DEV_DB.DBT_ANIQUETRIPMOLLIECOM.STG_PRODUCTS AS products
ON combined.product_id = products.product_id
GROUP BY 1,2, 3
order by product_id, created_day
