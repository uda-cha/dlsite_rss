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

## テスト

[VCR](https://github.com/vcr/vcr) を使ったフィクスチャベースのテスト。初回実行時のみ DLsite へ実際にアクセスしてレスポンスをカセット（YAML ファイル）に保存し、2回目以降はカセットから再生する。

カセットファイルは `spec/fixtures/vcr_cassettes/` に保存される（`.gitignore` で除外済み）。

### 実行

```sh
$ bundle exec rspec
```

初回はカセットを録音するため DLsite へアクセスする（実行に数分かかる）。2回目以降は即座に完了する。

### カセットの更新

DLsite の DOM 構造が変わってテストが落ちた場合、カセットを削除して再録音する。

```sh
# 全カセット削除
$ rm spec/fixtures/vcr_cassettes/**/*.yml
$ bundle exec rspec
```

## デバッグ

DOM 構造が変わってスクレイピングが壊れた場合、以下のタスクで素早く原因を特定できる。

```sh
$ bundle exec rake debug_scraper        # voice がデフォルト
$ bundle exec rake debug_scraper[voice]
```

実行すると以下のファイルが `tmp/` に出力される（`.gitignore` で除外済み）。

* `tmp/#{category}_list.html` — DLsite から取得した一覧ページの HTML
* `tmp/#{category}_debug.json` — スクレイパーが抽出したアイテムの JSON

html を見てセレクタを修正し、`debug_scraper` を再実行して確認する。HTTP アクセスは初回のみで、2回目以降はキャッシュ済み HTML を使うため即座に完了する。

作業が終わったら `tmp/` を削除する。

```sh
$ rm -rf tmp/
```

## 環境変数

* `ACCESS_KEY`: AWS S3 アクセスキー
* `SECRET_ACCESS_KEY`: AWS S3 シークレットキー
* `BUCKET`: RSSをホスティングするバケット名
* `REGION`: AWS リージョン
* `RSS_URL`: RSSチャンネルに表示するURL
