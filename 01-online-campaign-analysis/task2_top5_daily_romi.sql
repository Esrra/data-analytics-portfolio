WITH combined AS (
    SELECT ad_date, spend, value
    FROM facebook_ads_basic_daily
    WHERE ad_date IS NOT NULL
    UNION ALL
    SELECT ad_date, spend, value
    FROM google_ads_basic_daily
    WHERE ad_date IS NOT NULL
)
SELECT
    ad_date,
    ROUND(100.0 * (COALESCE(SUM(value), 0) - SUM(spend)) / SUM(spend), 2) AS romi
FROM combined
GROUP BY ad_date
HAVING SUM(spend) > 0
ORDER BY romi DESC
LIMIT 5;
