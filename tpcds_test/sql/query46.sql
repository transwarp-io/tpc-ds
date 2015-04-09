
select
        c_last_name
       ,c_first_name
       ,ca_city
       ,bought_city
       ,ss_ticket_number
       ,amt,profit 
 from
   (select /*+ MAPJOIN(date_dim, store, hd) */
           ss_ticket_number
          ,ss_customer_sk
          ,ca_city as bought_city
          ,sum(ss_coupon_amt) as amt
          ,sum(ss_net_profit) as profit
    from store_sales
         JOIN store ON store_sales.ss_store_sk = store.s_store_sk  
         JOIN date_dim ON store_sales.ss_sold_date_sk = date_dim.d_date_sk
         join (select hd_demo_sk 
               from household_demographics
               where household_demographics.hd_dep_count = 5 or household_demographics.hd_vehicle_count= 3
              ) hd
         ON store_sales.ss_hdemo_sk = hd.hd_demo_sk
         JOIN customer_address ON store_sales.ss_addr_sk = customer_address.ca_address_sk
    where  date_dim.d_dow in (6,0)  and date_dim.d_year in (1999,2000,2001) and store.s_city in ('Midway','Fairview') 
    group by ss_ticket_number,ss_customer_sk,ss_addr_sk,ca_city) dn
  JOIN customer ON dn.ss_customer_sk = customer.c_customer_sk
  JOIN customer_address ON customer.c_current_addr_sk = customer_address.ca_address_sk
  where customer_address.ca_city <> dn.bought_city
  order by c_last_name
          ,c_first_name
          ,ca_city
          ,bought_city
          ,ss_ticket_number
  limit 100;
