

with ss_items as
 (select  i_item_id item_id
        ,sum(ss_ext_sales_price) ss_item_rev 
 from (select ss_item_sk, ss_ext_sales_price from store_sales
     ,(select d_date_sk from date_dim
                  where d_date in (select d_date
                  from date_dim
                  where d_week_seq = (select d_week_seq
                                      from date_dim
                                      where d_date = '1998-02-19'))) ssd where ss_sold_date_sk = d_date_sk) sss
     ,item
 where ss_item_sk = i_item_sk
 group by i_item_id),
with cs_items as
 (select  i_item_id item_id
        ,sum(cs_ext_sales_price) cs_item_rev
  from (select cs_item_sk, cs_ext_sales_price from catalog_sales
      ,(select d_date_sk from date_dim
                  where d_date in (select d_date
                  from date_dim
                  where d_week_seq = (select d_week_seq
                                      from date_dim
                                      where d_date = '1998-02-19'))) csd where cs_sold_date_sk = d_date_sk) css
      ,item
 where cs_item_sk = i_item_sk
 group by i_item_id),
with ws_items as
 (select i_item_id item_id
        ,sum(ws_ext_sales_price) ws_item_rev
  from (select ws_item_sk, ws_ext_sales_price from web_sales
      ,(select d_date_sk from date_dim
                  where d_date in (select d_date
                  from date_dim
                  where d_week_seq = (select d_week_seq
                                      from date_dim
                                      where d_date = '1998-02-19'))) wsd where ws_sold_date_sk = d_date_sk) wss
      ,item
  where ws_item_sk = i_item_sk
 group by i_item_id)
select  ss_items.item_id
       ,ss_item_rev
       ,ss_item_rev/(ss_item_rev+cs_item_rev+ws_item_rev)/3 * 100 ss_dev
       ,cs_item_rev
       ,cs_item_rev/(ss_item_rev+cs_item_rev+ws_item_rev)/3 * 100 cs_dev
       ,ws_item_rev
       ,ws_item_rev/(ss_item_rev+cs_item_rev+ws_item_rev)/3 * 100 ws_dev
       ,(ss_item_rev+cs_item_rev+ws_item_rev)/3 average
 from ss_items,cs_items,ws_items
 where ss_items.item_id=cs_items.item_id
   and ss_items.item_id=ws_items.item_id 
   and ss_item_rev between 0.9 * cs_item_rev and 1.1 * cs_item_rev
   and ss_item_rev between 0.9 * ws_item_rev and 1.1 * ws_item_rev
   and cs_item_rev between 0.9 * ss_item_rev and 1.1 * ss_item_rev
   and cs_item_rev between 0.9 * ws_item_rev and 1.1 * ws_item_rev
   and ws_item_rev between 0.9 * ss_item_rev and 1.1 * ss_item_rev
   and ws_item_rev between 0.9 * cs_item_rev and 1.1 * cs_item_rev
 order by item_id
         ,ss_item_rev
limit 100
