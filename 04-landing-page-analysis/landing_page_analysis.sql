WITH session_start_raw AS (

    SELECT
        user_pseudo_id,

        (
            SELECT value.int_value
            FROM UNNEST(event_params)
            WHERE key = 'ga_session_id'
        ) AS session_id,

        (
            SELECT value.string_value
            FROM UNNEST(event_params)
            WHERE key = 'page_location'
        ) AS page_location

   FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
   WHERE _TABLE_SUFFIX BETWEEN '20200101' AND '20201231' 
    AND event_name = 'session_start'

),

purchases_raw AS (

    SELECT DISTINCT

        user_pseudo_id,

        (
            SELECT value.int_value
            FROM UNNEST(event_params)
            WHERE key = 'ga_session_id'
        ) AS session_id

   FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
   WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20211231' 
   AND event_name = 'purchase'

),

sessions_with_path AS (

    SELECT

        s.user_pseudo_id,
        s.session_id,

        REGEXP_EXTRACT(
            s.page_location,
            r'^https?://[^/]+(/[^?]*)'
        ) AS landing_page_path,

        IF(
            p.session_id IS NOT NULL,
            1,
            0
        ) AS has_purchase

    FROM session_start_raw s

    LEFT JOIN purchases_raw p

        ON s.user_pseudo_id = p.user_pseudo_id
        AND s.session_id = p.session_id
),

unique_sessions AS (

    SELECT DISTINCT

        user_pseudo_id,
        session_id,
        landing_page_path,
        has_purchase

    FROM sessions_with_path
)

SELECT

    landing_page_path,

    COUNT(*) AS user_sessions_count,

    SUM(has_purchase) AS purchases_count,

    SAFE_DIVIDE(
        SUM(has_purchase),
        COUNT(*)
    ) AS visit_to_purchase

FROM unique_sessions

WHERE landing_page_path IS NOT NULL

GROUP BY landing_page_path

ORDER BY user_sessions_count DESC;
