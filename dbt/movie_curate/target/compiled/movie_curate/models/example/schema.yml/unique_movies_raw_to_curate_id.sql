
    
    

with dbt_test__target as (

  select id as unique_field
  from `ee-india-se-data`.`movies_data_punit`.`movies_raw_to_curate`
  where id is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


