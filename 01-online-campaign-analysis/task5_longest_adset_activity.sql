with facebook_with_reach as(
				select
				fabd.ad_date,
				fa.adset_name
				from facebook_ads_basic_daily as fabd
				inner join facebook_adset fa on fa.adset_id= fabd.adset_id				
				
	
),
	
ads_data as (
			select
				ad_date,
				adset_name
				from facebook_with_reach
				
				UNION
				
				select
				ad_date,
				adset_name
				from google_ads_basic_daily 	
					
),

--SELECT * FROM combined_ads WHERE ads_data = 'Abstract' AND ad_date = '2022-05-20'

adset_streak AS (
    select
        adset_name,
        ad_date,
        ad_date - ROW_NUMBER() OVER (PARTITION BY adset_name ORDER BY ad_date)::integer AS grp
    from ads_data
),


count_blok as (
    select
        adset_name,
        grp,
        count(*) as duration_day,
        min(ad_date) as start_date,
        max(ad_date) as end_date
    from adset_streak
    group by adset_name, grp
)

select adset_name,
		start_date,
		end_date,
		duration_day
from count_blok
order by duration_day desc
limit 1
