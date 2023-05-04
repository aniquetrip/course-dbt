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

![dbt-dag exposure - week 4](https://user-images.githubusercontent.com/130590347/236140622-33bf3f23-3c2d-48c3-8c19-d43bc922fedc.png)



### Part 3: Reflection questions
**3A. What are 1-2 things you might do differently / recommend to your organization based on learning from this course?.**

* Testing - say we make changes to a dbt model, we test this locally before we push changes to production. When we test this locally we basically run all the data in that model, which means a lot of data is processed. I think we could improve this by running this not on all historical data in that model, but perhaps look at a smaller set of data to test the changes on.
* Snapshots - we currently don't make use of snapshots, but I think there will be use cases at our company where we could apply it and benefit from this useful feature.

**3B. How would you go about setting up a production/scheduled dbt run of your project in an ideal state?**

I would schedule my production run every morning on a daily schedule (say new/fresh data is ingested every morning), after the ingestion of all the data is completed. To schedule this I would use Airflow, so that we can set this up automatically on a recurring time every day, early enough to make sure the entire dbt run is completed so that all data is refreshed in our BI tool at the latest by 9am. In this way, dashboard users can start their day with fresh data. In this schedule I would run all dbt models and tests, and setup alerts in a dedicated "data-alerts" slack channel, for whenever any test fails. In this way, our team gets notified when there is any issue with the data, so we can act upon it straight away. 

In the ideal state I would connect our critical dashboards (in our BI tool Looker), to the upstream dbt model dependencies, so that we can also setup alerts to notify stakeholders of these critical dashboards whenever the data is not up-to-date/accurate. I'm not sure how I would setup these dependencies though, as we have many critical dashboards (>50), so creating and updating this manually 1:1 in an exposure does not seem feasible to me. So if anyone would have any suggestion for this (without having to pay for another tool ;), that would be very useful.  