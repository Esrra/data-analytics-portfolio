with facebook_with_campaign as(
				select
				fc.campaign_name,
				fabd.ad_date,
				fabd.value
				from facebook_ads_basic_daily as fabd
				inner join facebook_campaign fc on fc.campaign_id= fabd.campaign_id				
	
),
	
ads_data as (
			select
				campaign_name,
				ad_date,
				coalesce(value ,0) as value,
				'Facebook Ads' AS media_source 
				from facebook_with_campaign
				
				UNION all
				
				select
				campaign_name,
				ad_date,
				coalesce(value ,0) as value,
				'Google Ads' AS media_source 
				from google_ads_basic_daily 	
					
),
weekly_totals as(
		select 
			date_trunc('week', ad_date::date)::date as ad_week,
			sum(value) as total_value,
			campaign_name

from ads_data
group by date_trunc('week', ad_date::date),campaign_name

)

select  ad_week as ad_week,
		total_value,
		campaign_name
		
from weekly_totals
order by total_value desc
limit 1
