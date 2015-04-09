select
i_brand_id, i_brand, i_manufact_id, i_manufact, sum(ss_ext_sales_price) ext_price
from customer_address,
( select
  ss_customer_sk, ss_ext_sales_price, i_brand, i_brand_id, i_manufact_id, i_manufact, c_current_addr_sk, s_zip 
  from customer,
  ( select /*+MAPJOIN(date_dim,item,store)*/
    ss_customer_sk, ss_ext_sales_price, i_brand, i_brand_id, i_manufact_id, i_manufact, s_zip
    from date_dim
       , store_sales
       , item
       , store
    where d_date_sk = ss_sold_date_sk
      and ss_item_sk = i_item_sk
      and i_manager_id=7
      and d_moy=11
      and d_year=1999
      and ss_store_sk = s_store_sk )x 
  where x.ss_customer_sk = c_customer_sk ) y 
where y.c_current_addr_sk = ca_address_sk
  and substr(ca_zip,1,5) <> substr(y.s_zip,1,5) 
group by i_brand
     ,i_brand_id
     ,i_manufact_id
     ,i_manufact
order by ext_price desc
        ,i_brand
        ,i_brand_id
        ,i_manufact_id
        ,i_manufact
limit 100
;
