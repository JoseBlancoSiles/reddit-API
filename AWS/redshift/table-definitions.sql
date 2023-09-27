-- Create staging table
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

-- Create fact table 
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