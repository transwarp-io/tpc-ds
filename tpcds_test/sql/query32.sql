select /*+MAPJOIN(dm, it)*/ sum(cs.cs_ext_discount_amt)  as excess_discount_amount
from
   catalog_sales cs 
   ,date_dim dm 
   ,item it 
where
it.i_manufact_id = 269
and it.i_item_sk = cs.cs_item_sk
and dm.d_date between '1998-03-18' and
        (cast('1998-03-18' as date) + INTERVAL '90' day)
and dm.d_date_sk = cs.cs_sold_date_sk
and cs.cs_ext_discount_amt
     > (
         select
            1.3 * avg(cs1.cs_ext_discount_amt)
         from
            catalog_sales cs1
           ,date_dim dm1
         where
              cs1.cs_item_sk = it.i_item_sk                                                                                                                                                                                          
          and dm1.d_date between '1998-03-18' and
                             (cast('1998-03-18' as date) + INTERVAL '90' day)
          and dm1.d_date_sk = cs1.cs_sold_date_sk
      )  
limit 100
;
