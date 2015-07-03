select  i_item_desc
      ,w_warehouse_name
      ,d1.d_week_seq
      ,count(case when p_promo_sk is null then 1 else 0 end) no_promo
      ,count(case when p_promo_sk is not null then 1 else 0 end) promo
      ,count(*) total_cnt
from catalog_sales cs
join date_dim d1 on (cs.cs_sold_date_sk = d1.d_date_sk)
join customer_demographics cd on (cs.cs_bill_cdemo_sk = cd.cd_demo_sk)
join household_demographics hd on (cs.cs_bill_hdemo_sk = hd.hd_demo_sk)
join date_dim d3 on (cs.cs_ship_date_sk = d3.d_date_sk)
join item it on (it.i_item_sk = cs.cs_item_sk)
join (
  select d2.d_week_seq, inv.inv_item_sk inv_item_sk, inv_quantity_on_hand, w_warehouse_name
  from
  inventory inv 
  join date_dim d2 on (inv.inv_date_sk = d2.d_date_sk)
  join warehouse wh on (wh.w_warehouse_sk=inv.inv_warehouse_sk)

) x
on cs.cs_item_sk = x.inv_item_sk and d1.d_week_seq = x.d_week_seq
left outer join promotion pm on (cs.cs_promo_sk=pm.p_promo_sk)
left outer join catalog_returns cr on (cr.cr_item_sk = cs.cs_item_sk and cr.cr_order_number = cs.cs_order_number)
where x.inv_quantity_on_hand < cs.cs_quantity
  and hd.hd_buy_potential = '1001-5000'
  and d1.d_year = 2001
  and cd.cd_marital_status = 'M'
  and cast(d3.d_date as date) > (cast(d1.d_date as date) + INTERVAL '5' day)  
group by i_item_desc,w_warehouse_name,d1.d_week_seq
order by total_cnt desc, i_item_desc, w_warehouse_name, d_week_seq
limit 100
