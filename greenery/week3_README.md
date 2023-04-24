## Week 3 - Project questions

### Part 1. Models
**What is our overall conversion rate?**
= # of unique sessions with a purchase event / total number of unique sessions.
= 62.5% (0.624567)

```
SELECT COUNT(DISTINCT order_id) / COUNT(DISTINCT session_id) AS conversion_rate
FROM DEV_DB.DBT_ANIQUETRIPMOLLIECOM.STG_EVENTS AS events

```
**What is our conversion rate by product?**
=  # of unique sessions with a purchase event of that product / total number of unique sessions that viewed that product

```
WITH orders AS (
SELECT 
   order_items.product_id
    , COUNT(DISTINCT order_items.order_id) as total_orders
FROM DEV_DB.DBT_ANIQUETRIPMOLLIECOM.STG_EVENTS AS events
LEFT JOIN DEV_DB.DBT_ANIQUETRIPMOLLIECOM.STG_ORDER_ITEMS AS order_items
    ON events.order_id = order_items.order_id
GROUP BY 1
)

, page_views AS (
SELECT 
 product_id
, SUM(CASE WHEN event_type = 'page_view' THEN 1 ELSE 0 END) AS total_page_views
FROM DEV_DB.DBT_ANIQUETRIPMOLLIECOM.STG_EVENTS AS events
GROUP BY 1
)

SELECT 
    page_views.product_id
    , products.name
    , ROUND((total_orders) / (total_page_views),2) AS conversion_rate 
FROM page_views
LEFT JOIN orders 
    ON page_views.product_id = orders.product_id 
LEFT JOIN DEV_DB.DBT_ANIQUETRIPMOLLIECOM.STG_PRODUCTS AS products
    ON page_views.product_id = products.product_id
WHERE page_views.product_id IS NOT NULL
ORDER BY conversion_rate DESC
```

| PRODUCT_NAME | CONVERSION_RATE
| --- | ---|
|String of pearls| 0.6
|Cactus|  0.55
|Arrow Head| 0.55
|Bamboo| 0.52
|ZZ Plant| 
|Monstera| 
|Calathea Makoyana| 
|Rubber Plant| 
|Devil's Ivy| 


### Part 2. 

**Create a macro to simplify part of a model(s).**

xxxx

### Part 3.
**Add a post hook to your project to apply grants to the role “reporting”.**

xxx

### Part 4. 
**Install a package (i.e. dbt-utils, dbt-expectations) and apply one or more of the macros to your project?**

### Part 5. 
**Show (using dbt docs and the model DAGs) how you have simplified or improved a DAG using macros and/or dbt packages.**

### Part 6.
**Which products had their inventory change from week 1 to week 2?**