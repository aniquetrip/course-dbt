### Week 1 - Project questions

Part 4
## How many users do we have? 
130 users

```
SELECT COUNT(DISTINCT user_id) AS distinct_users
FROM DEV_DB.DBT_ANIQUETRIPMOLLIECOM.STG_USERS
```

## On average, how many orders do we receive per hour?
8 orders per hour (7.52)

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

NUMBER_OF_ORDERS	NUMBER_OF_USERS
1               	25
2	                28
3	                34
4	                20
5	                10
6	                 2
7	                 4
8	                 1

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