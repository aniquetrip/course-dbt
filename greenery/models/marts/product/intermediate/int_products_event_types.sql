-- intermediate model to aggregate event types per product
{{ 
    config(
        materialized='table'
) 
}}

WITH products_orders AS (
    SELECT * FROM {{ ref('int_products_orders') }}
)

SELECT
    product_id
    , DATE(created_at) AS created_day
     {{ agg_event_types() }}
FROM products_orders
GROUP BY 1,2