-- mart model to determine and join daily statistics per product

{{ 
    config(
        materialized='table'
) 
}}

WITH orders_products AS (
    SELECT * FROM {{ ref('int_orders_products') }}
)

, page_views_products AS (
   SELECT * FROM {{ ref('int_page_views_products') }}
)

, products AS (
   SELECT * FROM {{ ref('stg_products') }}
)

SELECT 
page_views_products.product_id
, products.name
, page_views_products.created_day
, page_views_products.total_page_views
, page_views_products.total_add_to_carts
, orders_products.total_orders
, ROUND((total_orders) / (total_page_views),2) AS conversion_rate -- conversion rate of page views into orders
FROM page_views_products
LEFT JOIN orders_products 
    ON page_views_products.product_id = orders_products.product_id AND page_views_products.created_day = orders_products.created_day
LEFT JOIN products
    ON orders_products.product_id = products.product_id
