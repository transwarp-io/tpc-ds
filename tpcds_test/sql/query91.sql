with t as (
    select /*+MAPJOIN(customer_demographics, customer_address, household_demographics)*/ 
        cd_marital_status
       ,cd_education_status
       ,c_customer_sk
       
    from customer 
    join customer_demographics 
    on cd_demo_sk = c_current_cdemo_sk 
    join customer_address 
    on ca_address_sk = c_current_addr_sk 
    join household_demographics
    on hd_demo_sk = c_current_hdemo_sk 
    where ca_gmt_offset = -7 
    and ((cd_marital_status = 'M' and cd_education_status = 'Unknown')
       or(cd_marital_status = 'W' and cd_education_status = 'Advanced Degree'))
    and hd_buy_potential like '0-500%' )

select
        /*+MAPJOIN(t, call_center, date_dim)*/
        cc_call_center_id Call_Center,
        cc_name Call_Center_Name,
        cc_manager Manager,
        sum(cr_net_loss) Returns_Loss
from    t
join    catalog_returns 
on      cr_returning_customer_sk = c_customer_sk
join    date_dim
on      cr_returned_date_sk = d_date_sk
join    call_center
on      cr_call_center_sk       = cc_call_center_sk
where   d_year = 1999
and     d_moy  = 11
group by cc_call_center_id,cc_name,cc_manager,cd_marital_status,cd_education_status
order by Returns_Loss desc
limit 100
