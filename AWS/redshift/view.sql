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