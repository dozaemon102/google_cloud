# 実装計画

## 方針

CI/CD を先に作るのではなく、基盤の最小化、ローカル実装、手動デプロイ、CI/CD の順に進める。
ビルド対象、デプロイ先、検証条件が確立してから CI/CD を導入することで、問題を切り分けやすくする。

## 1. Terraform を最小実用形にする

- Cloud Run のサービス名を `heat-risk-dev-api` などの命名規則へ合わせる。
- Artifact Registry、Cloud Run API、Firestore、Pub/Sub（raw/DLQ）、BigQuery（データセット・テーブル）、最小 IAM を Terraform 管理に追加する。
- Cloud Run API、collector、enricher のデプロイ先を準備する。
- `terraform apply` と `terraform destroy` で安全に作成・削除できることを確認する。

## 2. データパイプラインをローカルで完成させる

- Open-Meteo から都市別の気象データを取得する collector を実装する。
- WBGT の簡易推定と注意レベル判定を、単体テスト可能な関数として実装する。
- enricher で Pub/Sub メッセージを受け取り、Firestore の最新状態と BigQuery の履歴へ保存する。
- Docker 化し、ローカルテスト後に Artifact Registry へ手動 push して Cloud Run 上でエンドツーエンド確認する。

## 3. FastAPI を実装・手動デプロイする

- `backend/main.py` を FastAPI アプリケーションへ置き換える。
- 都市一覧と最新リスク取得 API を先に提供する。
- Firestore からパイプラインが保存したデータを読み取る。
- Docker 化して Cloud Run API へ手動デプロイする。
- API URL を Terraform output として返し、疎通テストを追加する。

## 4. フロントエンドを作る

- Vite + React を使い、地域選択と当日の注意レベルを API から表示する。
- Firebase Hosting に手動デプロイする。
- ブラウザから API まで一連の動作を確認する。

## 5. CI/CD を導入する

- GitHub Actions 用の Workload Identity Federation と deployer サービスアカウントを Terraform で追加する。
- `terraform.yml` に、PR の `fmt`、`validate`、`plan`、main マージ時の承認付き apply を実装する。
- `deploy-app.yml` と `deploy-pipeline.yml` に、テスト、Docker build、Artifact Registry push、Cloud Run 更新を実装する。

## 6. 分析・監視を仕上げる

- BigQuery 集計ビュー `v_heat_risk_metrics` を作成し、Looker Studio ダッシュボードを接続する。
- Cloud Scheduler で collector を定期実行する。
- Pub/Sub の DLQ、収集失敗、Cloud Run エラーを Cloud Monitoring で検知する。

## 最初の着手点

次は Terraform に、Artifact Registry、Pub/Sub、Firestore、BigQuery、必要な API と IAM を dev 環境向けに追加する。
これにより、パイプラインと API を実際の GCP リソースへ段階的に接続できる。
