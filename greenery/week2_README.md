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
Time between consecutive orders
Time since last order
Number of times ordered
Discount amount

Indicators of users who are NOT likely to purchase again:
Late delivery (time delivered > estimated delivery time)
Shipping costs

Additional features
Number of times order returned


```
WITH order_counts AS (
SELECT 
    DATE_TRUNC('HOUR',created_at) AS created_hour
    , COUNT(*) AS order_count
FROM DEV_DB.DBT_ANIQUETRIPMOLLIECOM.STG_ORDERS
GROUP BY 1
)

SELECT 
    AVG(order_count) AS orders_per_hour
FROM order_counts
```

## On average, how long does an order take from being placed to being delivered?
3.89 days

```
SELECT 
    AVG(DATEDIFF('DAY', created_at, delivered_at)) AS average_order_duration
FROM DEV_DB.DBT_ANIQUETRIPMOLLIECOM.STG_ORDERS
WHERE delivered_at IS NOT NULL
```

## How many users have only made one purchase? Two purchases? Three+ purchases?

| NUMBER_OF_ORDERS | NUMBER_OF_USERS
| --- | ---|
| 1 | 25
| 2	| 28
| 3	| 34
| 4	| 20
| 5	| 10
| 6	| 2
| 7	| 4
| 8	| 1

```
WITH orders_per_user AS (
SELECT 
    user_id
    , COUNT(order_id) AS number_of_orders
FROM DEV_DB.DBT_ANIQUETRIPMOLLIECOM.STG_ORDERS
GROUP BY 1
)

SELECT 
    number_of_orders
    , COUNT(*) AS number_of_users
FROM orders_per_user
GROUP BY 1
ORDER BY 1
```

## On average, how many unique sessions do we have per hour?
16 (16.33)

```
WITH sessions_per_hour AS (
SELECT 
    DATE_TRUNC(HOUR,created_at) AS created_hour
    , COUNT(DISTINCT session_id) AS count_unique_sessions
FROM DEV_DB.DBT_ANIQUETRIPMOLLIECOM.STG_EVENTS
GROUP BY 1
)

SELECT ROUND(AVG(count_unique_sessions),2) AS avg_unique_sessions
FROM sessions_per_hour
```