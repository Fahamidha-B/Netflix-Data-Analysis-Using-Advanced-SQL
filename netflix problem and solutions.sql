--- drop table 
DROP TABLE IF EXISTS netflix;

-- query for create columns

CREATE TABLE netflix
(
    show_id      VARCHAR(15),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);

-- header name and csv file name should be same to import files in pssql

COPY netflix FROM 'C:\PostgreSQL_import\netflix.csv' DELIMITER ',' CSV HEADER; 

--- select all records from the file

select * from netflix;

----- find out the all reocrds are available

select count(*) as total_content
from netflix;

-- shows distinct types of movie content

select distinct type
from netflix;

select * from netflix;

--- qns 1. count no of movies and tv shows

select type,count(*) as total_content
from netflix
group by type;

------ qns 2  Find the most common rating for movies and TV shows


select * from netflix;

select type,rating
from netflix;

-- the datatypes of ratings are in varchar type rather than int type

select type,max(rating)
from netflix
group by type;


select type,rating,count(*) as total_ratings
from netflix
group by 1,2  -- 1 as type and 2 as rating
order by 3 desc; 


select type,rating,count(*) as total_ratings
from netflix
group by 1,2  -- 1 as type and 2 as rating
order by 1,3 desc; -- 1 as type and 3 total ratings digit

---  answer 2

select type ,rating
from 
(
  select type,rating,count(*),
  rank() over(partition by type order by  count(*) desc) as ranking  -- rank function
  from netflix
  group by 1,2
) as T1
where ranking = 1;


------------- qns 3 List all movies released in a specific year (e.g., 2020)

select * from netflix;

select * 
from netflix
where type ='Movie' and  release_year=2020;

----------- qns 4 Find the top 5 countries with the most content on Netflix

select country, count(*) as contents
from netflix
group by country;   --- in this case some countries are clubbed together

-- we have to split the country 1st then find out ans for qns

select string_to_array(country,',') as contens  -- string to array functions expects column and delimiter values to split
from netflix;


select unnest(string_to_array(country,',')) as countries
from netflix;  ----  countries are splitted but duplicated(repated twice)

select distinct(unnest(string_to_array(country,','))) as countries
from netflix;  --- this is perfect for splitting country using distinct fucntion

---or

select unnest(string_to_array(country,',')) as countries
from netflix
group by 1; ---this is perfect for splitting country using group by fucntion


select distinct(unnest(string_to_array(country,','))) as countries ,count(show_id) as total_count
from netflix
group by 1   -- 1 represent as [(unnest(string_to_array(country,',')) as countries)]
order by 2 desc;  --- 2 represent as [count(show_id) as total_count]

--- find out top 5 movies

select distinct(unnest(string_to_array(country,','))) as countries ,count(show_id) as total_count
from netflix
group by 1   -- 1 represent as [(unnest(string_to_array(country,',')) as countries)]
order by 2 desc--- 2 represent as [count(show_id) as total_count]
limit 5;  -- shows top 5 records


------ qns 5 identify the longest movie

select * from netflix;


select max(duration)
from netflix;

select *
from netflix
where type='Movie' and duration =(select max(duration)from netflix);  ---99 minutes is the longest duration of movie

---- qns 6 find content added in last 5 years


select date_added from netflix;
	
select *,TO_DATE(date_added,'Month DD,YYYY')  --- converting string date into actual date formate
from netflix;

SELECT *, TO_DATE(date_added, 'DD-Month-YY') AS formatted_date
FROM netflix;
select CURRENT_DATE - INTERVAL '5 years'   --- subtract current date with 5 years


SELECT*
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'  --converting string date into actual date formate then subtracting it with 5 years 


----------- qns  7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select * from netflix;

select *
from netflix
where director='Rajiv Chilaka';  --- only 19 records shows based on director name


select *
from netflix
where director like '%Rajiv Chilaka%';  -- now 22 reocrds shows based on director


select *
from netflix
where director ilike '%Rajiv Chilaka%';  -- for case sensitive letter

-- use substring form

SELECT 
        *,
        UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
FROM netflix;


select *
from (SELECT 
        *,
        UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name   --- unnest used to seprate string to array formate if the reocrds holds delimiter
FROM netflix) as T1
where director like '%Rajiv Chilaka%';


------- List All TV Shows with More Than 5 Seasons

select * from netflix;

select *
from netflix
where type ='TV Show' and duration >= '5 seasons';

select SPLIT_PART(duration,' ',1) as seasons  --- spit part function for spliting characters
from netflix
where type ='TV Show';

select * 
from netflix
where  type='TV Show' and  SPLIT_PART(duration,' ',1):: INT > 5;  ---- we use INT or Numeric

select * 
from netflix
where  type='TV Show' and  SPLIT_PART(duration,' ',1):: Numeric > 5;  ---- we use INT or Numeric


-- example for split part function

SELECT split_part('apple banana graps', ' ', 1) AS fruits;

SELECT split_part('apple banana graps', ' ',2) AS fruits;

SELECT split_part('apple banana graps', ' ', 3) AS fruits;

---------- qns 9	Count the Number of Content Items in Each Genre

select * from netflix;


select listed_in ,show_id   -- genre is mentioned in the name of listed in
from netflix;

select show_id,listed_in,STRING_TO_ARRAY(listed_in,',') as genre
from netflix;


select show_id,listed_in,STRING_TO_ARRAY(listed_in,',') as genre,unnest(STRING_TO_ARRAY(listed_in,',')) as splitted_genre
from netflix;

-- count no of content(show_id) in genre

select unnest(STRING_TO_ARRAY(listed_in,',')) as genre,
	count(show_id) as number_of_contents
from netflix
group by 1;  ------------1 defines splitted genre(unnest(STRING_TO_ARRAY(listed_in,',')))
	

--- qns 10.Find each year and the average numbers of content release in India on netflix.return top 5 years with average content relase

select * from netflix;

select date_added
from netflix
where country='india';

SELECT TO_DATE(date_added, 'DD-Mon-YY') AS date
FROM netflix
where country='india';

select count(show_id)::int/972
from netflix;




SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;


---------- qns 11 list all movies that are documentries

select * from netflix;


select * from netflix
where type='Movie' and listed_in like '%Documentaries%'  --- case sensitive 

select * from netflix
where type='Movie' and listed_in ilike '%documentaries%'  --- i like ignore case sensitive

select show_id,type, unnest(STRING_TO_ARRAY(listed_in,',')) as new_list
from netflix
where listed_in like '%Documentaries%' and type='Movie';


------ qns 12 find  al content without a director

select * from netflix;


select * 
from netflix
where director is null;

------ qns 13 find how many movies actoe salman khan apperars last 10 years

select * from netflix;

select *
from netflix
where casts ilike '%salman Khan%' and release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;


----  qns 14  Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

select * from netflix;

select * from netflix
where country ilike '%india%';

select show_id, unnest(STRING_TO_ARRAY(casts,','))as directors
from netflix
where country ilike '%india%'
limit 10;

SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;
	
------ 15.Categorize the content based on the presence of the keywords 'kill' and 'violence
--in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.

select *,
	case 
	when description ilike '%kill%'
		or description ilike '%violence%' then 'bad_content' 
		else 'good_content'
	end catergory
from netflix;


-- use CTE common table expression

WITH new_table AS (
  SELECT *,
    CASE 
      WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'bad_content' 
      ELSE 'good_content'
    END AS category
  FROM netflix
)

SELECT category, COUNT(*) as total_movie
FROM new_table
GROUP BY category
order by total_movie desc;






