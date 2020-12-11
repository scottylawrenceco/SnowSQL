/* This script takes flattened Sendgrid data, processed with previous Python and stored in Redshift */
/* This script will not have universal application outside this specific project. */

WITH 
CTE_TYPES as (
SELECT DISTINCT
	CASE WHEN category in ('the-new-science-of-talent','future-of-finance','the-race-to-zero-emissions','space-business') then category
		 WHEN category like '%obses%' then 'Obessions'
		 WHEN category like '%daily%' then 'Daily Brief'
		 WHEN category like '%corona%' then 'COVID'
		 WHEN category like '%promo%' then 'Promo'
		 WHEN category like '%africa%' then 'Africa'
		 WHEN category like '%z-at-work%' then 'QZ At Work'
		 WHEN category like '%quartzy%' then 'Quartzy'
		 WHEN category like '%member%' then 'Membership'
		 ELSE 'Other' END as "Grouped"
	, marketing_campaign_id 
	
FROM 
	sendgrid_campaign_reference
),
CTE_First_Contact as (
SELECT
	e.email
	,e.email_id 
	,MIN(event_timestamp) as "first_date"
	,DATEADD(day,7,MIN(event_timestamp)) as "first_week_end"
FROM
	sendgrid_email_campaigns sec
	LEFT JOIN email_id_map as E on E.email_id = sec.email_id
WHERE
	sec.event = 'delivered'
	and e.email is not null
GROUP BY 
	1, 2

)

SELECT
	f.email
	,sec.email_id 
	,f.first_date
	,f.first_week_end

	,DATEDIFF('day',f.first_date,CURRENT_DATE ) as "days_as_member"
	,COUNT(*) as "all_opens"
	,MIN(event_timestamp) as "first_subscribe"
	,SUM(case when t.Grouped = 'the-race-to-zero-emissions' and event_timestamp between first_date and first_week_end THEN 1 else 0 end) as "first_race_to_zero_emissions"
	,SUM(case when t.Grouped = 'Membership' and event_timestamp between first_date and first_week_end THEN 1 else 0 end) as "first_membership"
	,SUM(case when t.Grouped = 'Promo' and event_timestamp between first_date and first_week_end THEN 1 else 0 end) as "first_promo"
	,SUM(case when t.Grouped = 'COVID' and event_timestamp between first_date and first_week_end THEN 1 else 0 end) as "first_covid"
	,SUM(case when t.Grouped = 'the-new-science-of-talent' and event_timestamp between first_date and first_week_end THEN 1 else 0 end) as "first_science_of_talent"
	,SUM(case when t.Grouped = 'Other'and event_timestamp between first_date and first_week_end THEN 1 else 0 end) as "first_other"
	,SUM(case when t.Grouped = 'Africa' and event_timestamp between first_date and first_week_end THEN 1 else 0 end) as "first_africa"
	,SUM(case when t.Grouped = 'QZ At Work' and event_timestamp between first_date and first_week_end THEN 1 else 0 end) as "first_QZ_at_work"
	,SUM(case when t.Grouped = 'Quartzy' and event_timestamp between first_date and first_week_end THEN 1 else 0 end) as "first_quartzy"
	,SUM(case when t.Grouped = 'Daily Brief' and event_timestamp between first_date and first_week_end THEN 1 else 0 end) as "first_DB"
	,SUM(case when t.Grouped = 'Obessions' and event_timestamp between first_date and first_week_end THEN 1 else 0 end) as "first_obessions"
	,SUM(case when t.Grouped = 'space-business' and event_timestamp between first_date and first_week_end THEN 1 else 0 end) as "first_space_biz"
	,SUM(case when t.Grouped = 'future-of-finance' and event_timestamp between first_date and first_week_end THEN 1 else 0 end) as "first_future_finance"
FROM
	sendgrid_email_campaigns as sec
	LEFT JOIN cte_types as t on t.marketing_campaign_id = sec.marketing_campaign_id 
	LEFT JOIN CTE_first_contact as F on F.email_id = sec.email_id 
WHERE
	sec.event = 'open'
	and F.email is not null
	and F.first_date >= '2020-02-01'
GROUP BY 
	1, 2, 3, 4
