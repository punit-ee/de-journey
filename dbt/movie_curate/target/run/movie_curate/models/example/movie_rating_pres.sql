

  create or replace view `ee-india-se-data`.`movies_data_punit`.`movie_rating_pres`
  OPTIONS()
  as /*
    Welcome to your first dbt model!
    Did you know that you can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml

    Try changing "table" to "view" below
*/



WITH RATING_MEDIAN_DATA AS (
    SELECT distinct movieId,
                    PERCENTILE_CONT(rating, 0.5) OVER (PARTITION BY movieId) AS median,
                    COUNT(rating) over (partition by movieId) As rating_count
    FROM `ee-india-se-data`.`movies_data_punit`.`rating_raw_to_curate`
)

SELECT movieId              As Movie_Id,
       movie.original_title As Title,
       rating_count         As Number_Of_Rating,
       median               as Median_Rating,
       RANK() OVER (ORDER BY median desc) AS Movie_Rank
FROM RATING_MEDIAN_DATA
         JOIN `ee-india-se-data`.`movies_data_punit`.`movies_raw_to_curate` movie ON movie.id = RATING_MEDIAN_DATA.movieId


/*
    Uncomment the line below to remove records with null `id` values
*/;

