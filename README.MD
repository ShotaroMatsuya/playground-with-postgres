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

### 他のデータベースに接続

```
postgres=# \c (dbname)
```

### データベース作成

```
postgres=# create database (dbname);
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
