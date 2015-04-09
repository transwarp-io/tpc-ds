set hive.enforce.bucketing=true;
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.exec.max.dynamic.partitions.pernode=4096;
set mapred.job.reduce.input.buffer.percent=0.0;

create database if not exists ${DB};
use ${DB};

drop table if exists web_returns;

create table web_returns
(
    wr_returned_date_sk       int,
    wr_returned_time_sk       int,
    wr_item_sk                int,
    wr_refunded_customer_sk   int,
    wr_refunded_cdemo_sk      int,
    wr_refunded_hdemo_sk      int,
    wr_refunded_addr_sk       int,
    wr_returning_customer_sk  int,
    wr_returning_cdemo_sk     int,
    wr_returning_hdemo_sk     int,
    wr_returning_addr_sk      int,
    wr_web_page_sk            int,
    wr_reason_sk              int,
    wr_order_number           int,
    wr_return_quantity        int,
    wr_return_amt             float,
    wr_return_tax             float,
    wr_return_amt_inc_tax     float,
    wr_fee                    float,
    wr_return_ship_cost       float,
    wr_refunded_cash          float,
    wr_reversed_charge        float,
    wr_account_credit         float,
    wr_net_loss               float
)
partitioned by (wr_returned_date string)
clustered by (wr_item_sk) sorted by (wr_item_sk) into ${RETURN_BUCKETS} buckets
row format serde '${SERDE}'
stored as ${FILE};

from (select
        /*+ MAPJOIN(dd) */
        wr.wr_returned_date_sk,
        wr.wr_returned_time_sk,
        wr.wr_item_sk,
        wr.wr_refunded_customer_sk,
        wr.wr_refunded_cdemo_sk,
        wr.wr_refunded_hdemo_sk,
        wr.wr_refunded_addr_sk,
        wr.wr_returning_customer_sk,
        wr.wr_returning_cdemo_sk,
        wr.wr_returning_hdemo_sk,
        wr.wr_returning_addr_sk,
        wr.wr_web_page_sk,
        wr.wr_reason_sk,
        wr.wr_order_number,
        wr.wr_return_quantity,
        wr.wr_return_amt,
        wr.wr_return_tax,
        wr.wr_return_amt_inc_tax,
        wr.wr_fee,
        wr.wr_return_ship_cost,
        wr.wr_refunded_cash,
        wr.wr_reversed_charge,
        wr.wr_account_credit,
        wr.wr_net_loss,
        dd.d_date as wr_returned_date
      from ${SOURCE}.web_returns wr
      left outer join ${SOURCE}.date_dim dd
      on (wr.wr_returned_date_sk = dd.d_date_sk)) tbl
insert overwrite table web_returns partition (wr_returned_date)
  select * where month(wr_returned_date) = 1
insert overwrite table web_returns partition (wr_returned_date)
  select * where month(wr_returned_date) = 2
insert overwrite table web_returns partition (wr_returned_date)
  select * where month(wr_returned_date) = 3
insert overwrite table web_returns partition (wr_returned_date)
  select * where month(wr_returned_date) = 4
insert overwrite table web_returns partition (wr_returned_date)
  select * where month(wr_returned_date) = 5
insert overwrite table web_returns partition (wr_returned_date)
  select * where month(wr_returned_date) = 6
insert overwrite table web_returns partition (wr_returned_date)
  select * where month(wr_returned_date) = 7
insert overwrite table web_returns partition (wr_returned_date)
  select * where month(wr_returned_date) = 8
insert overwrite table web_returns partition (wr_returned_date)
  select * where month(wr_returned_date) = 9
insert overwrite table web_returns partition (wr_returned_date)
  select * where month(wr_returned_date) = 10
insert overwrite table web_returns partition (wr_returned_date)
  select * where month(wr_returned_date) = 11
insert overwrite table web_returns partition (wr_returned_date)
  select * where month(wr_returned_date) = 12
;
