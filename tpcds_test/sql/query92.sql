select
   sum(ws_ext_discount_amt)  as Excess_Discount_Amount
from
    web_sales ws1
   ,item i1
   ,date_dim d1
where
i1.i_manufact_id = 269
and i1.i_item_sk = ws1.ws_item_sk
and d1.d_date between '1998-03-18' and
      --  (cast('1998-03-18' as date) + 90 days)
      (cast('1998-03-18' as date) + interval '90' day)
and d1.d_date_sk = ws1.ws_sold_date_sk
and ws1.ws_ext_discount_amt
     > (
         SELECT
            1.3 * avg(ws2.ws_ext_discount_amt)
         FROM
            web_sales ws2
           ,date_dim d2
         WHERE 
          ws2.ws_item_sk = i1.i_item_sk    
          and  d2.d_date between '1998-03-18' and
                        (cast('1998-03-18' as date) + interval '90' day)
          and d2.d_date_sk = ws2.ws_sold_date_sk
      )
order by sum(ws_ext_discount_amt)
limit 100;

