-- Combining dataset
CREATE TABLE appleStore_description_combined AS

SELECT * FROM appleStore_description1
UNION ALL

SELECT * FROM appleStore_description2
UNION ALL

SELECT * FROM appleStore_description3
UNION ALL

SELECT * FROM appleStore_description4

**Exploratory Data Analysis**

-- Check the number of unique apps in both tableAppleStore

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM AppleStore
-- 7197

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM appleStore_description_combined
-- 7197
-- No missing data between the these two tables

-- Check for any missing values in key fields

SELECT COUNT(*) AS MissingValues
FROM AppleStore
WHERE track_name IS null OR user_rating IS null OR prime_genre IS NULL
-- Zero missing values

SELECT COUNT(*) AS MissingValues
FROM appleSttore_description_combined
WHERE app_desc IS null
-- Zero missing values

-- Find out the number of apps per genre

SELECT prime_genre, COUNT(*) AS NumApps
From AppleStore
GROUP By prime_genre
ORDER BY NumApps DESC

-- Get an overview of the apps' ratings

SELECT min(user_rating) AS MinRating,
       max(user_rating) AS MaxRating,
       avg(user_rating) AS AvgRating
FROM AppleStore
-- Min Rating is 0, Max Rating is 5, Avg Rating is 3.53

**Data Analysis**

--Get the distribution pf app prices

SELECT
	(price / 2) * 2 AS PriceBinStart,
    ((price / 2) * 2) + 2 AS PriceBinEnd,
    COUNT(*) AS NumApps
From AppleStore

GROUP BY PriceBinStart
ORDER BY PriceBinStart

-- Detremine whether paid apps have higher ratings than free apps

SELECT CASE
			WHEN price > 0 Then 'Paid'
            ELSE 'Free'
		END AS App_Type,
        avg(user_rating) AS Avg_Ratig
FROM AppleStore
GROUP BY App_Type
-- On average the rating of paid apps is slightly higher compare to the free apps.

-- Check if apps with more supported languages have higher ratings.

SELECT CASE
			WHEN lang_num < 10 THEN '<10 languages'
            WHEN lang_num Between 10 AND 30 THEN '10-30 languages'
            ELSE '>30 languages'
		END AS language_bucket,
        avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY language_bucket
ORDER by Avg_Rating DESC
-- The middle bucket(>30 languages) has higher average user rating. 

-- Check genres with low ratings

SELECT prime_genre,
       avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY prime_genre
ORDER by Avg_Rating ASC
LIMIT 10
-- Users rating is low for Catlogs, Finance and Book

-- Check if there is correlation between the length of the app description and the user rating

Select case 
			When length(b.app_desc) < 500 THEN 'Short'
            When length(b.app_desc) Between 500 AND 1000 then 'Medium'
            ELSE 'Long'
		END AS description_length_bucket,
        avg(a.user_rating) as average_rating
FROM
	AppleStore AS A
JOIN
	appleStore_description_combined AS b
ON 
	a.id = b.id
GROUP BY description_length_bucket
ORDER BY average_rating DESC
-- Longer the description better is the user rating on average

-- Check the top rated apps for each genre

SELECT
	prime_genre,
    track_name,
    user_rating
FROM (
  	  SELECT
  	  prime_genre,
  	  track_name,
      user_rating,
      RANK() OVER(PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) AS rank
  	  FROM
      AppleStore
     ) AS a 
WHERE
a.rank = 1

*Final Recommendations*
-- Paid apps have better ratings. 
-- Apps supporting between 10 and 30 languages have better ratings. 
-- Finance and Book apps have low ratings. 
-- Apps with a longer description have better ratings. 
-- A new app should aim for average rating above 3.5. 
-- Games and Entertainment have high competition. 