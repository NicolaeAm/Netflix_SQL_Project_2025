# Netflix Movies and TV Shows Data Analysis using SQL

![Netflix_Logo](https://github.com/NicolaeAm/Netflix_SQL_Project_2025/blob/main/Netflix_Logo_Print_FourColorCMYK.png)

## Project Overview 

  This project provides an in-depth analysis of Netflix’s global content catalog using SQL.
By exploring thousands of Movies and TV Shows, the goal is to uncover patterns, trends, and insights that can help understand Netflix’s content strategy — such as which countries produce the most content, what genres are dominant, and how content growth has evolved.

## Project Objective

  The objective of this project is to analyze Netflix’s catalog of Movies and TV Shows using SQL.
By leveraging SQL queries, we extract insights such as:
 -Total number of movies and shows available
 -Country-wise contributions
 -Common ratings
 -Top actors, directors, and genres
 -Yearly content additions
 -And other key business metrics about Netflix’s content trends.

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

