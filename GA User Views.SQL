CREATE OR REPLACE VIEW ANALYTICS.GOOGLE_ANALYTICS.VW_USER_SUMMARY as 
SELECT
    FULLVISITORID
    ,DEVICE:deviceCategory::string as "device"
    ,GEONETWORK:"country"::string as "country"
    ,SUM(IFNULL(TOTALS:visits,0)::int) as "total_visits"
    ,SUM(IFNULL(TOTALS:timeOnSite,0)::int) as "time_on_site"
    ,MIN(DATE) as "FIRST_DATE"
FROM
    "STITCH_DATA"."GOOGLE_ANALYTICS"."GA_SESSIONS"
GROUP BY
    1, 2, 3;
