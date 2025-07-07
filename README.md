# Spotify_Tracks_Analysis_Using_SQL
![Spotify Logo](https://raw.githubusercontent.com/Manishkannoujiya/Spotify_SQL_Project/refs/heads/main/everything-you-need-to-know-about-spotify-wrapped-2024_r5wm.1248.webp)

## Overview
This SQL project, titled "Spotify Track Analysis Using pgAdmin", focuses on analyzing a large dataset of Spotify music tracks through PostgreSQL, using the pgAdmin interface for database management and querying. The primary objective is to extract meaningful insights from the audio and metadata of tracks, uncover listening trends, and build data-driven functionality such as recommendation systems and mood categorization—all using pure SQL.
## Project Goals
* Perform basic, intermediate, and advanced queries on the dataset.

* Explore audio features, artist behavior, track trends, and musical patterns.

* Enable track similarity, mood prediction, and regression-based analysis.

## Key SQL Features Demonstrated
### Basic to Intermedeiate Queries
 * Track filtering by popularity, duration, explicit content, and time signature.

* Aggregate queries (AVG, COUNT, GROUP BY).

* String matching (e.g., Christmas songs, acoustic covers).

* Correlation analysis using corr().
### Advanced Analysis
* Feature-based similarity: Custom SQL function to find similar tracks.

* Regression analysis: Using regr_slope() and regr_r2() to predict popularity.

* Outlier detection: Tracks with unusually long or short durations.

* Mood classification: Categorizing artists based on valence and energy.

* Artist diversity: Artists with the widest range of musical features.

## Custom SQL Function
A powerful find_similar_tracks() function:

* Accepts a track ID and returns similar tracks based on audio features.

* Implements a normalized Euclidean distance-like similarity score.

## Use Cases of the Project
* Music recommendation system (based on similarity or mood)

* Market trend analysis (e.g., most popular durations, energy levels)

* Content moderation (explicit content statistics)

* Musical data science (correlation, regression, clustering prep)

* Creative insight (e.g., what makes a song danceable or versatile)

  
  
