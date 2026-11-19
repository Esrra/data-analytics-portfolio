with facebook_with_reach as(
				select
				fc.campaign_name,
				fabd.ad_date,
				fabd.reach
				from facebook_ads_basic_daily as fabd
				inner join facebook_campaign fc on fc.campaign_id= fabd.campaign_id				
	
),
	
ads_data as (
			select
				campaign_name,
				ad_date,
				coalesce(reach ,0) as reach,
				'Facebook Ads' AS media_source 
				from facebook_with_reach
				
				UNION all
				
				select
				campaign_name,
				ad_date,
				coalesce(reach ,0) as reach,
				'Google Ads' AS media_source 
				from google_ads_basic_daily 	
					
),

monthly_reach as (
			select
				campaign_name,
				DATE_TRUNC('month', ad_date::date)::date as ad_month,
				sum(reach) as total_reach
from ads_data
group by campaign_name,DATE_TRUNC('month', ad_date::date)::date 			

),

reach_growth as (
    select
        campaign_name,
        ad_month,
        total_reach,
        total_reach - LAG(total_reach) OVER (PARTITION BY campaign_name ORDER BY ad_month) AS reach_growth
    from monthly_reach
)

select	campaign_name,
		ad_month,
		reach_growth
from reach_growth
where reach_growth is not null
order by reach_growth desc 
limit 1
