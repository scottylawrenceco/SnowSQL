SELECT DISTINCT
fullvisitorId,
visitid,
hit.hitnumber,
date,
totals.timeOnSite,
trafficSource.campaign,
trafficSource.source,
trafficSource.medium,
trafficSource.keyword,
device.browser,
device.operatingSystem,
device.browserVersion,
device.operatingSystem,
geoNetwork.metro,
geoNetwork.city,
(SELECT x.value FROM UNNEST(hit.customDimensions) x WHERE x.index = 45) as creative_id,
(SELECT x.value FROM UNNEST(hit.customDimensions) x WHERE x.index = 46) as questions,
(SELECT x.value FROM UNNEST(hit.customDimensions) x WHERE x.index = 58) as type,
(SELECT x.value FROM UNNEST(hit.customDimensions) x WHERE x.index = 60) as existingCustomer
/* Create an UNNEST(dimension) argument, join with a comma on your main table to enable extractions */
FROM
  `167490341`.`ga_realtime_sessions_202012*`,
  UNNEST(hits) as hit
WHERE (SELECT x.value FROM UNNEST(hit.customDimensions) x WHERE x.index = 45) = '138330173277'
      and (SELECT x.value FROM UNNEST(hit.customDimensions) x WHERE x.index = 47) = 'click'
      and fullvisitorid <> '7990427192822679001'
