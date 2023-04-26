-- mart model to determine overall stats
{{ 
    config(
        materialized='table'
) 
}}

WITH products_orders AS (
   SELECT * FROM {{ ref('int_products_orders') }}
)

SELECT COUNT(DISTINCT order_id) / COUNT(DISTINCT session_id) AS conversion_rate -- conversion rate of page views into orders
FROM products_orders

