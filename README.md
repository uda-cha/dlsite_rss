# dlsite_rss

DLsiteの新作をクローリング・整形してRSS配信するためのスクリプト

## 構成

* スクリプト実行環境: CircleCI(Ruby 2.6.2)

## 環境構築

```sh
$ bundle install
```

## 環境変数

* `ACCESS_KEY`
* `SECRET_ACCESS_KEY`
* `BUCKET`: RSSをホスティングするバケット名
* `REGION`: そのリージョン
* `RSS_URL`: RSSチャンネルに表示するＵＲＬ
