# dlsite_rss

DLsiteの新作をクローリング・整形してRSS配信するためのスクリプト

## 構成

* スクリプト実行環境: CircleCI(Ruby 3.3.0)
* RSSホスティング: AWS S3

## 環境構築

```sh
$ bundle install
```

## 実行方法

### 開発環境（標準出力）
```sh
$ bundle exec rake run
# または
$ bundle exec rake run[voice]
```

### 本番環境（S3に保存）
```sh
$ bundle exec rake run[voice,production]
```

## 環境変数

* `ACCESS_KEY`: AWS S3 アクセスキー
* `SECRET_ACCESS_KEY`: AWS S3 シークレットキー
* `BUCKET`: RSSをホスティングするバケット名
* `REGION`: AWS リージョン
* `RSS_URL`: RSSチャンネルに表示するURL
