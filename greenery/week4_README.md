## Week 4 - Project questions

### Part 1. dbt Snapshots
**Which products had their inventory change from week 3 to week 4?**

* Bamboo
* Monstera 
* Philodendron 
* String of pearls
* Pothos
* ZZ Plant


**Which products had the most fluctuations in inventory?**


**Did we have any items go out of stock in the last 3 weeks?**

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

**Use an exposure on your product analytics model to represent that this is being used in downstream BI tools.**

The exposure that I've added in the exposures.yml file can be found below.

```
version: 2

exposures:  
  - name: product_funnel_dashboard
    description: >
      This dashboard is critical and is dependent on the product funnel mart model. We therefore want to know if this model run successfully or not.
    type: dashboard
    maturity: high
    owner:
      name: Anique Trip
      email: anique.trip@mollie.com
    depends_on:
      - ref('fact_sessions_funnel')
```

### Part 3: Reflection questions
**3A. dbt next steps for you .**

xxxx

**3B. Setting up for production / scheduled dbt run of your project .**

