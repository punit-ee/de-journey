
{{ config(materialized='table') }}
WITH rating_source as (SELECT *,
                        ROW_NUMBER() OVER(PARTITION BY userId, movieId ORDER BY timestamp desc) As row_num
                       FROM ee-india-se-data.movies_data_punit.rating_raw)
select SAFE_CAST(userId as NUMERIC)  as userId,
       SAFE_CAST(movieId as NUMERIC) as movieId,
       SAFE_CAST(rating as NUMERIC)  as rating,
       SAFE_CAST(timestamp as NUMERIC) as timestamp,
       CURRENT_DATE() as load_date
from rating_source
WHERE row_num = 1