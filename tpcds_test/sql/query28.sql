
select avg(ss_list_price) B1_LP ,count(ss_list_price) B1_CNT
from store_sales
where ss_quantity  > 0 and ss_quantity < 5 and ( (ss_list_price > 145 and ss_list_price  < 155) or (ss_coupon_amt > 9000 and ss_coupon_amt < 10000) or (ss_wholesale_cost > 50 and ss_wholesale_cost < 71));
