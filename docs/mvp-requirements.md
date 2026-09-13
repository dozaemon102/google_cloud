# データパイプライン MVP 要件

## 目的

日本の主要都市における熱中症リスクを、Open-Meteo の時間別予報から推定し、公開 API で提供する。

## 対象地域

初期リリースでは、次の 10 都市を対象とする。

- 札幌
- 仙台
- 東京
- 名古屋
- 大阪
- 京都
- 広島
- 福岡
- 長崎
- 那覇

各都市は `city_id`、表示名、緯度、経度、タイムゾーン（`Asia/Tokyo`）を持つ。

## データ取得

- Open-Meteo Forecast API を利用する。
- Cloud Scheduler から collector を毎時 1 回起動する。
- 都市ごとに、時間別の気温、相対湿度、降水量、風速、予報対象時刻を取得する。
- collector は取得結果を標準化した JSON として Pub/Sub の raw topic へ発行する。

## リスク判定

- enricher は気温と相対湿度から WBGT を簡易推定する。
- 推定 WBGT を環境省の注意区分に対応させ、次の 5 段階で返す。
  - ほぼ安全
  - 注意
  - 警戒
  - 厳重警戒
  - 危険
- 実測 WBGT ではないため、API と画面では「推定」であることを明記する。

## データ保存

- Firestore には、都市ごとの最新予報と最新リスクを保存する。
- BigQuery には、気象予報とリスク判定の時系列履歴を保存する。
- BigQuery は `forecast_at` を日付パーティションにし、当面のデータ保持期間は 90 日とする。

## 公開 API

- 認証なしの読み取り専用 API とする。
- 都市一覧を返す。
- 都市ごとの最新リスクを返す。

## データフロー

```text
Cloud Scheduler
  → collector（Cloud Run Job）
  → Pub/Sub raw topic
  → enricher（Cloud Run service）
  → Firestore / BigQuery
  → FastAPI
```

## 今回の対象外

- 過去実績データの取得と予報精度比較
- Firebase Authentication
- ユーザーの地域登録と通知送信
- Looker Studio
- Cloud Monitoring
- GitHub Actions による CI/CD
