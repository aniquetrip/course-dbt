-- intermediate model to determine  daily page views and add to carts per product 
{{ 
    config(
        materialized='table'
) 
}}

WITH events AS (
    SELECT * FROM {{ ref('stg_events') }}
)

SELECT 
 product_id
, DATE(created_at) AS created_day
,{{ agg_event_types('checkout') }}
,{{ agg_event_types('package_shipped') }}
,{{ agg_event_types('page_view') }}
,{{ agg_event_types('add_to_cart') }}
FROM events
GROUP BY 1,2


