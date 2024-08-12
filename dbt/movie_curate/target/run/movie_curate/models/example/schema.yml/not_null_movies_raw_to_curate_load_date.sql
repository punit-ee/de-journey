select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select load_date
from `ee-india-se-data`.`movies_data_punit`.`movies_raw_to_curate`
where load_date is null



      
    ) dbt_internal_test