WITH events AS (
    
  SELECT
    TIMESTAMP_MICROS(event_timestamp) AS event_timestamp,
    user_pseudo_id,
   (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
    event_name,
    geo.country AS country,
    device.category AS device_category,
    traffic_source.source AS source,
    traffic_source.medium AS medium,
    traffic_source.name AS campaign


FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20211231' 
    AND event_name IN (
        'session_start',
        'view_item',
        'add_to_cart',
        'begin_checkout',
        'add_shipping_info',
        'add_payment_info',
        'purchase'
    )

),

session_data AS (
    SELECT
        user_pseudo_id,
        session_id,

        MAX(CASE
            WHEN event_name = 'session_start'
            THEN DATE(event_timestamp)
        END) AS event_date,

        MAX(CASE
            WHEN event_name = 'session_start'
            THEN source
        END) AS source,

        MAX(CASE
            WHEN event_name = 'session_start'
            THEN medium
        END) AS medium,

        MAX(CASE
            WHEN event_name = 'session_start'
            THEN campaign
        END) AS campaign,

        MAX(CASE
            WHEN event_name = 'add_to_cart' THEN 1
            ELSE 0
        END) AS has_cart,

        MAX(CASE
            WHEN event_name = 'begin_checkout' THEN 1
            ELSE 0
        END) AS begin_checkout,

        MAX(CASE
            WHEN event_name = 'purchase' THEN 1
            ELSE 0
        END) AS purchase

    FROM events

    GROUP BY
        user_pseudo_id,
        session_id
    HAVING COUNTIF(event_name = 'session_start') > 0
)


SELECT
    event_date,
    source,
    medium,
    campaign,
    COUNT(*) AS user_sessions_count,
    SUM(has_cart) AS visit_to_cart,
    SUM(begin_checkout) AS visit_to_checkout,
    SUM(purchase) AS visit_to_purchase
FROM session_data
GROUP BY
    event_date,
    source,
    medium,
    campaign


