# dlsite_rss

DLsiteの新作をクローリング・整形してRSS配信するためのスクリプト

## 構成

* スクリプト実行環境: AWS Lambda(Ruby 2.5)
* RSSホスティング: AWS S3
* 構成管理: AWS SAM

## 環境構築

```sh
$ pipenv install
$ bundle install
```

## 環境変数

### AWS Lambda

* `ACCESS_KEY`
* `SECRET_ACCESS_KEY`
* `BUCKET`: RSSをホスティングするバケット名
* `REGION`: そのリージョン
* `RSS_URL`: RSSチャンネルに表示するＵＲＬ

### AWS SAM

`$ aws sam deploy`に必要な変数

https://docs.aws.amazon.com/ja_jp/serverless-application-model/latest/developerguide/sam-cli-command-reference-sam-deploy.html

* `SAM_CAPABILITIES`
* `SAM_REGION`
* `SAM_S3_BUCKET`
* `SAM_S3_PREFIX`
* `SAM_STACK_NAME`

## ローカルでのビルド

```sh
$ pipenv run sam build --use-container
```

## デプロイ

ビルド後に実施する

```sh
$ pipenv run sam package --s3-bucket ${SAM_S3_BUCKET}
$ pipenv run sam deploy \
    --stack-name ${SAM_STACK_NAME} \
    --s3-bucket ${SAM_S3_BUCKET} \
    --s3-prefix ${SAM_S3_PREFIX} \
    --capabilities ${SAM_CAPABILITIES} \
    --region ${SAM_REGION} \
    --no-fail-on-empty-changeset
```

## Unit tests

```sh
$ bundle exec ruby tests/unit/test_handler.rb
```
