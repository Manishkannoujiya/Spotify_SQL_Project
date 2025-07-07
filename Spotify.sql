CREATE TABLE spotify_tracks (
    id SERIAL PRIMARY KEY,
    track_id VARCHAR(50),
    artists VARCHAR(1000),
    album_name VARCHAR(255),
    track_name VARCHAR(1000),
    popularity INTEGER,
    duration_ms INTEGER,
    explicit BOOLEAN,
    danceability DECIMAL(10,6),
    energy DECIMAL(10,6),
    key INTEGER,
    loudness DECIMAL(10,6),
    mode INTEGER,
    speechiness DECIMAL(10,6),
    acousticness DECIMAL(10,6),
    instrumentalness DECIMAL(10,6),
    liveness DECIMAL(10,6),
    valence DECIMAL(10,6),
    tempo DECIMAL(10,6),
    time_signature INTEGER,
    track_genre VARCHAR(50)
);
COPY spotify_tracks FROM 'D:\PROJECTS\SQL_Projects\Spotify\dataset.csv\dataset.csv'
WITH (FORMAT csv, HEADER true, QUOTE '"', ESCAPE '"');



DROP TABLE IF EXISTS temp_spotify_tracks;

CREATE TEMP TABLE temp_spotify_tracks (
    id INTEGER,
    track_id VARCHAR(255),
    artist VARCHAR(500)
    -- Add other columns as needed, matching your CSV and spotify_tracks structure
    -- For example:
    -- album_name VARCHAR(255),
    -- release_date DATE,
    -- duration_ms INTEGER,
    -- ...
);

COPY temp_spotify_tracks
FROM 'D:\PROJECTS\SQL_Projects\Spotify\dataset.csv\dataset.csv'
WITH (
    FORMAT csv,
    HEADER true,
    QUOTE '"',
    ESCAPE '"'
);

INSERT INTO spotify_tracks
SELECT *
FROM temp_spotify_tracks
ON CONFLICT (id) DO NOTHING;

SELECT *
FROM temp_spotify_tracks t
WHERE EXISTS (
    SELECT 1 FROM spotify_tracks s WHERE s.id = t.id
);
SELECT COUNT(*) FROM spotify_tracks;

SELECT COUNT(*) FROM temp_spotify_tracks;

select * from spotify_tracks;

---------------------------------------- Problems------------------------------------------

-------------Query 01. List all tracks with popularity above 80 , ordered by popularity descending

SELECT track_name, artists, popularity 
FROM spotify_tracks 
WHERE popularity > 80 
ORDER BY popularity DESC;

-------------Query 02. Find the average duration of the ttracks in minutes

Select round(AVG(duration_ms)/60000.0, 2) as avg_duration_minutes
from spotify_tracks;

--------------Query 03. Count tracks by explicit contnet flag

select  explicit , count(*) as track_count
from spotify_tracks
group by explicit;


---------------Query 04. List the top 10 most common time signatures
Select time_signature, count(*) as count
from spotify_tracks
group by time_signature
order by count desc
limit 10;

-------------- Query 05. Find tracks with danceability above 0.8 and energy above 0.7
select track_name , artists, danceability, energy
from spotify_tracks
where danceability > 0.8 and energy > 0.7
order by danceability DESC;

--------------- Query 06. Calculate average popularity by artist (fofr artists with at least 5 tracks)
Select artists, AVG(popularity) as avg_popularity, COUNT(*) as track_count
from spotify_tracks
group by artists
having count(*) >=5
order by avg_popularity desc;

---------------Query 07. Find tracks with the highest valence(happiness) scores
select track_name, artists, valence
from spotify_tracks
order by valence desc
limit 10;

------------ Query 08. List of the tracks with duration between 3 and 4 minutes
Select track_name , artists, duration_ms/60000.0 as duration_minutes
from spotify_tracks
where duration_ms BETWEEN 180000 AND 240000
order by duration_ms;


-------------- Query 09. Count tracks by key (musical key)
select key, count(*) as track_count
from spotify_tracks
group by key
order by key;

---------------Query 10. Find the artist with most tracks in the dataset
select artists, count(*) as track_count
from spotify_tracks
group by artists
order by track_count desc
limit 1;

-------------- Query 11. Calculate average tempo by tiem signature
Select time_signature, ROUND(AVG(tempo),2) as avg_tempo
from spotify_tracks
group by time_signature
order by time_signature;

--------------Query 12. Find Tracks with high acousticness(above 0.9) and low energy (below 0.2)
Select track_name, artists, acousticness , energy
from spotify_tracks
where acousticness < 0.9 and energy <0.2
order by acousticness desc;

---------------Query 13. List Christmas related Tracks
Select track_name , artists
from spotify_tracks
where lower(track_name) like '%christmas'
    or lower(album_name) like '%christmas';

----------------Query 14. Calculate the correalation between danceability and valence
select corr(danceability, valence) as dance_valence_correlation
from spotify_tracks;

----------Query 15. FInd the tracks with the highest speechiness
select track_name, artists, speechiness
from spotify_tracks
order by speechiness DESC
limit 10;

---------------Query 16. List tracks by Jason Mraz ordered by popularity
Select track_name, album_name, popularity
from spotify_tracks
where artists LIKE '%Jason Mraz'
order by popularity desc;

-------------Query 17. Calculate average loudness by artist(for top 10 artist by track count)
WITH top_artists AS (
    SELECT artists 
    FROM spotify_tracks 
    GROUP BY artists 
    ORDER BY COUNT(*) DESC 
    LIMIT 10
)
SELECT t.artists, AVG(s.loudness) AS avg_loudness 
FROM spotify_tracks s
JOIN top_artists t ON s.artists = t.artists 
GROUP BY t.artists 
ORDER BY avg_loudness;

-----------------Query 18. Find track with instrumentalness above 0.5 (mostly instrumental)
select track_name, artists , instrumentalness
from spotify_tracks
where instrumentalness > 0.5
order by instrumentalness desc;

--------------- query -19 list track with popularity 0 and their artists
select track_name , artists
from spotify_tracks
where popularity = 0;

--------------- Query 20. calculate the percentage of explicit tracks
SELECT 
    (COUNT(*) FILTER (WHERE explicit = TRUE) * 100.0 / COUNT(*) AS explicit_percentage,
    (COUNT(*) FILTER (WHERE explicit = FALSE) * 100.0 / COUNT(*) AS clean_percentage
FROM spotify_tracks;


-----------------Avanced Problems------------


---------------------Query 1. Find the most "balanced" tracks(closet to average on all audio features)
WITH averages AS (
    SELECT 
        AVG(danceability) AS avg_dance,
        AVG(energy) AS avg_energy,
        AVG(loudness) AS avg_loudness,
        AVG(speechiness) AS avg_speech,
        AVG(acousticness) AS avg_acoustic,
        AVG(instrumentalness) AS avg_instrumental,
        AVG(liveness) AS avg_live,
        AVG(valence) AS avg_valence,
        AVG(tempo) AS avg_tempo
    FROM spotify_tracks
)
SELECT 
    track_name, 
    artists,
    SQRT(
        POWER(danceability - avg_dance, 2) +
        POWER(energy - avg_energy, 2) +
        POWER(loudness - avg_loudness, 2) +
        POWER(speechiness - avg_speech, 2) +
        POWER(acousticness - avg_acoustic, 2) +
        POWER(instrumentalness - avg_instrumental, 2) +
        POWER(liveness - avg_live, 2) +
        POWER(valence - avg_valence, 2) +
        POWER(tempo - avg_tempo, 2)
    ) AS distance_from_average
FROM spotify_tracks, averages
ORDER BY distance_from_average
LIMIT 10;



------------Query 2. Identify tracks that are statistical outliers in duration
with stats as(
select avg(duration_ms) as mean,
STDDEV(duration_ms) as stddev
from spotify_tracks
)
select track_name,
artists,
duration_ms/60000.0 as duration_minutes
from spotify_tracks, stats
where duration_ms > mean + 2*stddev OR duration_ms < mean - 2*stddev
order by duration_ms DESC;


------------------Query 03. Find the most verstile artist (those with widest range of audio features)
WITH artist_stats AS (
    SELECT 
        artists,
        MAX(danceability) - MIN(danceability) AS dance_range,
        MAX(energy) - MIN(energy) AS energy_range,
        MAX(valence) - MIN(valence) AS valence_range,
        MAX(tempo) - MIN(tempo) AS tempo_range,
        COUNT(*) AS track_count
    FROM spotify_tracks
    GROUP BY artists
    HAVING COUNT(*) >= 5
)
SELECT 
    artists,
    (dance_range + energy_range + valence_range + tempo_range) / 4 AS avg_feature_range,
    track_count
FROM artist_stats
ORDER BY avg_feature_range DESC
LIMIT 10;
	  
)


---------------------- Query 4. Create a track similarity search function

CREATE OR REPLACE FUNCTION find_similar_tracks(target_track_id VARCHAR, limit_count INT)
RETURNS TABLE(
    track_name VARCHAR,
    artists VARCHAR,
    similarity_score FLOAT
) AS $$
BEGIN
    RETURN QUERY
    WITH target AS (
        SELECT 
            danceability, energy, loudness, speechiness,
            acousticness, instrumentalness, liveness, valence, tempo
        FROM spotify_tracks
        WHERE track_id = target_track_id
    )
    SELECT 
        s.track_name,
        s.artists,
        (1 - (
            ABS(s.danceability - t.danceability) +
            ABS(s.energy - t.energy) +
            ABS(s.loudness - t.loudness)/60 + -- normalize loudness
            ABS(s.speechiness - t.speechiness) +
            ABS(s.acousticness - t.acousticness) +
            ABS(s.instrumentalness - t.instrumentalness) +
            ABS(s.liveness - t.liveness) +
            ABS(s.valence - t.valence) +
            ABS(s.tempo - t.tempo)/200 -- normalize tempo
        )/9) AS similarity_score
    FROM spotify_tracks s, target t
    WHERE s.track_id != target_track_id
    ORDER BY similarity_score DESC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Example usage:
 SELECT * FROM find_similar_tracks('5SuOikwiRyPMVoIQDJUgSV', 5);


 ----------------- Query 06. Predict popularity based on the audio feature using regrssion
SELECT 
    regr_slope(popularity, danceability) AS danceability_slope,
    regr_slope(popularity, energy) AS energy_slope,
    regr_slope(popularity, valence) AS valence_slope,
    regr_r2(popularity, danceability) AS danceability_r2,
    regr_r2(popularity, energy) AS energy_r2,
    regr_r2(popularity, valence) AS valence_r2
FROM spotify_tracks
WHERE popularity > 0;


-------------------- Query 07. Calculate the mood of the each artist(average valence and energy)

SELECT 
    artists,
    AVG(valence) AS avg_valence,
    AVG(energy) AS avg_energy,
    CASE
        WHEN AVG(valence) > 0.5 AND AVG(energy) > 0.5 THEN 'Happy/Energetic'
        WHEN AVG(valence) > 0.5 AND AVG(energy) <= 0.5 THEN 'Happy/Calm'
        WHEN AVG(valence) <= 0.5 AND AVG(energy) > 0.5 THEN 'Sad/Energetic'
        ELSE 'Sad/Calm'
    END AS mood_category,
    COUNT(*) AS track_count
FROM spotify_tracks
GROUP BY artists
HAVING COUNT(*) >= 5
ORDER BY avg_valence DESC;


---------------------Query 08. Find the tracks that are unusually popular given their audio features
WITH predicted_popularity AS (
    SELECT 
        track_id,
        track_name,
        artists,
        popularity,
        (0.5 * danceability + 0.3 * energy + 0.2 * valence) * 100 AS predicted_pop
    FROM spotify_tracks
    WHERE popularity > 0
)
SELECT 
    track_name,
    artists,
    popularity,
    predicted_pop,
    popularity - predicted_pop AS popularity_difference
FROM predicted_popularity
ORDER BY popularity_difference DESC
LIMIT 10;


---------------- Query 09.Analyze the relationship between loudness and energy
select 
corr(loudness, energy) as loudness_energy_correlation,
regr_slope(energy,loudness) as slope,
regr_intercept(energy, loudness) as intercept
from spotify_tracks;

------------------ Query 10. Fimd the most "consistent" albums(least variation in audio features)
WITH album_stats AS (
    SELECT 
        album_name,
        artists,
        STDDEV(danceability) AS dance_stddev,
        STDDEV(energy) AS energy_stddev,
        STDDEV(valence) AS valence_stddev,
        COUNT(*) AS track_count
    FROM spotify_tracks
    GROUP BY album_name, artists
    HAVING COUNT(*) >= 5
)
SELECT 
    album_name,
    artists,
    (dance_stddev + energy_stddev + valence_stddev) / 3 AS avg_feature_stddev,
    track_count
FROM album_stats
ORDER BY avg_feature_stddev
LIMIT 10;


-----------------------Query 11. Find the most polarizing tracks (highest varience in features within an album)
WITH album_feature_var AS (
    SELECT 
        album_name,
        artists,
        VARIANCE(danceability) AS dance_var,
        VARIANCE(energy) AS energy_var,
        VARIANCE(valence) AS valence_var,
        COUNT(*) AS track_count
    FROM spotify_tracks
    GROUP BY album_name, artists
    HAVING COUNT(*) >= 5
)
SELECT 
    album_name,
    artists,
    (dance_var + energy_var + valence_var) / 3 AS avg_feature_variance,
    track_count
FROM album_feature_var
ORDER BY avg_feature_variance DESC
LIMIT 10;


----------------Query 12. Analyze the relationship between popularity and explicit content
SELECT 
    explicit,
    AVG(popularity) AS avg_popularity,
    COUNT(*) AS track_count,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY popularity) AS median_popularity
FROM spotify_tracks
GROUP BY explicit;


------------------Query 13. Find the track that are good fro different activities

SELECT 
    track_name,
    artists,
    CASE
        WHEN energy > 0.7 AND valence > 0.7 THEN 'Workout'
        WHEN energy < 0.4 AND valence > 0.6 THEN 'Relaxation'
        WHEN danceability > 0.7 AND energy > 0.6 THEN 'Dancing'
        WHEN speechiness > 0.3 THEN 'Podcast-like'
        ELSE 'General listening'
    END AS suggested_activity
FROM spotify_tracks
ORDER BY RANDOM()
LIMIT 10;

---------------- Query 14. Find the artists who have both very happy (valence>0.8) and very sad (valence<0.3) tracks   ier
WITH happy_artists AS (
    SELECT DISTINCT artists
    FROM spotify_tracks
    WHERE valence > 0.8
),
sad_artists AS (
    SELECT DISTINCT artists
    FROM spotify_tracks
    WHERE valence < 0.3
)
SELECT 
    h.artists,
    COUNT(*) AS total_tracks,
    SUM(CASE WHEN valence > 0.8 THEN 1 ELSE 0 END) AS happy_tracks,
    SUM(CASE WHEN valence < 0.3 THEN 1 ELSE 0 END) AS sad_tracks
FROM spotify_tracks s
JOIN happy_artists h ON s.artists = h.artists
JOIN sad_artists sa ON s.artists = sa.artists
GROUP BY h.artists
HAVING COUNT(*) >= 5
ORDER BY total_tracks DESC;



---------------Query 15.Calculate the average tempo difference between major and minor key tracks

SELECT 
    CASE WHEN mode = 1 THEN 'Major' ELSE 'Minor' END AS key_mode,
    COUNT(*) AS track_count,
    ROUND(AVG(tempo), 2) AS avg_tempo,
    ROUND(AVG(danceability), 2) AS avg_danceability
FROM spotify_tracks
GROUP BY key_mode;

------------------Query 16. List acoustic cover(tracks with "Acoustic" in the name) by popularity
SELECT 
    track_name, 
    artists, 
    popularity,
    duration_ms/60000.0 AS duration_minutes
FROM spotify_tracks
WHERE LOWER(track_name) LIKE '%acoustic%'
ORDER BY popularity DESC
LIMIT 15;


--------------- Query 17 Find tracks with the highest energy to danceability ratio (energetic but less danceable)
SELECT 
    track_name, 
    artists, 
    energy, 
    danceability,
    ROUND(energy / NULLIF(danceability, 0), 2) AS energy_dance_ratio
FROM spotify_tracks
WHERE danceability > 0
ORDER BY energy_dance_ratio DESC
LIMIT 10;


--------------Query 18. Find the most balanced acoustic tracks (where energy and acousticness are both high)
select track_name,
artists,
energy,
acousticness,
round((energy+ acousticness)/2,2) as balance_score
from spotify_tracks
where energy> 0.5 and acousticness >0/5
order by balance_score desc
limit 10;

-------------- Query 19. Identify artists with the widest tempo range in their discography
WITH artist_tempo_stats AS (
    SELECT 
        artists,
        MAX(tempo) - MIN(tempo) AS tempo_range,
        COUNT(*) AS track_count
    FROM spotify_tracks
    GROUP BY artists
    HAVING COUNT(*) >= 5
)
SELECT 
    artists,
    tempo_range,
    track_count
FROM artist_tempo_stats
ORDER BY tempo_range DESC
LIMIT 10;


----------------Query 20. Find the top 10 most popular acoustic tracks:


SELECT 
    track_name AS "Song Title",
    artists AS "Artist",
    popularity AS "Popularity Score"
FROM spotify_tracks
ORDER BY popularity DESC
LIMIT 10;