select /*+ MAPJOIN(x, date_dim)*/
        i_item_id
       ,i_item_desc
       ,i_current_price
from
( select /*+ MAPJOIN(item)*/ i_item_sk,i_item_desc,i_current_price,i_item_id
  from catalog_sales join item on cs_item_sk = i_item_sk where i_manufact_id in (678,964,918,849) 
) x
join inventory on inv_item_sk = i_item_sk
join date_dim  on d_date_sk=inv_date_sk
where d_date between cast('2001-06-02' as date) and (cast('2001-06-02' as date) +  INTERVAL '60' day)
      and inv_quantity_on_hand between 100 and 500
group by i_item_id,i_item_desc,i_current_price
order by i_item_id
limit 100;

