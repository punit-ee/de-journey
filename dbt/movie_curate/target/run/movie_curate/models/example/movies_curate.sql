
  
    

    create or replace table `ee-india-se-data`.`movies_data_punit`.`movies_curate`
      
    
    

    OPTIONS()
    as (
      /*
    Welcome to your first dbt model!
    Did you know that you can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml

    Try changing "table" to "view" below
*/



WITH movie_source as (SELECT *
                      from ee-india-se-data.movies_data_punit.movies_raw)
SELECT SAFE_CAST(adult AS boolean)                          as adult,
       PARSE_JSON(JSON_EXTRACT(belongs_to_collection, "$")) as belongs_to_collection,
       SAFE_CAST(budget as Numeric)                         as budget,
       PARSE_JSON(JSON_EXTRACT(genres, "$"))                as genres,
       homepage,
       SAFE_CAST(id as Numeric)                             as id,
       imdb_id,
       original_language,
       original_title,
       overview,
       SAFE_CAST(popularity as NUMERIC)                     as popularity,
       poster_path,
       PARSE_JSON(JSON_EXTRACT(production_companies, "$"))  as production_companies,
       PARSE_JSON(JSON_EXTRACT(production_countries, "$"))  as production_countries,
       SAFE_CAST(release_date As DATE FORMAT 'YYYY-MM-DD')  as release_date,
       SAFE_CAST(revenue as NUMERIC)                        as revenue,
       SAFE_CAST(runtime as NUMERIC)                        as runtime,
       PARSE_JSON(JSON_EXTRACT(spoken_languages, "$"))      as spoken_languages,
       status,
       tagline,
       title,
       SAFE_CAST(video as boolean)                          as video,
       SAFE_CAST(vote_average as NUMERIC)                   as vote_average,
       SAFE_CAST(vote_count as NUMERIC)                     as vote_count,
       CURRENT_DATE()                                       as load_date
FROM movie_source
/*
    Uncomment the line below to remove records with null `id` values
*/

-- where id is not null
    );
  