/* Copy post from S3 to staging table --> Create TEMP table --> Rename columns, cast created as Timestamp --> Insert into Data Warehouse. --> Truncate staging*/

COPY reddit.staging_posts
FROM 's3://reddit-project-jose1/reddit-posts-categorized/'
IAM_ROLE 'arn:aws:iam::962344403189:role/redshift'
FORMAT AS PARQUET;

CREATE TEMPORARY TABLE staging_posts_refined AS (
    SELECT
        author_fullname AS author_id,
        author_premium AS author_is_premium,
        created::timestamp AS created_timestamp, -- Had problems dealing with parquet timestamp, so loaded as string and casted as timestamp in staging.
        id AS post_id,
        num_comments,
        over_18,
        score,
        url AS link_to_post,
        title,
        category
    FROM reddit.staging_posts
);

-- To populate the dim_author table in every match, we must exclude: 1. Same authors that posted in the same batch. 2. Authors that are already present in dim_author.
INSERT INTO reddit.dim_author
(SELECT
    DISTINCT author_id,
    author_is_premium
FROM staging_posts_refined 
WHERE NOT EXISTS (
    SELECT author_id
    FROM reddit.dim_author AS destination
    WHERE destination.author_id = staging_posts_refined.author_id
)
);

INSERT INTO reddit.dim_date (created_timestamp, hour, day, week, month)
(SELECT
    DISTINCT created_timestamp,
    EXTRACT(HOUR FROM created_timestamp) AS hour,
    EXTRACT(DAY FROM created_timestamp) AS day,
    EXTRACT(WEEK FROM created_timestamp) AS week,
    EXTRACT(MONTH FROM created_timestamp) AS month
FROM staging_posts_refined
WHERE NOT EXISTS (
    SELECT created_timestamp
    FROM reddit.dim_date AS destination_date
    WHERE destination_date.created_timestamp= staging_posts_refined.created_timestamp
)
);

INSERT INTO reddit.fact_posts
(SELECT
    author_id,
    created_timestamp,
    post_id,
    num_comments,
    over_18,
    score,
    link_to_post,
    title,
    category
FROM staging_posts_refined
WHERE NOT EXISTS (
    SELECT post_id
    FROM reddit.fact_posts AS destination_fact
    WHERE destination_fact.post_id = staging_posts_refined.post_id
)
);

-- Important: Truncate stating table, so whenever new records come from the S3, we have an empty table, avoiding duplicates.
TRUNCATE TABLE reddit.staging_posts;

-- Important: Drop temporary table to save storage.
DROP TABLE staging_posts_refined;


----------------------


/* CREATE FACT AND DIM TABLES TO HANDLE REDDIT DATA */

DROP TABLE IF EXISTS reddit.fact_posts;
CREATE TABLE reddit.fact_posts (
    author_id VARCHAR,
    created_timestamp TIMESTAMP,
    post_id VARCHAR PRIMARY KEY,
    num_comments INT,
    over_18 BOOLEAN,
    score INT,
    link_to_post VARCHAR(2000),
    title VARCHAR(2000),
    category VARCHAR
);

-- CREATE DIM category
DROP TABLE IF EXISTS reddit.dim_author;
CREATE TABLE reddit.dim_author (
    author_id VARCHAR PRIMARY KEY,
    author_premium BOOLEAN
);

-- CREATE DIM date
DROP TABLE IF EXISTS reddit.dim_date;
CREATE TABLE reddit.dim_date (
    date_key INT IDENTITY(1,1) PRIMARY KEY,
    created_timestamp TIMESTAMP,
    hour INT,
    day INT,
    week INT,
    month INT
);

---------------

select * from reddit.dim_author;
select * from reddit.dim_date;
select * from reddit.fact_posts;

select count(*) from reddit.dim_author;
select count(*) from reddit.dim_date;
select count(*) from reddit.fact_posts;

SELECT
    author_id,
    COUNT(*) as n
FROM reddit.dim_author
GROUP BY author_id
ORDER BY n DESC;


SELECT
    post_id,
    COUNT(*) as n
FROM reddit.fact_posts
GROUP BY post_id
ORDER BY n DESC;


SELECT
    created_timestamp,
    COUNT(*) as n
FROM reddit.dim_date
GROUP BY created_timestamp
ORDER BY n DESC;

SELECT
    post_id,
    COUNT(*) as n
FROM reddit.fact_posts
GROUP BY post_id
ORDER BY n DESC;


SELECT
    author_id,
    COUNT(*) as n
FROM reddit.dim_author
GROUP BY author_id
ORDER BY n DESC;



select * from reddit
where created_timestamp = '2023-09-25 12:49:02';

--------------


-- DROP TABLE reddit.staging_posts;
-- Create the staging_posts table

CREATE TABLE reddit.staging_posts (
    author_cakeday BOOLEAN,
    author_fullname VARCHAR,
    author_premium BOOLEAN,
    created VARCHAR,
    edited VARCHAR, 
    hide_score BOOLEAN,
    id VARCHAR,
    link_flair_background_color VARCHAR,
    link_flair_template_id VARCHAR,
    link_flair_text VARCHAR,
    link_flair_text_color VARCHAR,
    link_flair_type VARCHAR,
    no_follow BOOLEAN,
    num_comments BIGINT,
    num_crossposts BIGINT,
    over_18 BOOLEAN,
    score BIGINT,
    send_replies BOOLEAN,
    spoiler BOOLEAN,
    ups BIGINT,
    upvote_ratio FLOAT,
    url VARCHAR,
    title VARCHAR(max),
    category VARCHAR
);


--------------
DROP VIEW reddit.reddit_data_view;
CREATE VIEW reddit.reddit_data_view AS
SELECT
    fp.author_id,
    da.author_premium,
    dd.created_timestamp,
    dd.hour,
    dd.day,
    dd.week,
    dd.month,
    fp.post_id,
    fp.num_comments,
    fp.over_18,
    fp.score,
    fp.link_to_post,
    fp.title,
    fp.category
FROM
    reddit.fact_posts fp
JOIN
    reddit.dim_author da ON fp.author_id = da.author_id
JOIN
    reddit.dim_date dd ON fp.created_timestamp = dd.created_timestamp;


UNLOAD('SELECT * FROM reddit.reddit_data_view')
TO 's3://reddit-project-jose1/results-reddit/'
iam_role 'arn:aws:iam::962344403189:role/redshift'
CSV GZIP PARALLEL OFF