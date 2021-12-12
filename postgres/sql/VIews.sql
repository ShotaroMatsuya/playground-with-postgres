-- Show the most popular users - the users who were tagged the most
SELECT username, COUNT(*)
FROM users
JOIN (
    SELECT user_id FROM photo_tags 
    UNION ALL
    SELECT user_id FROM caption_tags
) AS tags ON tags.user_id = users.id
GROUP BY username
ORDER BY COUNT(*) DESC;

-- create views
CREATE VIEW tags AS (
    SELECT id,created_at, user_id, post_id, 'photo_tag' AS type FROM photo_tags
    UNION ALL
    SELECT id,created_at, user_id, post_id, 'caption_tag' AS type FROM caption_tags
);


-- using views
SELECT username, COUNT(*)
FROM users
JOIN tags ON tags.user_id = users.id
GROUP BY username
ORDER BY COUNT(*) DESC;

-- 10 most recent posts is very important.
CREATE VIEW recent_posts AS(
    SELECT * FROM posts ORDER BY created_at DESC LIMIT 10
);
-- Show the users who created the 10 mosts recent posts

SELECT * FROM recent_posts JOIN users ON users.id = recent_posts.user_id;


-- Changing the View

CREATE OR REPLACE VIEW recent_posts AS (
    SELECT * FROM posts ORDER BY created_at DESC LIMIT 15
);

-- Delete the View
DROP VIEW recent_posts;

-- For each week, show the number of likes that posts and comments received,
-- Use the post and comment created_at date, not when the like was received.

-- 3way join(slow query)

SELECT * FROM likes 
LEFT JOIN posts 
ON posts.id = likes.post_id
LEFT JOIN comments 
ON comments.id = likes.comment_id;

-- group by week
SELECT 
    date_trunc('week', COALESCE(posts.created_at, comments.created_at)) AS week,
    COUNT(posts.id) AS num_likes_for_posts,
    COUNT(comments.id) AS num_likes_for_comments
FROM likes 
LEFT JOIN posts 
ON posts.id = likes.post_id
LEFT JOIN comments 
ON comments.id = likes.comment_id
GROUP BY week
ORDER BY week;

-- improving the performance by using Materialized View
-- Create materialized view
CREATE MATERIALIZED VIEW weekly_likes AS(
    SELECT 
    date_trunc('week', COALESCE(posts.created_at, comments.created_at)) AS week,
    COUNT(posts.id) AS num_likes_for_posts,
    COUNT(comments.id) AS num_likes_for_comments
    FROM likes 
    LEFT JOIN posts 
    ON posts.id = likes.post_id
    LEFT JOIN comments 
    ON comments.id = likes.comment_id
    GROUP BY week
    ORDER BY week
) WITH DATA;

-- delete some posts
DELETE FROM posts WHERE created_at < '2010-02-01';

-- Update materialized view
REFRESH MATERIALIZED VIEW weekly_likes;