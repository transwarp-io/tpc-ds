

select
  ca_state,
  cd_gender,
  cd_marital_status,
  cd_dep_count,
  count(*) cnt1,
  avg(cd_dep_count),
  max(cd_dep_count),
  sum(cd_dep_count),
  cd_dep_employed_count,
  count(*) cnt2,
  avg(cd_dep_employed_count),
  max(cd_dep_employed_count),
  sum(cd_dep_employed_count),
  cd_dep_college_count,
  count(*) cnt3,
  avg(cd_dep_college_count),
  max(cd_dep_college_count),
  sum(cd_dep_college_count)
 from
  customer c,customer_address ca,customer_demographics
 where
  c.c_current_addr_sk = ca.ca_address_sk and
  cd_demo_sk = c.c_current_cdemo_sk
  and
  exists (select 1 
          from store_sales ss,date_dim dd1
          where c.c_customer_sk = ss.ss_customer_sk and
                ss.ss_sold_date_sk = dd1.d_date_sk and
                dd1.d_year = 1999 and
                dd1.d_qoy < 4)
   and
   exists (  select 1
             from 
             (select ws.ws_bill_customer_sk customsk
              from web_sales ws,date_dim dd2
              where ws.ws_sold_date_sk = dd2.d_date_sk and
                    dd2.d_year = 1999 and
                    dd2.d_qoy < 4
              union
              select cs.cs_ship_customer_sk customsk
              from catalog_sales cs,date_dim dd3
              where cs.cs_sold_date_sk = dd3.d_date_sk and
                    dd3.d_year = 1999 and
                    dd3.d_qoy < 4) x
              where c.c_customer_sk = x.customsk
           )
 group by ca_state,
          cd_gender,
          cd_marital_status,
          cd_dep_count,
          cd_dep_employed_count,
          cd_dep_college_count
 order by ca_state,
          cd_gender,
          cd_marital_status,
          cd_dep_count,
          cd_dep_employed_count,
          cd_dep_college_count
 
 limit 100;
