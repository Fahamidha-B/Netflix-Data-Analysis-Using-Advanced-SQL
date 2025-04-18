

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

select unnest(STRING_TO_ARRAY(listed_in,',')) as genre,
	count(show_id) as number_of_contents
from netflix
group by 1;  ------------1 defines splitted genre(unnest(STRING_TO_ARRAY(listed_in,',')))
	

