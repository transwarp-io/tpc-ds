with ssr as (
select 
        s_store_id,
        sum(sales_price) as sales,
        sum(profit) as profit,
        sum(return_amt) as returns,
        sum(net_loss) as profit_loss
 from
  ( select  ss_store_sk as store_sk,
            ss_ext_sales_price as sales_price,
            ss_net_profit as profit,
            cast(0 as double) as return_amt,
            cast(0 as double) as net_loss
    from store_sales,
     date_dim
 where ss_sold_date_sk = d_date_sk
       and d_date between '1998-08-04' and '1998-08-18'
    union all
    select sr_store_sk as store_sk,
           cast(0 as double) as sales_price,
           cast(0 as double) as profit,
           sr_return_amt as return_amt,
           sr_net_loss as net_loss
    from store_returns,
     date_dim
 where sr_returned_date_sk = d_date_sk
       and d_date between '1998-08-04' and '1998-08-18'
   ) salesreturns1,
     store
 where 




       salesreturns1.store_sk = store.s_store_sk

 group by s_store_id),

 with csr as (
 select 
      cp_catalog_page_id,
        sum(sales_price) as sales,
        sum(profit) as profit,
        sum(return_amt) as returns,
        sum(net_loss) as profit_loss
 from
  ( select  cs_catalog_page_sk as page_sk,
            cs_ext_sales_price as sales_price,
            cs_net_profit as profit,
            cast(0 as double) as return_amt,
            cast(0 as double) as net_loss
    from catalog_sales, date_dim
    where cs_sold_date_sk = d_date_sk and d_date between '1998-08-04' and '1998-08-18'
    union all
    select cr_catalog_page_sk as page_sk,
           cast(0 as double) as sales_price,
           cast(0 as double) as profit,
           cr_return_amount as return_amt,
           cr_net_loss as net_loss
    from catalog_returns, date_dim
    where cr_returned_date_sk = d_date_sk and d_date between '1998-08-04' and '1998-08-18'
    
   ) salesreturns2,
     catalog_page
 where
       
        
       salesreturns2.page_sk = cp_catalog_page_sk

 group by cp_catalog_page_id),

 with wsr as(
  select 
        web_site_id,
        sum(sales_price) as sales,
        sum(profit) as profit,
        sum(return_amt) as returns,
        sum(net_loss) as profit_loss
 from
  ( select  ws_web_site_sk as wsr_web_site_sk,
            ws_ext_sales_price as sales_price,
            ws_net_profit as profit,
            cast(0 as double) as return_amt,
            cast(0 as double) as net_loss
    from web_sales, date_dim
    where ws_sold_date_sk = d_date_sk and d_date between '1998-08-04' and '1998-08-18'
    
    union all
    select ws_web_site_sk as wsr_web_site_sk,
           cast(0 as double) as sales_price,
           cast(0 as double) as profit,
           wr_return_amt as return_amt,
           wr_net_loss as net_loss
    from web_returns
	 join date_dim on wr_returned_date_sk = d_date_sk
	 left outer join web_sales on
         ( wr_item_sk = ws_item_sk
           and wr_order_number = ws_order_number)
    where d_date between '1998-08-04' and '1998-08-18'
   ) salesreturns3,
     web_site
 where 
       
       
       salesreturns3.wsr_web_site_sk = web_site_sk
 group by web_site_id)

select  channel
        , id
        , sum(sales) as sales
        , sum(returns) as returns
        , sum(profit) as profit
 from 
 (select 'store channel' as channel
        , 'store' || s_store_id as id
        , sales
        , returns
        , (profit - profit_loss) as profit
 from   ssr
 union all
 select 'catalog channel' as channel
        , 'catalog_page' || cp_catalog_page_id as id
        , sales
        , returns
        , (profit - profit_loss) as profit
 from  csr
 union all
 select 'web channel' as channel
        , 'web_site' || web_site_id as id
        , sales
        , returns
        , (profit - profit_loss) as profit
 from   wsr
 ) x
group by rollup (channel, id)
order by channel,id
limit 100
;

