with ws_wh as
(select ws1.ws_order_number,ws1.ws_warehouse_sk wh1,ws2.ws_warehouse_sk wh2
 from web_sales ws1,web_sales ws2
 where ws1.ws_order_number = ws2.ws_order_number
   and ws1.ws_warehouse_sk <> ws2.ws_warehouse_sk
)
 select  /*+MAPJOIN(date_dim,customer_address,web_site)*/
   count(distinct ws_order_number) as order_count
  ,sum(ws_ext_ship_cost) as total_shipping_cost
  ,sum(ws_net_profit) as total_net_profit
 from
   web_sales ws1
  ,date_dim
  ,customer_address
  ,web_site
 where
    d_date between '1999-5-01' and 
           (cast('1999-5-01' as date) + interval '60' day)
 and ws1.ws_ship_date_sk = d_date_sk
 and ws1.ws_ship_addr_sk = ca_address_sk
 and ca_state = 'TX'
 and ws1.ws_web_site_sk = web_site_sk
 and web_company_name = 'pri'
 and ws1.ws_order_number in (select ws_order_number
                             from ws_wh)
order by order_count
limit 100;

