




select  
 i_item_id
 ,i_item_desc
 ,s_store_id
 ,s_store_name
 ,sum(ss_net_profit) as store_sales_profit
 ,sum(sr_net_loss) as store_returns_loss
 ,sum(cs_net_profit) as catalog_sales_profit
 from
 (select ss_item_sk, ss_store_sk, ss_customer_sk, ss_net_profit, ss_ticket_number
	 from store_sales
 		,date_dim d1
	where  d1.d_moy = 4
	 and d1.d_year = 2000
	 and d1.d_date_sk = ss_sold_date_sk) z
 ,store
 ,item
 , (select sr_customer_sk, sr_ticket_number, sr_item_sk, sr_net_loss
	 from store_returns
	 ,date_dim d2
	 where sr_returned_date_sk = d2.d_date_sk
		 and d2.d_moy               between 4 and  10
 		and d2.d_year              = 2000) x
 , (select cs_bill_customer_sk, cs_item_sk, cs_net_profit
	 from catalog_sales
	 ,date_dim d3
	where cs_sold_date_sk = d3.d_date_sk
		 and d3.d_moy               between 4 and  10
		 and d3.d_year              = 2000) y
 where
 i_item_sk = ss_item_sk
 and s_store_sk = ss_store_sk
 and ss_customer_sk = sr_customer_sk
 and ss_item_sk = sr_item_sk
 and ss_ticket_number = sr_ticket_number
 and sr_customer_sk = cs_bill_customer_sk
 and sr_item_sk = cs_item_sk
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
