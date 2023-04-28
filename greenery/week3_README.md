## Week 3 - Project questions

### Part 1. Models
**What is our overall conversion rate?**

= # of unique sessions with a purchase event / total number of unique sessions.
= 62.5% (0.624567)

```
SELECT
    COUNT(DISTINCT CASE WHEN TOTAL_CHECKOUTS > 0 THEN session_id END) AS count_checkouts
    , COUNT(DISTINCT session_id) AS count_sessions
    , count_checkouts/count_sessions AS conversion_rate
FROM DEV_DB.DBT_ANIQUETRIPMOLLIECOM.FACT_SESSIONS

```
**What is our conversion rate by product?**

=  # of unique sessions with a purchase event of that product / total number of unique sessions that viewed that product

```
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
ORDER BY conversion_rate DESC
```

| PRODUCT_NAME | CONVERSION_RATE
| --- | ---|
|String of pearls| 0.6
|Cactus|  0.55
|Arrow Head| 0.55
|Bamboo| 0.52
|ZZ Plant| 0.52
|Monstera| 0.51
|Calathea Makoyana| 0.51 
|Rubber Plant| 0.50
|Devil's Ivy| 0.49
|Aloe Vera|0.49
|Jade Plant|0.49
|Majesty Palm|0.48
|Philodendron|0.48
|..|..
|Pothos|0.33


### Part 2. 

**Create a macro to simplify part of a model(s).**

I created a macro that aggregates event types per product. 

Macro:
```
{% macro agg_event_types() %} 

 {% set event_types = dbt_utils.get_column_values(
    table=ref('stg_events')
    , column='event_type'
 ) %}

  {% for event_type in event_types  %}
      ,SUM(CASE WHEN event_type = '{{ event_type }}' THEN 1 ELSE 0 END)  AS total_{{ event_type }}s
  {% endfor %}

{% endmacro %} 

```

Then I used this macro in one of the CTEs in my intermediate model int_event_types_products.sql:
```
SELECT
    product_id
    , DATE(created_at) AS created_day
    {{ agg_event_types() }}
FROM events
GROUP BY 1,2
```

To better understand what the macro does, this is the compiled code as a result of the macro:
```
SELECT
    product_id
    , DATE(created_at) AS created_day
    ,SUM(CASE WHEN event_type = 'page_view' THEN 1 ELSE 0 END)  AS total_page_views

    ,SUM(CASE WHEN event_type = 'add_to_cart' THEN 1 ELSE 0 END)  AS total_add_to_carts
  
    ,SUM(CASE WHEN event_type = 'checkout' THEN 1 ELSE 0 END)  AS total_checkouts
  
    ,SUM(CASE WHEN event_type = 'package_shipped' THEN 1 ELSE 0 END)  AS total_package_shippeds
  
FROM events
GROUP BY 1,2
```


### Part 3.
**Add a post hook to your project to apply grants to the role “reporting”.**

I first created the reporting role. Then I added the post hook in the dbt_project.yml file and viewed the results in the query history from Activity in Snowflake, which showed it run successfully.

See here the code which I've added in the dbt_project.yml file
```
  post-hook:
    - "GRANT SELECT ON {{ this }} TO reporting"

on-run-end:
    - "GRANT USAGE ON SCHEMA {{ schema }} TO reporting"
```

### Part 4. 
**Install a package (i.e. dbt-utils, dbt-expectations) and apply one or more of the macros to your project?**

I installed the dbt-utils package and used the get_column_values macro from the package. This macro returns the unique values for a column in a given relation as an array. I used this in my other macro so that I don't have to hardcode the different event types in my macro or model. This can also be useful in case in the future there will be more/new event types in the source model, for which we then don't have to update the code since the get_vaulue_columns will retrieve all column values automatically.

Usage of the package:
```
{% set event_types = dbt_utils.get_column_values(
    table=ref('stg_events')
    , column='event_type'
 ) %}
```

### Part 5. 
**Show (using dbt docs and the model DAGs) how you have simplified or improved a DAG using macros and/or dbt packages.**

Instead of creating a separate intermediate model for each event type, with this macro its now very easy to create 1 intermediate model which aggregates every event type per product. This can then be used for various use cases in the mart models.

### Part 6.
**Which products had their inventory change from week 1 to week 2?**
* Bamboo - decreased from 56 to 44
* Monstera - descreased from 64 to 50
* Philodendron - decreased from 25 to 15
* Pothos  - decreased from 20 to 0
* String of Pearls - decreased from 10 to 0
* ZZ Plant - decreased from 89 to 53