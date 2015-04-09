
select /*+ MAPJOIN(web_page,date_dim) */
      substr(r_reason_desc,1,20) as r, avg(ws_quantity) as wq, avg(wr_refunded_cash) ref, avg(wr_fee) as fee
 from web_sales
 JOIN 
 (  select
    x.*,ca_country,ca_state
    from
    (  select /*+ MAPJOIN(reason,cd1,cd2) */
       r_reason_desc,wr_refunded_cash,wr_fee,wr_refunded_addr_sk
       ,cd1.cd_marital_status as cd1_marital_status, cd2.cd_education_status as cd2_education_status
       ,cd2.cd_marital_status as cd2_marital_status, cd1.cd_education_status as cd1_education_status
       ,wr_item_sk,wr_order_number 
       from web_returns
       JOIN reason ON reason.r_reason_sk = web_returns.wr_reason_sk
       JOIN customer_demographics cd1 ON cd1.cd_demo_sk = web_returns.wr_refunded_cdemo_sk 
       JOIN customer_demographics cd2 ON cd2.cd_demo_sk = web_returns.wr_returning_cdemo_sk
    ) x
    JOIN customer_address ON customer_address.ca_address_sk = x.wr_refunded_addr_sk
 ) y on  web_sales.ws_item_sk = y.wr_item_sk and web_sales.ws_order_number = y.wr_order_number
 JOIN web_page ON web_sales.ws_web_page_sk = web_page.wp_web_page_sk
 JOIN date_dim ON web_sales.ws_sold_date_sk = date_dim.d_date_sk
 where
   d_year = 1998
   and web_sales.ws_sold_date_sk between 2450815 and 2451179
   and
   (
    (
     cd1_marital_status = 'M'
     and
     cd1_marital_status = cd2_marital_status
     and
     cd1_education_status = '4 yr Degree'
     and 
     cd1_education_status = cd2_education_status
     and
     ws_sales_price >= 100.00 and ws_sales_price <= 150.00
    )
   or
    (
     cd1_marital_status = 'D'
     and
     cd1_marital_status = cd2_marital_status
     and
     cd1_education_status = 'Primary' 
     and
     cd1_education_status = cd2_education_status
     and
     ws_sales_price >= 50.00 and ws_sales_price <= 100.00
    )
   or
    (
     cd1_marital_status = 'U'
     and
     cd1_marital_status = cd2_marital_status
     and
     cd1_education_status = 'Advanced Degree'
     and
     cd1_education_status = cd2_education_status
     and
     ws_sales_price >= 150.00 and ws_sales_price <= 200.00
    )
   )
   and
   (
    (
     ca_country = 'United States'
     and
     ca_state in ('KY', 'GA', 'NM')
     and ws_net_profit >= 100 and ws_net_profit <= 200  
    )
    or
    (
     ca_country = 'United States'
     and
     ca_state in ('MT', 'OR', 'IN')
     and ws_net_profit >= 150 and ws_net_profit <= 300  
    )
    or
    (
     ca_country = 'United States'
     and
     ca_state in ('WI', 'MO', 'WV')
     and ws_net_profit >= 50 and ws_net_profit <= 250  
    )
   )
group by r_reason_desc
order by r, wq, ref, fee
limit 100;
