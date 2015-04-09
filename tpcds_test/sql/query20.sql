 select /*+MAPJOIN(date_dim, item)*/
        i_item_desc 
       ,i_category 
       ,i_class
       ,i_item_id 
       ,i_current_price
       ,sum(cs_ext_sales_price) as itemrevenue 
       ,sum(cs_ext_sales_price)*100/sum(sum(cs_ext_sales_price)) over
           (partition by i_class) as revenueratio
 from	catalog_sales
     ,date_dim
     ,item 
 where cs_item_sk = i_item_sk 
   and cs_sold_date_sk = d_date_sk
   and i_category in ('Jewelry', 'Sports', 'Books')
   and cast(d_date as date) between cast('2001-01-12' as date) 
   and (cast('2001-01-12' as date) + INTERVAL '30' day)
 group by i_item_id
         ,i_item_desc 
         ,i_category
         ,i_class
         ,i_current_price
 order by i_category
         ,i_class
         ,i_item_id
         ,i_item_desc
         ,revenueratio
 limit 100;
