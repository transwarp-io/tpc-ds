




select   i_item_id,
        ca_country,
        ca_state,
        ca_county,
        avg( cast(cs_quantity as    decimal(12,2))) agg1,
        avg( cast(cs_list_price as  decimal(12,2))) agg2,
        avg( cast(cs_coupon_amt as  decimal(12,2))) agg3,
        avg( cast(cs_sales_price as decimal(12,2))) agg4,
        avg( cast(cs_net_profit as  decimal(12,2))) agg5,
        avg( cast(c_birth_year as   decimal(12,2))) agg6,
        avg( cast(x1.cd_dep_count as decimal(12,2))) agg7
 from (select 
	cs_quantity, cs_list_price, cs_coupon_amt, cs_sales_price, cs_net_profit, cs_item_sk, cs_bill_customer_sk, cd_dep_count
	from catalog_sales
	     ,date_dim
	     ,customer_demographics cd1
	where cs_bill_cdemo_sk = cd1.cd_demo_sk and
	      cs_sold_date_sk = d_date_sk and
	      cd1.cd_education_status = 'College' and
	      cd1.cd_gender = 'M' and
	      d_year = 2001) x1
     ,item
     ,customer_demographics cd2
     , (select  c_current_cdemo_sk, ca_country,ca_state,ca_county, c_customer_sk, c_birth_year
	from customer
	     ,customer_address
	where c_current_addr_sk = ca_address_sk and
	      c_birth_month in (9,5,12,4,1,10) and
	      ca_state in ('ND','WI','AL'
                   ,'NC','OK','MS','TN')
	      ) y1
 where

       cs_item_sk = i_item_sk and

       cs_bill_customer_sk = c_customer_sk and


       c_current_cdemo_sk = cd2.cd_demo_sk 





 group by rollup (i_item_id, ca_country, ca_state, ca_county)
 order by ca_country,
        ca_state,
        ca_county,
	i_item_id
 limit 100;
