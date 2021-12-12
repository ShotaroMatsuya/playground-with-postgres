CREATE TABLE users(
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    username VARCHAR(30) NOT NULL, -- want a user(or engineer) to provide a value
    -- bio VARCHAR(400) NOT NULL DEFAULT '', -- always want a value, but it should be optional
    bio VARCHAR(400) NOT NULL, -- it doesn't matter if a value exits
    avatar VARCHAR(200),
    phone VARCHAR(25),
    email VARCHAR(40),
    password VARCHAR(50),
    status VARCHAR(15),
    CHECK(COALESCE(phone,email) IS NOT NULL) -- return the first argument that it's provided that is not null.
);

CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    url VARCHAR(200) NOT NULL,
    caption VARCHAR(240),
    lat REAL CHECK(lat IS NULL OR (lat >= -90 AND lat <= 90)),
    lng REAL CHECK(lng IS NULL OR (lng >= -180 AND lng <= 180)),
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE comments (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    contents VARCHAR(240) NOT NULL,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE
);

CREATE TABLE likes (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id INTEGER REFERENCES posts(id) ON DELETE CASCADE,
    comment_id INTEGER REFERENCES comments(id) ON DELETE CASCADE,
    CHECK(
        COALESCE((post_id)::BOOLEAN::INTEGER,0) + COALESCE((comment_id)::BOOLEAN::INTEGER,0) = 1
    ),
    UNIQUE(user_id, post_id, comment_id)
);

CREATE TABLE photo_tags(
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    X INTEGER NOT NULL,
    Y INTEGER NOT NULL,
    UNIQUE(user_id,post_id)
);
CREATE TABLE caption_tag(
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    UNIQUE(user_id,post_id)
);

CREATE TABLE hashtags(
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    title VARCHAR(20) NOT NULL UNIQUE
);
CREATE TABLE hashtags_posts(
    id SERIAL PRIMARY KEY,
    hashtag_id INTEGER NOT NULL REFERENCES hashtags(id) ON DELETE CASCADE,
    post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    UNIQUE(hashtag_id, post_id)
);

CREATE TABLE followers(
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    leader_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE, -- followed user
    follower_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE(leader_id, follower_id)
);

-- INDEX

CREATE INDEX users_username_idx ON users(username);

DROP INDEX users_username_idx;

EXPLAIN ANALYZE SELECT * FROM users WHERE username = 'Emil30';

SELECT relname, relkind FROM pg_class WHERE relkind = 'i';


CREATE EXTENSION pageinspect;

SELECT * FROM bt_metap('users_username_idx');
-- idxのpage3(leaf node)の各itemのhexデータを表示
SELECT * FROM bt_page_items('users_username_idx',3);


-- HDDのpathの出力
SHOW data_directory;
-- HDD内のファイル名(oid)を取得
SELECT oid, datname FROM pg_database;
-- 各folderの貯蔵している情報一覧の取得
SELECT + FROM pg_class;

-- index情報が格納されているfile名(oid)の取得
SELECT * FROM pg_class WHERE relkind = 'i'