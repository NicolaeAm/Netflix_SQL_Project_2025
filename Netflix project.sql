DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(15),
    type_        VARCHAR(10),
    title        VARCHAR(150),
    director     VARCHAR(210),
    casts        VARCHAR(1050),
    country      VARCHAR(150),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(150),
    description  VARCHAR(250)
);


SELECT * 
FROM netflix
LIMIT 100;

SELECT
	COUNT(*) AS total_content 
FROM netflix
;

SELECT 
rating 
FROM netflix
GROUP BY rating
;


--1.How many total Movies and TV Shows are available on Netflix?

SELECT 
	type_,
	COUNT(*) AS total_content
FROM netflix
GROUP BY type_
;

--2.How many movies released in 2022 year?

SELECT
	COUNT(*) AS total_released_2022
FROM netflix
	WHERE 
		type_ = 'Movie'
		AND
		release_year = 2022
;

--3.What are the top 10 countries contributing the most content?

SELECT  
	UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
	COUNT(*) AS total_contributing
FROM netflix
GROUP BY new_country
ORDER BY total_contributing DESC 
LIMIT  10
;

--4.Identify the longest movie in USA?

SELECT 
title,
duration,
type_,
FROM netflix
WHERE 
	type_ = 'Movie'
	AND
	duration = (SELECT MAX(duration) FROM netflix)
	AND country = 'United States'
;


--5.Find the most common rating for movies and TV shows?

SELECT  
	type_,
	rating
FROM
(
	SELECT  
			type_,
			rating,
			count(*), 
			RANK() OVER(PARTITION BY type_ ORDER BY COUNT(*) DESC) as common_rating
	FROM netflix
	GROUP BY type_, rating
	ORDER BY type_
	)r
WHERE common_rating = 1
;

--6.Who are the top 10 most frequently featured directors on Netflix?

SELECT 
	TRIM(director) AS director_name,
	COUNT(*) AS total_titles
FROM netflix
WHERE director IS NOT NULL
	AND TRIM(director) <> ''
GROUP BY director_name 
ORDER BY total_titles DESC
LIMIT 10;

--7.Which actors appear most frequently in USA Movies on Netflix?

WITH american_movies AS (
    SELECT
		show_id,
		casts
    FROM netflix
    WHERE country ILIKE '%United States%'
      AND type_ = 'Movie'
      AND casts IS NOT NULL
      AND TRIM(casts) <> ''
),
actors AS (
    SELECT
		show_id,
        TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS all_actor
    FROM american_movies
)
SELECT
	all_actor,
    COUNT(*) AS total_movies
FROM actors
GROUP BY all_actor
ORDER BY total_movies DESC
LIMIT 10;

--8.Which year had the highest number of new content added?

SELECT
    EXTRACT(YEAR FROM new_date)::numeric AS year_added,
    COUNT(*) AS yearly_content_added
FROM (
 	 SELECT
        show_id,
        CASE
            WHEN date_added IS NULL OR TRIM(date_added) = '' THEN NULL
            WHEN date_added ~ '^[0-9]'
                THEN TO_DATE(date_added, 'DD-Mon-YY')
            ELSE
                TO_DATE(TRIM(date_added), 'Month DD, YYYY')
        END AS new_date
    FROM netflix
)  sub
WHERE new_date IS NOT NULL
GROUP BY year_added
ORDER BY yearly_content_added DESC
LIMIT 3;

--8.Find how many movies actor 'Samuel L. Jackson' appeared in last 20?
 
SELECT
	COUNT(*) AS total_movies_last_20
FROM (
	SELECT
		TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS total_actors,
		release_year
	FROM netflix  
	WHERE type_ = 'Movie'
		AND casts IS NOT NULL
		AND TRIM(casts) <> ''
	) AS sub
			
WHERE
	total_actors Ilike 'Samuel L. Jackson' 
	AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 20
;

--9. Top 5 countries contributed the most new content in the last 5 years?

WITH contribution AS (
    SELECT
        show_id,
        CASE
            WHEN date_added IS NULL OR TRIM(date_added) = '' THEN NULL
            WHEN date_added ~ '^[0-9]'
                THEN TO_DATE(date_added, 'DD-Mon-YY')
            ELSE
                TO_DATE(TRIM(date_added), 'Month DD, YYYY')
        END AS new_date,
        country
    FROM netflix
),
recent AS (
    SELECT
        show_id,
        UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
        new_date
    FROM contribution
    WHERE new_date >= CURRENT_DATE - INTERVAL '5 years'
      AND country IS NOT NULL AND TRIM(country) <> ''
)
SELECT
    new_country AS country,
    COUNT(*) AS total_content
FROM recent
GROUP BY new_country
ORDER BY total_content DESC
LIMIT 5;

--10.Count the number of content items in the each genre for United States?

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(show_id) as total_content
FROM netflix
WHERE country iLIKE '%United States%'
GROUP BY 1
ORDER BY 2 DESC;


--11.Find each year and the average numbers of content realease in USA on netflix?
   --Retun top 5 years with highest avg content realease! 
SELECT 
	country,
    EXTRACT(YEAR FROM new_date) AS year,
    COUNT(*) AS yearly_content,
	ROUND(
	COUNT(*)::numeric/(SELECT COUNT(*)::numeric FROM netflix WHERE country = 'United States') * 100
	,2) AS avg_content_per_yer
FROM (
    SELECT 
        n.*,
        CASE
            WHEN date_added ~ '^[0-9]' 
                THEN TO_DATE(date_added, 'DD-Mon-YY')
            ELSE 
                TO_DATE(TRIM(date_added), 'Month DD, YYYY')
        END AS new_date
    FROM netflix n
    WHERE country = 'United States'
) sub
GROUP BY year, country
ORDER BY yearly_content DESC
LIMIT 5
;
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	