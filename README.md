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
 


 
