
select   
       count(*) as ct
from store, time_dim, store_sales, household_demographics
where
    store_sales.ss_sold_time_sk = time_dim.t_time_sk
    and store_sales.ss_store_sk = store.s_store_sk
    and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
    and   time_dim.t_hour = 8
    and time_dim.t_minute >= 30
    and household_demographics.hd_dep_count = 5
    and store.s_store_name = 'ese'
order by ct
limit 100;

