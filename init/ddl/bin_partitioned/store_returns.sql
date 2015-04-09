set hive.enforce.bucketing=true;
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.exec.max.dynamic.partitions.pernode=4096;
set mapred.job.reduce.input.buffer.percent=0.0;

create database if not exists ${DB};
use ${DB};

drop table if exists store_returns;

create table store_returns
(
    sr_returned_date_sk       int,
    sr_return_time_sk         int,
    sr_item_sk                int,
    sr_customer_sk            int,
    sr_cdemo_sk               int,
    sr_hdemo_sk               int,
    sr_addr_sk                int,
    sr_store_sk               int,
    sr_reason_sk              int,
    sr_ticket_number          int,
    sr_return_quantity        int,
    sr_return_amt             float,
    sr_return_tax             float,
    sr_return_amt_inc_tax     float,
    sr_fee                    float,
    sr_return_ship_cost       float,
    sr_refunded_cash          float,
    sr_reversed_charge        float,
    sr_store_credit           float,
    sr_net_loss               float
)
partitioned by (sr_returned_date string)
clustered by (sr_item_sk) sorted by (sr_item_sk) into ${RETURN_BUCKETS} buckets
row format serde '${SERDE}'
stored as ${FILE};

from (select
        /*+ MAPJOIN(dd) */
        sr.sr_returned_date_sk,
        sr.sr_return_time_sk,
        sr.sr_item_sk,
        sr.sr_customer_sk,
        sr.sr_cdemo_sk,
        sr.sr_hdemo_sk,
        sr.sr_addr_sk,
        sr.sr_store_sk,
        sr.sr_reason_sk,
        sr.sr_ticket_number,
        sr.sr_return_quantity,
        sr.sr_return_amt,
        sr.sr_return_tax,
        sr.sr_return_amt_inc_tax,
        sr.sr_fee,
        sr.sr_return_ship_cost,
        sr.sr_refunded_cash,
        sr.sr_reversed_charge,
        sr.sr_store_credit,
        sr.sr_net_loss,
        dd.d_date as sr_returned_date
      from ${SOURCE}.store_returns sr
      left outer join ${SOURCE}.date_dim dd
      on (sr.sr_returned_date_sk = dd.d_date_sk)) tbl
insert overwrite table store_returns partition (sr_returned_date) 
  select * where month(sr_returned_date) = 1
insert overwrite table store_returns partition (sr_returned_date) 
  select * where month(sr_returned_date) = 2
insert overwrite table store_returns partition (sr_returned_date) 
  select * where month(sr_returned_date) = 3
insert overwrite table store_returns partition (sr_returned_date) 
  select * where month(sr_returned_date) = 4
insert overwrite table store_returns partition (sr_returned_date) 
  select * where month(sr_returned_date) = 5
insert overwrite table store_returns partition (sr_returned_date) 
  select * where month(sr_returned_date) = 6
insert overwrite table store_returns partition (sr_returned_date) 
  select * where month(sr_returned_date) = 7
insert overwrite table store_returns partition (sr_returned_date) 
  select * where month(sr_returned_date) = 8
insert overwrite table store_returns partition (sr_returned_date) 
  select * where month(sr_returned_date) = 9
insert overwrite table store_returns partition (sr_returned_date) 
  select * where month(sr_returned_date) = 10
insert overwrite table store_returns partition (sr_returned_date) 
  select * where month(sr_returned_date) = 11
insert overwrite table store_returns partition (sr_returned_date) 
  select * where month(sr_returned_date) = 12
;
