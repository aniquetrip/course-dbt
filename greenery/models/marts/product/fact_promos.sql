-- mart model to identify which promos have been given to specific orders and products

{{ 
    config(
        materialized='table'
) 
}}

WITH products_orders AS (
    SELECT * FROM {{ ref('int_products_orders') }}
)

, orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
)

, promos AS (
    SELECT * FROM {{ ref('stg_promos') }}
)

, products AS (
    SELECT * FROM {{ ref('stg_products') }}
)

SELECT products_orders.order_id
    , products_orders.product_id
    , orders.promo_id
    , promos.discount_amount
FROM products_orders
LEFT JOIN orders
ON products_orders.order_id = orders.order_id
LEFT JOIN promos
    ON orders.promo_id = promos.promo_id
LEFT JOIN products
    ON products_orders.product_id = products.product_id
WHERE event_type = 'add_to_cart'