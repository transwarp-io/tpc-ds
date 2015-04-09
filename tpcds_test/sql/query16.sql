select /* +MAPJOIN(date_dim, call_center)*/ 
  count(distinct cs1.cs_order_number) as order_count
  ,sum(cs1.cs_ext_ship_cost) as total_shipping_cost
  ,sum(cs1.cs_net_profit) as total_net_profit
from
   catalog_sales cs1
  ,date_dim
  ,call_center
  ,customer_address
where
    cast(d_date as date) between cast('1999-02-01' as date) and 
           (cast('1999-02-01' as date) + INTERVAL '60' day)
and cs1.cs_ship_date_sk = d_date_sk
and cs1.cs_ship_addr_sk = ca_address_sk
and ca_state = 'IL'
and cs1.cs_call_center_sk = cc_call_center_sk
and cc_county in ('Williamson County','Williamson County','Williamson County','Williamson County',
                  'Williamson County'
)
and exists (select 1
            from catalog_sales cs2
            where cs1.cs_order_number = cs2.cs_order_number
              and cs1.cs_warehouse_sk <> cs2.cs_warehouse_sk)
and not exists(select 1
               from catalog_returns cr1
               where cs1.cs_order_number = cr1.cr_order_number)
order by order_count
limit 100;
