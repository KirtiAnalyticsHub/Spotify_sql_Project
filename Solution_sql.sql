-- Advanced SQL Project -- Spotify datasets

DROP TABLE IF EXISTS spotify
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

select * from spotify ;

-- EDA 
Select count(*) from spotify ;

Select count(distinct artist ) from spotify ;

Select count(distinct album ) from spotify ;

Select distinct album_type from spotify ;

Select  duration_min from spotify ;

Select  max(duration_min) from spotify ;

Select  min(duration_min) from spotify ;

select * from spotify 
where duration_min = 0;

delete from spotify 
where duration_min = 0;

select * from spotify 
where duration_min = 0;

select distinct channel from spotify ;

select distinct   most_played_on from spotify ;
/*
-- -------------------------------
-- Data Analysis - Easy Category
-- -------------------------------

1. Retrieve the names of all tracks that have more than 1 billion streams.
2. List all albums along with their respective artists.
3. Get the total number of comments for tracks where `licensed = TRUE`.
4. Find all tracks that belong to the album type `single`.
5. Count the total number of tracks by each artist.
*/

--1. Retrieve the names of all tracks that have more than 1 billion streams.

select track,stream from spotify 
where stream > 1000000000 ;

--2. List all albums along with their respective artists.
SELECT DISTINCT ALBUM, ARTIST
FROM SPOTIFY
ORDER BY	1 ;

--3. Get the total number of comments for tracks where `licensed = TRUE`.
select sum(comments) from spotify
where licensed = 'true' ;

--4. Find all tracks that belong to the album type `single`.
select * from spotify 
where album_type = 'single' ;

-- 5. Count the total number of tracks by each artist.
select artist , count(track)as total_songs
from spotify
group by 1
order by 2 desc ;

/*
-- --------------------------  
-- Medium Leave
-- --------------------------
1. Calculate the average danceability of tracks in each album.
2. Find the top 5 tracks with the highest energy values.
3. List all tracks along with their views and likes where `official_video = TRUE`.
4. For each album, calculate the total views of all associated tracks.
5. Retrieve the track names that have been streamed on Spotify more than YouTube.
*/

-- 1. Calculate the average danceability of tracks in each album.
 
select album , avg(danceability) 
from spotify
group by album 
order by 2 desc ;

-- 2. Find the top 5 tracks with the highest energy values.
select track , energy
from spotify
order by 2 desc
limit 5 ;

-- 3. List all tracks along with their views and likes where `official_video = TRUE`.
select track , sum(views) , sum(likes )
from spotify
where official_video = 'true' 
group by track
order by 2 desc

-- 4. For each album, calculate the total views of all associated tracks.
select album , sum(views) as total_views , track
from spotify
group by 1 , 3 
order by 2 desc ;

-- 5. Retrieve the track names that have been streamed on Spotify more than YouTube.

select * from
	  
(Select 
     track,
      coalesce(sum(case when most_played_on = 'Youtube' then stream END ),0) AS STREAMED_ON_youtube,
     coalesce(sum(case when most_played_on = 'Spotify' then stream END ),0) AS STREAMED_ON_spotify
from Spotify
group by 1
 ) as t1 
 
where  STREAMED_ON_spotify > STREAMED_ON_youtube
       and
	   STREAMED_ON_youtube <> 0 ; 

/*
-- ------------------------------------
-- Advance Problems 
-- ------------------------------------
1. Find the top 3 most-viewed tracks for each artist using window functions.
2. Write a query to find tracks where the liveness score is above the average.
3. Use a `WITH` clause to calculate the difference between the highest and lowest energy values for tracks in each album.
4. Find tracks where the energy-to-liveness ratio is greater than 1.2.
5. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
*/


-- 1. Find the top 3 most-viewed tracks for each artist using window functions.
-- each artists and total view for each track
-- track with highest view for each artist ( we need top)
-- dense rank
-- cte and filter rank <= 3
with ranking_artist
as
(select  
      artist ,
	  track,
	  sum(views) as totoal_views,
	  dense_rank() over (partition by artist order by sum(views) desc )as rank  
from spotify
group by 1 ,2  
order by 1 , 3 desc
)
select * from ranking_artist
where rank<= 3

-- 2. Write a query to find tracks where the liveness score is above the average.

select avg(liveness) from spotify  -- .19


select track , 
       artist ,
	   liveness
from spotify
where liveness > (select avg(liveness) from spotify)
	   
-- 3. Use a `WITH` clause to calculate the difference between the highest and lowest energy values for tracks in each album.	   
with cte
as 
( select 
       album ,
	   max ( energy ) as higehst_energy ,
	    min ( energy ) as lowest_energy
from spotify
group by 1
)
		
select album , 
       higehst_energy - lowest_energy as energy_diff 
from cte
order by 2 desc