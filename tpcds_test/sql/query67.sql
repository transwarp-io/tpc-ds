
drop table sssd;
create table sssd stored as orc as 
    select ss_sales_price, ss_quantity, ss_store_sk, ss_item_sk, d_year, d_qoy, d_moy
    from store_sales, (select d_date_sk, d_year, d_qoy, d_moy from date_dim where d_month_seq between 1212 and 1212+11) ssd
    where ss_sold_date_sk = d_date_sk;

drop table subq;
create table subq stored as orc as
            select i_category, i_class, i_brand, i_product_name, s_store_id, ss_sales_price, ss_quantity, ss_store_sk, ss_item_sk, d_year, d_qoy, d_moy
            from sssd
                ,store
                ,item
            where  sssd.ss_item_sk = item.i_item_sk
            and sssd.ss_store_sk = store.s_store_sk;




select * from (
  select i_category
            ,i_class
            ,i_brand
            ,i_product_name
            ,d_year
            ,d_qoy
            ,d_moy
            ,s_store_id
            ,sumsales
            ,rank() over (partition by i_category order by sumsales desc) rk
      from (
	    select  i_category
                  ,i_class
                  ,i_brand
                  ,i_product_name
                  ,d_year
                  ,d_qoy
                  ,d_moy
                  ,s_store_id
                  ,sum(coalesce(subq.ss_sales_price * subq.ss_quantity,0)) sumsales
            from subq
            group by i_category, i_class, i_brand, i_product_name, d_year, d_qoy, d_moy, s_store_id

		union	    

	    select  i_category
                  ,i_class
                  ,i_brand
                  ,i_product_name
                  ,d_year
                  ,d_qoy
                  ,d_moy
                  ,NULL as s_store_id
                  ,sum(coalesce(subq.ss_sales_price * subq.ss_quantity,0)) sumsales
            from subq
            group by i_category, i_class, i_brand, i_product_name, d_year, d_qoy, d_moy

		union

	    select  i_category
                  ,i_class
                  ,i_brand
                  ,i_product_name
                  ,d_year
                  ,d_qoy
                  ,NULL as d_moy
                  ,NULL as s_store_id
                  ,sum(coalesce(ss_sales_price*ss_quantity,0)) sumsales
            from subq
            group by i_category, i_class, i_brand, i_product_name, d_year, d_qoy

		union

	    select  i_category
                  ,i_class
                  ,i_brand
                  ,i_product_name
                  ,d_year
                  ,NULL as d_qoy
                  ,NULL as d_moy
                  ,NULL as s_store_id
                  ,sum(coalesce(ss_sales_price*ss_quantity,0)) sumsales
            from subq
            group by i_category, i_class, i_brand, i_product_name, d_year

		union

	    select  i_category
                  ,i_class
                  ,i_brand
                  ,i_product_name
                  ,NULL as d_year
                  ,NULL as d_qoy
                  ,NULL as d_moy
                  ,NULL as s_store_id
                  ,sum(coalesce(ss_sales_price*ss_quantity,0)) sumsales
            from subq 
            group by i_category, i_class, i_brand, i_product_name
		
		union

	    select  i_category
                  ,i_class
                  ,i_brand
                  ,NULL as i_product_name
                  ,NULL as d_year
                  ,NULL as d_qoy
                  ,NULL as d_moy
                  ,NULL as s_store_id
                  ,sum(coalesce(ss_sales_price*ss_quantity,0)) sumsales
            from subq 
            group by i_category, i_class, i_brand

		union

	    select  i_category
                  ,i_class
                  ,NULL as i_brand
                  ,NULL as i_product_name
                  ,NULL as d_year
                  ,NULL as d_qoy
                  ,NULL as d_moy
                  ,NULL as s_store_id
                  ,sum(coalesce(ss_sales_price*ss_quantity,0)) sumsales
            from subq 
            group by i_category, i_class
	
		union
	    select  i_category
                  ,NULL as i_class
                  ,NULL as i_brand
                  ,NULL as i_product_name
                  ,NULL as d_year
                  ,NULL as d_qoy
                  ,NULL as d_moy
                  ,NULL as s_store_id
                  ,sum(coalesce(ss_sales_price*ss_quantity,0)) sumsales
            from subq 
            group by i_category

		union

	    select  NULL as i_category
                  ,NULL as i_class
                  ,NULL as i_brand
                  ,NULL as i_product_name
                  ,NULL as d_year
                  ,NULL as d_qoy
                  ,NULL as d_moy
                  ,NULL as s_store_id
                  ,sum(coalesce(ss_sales_price*ss_quantity,0)) sumsales
            from subq 
            group by NULL
       ) dw1
) dw2
where rk <= 100
order by i_category
        ,i_class
        ,i_brand
        ,i_product_name
        ,d_year
        ,d_qoy
        ,d_moy
        ,s_store_id
	,sumsales
        ,rk
limit 100
