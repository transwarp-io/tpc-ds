



with cs_ui as
 (select cs_item_sk
        ,sum(cs_ext_list_price) as sale,sum(cr_refunded_cash+cr_reversed_charge+cr_store_credit) as refund
  from catalog_sales
      ,catalog_returns
  where cs_item_sk = cr_item_sk
    and cs_order_number = cr_order_number
  group by cs_item_sk
  having sum(cs_ext_list_price)>2*sum(cr_refunded_cash+cr_reversed_charge+cr_store_credit)),
with cross_sales as
 (select  i_product_name product_name
     ,i_item_sk item_sk
     ,s_store_name store_name
     ,s_zip store_zip
     ,ss_filter.ca_street_number b_street_number
     ,ss_filter.ca_street_name b_streen_name
     ,ss_filter.ca_city b_city
     ,ss_filter.ca_zip b_zip
     ,cs_filter.ca_street_number c_street_number
     ,cs_filter.ca_street_name c_street_name
     ,cs_filter.ca_city c_city
     ,cs_filter.ca_zip c_zip
     ,ss_filter.d_year as syear
     ,ss_filter.d_year as fsyear
     ,ss_filter.d_year s2year
     ,count(*) cnt
     ,sum(ss_wholesale_cost) s1
     ,sum(ss_list_price) s2
     ,sum(ss_coupon_amt) s3
  FROM 
        store_returns,
	(select i_item_sk, i_product_name, d_year,s_store_name,s_zip
		,ss_customer_sk,ss_cdemo_sk,ss_item_sk,ss_ticket_number,ss_wholesale_cost, ss_list_price,ss_coupon_amt		
		,ca_street_number, ca_street_name, ca_city, ca_zip
	 from store_sales, date_dim, item, store, customer_address, promotion, household_demographics, income_band, cs_ui
	 where ss_sold_date_sk = d_date_sk AND
	      d_year in (2000, 2001) and
               ss_item_sk = i_item_sk and
               i_color in ('maroon','burnished','dim','steel','navajo','chocolate') and
	       i_current_price between 35 and 35 + 10 and
	       i_current_price between 35 + 1 and 35 + 15 and
        	 ss_item_sk = cs_ui.cs_item_sk and
	       ss_promo_sk = p_promo_sk and ss_hdemo_sk = hd_demo_sk AND hd_income_band_sk = ib_income_band_sk and
	       ss_store_sk = s_store_sk and 
	       ss_addr_sk = ca_address_sk) ss_filter, 
	(select c_customer_sk, c_current_cdemo_sk, ca_street_number, ca_street_name, ca_city, ca_zip
	 from  customer
        	,date_dim d2
		,date_dim d3
        	,customer_address
        	,household_demographics
	        ,income_band
	 where
         	c_first_sales_date_sk = d2.d_date_sk and c_current_hdemo_sk = hd_demo_sk and hd_income_band_sk = ib_income_band_sk and
	        c_first_shipto_date_sk = d3.d_date_sk and
         	c_current_addr_sk = ca_address_sk		
	 ) cs_filter
        ,customer_demographics cd1
        ,customer_demographics cd2
  WHERE
         ss_customer_sk = c_customer_sk AND
         ss_cdemo_sk= cd1.cd_demo_sk AND
         ss_item_sk = sr_item_sk and
         ss_ticket_number = sr_ticket_number and
         c_current_cdemo_sk = cd2.cd_demo_sk AND
         cd1.cd_marital_status <> cd2.cd_marital_status
group by i_product_name
       ,i_item_sk
       ,s_store_name
       ,s_zip
       ,ss_filter.ca_street_number
       ,ss_filter.ca_street_name
       ,ss_filter.ca_city
       ,ss_filter.ca_zip
       ,cs_filter.ca_street_number
       ,cs_filter.ca_street_name
       ,cs_filter.ca_city
       ,cs_filter.ca_zip
       ,ss_filter.d_year
       ,ss_filter.d_year
       ,ss_filter.d_year)
select cs1.product_name
     ,cs1.store_name
     ,cs1.store_zip
     ,cs1.b_street_number
     ,cs1.b_streen_name
     ,cs1.b_city
     ,cs1.b_zip
     ,cs1.c_street_number
     ,cs1.c_street_name
     ,cs1.c_city
     ,cs1.c_zip
     ,cs1.syear
     ,cs1.cnt
     ,cs1.s1
     ,cs1.s2
     ,cs1.s3
     ,cs2.s1
     ,cs2.s2
     ,cs2.s3
     ,cs2.syear
     ,cs2.cnt
from cross_sales cs1,cross_sales cs2
where cs1.item_sk=cs2.item_sk and
     cs1.syear = 2000 and
     cs2.syear = 2000 + 1 and
     cs2.cnt <= cs1.cnt and
     cs1.store_name = cs2.store_name and
     cs1.store_zip = cs2.store_zip
order by cs1.product_name
       ,cs1.store_name
       ,cs2.cnt
limit 100

