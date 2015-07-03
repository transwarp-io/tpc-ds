
select 
   s_store_name ,s_company_id ,s_street_number ,s_street_name ,s_street_type
  ,s_suite_number ,s_city ,s_county ,s_state ,s_zip
  ,sum(case when (sr_returned_date_sk - ss_sold_date_sk <= 30 ) then 1 else 0 end)  as 30days
  ,sum(case when (sr_returned_date_sk - ss_sold_date_sk > 30) and
                 (sr_returned_date_sk - ss_sold_date_sk <= 60) then 1 else 0 end )  as 3160days
  ,sum(case when (sr_returned_date_sk - ss_sold_date_sk > 60) and
                 (sr_returned_date_sk - ss_sold_date_sk <= 90) then 1 else 0 end)  as 6190days
  ,sum(case when (sr_returned_date_sk - ss_sold_date_sk > 90) and
                 (sr_returned_date_sk - ss_sold_date_sk <= 120) then 1 else 0 end)  as 91120days
  ,sum(case when (sr_returned_date_sk - ss_sold_date_sk  > 120) then 1 else 0 end)  as 120days
from
  store_sales
  JOIN
  (  select  sr_ticket_number, sr_item_sk, sr_returned_date_sk, sr_customer_sk
     from store_returns
     JOIN date_dim d2 ON store_returns.sr_returned_date_sk   = d2.d_date_sk
     where d2.d_year = 2000 and d2.d_moy  = 9
  ) x ON
    store_sales.ss_ticket_number = x.sr_ticket_number
and store_sales.ss_item_sk = x.sr_item_sk
and store_sales.ss_customer_sk = x.sr_customer_sk
  JOIN date_dim d1 ON store_sales.ss_sold_date_sk   = d1.d_date_sk
  JOIN store ON store_sales.ss_store_sk = store.s_store_sk
group by
   s_store_name ,s_company_id ,s_street_number ,s_street_name ,s_street_type ,s_suite_number
  ,s_city ,s_county ,s_state ,s_zip
order by s_store_name ,s_company_id ,s_street_number ,s_street_name ,s_street_type
        ,s_suite_number ,s_city ,s_county ,s_state ,s_zip
limit 100;
