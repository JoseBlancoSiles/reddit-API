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
