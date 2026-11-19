with combined as (
    select
        fabd.ad_date,
        'Facebook' as media_source,
        fabd.spend
    from facebook_ads_basic_daily fabd
	left join facebook_adset fa on fa.adset_id = fabd.adset_id
	left join facebook_campaign fc on fc.campaign_id = fabd.campaign_id

    union all

    select
        ad_date,
        'Google' as media_source,
        spend
    from google_ads_basic_daily
)
select
    ad_date,
    media_source,
    round(avg(spend)::numeric, 2) as avg_spend,
    round(max(spend)::numeric, 2) as max_spend,
    round(min(spend)::numeric, 2) as min_spend
from combined
group by ad_date, media_source
order by ad_date, media_source
