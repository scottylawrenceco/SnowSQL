CREATE OR REPLACE VIEW ANALYTICS.STRIPE.SUBSCRIPTIONS AS  
/* ===== Subscriptions with payments ============
   Purpose: Paid Subscriptions, aggregate invoices for payments and duration.
   Notes: A subscription will create additional invoices for renewals.
          This only includes paid subscriptions, which excludes all trials.

    -- Scott Lawrence: 2020-12-08 Known Issues: 
    - Region is using the plan name instead of a more stable field
    - Exchange rates from different currencies are using an aggregated snapshot for simplicity
 */

SELECT DISTINCT
   I.CUSTOMER_ID
   ,S.ID as "SUBSCRIPTION_ID" 
   ,P."INTERVAL"
   ,P."NICKNAME" as "PLAN"
   ,CASE when lower(P.NICKNAME) like '%jap%' then 'Japan'
         when lower(P.NICKNAME) like '%uk%' then 'United Kingdom'
         when lower(P.NICKNAME) like '%india%' then 'India'
         else 'US' END as "Region"
   ,I."CURRENCY"
   ,S."STATUS" as "SUB_STATUS"
   ,S."BILLING_CYCLE_ANCHOR"  as "SUB_START_DATE"
   ,S."ENDED_AT" as "SUB_END_DATE"
   ,S."CURRENT_PERIOD_END"
   ,CASE WHEN ENDED_AT is null then null
         ELSE DATEDIFF('month',BILLING_CYCLE_ANCHOR,ENDED_AT) END as "SUB_LENGTH_MONTHS"

   ,COUNT(DISTINCT I.ID) as "INVOICES"
   ,SUM(IP."NET_REVENUE_USD") as "NET_REVENUE_USD"
FROM  
   "FIVETRAN_DATABASE"."STRIPE"."INVOICE" as I
   LEFT JOIN (SELECT DISTINCT SUBSCRIPTION_ID, INVOICE_ID, PLAN_ID FROM "FIVETRAN_DATABASE"."STRIPE"."INVOICE_LINE_ITEM") as IL on IL.INVOICE_ID = I.ID
   LEFT JOIN "FIVETRAN_DATABASE"."STRIPE"."PLAN" as P on P.ID = IL.PLAN_ID
   LEFT JOIN "FIVETRAN_DATABASE"."STRIPE"."SUBSCRIPTION" as S on S.ID = IL.SUBSCRIPTION_ID
   LEFT JOIN "ANALYTICS"."STRIPE"."VW_INVOICE_PAYMENTS" as IP on IP.INVOICE_ID = I.ID
WHERE
  AMOUNT_PAID > 0 
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11;
