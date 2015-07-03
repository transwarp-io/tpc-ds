

with ws as
(select * from 
  (select  d_year AS ws_sold_year, ws_item_sk,
    ws_bill_customer_sk ws_customer_sk,
    sum(ws_quantity) ws_qty,
    sum(ws_wholesale_cost) ws_wc,
    sum(ws_sales_price) ws_sp
   from web_sales
   join date_dim on ws_sold_date_sk = d_date_sk
   left join web_returns on wr_order_number=ws_order_number and ws_item_sk=wr_item_sk
   where wr_order_number is null
   group by d_year, ws_item_sk, ws_bill_customer_sk
   ) where ws_sold_year=2000),
with cs as
  (select * from (select  d_year AS cs_sold_year, cs_item_sk,
    cs_bill_customer_sk cs_customer_sk,
    sum(cs_quantity) cs_qty,
    sum(cs_wholesale_cost) cs_wc,
    sum(cs_sales_price) cs_sp
   from catalog_sales
   join date_dim on cs_sold_date_sk = d_date_sk
   left join catalog_returns on cr_order_number=cs_order_number and cs_item_sk=cr_item_sk
   where cr_order_number is null
   group by d_year, cs_item_sk, cs_bill_customer_sk) where cs_sold_year = 2000
   ),
with ss as
(select* from  (select  d_year AS ss_sold_year, ss_item_sk,
    ss_customer_sk,
    sum(ss_quantity) ss_qty,
    sum(ss_wholesale_cost) ss_wc,
    sum(ss_sales_price) ss_sp
   from store_sales
   join date_dim on ss_sold_date_sk = d_date_sk
   left join store_returns on sr_ticket_number=ss_ticket_number and ss_item_sk=sr_item_sk
   where sr_ticket_number is null
   group by d_year, ss_item_sk, ss_customer_sk
   ) where ss_sold_year=2000)
select 
ss_sold_year, ss_item_sk, ss_customer_sk,
round(ss_qty/(coalesce(ws_qty+cs_qty,1)),2) ratio,
ss_qty store_qty, ss_wc store_wholesale_cost, ss_sp store_sales_price,
coalesce(ws_qty,0)+coalesce(cs_qty,0) other_chan_qty,
coalesce(ws_wc,0)+coalesce(cs_wc,0) other_chan_wholesale_cost,
coalesce(ws_sp,0)+coalesce(cs_sp,0) other_chan_sales_price
from ss
left join ws on (ws_item_sk=ss_item_sk and ws_customer_sk=ss_customer_sk)
left join cs on (cs_item_sk=cs_item_sk and cs_customer_sk=ss_customer_sk)
where coalesce(ws_qty,0)>0 and coalesce(cs_qty, 0)>0
order by 
  ss_item_sk, ss_customer_sk,
  store_qty desc, store_wholesale_cost desc, store_sales_price desc,
  other_chan_qty,
  other_chan_wholesale_cost,
  other_chan_sales_price
limit 100
;
