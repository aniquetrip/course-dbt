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
-Time between consecutive orders

-Time since last order

-Number of times ordered

-Discount amount

Indicators of users who are NOT likely to purchase again:
-Late delivery (time delivered > estimated delivery time)

-Shipping costs

Additional features
-Number of times order returned

