select * from (
select  
 'web' as channel
 ,web.item myitem
 ,web.return_ratio myreturnratio
 ,web.return_rank myreturnrank
 ,web.currency_rank mycurrencyrank
 from (
 	select 
 	 item
 	,return_ratio
 	,currency_ratio
 	,rank() over (order by return_ratio) as return_rank
 	,rank() over (order by currency_ratio) as currency_rank
 	from
 	(	select  
                 ws.ws_item_sk as item
 		,(cast(sum(coalesce(wr.wr_return_quantity,0)) as decimal(15,4))/
 		cast(sum(coalesce(ws.ws_quantity,0)) as decimal(15,4) )) as return_ratio
 		,(cast(sum(coalesce(wr.wr_return_amt,0)) as decimal(15,4))/
 		cast(sum(coalesce(ws.ws_net_paid,0)) as decimal(15,4) )) as currency_ratio
 		from 
 		web_sales ws 
                join date_dim
                on ws_sold_date_sk = d_date_sk
                left outer join web_returns wr 
 	        on (ws.ws_order_number = wr.wr_order_number and ws.ws_item_sk = wr.wr_item_sk)
 		where 
 			wr.wr_return_amt > 10000 
 			and ws.ws_net_profit > 1
                        and ws.ws_net_paid > 0
                        and ws.ws_quantity > 0
                        and d_year = 2000
                        and d_moy = 12
 		group by ws.ws_item_sk
 	) in_web
 ) web
 where web.return_rank <= 10 or web.currency_rank <= 10
 union all
 select 
 'catalog' as channel
 ,catalog.item myitem
 ,catalog.return_ratio myreturnratio
 ,catalog.return_rank myreturnrank
 ,catalog.currency_rank mycurrencyrank
 from (
 	select 
 	 item
 	,return_ratio
 	,currency_ratio
 	,rank() over (order by return_ratio) as return_rank
 	,rank() over (order by currency_ratio) as currency_rank
 	from
 	(	select 
 		cs.cs_item_sk as item
 		,(cast(sum(coalesce(cr.cr_return_quantity,0)) as decimal(15,4))/
 		cast(sum(coalesce(cs.cs_quantity,0)) as decimal(15,4) )) as return_ratio
 		,(cast(sum(coalesce(cr.cr_return_amount,0)) as decimal(15,4))/
 		cast(sum(coalesce(cs.cs_net_paid,0)) as decimal(15,4) )) as currency_ratio
 		from 
 		catalog_sales cs 
                join date_dim
                on cs_sold_date_sk = d_date_sk
                left outer join catalog_returns cr
 			on (cs.cs_order_number = cr.cr_order_number and 
 			cs.cs_item_sk = cr.cr_item_sk)
 		where 
 			cr.cr_return_amount > 10000 
 			and cs.cs_net_profit > 1
                         and cs.cs_net_paid > 0
                         and cs.cs_quantity > 0
                         and d_year = 2000
                         and d_moy = 12
                 group by cs.cs_item_sk
 	) in_cat
 ) catalog
 where 
 catalog.return_rank <= 10 or catalog.currency_rank <=10
 union all
 select 
 'store' as channel
 ,store.item myitem
 ,store.return_ratio myreturnratio
 ,store.return_rank myreturnrank
 ,store.currency_rank mycurrencyrank
 from (
 	select 
 	 item
 	,return_ratio
 	,currency_ratio
 	,rank() over (order by return_ratio) as return_rank
 	,rank() over (order by currency_ratio) as currency_rank
 	from
 	(	select 
                sts.ss_item_sk as item
 		,(cast(sum(coalesce(sr.sr_return_quantity,0)) as decimal(15,4))/cast(sum(coalesce(sts.ss_quantity,0)) as decimal(15,4) )) as return_ratio
 		,(cast(sum(coalesce(sr.sr_return_amt,0)) as decimal(15,4))/cast(sum(coalesce(sts.ss_net_paid,0)) as decimal(15,4) )) as currency_ratio
 		from 
 		store_sales sts 
                join date_dim
                on ss_sold_date_sk = d_date_sk
                left outer join store_returns sr
 			on (sts.ss_ticket_number = sr.sr_ticket_number and sts.ss_item_sk = sr.sr_item_sk)
 		where 
 			sr.sr_return_amt > 10000 
 			and sts.ss_net_profit > 1
                         and sts.ss_net_paid > 0 
                         and sts.ss_quantity > 0
                         and d_year = 2000
                         and d_moy = 12
 		group by sts.ss_item_sk
 	) in_store
 ) store
 where  store.return_rank <= 10 or store.currency_rank <= 10 
)
order by channel, myreturnrank, mycurrencyrank
limit 100;


