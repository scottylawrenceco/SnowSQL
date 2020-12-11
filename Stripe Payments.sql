CREATE OR REPLACE VIEW ANALYTICS.STRIPE.VW_INVOICE_PAYMENTS as
/* This table is getting post-FOREX adjusted payments and refunds, converted into USD and applied against an Invoice

*/      
SELECT
    I.ID as "INVOICE_ID"
    ,I.HOSTED_INVOICE_URL
    ,I.CURRENCY as "INVOICE_CURRNECY"
    ,SUM(IFNULL(BC.NET,0) + IFNULL(BR.NET,0))/100 as "NET_REVENUE_USD"
    ,SUM(IFNULL(BC.NET,0))/100 as "REVENUE_USD"
    ,SUM(IFNULL(BC.FEE,0))/100 as "EXCHANGE_FEE_USD"
    ,SUM(IFNULL(BR.AMOUNT,0))/100 as "REFUND_USD"
    ,SUM(IFNULL(BR.NET,0))/100 as "REFUNED_FEE_USD"
FROM
    "FIVETRAN_DATABASE"."STRIPE"."INVOICE" as I
    LEFT JOIN "FIVETRAN_DATABASE"."STRIPE"."CHARGE" as C on C.ID = I.CHARGE_ID
    LEFT JOIN FIVETRAN_DATABASE.STRIPE.REFUND R on R.CHARGE_ID = C.ID
    LEFT JOIN "FIVETRAN_DATABASE"."STRIPE"."BALANCE_TRANSACTION" as BC on BC.ID = C.BALANCE_TRANSACTION_ID
    LEFT JOIN "FIVETRAN_DATABASE"."STRIPE"."BALANCE_TRANSACTION" as BR on BR.ID = R.BALANCE_TRANSACTION_ID
GROUP BY 1, 2, 3;