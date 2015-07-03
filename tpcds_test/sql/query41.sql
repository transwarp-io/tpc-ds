
with subq as 
(
select i_manufact from item t where 
          (
              ( t.i_category = 'Women' and
                 (t.i_color = 'orchid' or t.i_color = 'papaya') and
                 (t.i_units = 'Pound' or t.i_units = 'Lb') and
                 (t.i_size = 'petite' or t.i_size = 'medium')
               ) or
               ( t.i_category = 'Women' and
                 (t.i_color = 'burlywood' or t.i_color = 'navy') and
                 (t.i_units = 'Bundle' or t.i_units = 'Each') and
                 (t.i_size = 'N/A' or t.i_size = 'extra large')
               ) or
               ( t.i_category = 'Men' and
                 (t.i_color = 'bisque' or t.i_color = 'azure') and
                 (t.i_units = 'N/A' or t.i_units = 'Tsp') and
                 (t.i_size = 'small' or t.i_size = 'large')
               ) or
               ( t.i_category = 'Men' and
                 (t.i_color = 'chocolate' or t.i_color = 'cornflower') and
                 (t.i_units = 'Bunch' or t.i_units = 'Gross') and
                 (t.i_size = 'petite' or t.i_size = 'medium')
               )
            or
              (  t.i_category = 'Women' and
                (t.i_color = 'salmon' or t.i_color = 'midnight') and
                (t.i_units = 'Oz' or t.i_units = 'Box') and
                (t.i_size = 'petite' or t.i_size = 'medium')
              ) or
              (  t.i_category = 'Women' and
                (t.i_color = 'snow' or t.i_color = 'steel') and
                (t.i_units = 'Carton' or t.i_units = 'Tbl') and
                (t.i_size = 'N/A' or t.i_size = 'extra large')
              ) or
              (  t.i_category = 'Men' and
                (t.i_color = 'purple' or t.i_color = 'gainsboro') and
                (t.i_units = 'Dram' or t.i_units = 'Unknown') and
                (t.i_size = 'small' or t.i_size = 'large')
              ) or
              (  t.i_category = 'Men' and
                (t.i_color = 'metallic' or t.i_color = 'forest') and
                (t.i_units = 'Gram' or t.i_units = 'Ounce') and
                (t.i_size = 'petite' or t.i_size = 'medium')
              )
           )
)
select  distinct(i_product_name)
 from item i1
 where exists ( 
          select count(*) as item_cnt
          from subq tt
          where
          tt.i_manufact = i1.i_manufact 
  )
 and i_manufact_id between 742 and 742+40
 order by i_product_name
 limit 100;

