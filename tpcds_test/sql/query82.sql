


with t as (
select
       
        i_item_id
       ,i_item_desc
       ,i_current_price
       ,i_item_sk
from   inventory
join   item
on     inv_item_sk = i_item_sk
join   date_dim
on     d_date_sk=inv_date_sk
where  i_current_price between 30 and 30+30
and    d_date between cast('2002-05-30' as date) and (cast('2002-05-30' as date) + interval '60' day)
and    i_manufact_id in (437,129,727,663)
and    inv_quantity_on_hand between 100 and 500)


select 
       
        i_item_id
       ,i_item_desc
       ,i_current_price
from
       store_sales
join   t
on     ss_item_sk = i_item_sk
group by i_item_id,i_item_desc,i_current_price
order by i_item_id
limit 100



