set hive.enforce.bucketing=true;
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.exec.max.dynamic.partitions.pernode=4096;
set mapred.job.reduce.input.buffer.percent=0.0;

create database if not exists ${DB};
use ${DB};

drop table if exists catalog_sales;

create table catalog_sales
(
    cs_sold_date_sk           int,
    cs_sold_time_sk           int,
    cs_ship_date_sk           int,
    cs_bill_customer_sk       int,
    cs_bill_cdemo_sk          int,
    cs_bill_hdemo_sk          int,
    cs_bill_addr_sk           int,
    cs_ship_customer_sk       int,
    cs_ship_cdemo_sk          int,
    cs_ship_hdemo_sk          int,
    cs_ship_addr_sk           int,
    cs_call_center_sk         int,
    cs_catalog_page_sk        int,
    cs_ship_mode_sk           int,
    cs_warehouse_sk           int,
    cs_item_sk                int,
    cs_promo_sk               int,
    cs_order_number           int,
    cs_quantity               int,
    cs_wholesale_cost         float,
    cs_list_price             float,
    cs_sales_price            float,
    cs_ext_discount_amt       float,
    cs_ext_sales_price        float,
    cs_ext_wholesale_cost     float,
    cs_ext_list_price         float,
    cs_ext_tax                float,
    cs_coupon_amt             float,
    cs_ext_ship_cost          float,
    cs_net_paid               float,
    cs_net_paid_inc_tax       float,
    cs_net_paid_inc_ship      float,
    cs_net_paid_inc_ship_tax  float,
    cs_net_profit             float
)
partitioned by (cs_sold_date string)
clustered by (cs_item_sk) sorted by (cs_item_sk) into ${BUCKETS} buckets
row format serde '${SERDE}'
stored as ${FILE};

from (select
        /*+ MAPJOIN(dd) */
        cs.cs_sold_date_sk,
        cs.cs_sold_time_sk,
        cs.cs_ship_date_sk,
        cs.cs_bill_customer_sk,
        cs.cs_bill_cdemo_sk,
        cs.cs_bill_hdemo_sk,
        cs.cs_bill_addr_sk,
        cs.cs_ship_customer_sk,
        cs.cs_ship_cdemo_sk,
        cs.cs_ship_hdemo_sk,
        cs.cs_ship_addr_sk,
        cs.cs_call_center_sk,
        cs.cs_catalog_page_sk,
        cs.cs_ship_mode_sk,
        cs.cs_warehouse_sk,
        cs.cs_item_sk,
        cs.cs_promo_sk,
        cs.cs_order_number,
        cs.cs_quantity,
        cs.cs_wholesale_cost,
        cs.cs_list_price,
        cs.cs_sales_price,
        cs.cs_ext_discount_amt,
        cs.cs_ext_sales_price,
        cs.cs_ext_wholesale_cost,
        cs.cs_ext_list_price,
        cs.cs_ext_tax,
        cs.cs_coupon_amt,
        cs.cs_ext_ship_cost,
        cs.cs_net_paid,
        cs.cs_net_paid_inc_tax,
        cs.cs_net_paid_inc_ship,
        cs.cs_net_paid_inc_ship_tax,
        cs.cs_net_profit,
        dd.d_date as cs_sold_date
      from ${SOURCE}.catalog_sales cs
      left outer join ${SOURCE}.date_dim dd
      on (cs.cs_sold_date_sk = dd.d_date_sk)) tbl
insert overwrite table catalog_sales partition (cs_sold_date) 
  select * where month(cs_sold_date) = 1
insert overwrite table catalog_sales partition (cs_sold_date) 
  select * where month(cs_sold_date) = 2
insert overwrite table catalog_sales partition (cs_sold_date) 
  select * where month(cs_sold_date) = 3
insert overwrite table catalog_sales partition (cs_sold_date) 
  select * where month(cs_sold_date) = 4
insert overwrite table catalog_sales partition (cs_sold_date) 
  select * where month(cs_sold_date) = 5
insert overwrite table catalog_sales partition (cs_sold_date) 
  select * where month(cs_sold_date) = 6
insert overwrite table catalog_sales partition (cs_sold_date) 
  select * where month(cs_sold_date) = 7
insert overwrite table catalog_sales partition (cs_sold_date) 
  select * where month(cs_sold_date) = 8
insert overwrite table catalog_sales partition (cs_sold_date) 
  select * where month(cs_sold_date) = 9
insert overwrite table catalog_sales partition (cs_sold_date) 
  select * where month(cs_sold_date) = 10
insert overwrite table catalog_sales partition (cs_sold_date) 
  select * where month(cs_sold_date) = 11
insert overwrite table catalog_sales partition (cs_sold_date) 
  select * where month(cs_sold_date) = 12
;
