

select 
       
        i_item_id
       ,i_item_desc
       ,s_state
       ,count(ss_quantity) as store_sales_quantitycount
       ,avg(ss_quantity) as store_sales_quantityave
       ,stddev_samp(ss_quantity) as store_sales_quantitystdev
       ,stddev_samp(ss_quantity)/avg(ss_quantity) as store_sales_quantitycov
       ,count(sr_return_quantity) as_store_returns_quantitycount
       ,avg(sr_return_quantity) as_store_returns_quantityave
       ,stddev_samp(sr_return_quantity) as_store_returns_quantitystdev
       ,stddev_samp(sr_return_quantity)/avg(sr_return_quantity) as store_returns_quantitycov
       ,count(cs_quantity) as catalog_sales_quantitycount ,avg(cs_quantity) as catalog_sales_quantityave
       ,stddev_samp(cs_quantity)/avg(cs_quantity) as catalog_sales_quantitystdev
       ,stddev_samp(cs_quantity)/avg(cs_quantity) as catalog_sales_quantitycov
 from 
    (select ss_customer_sk, ss_item_sk, ss_quantity, ss_store_sk, ss_ticket_number
	from store_sales, date_dim d1
	where d1.d_quarter_name = '2000Q1'
	      and d1.d_date_sk = ss_sold_date_sk) x0
     ,store
     ,item
     , ( select  sr_customer_sk, sr_item_sk, sr_ticket_number, sr_return_quantity
         from
            store_returns
            ,date_dim d2
         where
         sr_returned_date_sk = d2.d_date_sk
         and d2.d_quarter_name in ('2000Q1','2000Q2','2000Q3')
       ) x1
     , ( select  cs_bill_customer_sk, cs_item_sk, cs_quantity
         from
            catalog_sales
            ,date_dim d3
         where
         cs_sold_date_sk = d3.d_date_sk
         and d3.d_quarter_name in ('2000Q1','2000Q2','2000Q3')
       ) y1
 where
   i_item_sk = ss_item_sk
   and s_store_sk = ss_store_sk
   and ss_customer_sk = x1.sr_customer_sk
   and ss_item_sk = x1.sr_item_sk
   and ss_ticket_number = x1.sr_ticket_number
   and x1.sr_customer_sk = y1.cs_bill_customer_sk
   and x1.sr_item_sk = y1.cs_item_sk
 group by i_item_id
         ,i_item_desc
         ,s_state
 order by i_item_id
         ,i_item_desc
         ,s_state
 limit 100;
















































