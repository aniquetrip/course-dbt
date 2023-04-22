-- mart model to identify which promos have been given to specific orders and products

{{ 
    config(
        materialized='table'
) 
}}

WITH events_products_orders AS (
    SELECT * FROM {{ ref('int_events_products_orders') }}
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

SELECT events_products_orders.order_id
    , events_products_orders.product_id
    , orders.promo_id
    , promos.discount_amount
FROM events_products_orders
LEFT JOIN orders
ON events_products_orders.order_id = orders.order_id
LEFT JOIN promos
    ON orders.promo_id = promos.promo_id
LEFT JOIN products
    ON events_products_orders.product_id = products.product_id
WHERE event_type = 'add_to_cart'