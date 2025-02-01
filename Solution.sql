SELECT 
	COUNT(*) AS "Total Content" 
FROM netflix;

SELECT 
	DISTINCT type
FROM netflix;

SELECT * FROM netflix;

-- 1. Count the number of movies vs TV Shows 
SELECT 
	type AS "Type", COUNT(*) AS "Total Count" 
FROM 
	netflix
GROUP BY type;

-- 2 Find the most common rating of Movies and TV Shows
SELECT 
	t1.type, t1.rating 
FROM
(
	SELECT 
		type, 
		rating, 
		COUNT(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC)as Ranking
	FROM 
		netflix
	GROUP BY 1, 2
) AS t1
WHERE 
	ranking = 1;

-- 3. List all movies released in specific year e.g. 2020
SELECT * FROM netflix;
SELECT 
	* 
FROM 
	netflix 
WHERE
	type='Movie'
	AND release_year = 2020;

-- 4. Find the top 5 countries with most content on Netflix
SELECT *
FROM
(
SELECT 
	UNNEST(STRING_TO_ARRAY(country, ',')) AS country, 
	COUNT(*) AS total_content
FROM 
	netflix
GROUP BY 1
) AS t2
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;

-- 5. Find the longest movie
SELECT 
	title, duration  
FROM
	netflix
WHERE
	type = 'Movie' AND duration = (SELECT MAX(duration) FROM netflix);

-- 6. Find content added in the last 5 years
SELECT * FROM netflix;
SELECT 
	show_id, type, title, director,country, date_added, release_year, rating, duration,
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS Formatted_YEAR,
	TO_DATE(date_added, 'Month DD, YYYY') AS AddedDate
FROM 
	netflix 
WHERE 
	TO_DATE(date_added, 'Month DD, YYYY') >= 
	(SELECT MAX(TO_DATE(date_added, 'Month DD, YYYY')) - INTERVAL '5 years' FROM netflix);

-- 7 Find all Movies and TV Shows by director 'Rajiv Chilaka'
SELECT 
	* 
FROM 
	netflix
WHERE 
	director ILIKE '%Rajiv Chilaka%';

-- 8. List all TV Shows with more than 5 seasons
SELECT 
	*
FROM 
	netflix
WHERE 
	type ='TV Show' AND SPLIT_PART(duration, ' ', 1)::numeric > 5;


-- 9. Count the number of content items in each genre
SELECT
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS Genre,
	COUNT(*) AS Total_content
FROM 
	netflix
GROUP BY Genre
ORDER BY Total_content DESC;

-- 10. Find each year and the average number of content release by India on netflix. Return
-- the top five year with highest average content
SELECT * FROM netflix;
SELECT 
 	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS Year,
	COUNT(*) AS Total_Content,
	ROUND(
	COUNT(*)::numeric / (SELECT COUNT(*) FROM netflix WHERE country LIKE '%India%')::numeric * 100, 2) 
	AS Avg_content_per_year
FROM 
	netflix
WHERE country LIKE '%India%'
GROUP BY 1
ORDER BY Total_Content DESC LIMIT 5;

-- 11. List all movies that are documentaries
SELECT 
	type, title, listed_in 
FROM 
	netflix
WHERE 
	type = 'Movie' AND listed_in ILIKE '%Documentaries%';

-- 12. Find all content with no director
SELECT * FROM netflix WHERE Director  IS NULL;

-- 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT MAX(release_year) FROM netflix;
SELECT 
	* 
FROM 
	netflix 
WHERE 
	casts ILIKE '%Salman Khan%'
	AND release_year > ((SELECT MAX(release_year) FROM netflix) - 10);

-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) AS Actors,
	COUNT(*) AS Total_movies
FROM 
	netflix
WHERE country LIKE '%India%'
GROUP BY 1
ORDER BY Total_movies DESC LIMIT 10;

-- 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT 
	category,
	COUNT(*) AS Total_content
FROM(
	SELECT 
	CASE 
		WHEN description ILIKE '%Kill%' OR description ILIKE '%Violence%' THEN 'Bad'
		ELSE 'Good'
	END AS Category
FROM 
	netflix
) AS Categorised_content 
GROUP BY category;

 
	