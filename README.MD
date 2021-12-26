# psql コマンド

### ログイン

```
psql -U user_name -d db_name (-h ホスト名)
```

### sql ファイルの実行

```
psql -f (ファイルパス) -U user_name -d db_name (-h ホスト名)
```

### データベース一覧表示

```
psql -l
```

### postgresql バージョン表示

```
psql -V
```

# psql 上で使うコマンド

### psql の終了

```
postgres=# \q
```

### ユーザー一覧を表示

```
postgres=# \du
```

### データベース一覧表示

```
postgres=# \l
```

か

```
postgres=# SELECT * FROM pg_database;
```

### 他のデータベースに接続

```
postgres=# \c (dbname)
```

### データベース作成

```
postgres=# create database (dbname);
```

### データベースの削除

```
postgres=# drop database <データベース名>;
```

### 接続中のデータベースの情報を表示

```
postgres=# \conninfo
```

### テーブル一覧の表示

```
postgres=# \z
```

### テーブル定義を確認

```
postgres=# \d (tablename)
```

### ファイルから実行

```
postgres=# \i filename.sql
```

# バックアップとリストア

### データベース単位のバックアップ

```
pg_dump mydb > db.sql
```

### テーブル単位のバックアップ

```
pg_dump -t mytab mydb > db.sql
```

### リストア

newdb というデータベースに db.sql(sql スクリプトファイル)の内容をリストア

```
psql -d newb -f db.sql
```

newdb というデータベースに db.dump(アーカイブファイル)の内容をリストア

```
pg_restore -d newdb db.dump
```

例
-a data-only
-e exit-on-error
-v verbose 冗長モードを指定
-d dbname

```
pg_restore -a -O --disable-triggers -e -v -d instagram ig.sql
```

# 権限周り

例

```
CREATE USER youruser WITH ENCRYPTED PASSWORD 'yourpass';
GRANT ALL PRIVILEGES ON DATABASE yourdbname TO youruser;
```

## root のロールを作成し、必要な権限を与える

### ロール作成

（docker-compose の設定に合わせて password も設定）

```
postgres=# CREATE ROLE root WITH LOGIN PASSWORD 'password';
```

### 権限を付与

```
postgres=# ALTER ROLE root SUPERUSER CREATEDB;
```

===

# Migration

## `docker network create postgres`

node アプリケーションと postgres を同じネットワーク内に配置する

## `docker-compose run --rm npm install node-pg-migrate pg`

node-pg-migrate と pg をインストール

## `postgres= create database socialnetwork`

postgres コンテナにログインして db を新たに作成

## `docker-compose run --rm npm run migrate create table comments`

comment table を作成
すると`migrations/1640106141898_table-comments.js`が生成

row SQL を記述

## `docker-compose run --rm npm run migrate up`

Migration の実行

## `docker-compose run --rm npm run migrate down`

Migration の rollback(1 回分)

---

# Web サーバー構築

## `docker-compose run --rm npm init -y`

## `docker-compose run --rm npm install dedent express jest node-pg-migrate nodemon pg pg-format supertest`
