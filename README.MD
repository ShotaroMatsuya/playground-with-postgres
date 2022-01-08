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

```sql
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

generate package.json

do this to add dependencies.

## `docker-compose run --rm npm install dedent express jest node-pg-migrate nodemon pg pg-format supertest`

---

# テスト実行

## `docker-compose run --rm npm run test`

# テスト用スキーマの作成

## test スキーマに users テーブルを作成

```
postgres=# CREATE SCHEMA test;
```

test スキーマに users テーブルを作成

```sql
CREATE TABLE test.users(
    id SERIAL PRIMARY KEY,
    username VARCHAR
);
```

## デフォルトスキーマの確認

```sql
SHOW search_path;
```

```bash
   search_path
-----------------
 "$user", public
(1 row)
```

## デフォルトスキーマの変更

```sql
SET search_path TO test, public;
```

## 作成済みスキーマの取得

### \dn コマンドから取得

```
postgres=# \dn
```

### システムカタログ **pg_namespace** から取得する

pg\_ で始まるスキーマは PostgreSQL のシステムが使用しているものです。また information_schema もシステムが使用するものです)。

```sql
select nspname, nspowner, nspacl from pg_namespace;
```

## スキーマの削除

```sql
DROP SCHEMA <スキーマ> CASCADE;
```

# Configuration

- まずデータの書き換えを行うと、shared_buffer 内のデータが更新。(ダーティデータとなる)
- Checkpoint によりすべてのダーティバッファが disk に書き込まれる
- dirty buffer の書き込みが終わると shared_buffers 内の dirty buffer が clean としてマークされる
- その後、WAL への書き込みが行われる

## shared_buffers

Disk 上にあるテーブルやインデックスのデータを、ブロック単位で共有メモリー上にキャッシュするための領域。  
データファイルは、複数の 8192 バイトのブロックで構成され、この単位でキャッシュされる（OS のシステムキャッシュを経由する）

- postgresql.conf の`shared_buffers`パラメータを変更

## Checkpoint

- checkpoint はトランザクション内で sequential な point である
- checkpoint の前までの data を disk に反映したら、新たな checkpoint を作成する
- すべての dirty page が flush されると特別な checkpoint record となり、redo record である WAL へ書き込みされる
- その後、次の checkpoint が作成されるまでは、WAL へ書き込みが行われる
- 仮に crash が起きたときには、最新の Checkpoint と WAL を用いて recovery する
- checkpoint があるところまでは disk にデータが有ることを保証する
- disk に存在する checkpoint や Redo record はリサイクルされたり、削除される
- `checkpoint_flush_after`はデフォルトでは 0、disk への flush を行う まとまりの page 数を規定する
- `checkpoint_timeout`は checkpoint の実行間隔 min を示す
- checkpoint の頻度を下げると、一度に大量のログを disk に書き込むので I/O スパイクが発生し、パフォーマンス低下を引き起こす
- `checkpoint_completion_target`は、どれくらい早く checkpoint プロセスを終了させるかの目標値。デフォルトでは 0.5。これを 0.9 などにすると長い時間をかけて checkpoint プロセスを実行することになる。それにより I/O スパイクが平坦になる
- 頻度の低い checkpoint は、WAL ログが増大化させシステムリカバリの際に復旧時間がかけることになる

## WAL wirter

- WAL(Write Ahead Log) はクラッシュリカバリに使用される

- 最新の Checkpoint と Redo ログが記録されている
- トランザクションが作成されると、WAL buffer 内に連続的に書き込まれる
- トランザクションがコミットされると、Buffer から WAL への書き込みが行われる
- WAL は書き込まれることが多く、読み込まれることが少ない
- WAL が読み込まれるケースは、recovery、server startup、replication
- 基本的なデータの書き込み処理は、checkpoint/BG writer によって shared_buffer 経由で行われており、WAL バッファはそれと並行してトランザクションデータを保持する目的で書き込まれている
- fsync によりトランザクションがコミットされた後に disk 内の WAL 領域に書き込む処理が実行されている
- つまり fsync をオフにするとバルクアップデートなどの処理が改善する。しかしデータ一貫性は失われるリスクが有る
- バックグラウンドライターは shared_buffer から dirty data を disk に書き込む処理を行っている
- bg ライターと checkpoint は同じ役割を持っているが、checkpoint はすべての dirty buffer を書き込み、WAL にチェックポイントレコードを書き込むのに対し、
  bg ライターは更新された dirty buffer をアルゴリズムによって disk へ書き込む処理を行っている
- bg ライターの目的は shared buffer のメモリを確保すること
- `bgwriter_delay` はどの程度頻繁に共有バッファを監視するかを指定。 デフォルトでは 200ms に 1 回
- `bgwriter_least_recent_used_maxpages`は一回につき書き込まれるバッファーのページのマックスサイズを指定する

The Background Writer is responsible for writing to disk **specific** dirty buffers based on an algorithm, while the Checkpointer writes **all** dirty buffers periodically.

# Vacuum for Performance

- Vacuum を手動で行うことによりスペースを reuse するためにマーキングすることができ、table rock が発生させない。これだけではテーブルのサイズは減らない
- Vacuum FULL を行うことで record の削除と reorder を行う。しかし非常に時間がかかるうえ、テーブルに対して排他ロックをかける

1. テーブルサイズをみる

```sql
select pg_size_pretty(pg_relation_size('テーブル名'));
```

- Vacuum により index bloat と excessive dead tuples を生み出す

2. dead tuple を検索

```sql
select * from pg_stat_user_tables;
```

Vacuum のチューニングには 2 つのゴールがある

1. dead tuples を掃除
2. cleanup インパクトを最小化する

- vacuum の設定は、管理するデータ量とオペレーションの種類(DELETE/UPDATE の比率)に依存  
  Default values in postgresql.conf(decided a long time ago & compatible with tiny machine)

- `autovacuum_naptime`はあるデータベースで実行される autovacuum デーモンの最小遅延を指定する。それぞれの周期で。デーモンはそのデータベースを試験し、そのデータベース内のテーブルで必要性が認められると VACUUM と ANALYZE コマンドを発行する。  
  遅延は秒単位で計測され、デフォルトは 1 分。このパラメータは postgresql.conf ファイルまたはサーバのコマンドラインでのみ設定される
- `autovacuum_max_workers`は同時に実行することができる autovacuum プロセスの最大数を指定する。デフォルトは 3。サーバー起動時のみ設定可能
- `autovacuum_vacuum_scale_factor`はデフォルトで 0.2。テーブルの 20%が変更されたときに autovacuum が実行される
- `autovacuum_vacuum_threshold`にて、少ないデータ量で頻繁に実行されないように変更されたタプル数の最小値を 50 としている
- `autovacuum_analyze_scale_factor`と`autovacuum_analyze_threshold`で統計情報の更新に関しても同様に設定可

- autovacuum はアクティブなトランザクションがなくなったときに実行される
- 9.6 以降からトランザクションの長さを設定できるようになった  
  長いトランザクションを制限することで vacuum が定期的に実行されるようになる
- `old_snapshot_threshold`により設定。-1 は disable を意味し、0 は immediate を意味し、1 分〜60 日間までのカスタム設定が可能

## vacuum 頻繁に実行されすぎ問題

- vacuum に対して十分なメモリを与えていないと、何度も vacuum が呼び出される。
  この場合は`maintenance_work_mem`は増やす必要がある
- 対象の DB が膨大である場合は、auto vacuum はそれぞれの db に対して 1 つずつ worker を起動するのでデフォルトのままだと、1 分毎にすべての safty な db に対して vacuum を実行することになる  
  この場合は`autovacuum_naptime`を増やす必要がある

## vacuum disruptive 問題

- vacuum を実行する際の累計 io コストを計算し、設定値よりも超える場合には、vacuum プロセスを delay time で指定した時間分 sleep してしまう
- そのような場合は、auto vacuum が遮断されてしまう原因となるので、`vacuum_cost_delay`を上げる必要がある

## vacuum keeping Up 問題

- IO は余裕あるにも関わらず、autovacuum が追いつかないときは、`vacuum_cost_delay`を下げる必要がある
- あるいは、テーブルごとに並行処理さえるので、table スキーマを細分化することで multiple worker process がパラレルに実行できる

# index の評価

## index-only スキャンと covering scan

- index scan はまず index lookup し、その後 heap lookup するため 2 つの工程が必要となる
- index only scan の恩恵を受けるための仕組みとして covering indexes というのが用意されている

設定例
x を where 句で指定する専用のカラムとするならば、y は payload 専用のカラムだとする
そのようなときには index 作成時に include を使って定義することで covering index を使用できる

```sql
SELECT y FROM tab WHERE x = 'key';
CREATE INDEX idx_xy ON tab(x) INCLUDE(y);
```

## partial index

- index をかける領域を値によってわけることを partial index という
- index の容量の節約につながる

- インデックスサイズの調べ方

```
postgres=# \di+
```

- テーブルサイズの調べ方

```
postgres=# \dt+
```

## clustered table

- 同じクエリを実行しても physical disk のデータレイアウトの変化によりパフォーマンスが変わることがある
- 一つの value が隣の value への依存度を correlation という。高い値であること　望ましい

```sql
select tablename, attname, correlation from pg_stats where tablename in ('テーブル名') order by 1,2;
```

整列されているテーブルでは correlation が 1 に近くなる

- cluster コマンドを実行することで望ましい order に書き換えることができる
- 裏側では、新しくソートされたテーブルを複製し古いものを drop している
- 作成中はテーブルロックをかけるので production 環境下ではあまり好まれない
- 複数のカラムを同時に整理することはできない
- correlation が経時的に劣化するのはある程度妥協が必要

  クラスターコマンド

```sql
Cluster t_random USING idx_random;
```

- テーブルサイズに実行時間が変わる

## Fill Factor

ページにテーブルやインデックスを格納する際、あえて空き領域を作成していく仕組み

- 10 から 100%までの値を設定できる。デフォルトでは 100
- これを 50%にした場合、insert オペレーションは page の 50%の領域のみで行われ、残りの 50%は update 用に確保される
- これにより、今後の update 処理は同一ページ内で書き込まれることになり、異なるページにまたがる場合と比較すると良いパフォーマンスが得られる
- 頻繁に update が実行される際にはこの値を低くすると良い
- しかし index スキャンの際には random disk I/O が必要となるので要注意

# 統計情報

- `pg_stat_statements`はどの種類のクエリが遅いかどれくらい頻繁に実行されているかがわかる
  適用するためには、postgresql.conf を以下のように編集して再起動
  `shared_preload_libraries= 'pg_stat_statements'`

- extension の作成

```
postgres=# create extension pg_stat_statements;
```

```sql
select * from pg_stat_statements;
```

で、クエリが実行された回数、消費した時間、最小時間最大時間などがわかる

- 特に重要なのは`stddev_time`。これは時間の安定性を示す指標
- unstable になる要因として、「リクエストした data がキャッシュに乗っていない」「引数が変わるたびに異なるクエリが実行計画が発行されていること」「並列処理やロック」となる

- 「リクエストした data がキャッシュに乗っていない」かは、`shared_blks_hits`と`shared_blks_read`をみる
- `shared_blks_hits`はキャッシュ内でヒットしているブロックの総数

- `shared_blks_read`は OS から読み込まれた block の総数

- `temp_blk_read` と`temp_blks_written`と`blk_read_time`は temp ファイルの指標
- temp_block ファイルは大きな index が構築されたときや、大きな DDL が関わるときなどに生成されるファイルで、OLTP 環境のような多くの小さなトランザクションを扱う DB の場合は、この temp ファイルは忌み嫌われる
- 不適切な`work_mem`の割り当てだと RAM で処理しきれなくなるため、disk で処理せざるを得なくなり temp ファイルが作成される要因となる
- expensive な query が実行されると temp ファイルが作成される
- 不適切な`maintenance_work_mem`だと、temp ファイルの生成につながる
- index を作成したときや DDL を実行したときにも temp ファイルは作成されるが、この場合はあまり重要でない

## top 10 time-consuming queries

```sql
SELECT round((100 * total_time / sum(total_time)
            OVER())::numeric, 2) percent,
            round(total_time::numeric, 2) AS total,
            calls,
            round(mean_time::numeric, 2) AS mean,
            substring(query, 1, 200)
FROM pg_stat_statements
            ORDER BY total_time DESC
            LIMIT 10;
```

- `track_activity_query_size`がデフォルトだと 1024byte になっているので、このカットオフよりも大きいクエリが表示されなくなってしまうので、上限まで上げると良い

- `pg_stat_user_tables`は user によって定義された table を見ることができ、insert/update/delete の実行回数を確認できる
- vacuum が最後に実行された時刻が表示され、有効な tuple と dead tuple をみることができる

```sql
-- このクエリでどのテーブルが seq scan されているか、index scan との比率などを確認できる
SELECT schemaname, relname, seq_scan, idx_scan,
        cast(idx_scan AS numeric) / (idx_scan + seq_scan) AS idx_scan_pct
    FROM pg_stat_user_tables
        WHERE (idx_scan + seq_scan) > 0 ORDER BY idx_scan_pct;
```

```sql
-- どのくらいの数のtupleがスキャン時にタッチされているかを調査
SELECT relname,seq_tup_read,idx_tup_fetch,
        cast(idx_tup_fetch AS numeric) / (idx_tup_fetch + seq_tup_read)
        AS idx_tup_pct
    FROM pg_stat_user_tables
        WHERE (idx_tup_fetch + seq_tup_read) > 0 ORDER BY idx_tup_pct;
```

## index が必要なクエリを探す

seq scan が頻繁に実行されているテーブルを抽出

```sql
SELECT schemaname, relname, seq_scan, seq_tup_read,
        seq_tup_read / seq_scan AS avg, idx_scan
    FROM pg_stat_user_tables
    WHERE seq_scan > 0
    ORDER BY seq_tup_read DESC
    LIMIT 25;
```

## hot updates

各テーブルで insert/update/delete された tuple の割合を表示

```sql
SELECT relname,
        trunc(cast(n_tup_inx AS numeric) / (n_tup_ins + n_tup_upd + n_tup_del), 2) AS ins_pct,
        trunc(cast(n_tup_upd AS numeric) / (n_tup_ins + n_tup_upd + n_tup_del), 2) AS ins_pct,
        trunc(cast(n_tup_del AS numeric) / (n_tup_ins + n_tup_upd + n_tup_del), 2) AS ins_pct,
FROM pg_stat_user_tables
ORDER BY relname;

```

- update が頻繁に実行される場合は、**Reindex command**
- delete が頻繁に実行される場合 h、**Cluster command**

HOT(heap only tup ) Update が実行されている割合を表示

```sql
SELECT relname,n_tup_upd.n_tup_hot_upd,
        trunc(cast(n_tup_hot_upd AS numeric) / n_tup_upd, 2) AS hot_pct
FROM pg_stat_user_tables
        WHERE n_tup_upd > 0 ORDER BY hot_pct;
```

- HOT が行われていればいるほど、よい update が実行されていると思って良い
- HOT update は更新時にコピーされた row を同一ページ内に作り、ゴミとなる block スペースを生じないので、パフォーマンス上大きな恩恵が得られる

## Finding Useless indexes

index が実行回数と index サイズを表示

```sql
SELECT schemaname, relname, indexrelname, idx_scan,
        pg_size_pretty(pg_relation_size(indexrelid)) AS idx_size
FROM pg_stat_user_indexes;
```

使われていないにも関わらず大きなサイズの index は削除

# Parallel Query

- postgres9.6 からパラレルクエリをサポート
- `max_parallel_workers_per_gather`で worker プロセスの数を決める
- `min_parallel_table_scan_size`の値がパラレルスキャンの対象となる、テーブルサイズの最低値を決める

# shared_buffers

- buffer サイズは server 起動時にのみ適用され、デフォルト値は非常に小さい環境用にセッティングされている
- shared_buffer は OS のキャッシュと協力しながらデータを保持している。  
  shared_buffer にキャッシュをより割り当てたいときは buffer のキャッシュ内容を確認する必要がある

## Analyzing Postgres shared_buffers contents

- 開始点として shared_buffer アロケーションを 25%から始めるのが良い
- benchmark を使うことで buffer の内容を確認することができる

### Getting the largest relations in the cache

まず pg_buffercache エクステンションのインストール

```
postgres=# create extension pg_buffercache;
```

テーブルや index などのバッファ量の相関関係を見ることができる

```sql
SELECT c.relname, count(*) AS buffers
FROM pg_class c
INNER JOIN pg_buffercache b
ON b.relfilenode=c.relfilenode
INNER JOIN pg_database d
ON (b.reldatabase=d.oid AND d,datname=current_database())
GROUP BY c.relname
ORDER BY 2 DESC
LIMIT 10;
```

### Buffer content Summary

各リソースごとのバッファー内の専有メモリ数、shared_buffer 内での割合、table 内での割合

```sql
SELECT c.relname, pg_size_pretty(count(*) * 8192) as buffered,
        round(100.0 * count(*) /
            (SELECT setting FROM pg_settings WHERE name='shared_buffers')::integer, 1)
            AS buffers_percent,
        round(100.0 * count(*) * 8192 / pg_table_size(c.oid), 1) AS percent_of_relation
FROM pg_class c
INNER JOIN pg_buffercache b
ON b.relfilenode = c.relfilenode
INNER JOIN pg_database d
ON (b.reldatabase = d.oid AND d.datname = current_database())
GROUP BY c.oid, c.relname
ORDER BY 3 DESC
LIMIT 10;

```

### Usage count distribution

- If you don't want to analyze your shared buffer content, 25 % of total RAM is a reasonable starting point for setting the shared_buffers.
- You will benefit from a larger shared_buffer cache when there are a lot of popular pages(pages with high usage count).

```sql
SELECT
 c.relname, count(*) AS buffers,usagecount
FROM pg_class c
 INNER JOIN pg_buffercache b
 ON b.relfilenode = c.relfilenode
 INNER JOIN pg_database d
 ON (b.reldatabase = d.oid AND d.datname = current_database())
GROUP BY c.relname,usagecount
ORDER BY c.relname,usagecount;
```

# pgbench

- 500 万件のデータを insert としてイニシャライズ

```bash
pgbench -i -s 50 <db名>;

```

- 同時に 8 つのクライアント接続数、select のみの 25000 回のトランザクション

```bash
pgbench -S -c 8 -t 25000 <db名>;
```
