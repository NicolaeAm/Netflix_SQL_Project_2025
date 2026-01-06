# Netflix Movies and TV Shows Data Analysis using SQL & Power BI

![Netflix_Logo](https://github.com/NicolaeAm/Netflix_SQL_Project_2025/blob/main/Netflix_Logo_Print_FourColorCMYK.png)

## Project Overview 

  This project provides an in-depth analysis of Netflix’s global content catalog using PostgreSQL for data analysis and Power BI for visualization and reporting.
By exploring thousands of Movies and TV Shows, the goal is to uncover patterns, trends, and insights that can help understand Netflix’s content strategy — such as which countries produce the most content, what genres are dominant, and how content growth has evolved.

## Project Objective

  The objective of this project is to analyze Netflix’s catalog of Movies and TV Shows using SQL.
By leveraging SQL queries, we extract insights such as:
 - Total number of movies and shows available
 - Country-wise contributions
 - Understand movie duration and rating patterns
 - Top actors, directors, and genres
 - Yearly content additions
 - Build a KPI-driven Power BI dashboard for stakeholders.

## Dataset Information
  The dataset used in this project is the Netflix Titles Dataset, the Public Kaggle Dataset.
  
 **Dataset Source:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Dataset Schema

 ```sql 
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
```
## Business Problem Statments & SQL Solutions

### 1. How many total Movies and TV Shows are available on Netflix?
``` sql
SELECT 
	type_,
	COUNT(*) AS total_content
FROM netflix
GROUP BY type_
;
```

**Objective:** Distribution between Movies and TV Shows.

### 2. How many movies were  released in 2022?
```sql
SELECT
	COUNT(*) AS total_released_2022
FROM netflix
	WHERE 
		type_ = 'Movie'
		AND
		release_year = 2022
;
```

**Objective:** Movie release trends.

### 3. What are the top 10 countries contributing the most content?

```sql
SELECT  
	UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
	COUNT(*) AS total_contributing
FROM netflix
GROUP BY new_country
ORDER BY total_contributing DESC 
LIMIT  10
;
```

 **Objective:** Top contributing countries.

 ### 4. Identify the longest movie in the  USA?

```sql
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
```

 **Objective:** Longest runtime film in the USA.

 ### 5. Find the most common rating for movies and TV shows?

```sql
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
```

 **Objective:** Popular audience rating.

 ### 6. Who are the top 10 most frequently featured directors on Netflix?

```sql
SELECT 
	TRIM(director) AS director_name,
	COUNT(*) AS total_titles
FROM netflix
WHERE director IS NOT NULL
	AND TRIM(director) <> ''
GROUP BY director_name 
ORDER BY total_titles DESC
LIMIT 10
;
```

**Objective:**  Most active directors.

### 7. Which actors appear most frequently in USA Movies on Netflix?

```sql
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
LIMIT 10
;
```

**Objective:**  Top 10 recurring actors.

### 8. Which year had the highest number of new content added?

```sql
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
LIMIT 3
;
```

**Objective:**  Peak years for new content.

### 9. Find how many movies actor 'Samuel L. Jackson' appeared in last 20 years?

 ```sql
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
```

**Objective:**  Actor’s Netflix presence.

### 10. Top 5 countries that contributed the most new content in the last 5 years?

```sql
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
LIMIT 5
;
```

**Objective:** Recent content trends.

### 11. Count the number of content items in each genre for the United States?

```sql
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(show_id) as total_content
FROM netflix
WHERE country iLIKE '%United States%'
GROUP BY 1
ORDER BY 2 DESC
;
```




**Objective:** Most popular genres.

### 12. Find each year and the average number of content releases in the USA on Netflix?
   --Return the top 5 years with the highest avg content release! 

```sql
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
```

**Objective:** Top content years.

## Insights & Findings

- Netflix hosts 6130 numbers of Movie and 2675 TV Shows.
- The United States, India, and United Kingdom are top contributors to Netflix’s library.
- TV-MA is the most common content rating.
- Rajiv Chilaka, RaÃºl Campos, and Jan Suter are among the most frequent directors.
- Samuel L. Jackson has appeared in 13 movies on Netflix within the last two decades.
- Popular genres in the USA include Dramas, Documentaries, and Comedies.

## Power BI Dashboard

The Power BI report provides an executive summary of Netflix’s content strategy through KPIs and interactive visuals.

![Power_BI_Dashboard](https://github.com/NicolaeAm/Netflix_SQL_Project_2025/blob/main/Power_BI_Netflix_Project_2025.jpg).

## KPI Cards (DAX Measures)
- Total Titles
- Total Movies
- Total TV Shows
- Average Movie Duration (Minutes)
- Titles Added in the Last 5 Years
- Average Years Since Release
- Countries with Content
- Average Genres per Title

## Visualizations (6 Charts)
- Movies vs TV Shows distribution
- Content growth by year
- Top 10 countries by content volume
- Genre distribution
- Rating distribution by content type
- Movie duration distribution

![PowerBI File:](https://github.com/NicolaeAm/Netflix_SQL_Project_2025/blob/main/Netflix_PowerBI_Project.pbix).

## DAX Example Measures
 - Average Movie Duration
```Avg Movie Duration =
AVERAGEX(
    FILTER(
        Netflix,
        Netflix[type_] = "Movie"
            && CONTAINSSTRING(Netflix[duration], "min")
    ),
    VALUE(SUBSTITUTE(Netflix[duration], " min", ""))
)
```
- Content Added in Last 5 Years
  
``` Titles Last 5 Years =
CALCULATE(
    COUNT(Netflix[show_id]),
    YEAR(Netflix[date_added]) >= YEAR(TODAY()) - 5
)
```

## Conclusion

This project demonstrates how SQL-driven data analysis and Power BI visualization work together to solve real business problems.By combining structured querying, DAX-based KPIs, and interactive dashboards, the project delivers insights that support content strategy, regional analysis, and catalog planning.

## Autor - Nicolae 

This project is part of my data analytics portfolio, showcasing SQL and Power BI skills relevant to data analyst roles. 













