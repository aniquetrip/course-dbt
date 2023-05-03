## Week 4 - Project questions

### Part 1. dbt Snapshots
**Which products had their inventory change from week 3 to week 4?**

* Bamboo
* Monstera 
* Philodendron 
* String of pearls
* Pothos
* ZZ Plant


**Which products had the most fluctuations in inventory? Did we have any items go out of stock in the last 3 weeks?**

Most fluctuations:

String of Pearls and Pothos went out of stock in week 3. However in week 4 these items got back in stock again.
```
WITH inventory AS (  
SELECT
        name
        , dbt_updated_at
        , inventory
        , LEAD(inventory) over (partition BY product_id  ORDER BY dbt_updated_at) AS following_inventory
    FROM DEV_DB.DBT_ANIQUETRIPMOLLIECOM.PRODUCTS_SNAPSHOT 
)

SELECT * FROM inventory
WHERE  inventory = 0 or following_inventory = 0 
```

### Part 2. Modeling challenge

**How are our users moving through the product funnel? Which steps in the funnel have largest drop off points?**

* Page view - 100% 
* Add to cart - 80.8%
* Checkout - 62.5%
* Package shipped - 57.9%

This basically means that from the 'page view' to 'add to cart' 19.2% of users are dropping out. From 'add to cart' to 'checkout' 18.3% of users are dropping out. This means that the largest drop off happens in the step from 'page view' to 'add to cart'.

```

SELECT
     COUNT(DISTINCT session_id) AS count_sessions
    , COUNT(DISTINCT CASE WHEN TOTAL_PAGE_VIEWS > 0 THEN session_id END) AS count_page_views
    , count_page_views/count_sessions AS page_view_conversion_rate
    , COUNT(DISTINCT CASE WHEN TOTAL_ADD_TO_CARTS > 0 THEN session_id END) AS count_add_to_carts
    , count_add_to_carts/count_sessions AS add_to_cart_conversion_rate
    , COUNT(DISTINCT CASE WHEN TOTAL_CHECKOUTS > 0 THEN session_id END) AS count_checkouts
    , count_checkouts/count_sessions AS checkout_conversion_rate
    , COUNT(DISTINCT CASE WHEN TOTAL_PACKAGE_SHIPPEDS > 0 THEN session_id END) AS count_package_shippeds
    , count_package_shippeds/count_sessions AS package_shippeds_conversion_rate
FROM DEV_DB.DBT_ANIQUETRIPMOLLIECOM.FACT_SESSIONS_FUNNEL

```


### Part 3: Reflection questions
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
