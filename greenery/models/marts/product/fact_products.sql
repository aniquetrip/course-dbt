-- mart model to determine and join daily statistics per product

{{ 
    config(
        materialized='table'
) 
}}

WITH products_orders AS (
    SELECT * FROM {{ ref('int_products_orders') }}
)

, products_event_types AS (
   SELECT * FROM {{ ref('int_products_event_types') }}
)

, products AS (
   SELECT * FROM {{ ref('stg_products') }}
)

, orders_per_product AS (
   SELECT 
     product_id
     , COUNT(DISTINCT order_id) AS total_orders
   FROM int_products_orders
   GROUP BY 1 
)

SELECT 
    products_event_types.product_id
    , products.name
    , products_event_types.total_page_views
    , products_event_types.total_add_to_carts
    , orders_per_product.total_orders
    , ROUND((total_orders) / (total_page_views),2) AS conversion_rate -- conversion rate of page views into orders
FROM products_event_types
LEFT JOIN orders_per_product 
    ON products_event_types.product_id = orders_per_product.product_id 
LEFT JOIN products
    ON orders_per_product.product_id = products.product_id
