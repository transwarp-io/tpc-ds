





with ws_date as
( select  ws_sales_price, ws_bill_customer_sk, ws_item_sk
      from web_sales, date_dim 
      where d_qoy = 2 and d_year = 2000
        and ws_sold_date_sk = d_date_sk 
)
 select ca_zip, ca_county, sum(ws_sales_price)
 from
 (  select ca_zip, ca_county, ws_sales_price
     from
     (select  ca_zip, ca_county, c_customer_sk
	from customer_address, customer
	where c_current_addr_sk = ca_address_sk
             and substr(ca_zip,1,5) in ('85669', '86197','88274','83405','86475', '85392', '85460', '80348', '81792')
    )t
    , ws_date, item
    where ws_bill_customer_sk = c_customer_sk
 	and ws_item_sk = i_item_sk
 union all
    select  ca_zip, ca_county, ws_sales_price
     from ws_date, item, customer, customer_address
     where  ws_bill_customer_sk = c_customer_sk
        and c_current_addr_sk = ca_address_sk
	and ws_item_sk = i_item_sk
        and i_item_id in (select i_item_id
                             from item
                             where i_item_sk in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29)
                             )
)
 group by ca_zip, ca_county
 order by ca_zip, ca_county
 limit 100;
