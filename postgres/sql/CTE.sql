-- Show the username of users who were tagged in a caption or photo before January 7th, 2010. Also show the date they were tagged.

SELECT username,tags.created_at 
FROM users 
JOIN (
    SELECT user_id, created_at FROM caption_tag
    UNION ALL
    SELECT user_id, created_at FROM photo_tags
) AS tags ON tags.user_id = users.id 
WHERE tags.created_at < '2010-01-07';

-- CTE replacement
WITH tags AS (
    SELECT user_id, created_at FROM caption_tag
    UNION ALL
    SELECT user_id, created_at FROM photo_tags
)

SELECT username,tags.created_at 
FROM users 
JOIN tags ON tags.user_id = users.id 
WHERE tags.created_at < '2010-01-07';

-- Recursive form

WITH RECURSIVE countdown(val) AS (
    SELECT 3 AS val -- Initial, Non-recursive query
    UNION
    SELECT val - 1 FROM countdown WHERE val > 1 --Recursive query
)
SELECT * FROM countdown;


-- 
WITH RECURSIVE suggestions(leader_id,follwer_id,depth) AS (
    SELECT leader_id, follower_id, 1 AS depth
    FROM followers
    WHERE id = 1000
    UNION
    SELECT followers.leader_id, followers.follower_id, depth + 1
    FROM followers
    JOIN suggestions ON suggestions.leader_id = followers.follower_id
    WHERE depth < 3
)
SELECT DISTINCT users.id , users.username
FROM suggestions
JOIN users ON users.id = suggestions.leader_id
WHERE depth > 1 LIMIT 30
;
