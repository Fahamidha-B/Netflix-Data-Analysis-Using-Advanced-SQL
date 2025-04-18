

  # 📺 Netflix Data Analysis Using Advanced SQL

This project involves performing advanced SQL queries on the Netflix dataset to uncover insights about its content library. The analysis focuses on content type, ratings, genre, regional contributions, key personnel, and trends over time.

---

## 📌 Project Overview

Netflix, being one of the leading streaming services worldwide, hosts thousands of TV shows and movies.
Understanding patterns in content type, production countries, genres, ratings, and content creators helps identify opportunities for business strategy improvements.

This project explores these elements using SQL for structured, in-depth analysis.

---

## 🎯 Objectives

- Explore and analyze Netflix's content distribution.
- Solve specific business problems using advanced SQL queries.
- Provide key insights on user preferences, popular genres, and countries with rich content contribution.
- Help stakeholders identify trends and patterns to inform strategic decisions.

---

## 📁 Dataset

- **Dataset Name**: `netflix_titles.csv`
- **Source**: [Netflix via Kaggle](https://www.kaggle.com/shivamb/netflix-shows)
- **Size**: ~8,800+ rows
- **Fields**:
  - `show_id`
  - `type` (Movie/TV Show)
  - `title`
  - `director`
  - `cast`
  - `country`
  - `date_added`
  - `release_year`
  - `rating`
  - `duration`
  - `listed_in` (genre)
  - `description`

---

## Schema

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
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

## 💡 Business Problems and SQL Solutions

### 1. **Count the number of Movies vs TV Shows**
```sql

select type,count(*) as total_content
from netflix
group by type;

### 2. **Find the most common rating for movies and TV shows**

select type ,rating
from 
(
  select type,rating,count(*),
  rank() over(partition by type order by  count(*) desc) as ranking  -- rank function
  from netflix
  group by 1,2
) as T1
where ranking = 1;


## 3. **List all movies released in a specific year (e.g., 2020)**

select * 
from netflix
where type ='Movie' and  release_year=2020;

## 4. **Find the top 5 countries with the most content on Netflix**

SELECT * 
FROM
(
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY 1
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;

## 5. **Identify the Longest Movie**

SELECT 
    *
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;

## 6. **Find Content Added in the Last 5 Years**


SELECT*
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'  --converting string date into actual date formate then subtracting it with 5 years

## 7. **Find All Movies/TV Shows by Director 'Rajiv Chilaka'**
select *
from (SELECT 
        *,
        UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name   --- unnest used to seprate string to array formate if the reocrds holds delimiter
FROM netflix) as T1
where director like '%Rajiv Chilaka%';

## 8. **List All TV Shows with More Than 5 Seasons**

SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;  ------------1 defines splitted genre(unnest(STRING_TO_ARRAY(listed_in,',')))

## 9. **Count the Number of Content Items in Each Genre**

SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY 1;

## 10.**Find each year and the average numbers of content release in India on netflix.return top 5 years with average content relase**

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

## 11.**list all movies that are documentries**
select show_id,type, unnest(STRING_TO_ARRAY(listed_in,',')) as new_list
from netflix
where listed_in like '%Documentaries%' and type='Movie';

## 12.**find  all content without a director**


select * 
from netflix
where director is null;

## 13. **find how many movies actoe salman khan apperars last 10 years**


select *
from netflix
where casts ilike '%salman Khan%' and release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

 ## 14. ** Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India**


	SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;

## 15.**Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords**

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

