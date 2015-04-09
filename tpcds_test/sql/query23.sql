with frequent_ss_items as 
 (select /*+MAPJOIN(date_dim,item)*/ substr(i_item_desc,1,30) itemdesc,i_item_sk item_sk,d_date solddate,count(*) cnt
  from store_sales
      ,date_dim 
      ,item
  where ss_sold_date_sk = d_date_sk
    and ss_item_sk = i_item_sk 
    and d_year in (1999,1999+1,1999+2,1999+3)
  group by substr(i_item_desc,1,30),i_item_sk,d_date
--  group by itemdesc,i_item_sk,d_date
  having count(*) >4),

with max_store_sales as
 (select max(csales) tpcds_cmax 
  from (select /*+MAPJOIN(date_dim)*/ c_customer_sk,sum(ss_quantity*ss_sales_price) csales
        from store_sales
            ,date_dim 
            ,customer
        where ss_customer_sk = c_customer_sk
         and ss_sold_date_sk = d_date_sk
         and d_year in (1999,1999+1,1999+2,1999+3) 
        group by c_customer_sk) x),

with best_ss_customer as
 (select c_customer_sk,sum(ss_quantity*ss_sales_price) ssales, tpcds_cmax
  from store_sales
      ,customer
      ,max_store_sales
  where ss_customer_sk = c_customer_sk
  group by c_customer_sk, tpcds_cmax
  having sum(ss_quantity*ss_sales_price) > (95/100.0) * tpcds_cmax
 )
select  sum(sales)
 from ( select  /*+MAPJOIN(date_dim)*/ cs_quantity*cs_list_price sales
        from catalog_sales
           ,date_dim 
        where d_year = 1999 
         and d_moy = 1 
         and cs_sold_date_sk = d_date_sk 
         and cs_item_sk in (select item_sk from frequent_ss_items)
         and cs_bill_customer_sk in (select c_customer_sk from best_ss_customer)
      union all
      select  /*+MAPJOIN(date_dim)*/ ws_quantity*ws_list_price sales
       from web_sales 
           ,date_dim 
       where d_year = 1999 
         and d_moy = 1 
         and ws_sold_date_sk = d_date_sk 
         and ws_item_sk in (select item_sk from frequent_ss_items)
         and ws_bill_customer_sk in (select c_customer_sk from best_ss_customer)
 ) y

