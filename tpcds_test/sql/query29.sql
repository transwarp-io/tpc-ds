
select
    
     i_item_id
    ,i_item_desc
    ,s_store_id
    ,s_store_name
    ,sum(ss_quantity)        as store_sales_quantity
    ,sum(sr_return_quantity) as store_returns_quantity
    ,sum(cs_quantity)        as catalog_sales_quantity
 from
    (select ss_item_sk, ss_customer_sk, ss_store_sk, ss_quantity, ss_ticket_number
     from    store_sales  ,date_dim     d1
	where d1.d_moy               = 4
	 and d1.d_year              = 1999
 	and d1.d_date_sk           = ss_sold_date_sk ) x0
   ,store
   ,item
   ,( select  sr_item_sk, sr_ticket_number, sr_customer_sk, sr_return_quantity
      from store_returns
           ,date_dim             d2
      where
       sr_returned_date_sk = d2.d_date_sk
       and d2.d_moy               between 4 and  4 + 3 
       and d2.d_year              = 1999
    ) x
   ,( select  cs_bill_customer_sk, cs_item_sk, cs_quantity
      from catalog_sales
          ,date_dim             d3
      where
       cs_sold_date_sk = d3.d_date_sk     
       and d3.d_year  in (1999,1999+1,1999+2)
    ) y
 where
 i_item_sk              = ss_item_sk
 and s_store_sk             = ss_store_sk
 and ss_customer_sk         = x.sr_customer_sk
 and ss_item_sk             = x.sr_item_sk
 and ss_ticket_number       = x.sr_ticket_number
 and x.sr_customer_sk         = y.cs_bill_customer_sk
 and x.sr_item_sk             = y.cs_item_sk
 group by
    i_item_id
   ,i_item_desc
   ,s_store_id
   ,s_store_name
 order by
    i_item_id 
   ,i_item_desc
   ,s_store_id
   ,s_store_name

 limit 100;


