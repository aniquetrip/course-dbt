 
SELECT  
    promo_id,
    discount AS discount_amount,
    status
FROM {{ source('postgres', 'promos') }}