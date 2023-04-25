-- mart model to determine and join daily statistics per product

{{ 
    config(
        materialized='table'
) 
}}

WITH orders_products AS (
    SELECT * FROM {{ ref('int_orders_products') }}
)

, event_types_products AS (
   SELECT * FROM {{ ref('int_event_types_products') }}
)

, products AS (
   SELECT * FROM {{ ref('stg_products') }}
)

SELECT 
event_types_products.product_id
, products.name
, event_types_products.created_day
, event_types_products.total_page_views
, event_types_products.total_add_to_carts
, orders_products.total_orders
, ROUND((total_orders) / (total_page_views),2) AS conversion_rate -- conversion rate of page views into orders
FROM event_types_products
LEFT JOIN orders_products 
    ON event_types_products.product_id = orders_products.product_id AND event_types_products.created_day = orders_products.created_day
LEFT JOIN products
    ON orders_products.product_id = products.product_id
