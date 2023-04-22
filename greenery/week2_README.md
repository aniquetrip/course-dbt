### Week 2 - Project questions

Part 1. Models
## What is our user repeat rate?
0.798387


```
WITH repeat_users AS (
    SELECT user_id, COUNT(*)
    FROM DEV_DB.DBT_ANIQUETRIPMOLLIECOM.STG_ORDERS AS orders
    GROUP BY 1
    HAVING COUNT(*) >= 2
)

SELECT COUNT(DISTINCT repeat_users.user_id) / COUNT(DISTINCT orders.user_id) AS repeat_rate
FROM DEV_DB.DBT_ANIQUETRIPMOLLIECOM.STG_ORDERS AS orders
LEFT JOIN repeat_users
    ON orders.user_id = repeat_users.user_id
```

## What are good indicators of a user who will likely purchase again? What about indicators of users who are likely NOT to purchase again? If you had more data, what features would you want to look into to answer this question?
Indicators of users who are likely to purchase again:
* Time between consecutive orders
* Time since last order
* Number of times ordered
* Discount amount

Indicators of users who are NOT likely to purchase again:
* Late delivery (time delivered > estimated delivery time)
* Shipping costs
* Products out of stock

Additional features
* Number of times order returned
* Customer feedback


## Within product marts folder, create intermediate models and dimension/fact models.
See Products marts folder [here](https://github.com/aniquetrip/course-dbt/tree/main/greenery/models/marts/product)

## Explain the product mart models you added. Why did you organize the models in the way you did?
Product mart models
* FACT_PROMOS - This mart model is built to show what promos (incl discount amounts) have been given to certain orders and products. I didnt aggregate this yet, but joined the data in such a way that you can identify which promos were given (not possible from source table cause product_id and order_id are not linked) and which gives the flexibility to analyse promos on both order and product level. 
* FACT_PRODUCT - This mart model is built to show daily stats per product. For example the daily page views, daily total orders and conversion rate of page views into orders. I added this on product level so the product team can analyse the performance per product.

Part 2. Tests
## We added some more models and transformed some data! Now we need to make sure they’re accurately reflecting the data. Add dbt tests into your dbt project on your existing models from Week 1, and new models from the section above
I've added the following generic tests to some of the columns in either staging or mart models. I used unique and not nulll tests on the primary key columns (so the id columns) because these values should be unique. Also these should not be null since these id columsn are used to join to other tables. In the mart models, I also added positive valuesf for values that should not be negative, like for example the total_orders or total_page_views columns.


Part 3. Snapshots
## Which products had their inventory change from week 1 to week 2? 
