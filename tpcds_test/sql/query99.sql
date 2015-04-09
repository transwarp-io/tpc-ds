select
   /*+MAPJOIN(warehouse ,ship_mode ,call_center ,date_dim)*/  
   substr(w_warehouse_name,1,20) sub_warehouse
  ,sm_type
  ,cc_name
  ,sum(case when (cs_ship_date_sk - cs_sold_date_sk <= 30 ) then 1 else 0 end)  as 30days 
  ,sum(case when (cs_ship_date_sk - cs_sold_date_sk > 30) and 
                 (cs_ship_date_sk - cs_sold_date_sk <= 60) then 1 else 0 end )  as 3160days 
  ,sum(case when (cs_ship_date_sk - cs_sold_date_sk > 60) and 
                 (cs_ship_date_sk - cs_sold_date_sk <= 90) then 1 else 0 end)  as 6190days 
  ,sum(case when (cs_ship_date_sk - cs_sold_date_sk > 90) and
                 (cs_ship_date_sk - cs_sold_date_sk <= 120) then 1 else 0 end)  as 91120days 
  ,sum(case when (cs_ship_date_sk - cs_sold_date_sk  > 120) then 1 else 0 end)  as 120days 
from
   catalog_sales
  ,date_dim
  ,warehouse
  ,ship_mode
  ,call_center
where
    d_month_seq between 1212 and 1212 + 11
and cs_ship_date_sk   = d_date_sk
and cs_warehouse_sk   = w_warehouse_sk
and cs_ship_mode_sk   = sm_ship_mode_sk
and cs_call_center_sk = cc_call_center_sk
group by
   substr(w_warehouse_name,1,20)
  ,w_warehouse_name
  ,sm_type
  ,cc_name
order by 
         sub_warehouse
        ,sm_type
        ,cc_name
limit 100;

