# Heat Risk Dashboard

日本主要10都市の気象データを Open-Meteo から毎時収集し、WBGT ベースの熱中症リスクを算出する。Cloud Run + Pub/Sub のデータパイプラインで Firestore / BigQuery に保存し、FastAPI + React で最新の注意度を表示します。

## デモ

| コンポーネント | URL |
|---|---|
| フロントエンド | https://heat-risk-dev.web.app |

都市 ID（例: `tokyo`）を入力してリスクを確認できます。

## アーキテクチャ

構成図は [docs/architecture.drawio](docs/architecture.drawio) にあります。  
[draw.io](https://app.diagrams.net/) または VS Code の Draw.io Integration 拡張で開けます。

```
Cloud Scheduler (毎時)
  → Cloud Run Job: collector
      → Open-Meteo JMA API
      → Pub/Sub: heat-risk-dev-events-raw
          → Cloud Run: enricher
              → Firestore (最新状態)
              → BigQuery (履歴)
  → Cloud Run: api
      → Firestore (読み取り)
  → Firebase Hosting: frontend
      → API (fetch)
```

## 技術スタック

| レイヤー | 技術 |
|---|---|
| フロントエンド | React 19, TypeScript, Vite |
| API | Python 3.13, FastAPI, uvicorn |
| データパイプライン | Python 3.13, Cloud Run Job / Service |
| インフラ | Terraform, GCS Backend |
| CI/CD | GitHub Actions, Workload Identity Federation |
| データストア | Firestore, BigQuery |
| ホスティング | Firebase Hosting, Cloud Run |

## ディレクトリ構成

```
.
├── backend/          # FastAPI（Cloud Run API）
├── pipeline/         # collector（Job）+ enricher（Service）
├── frontend/         # React SPA（Firebase Hosting）
├── terraform/        # IaC（environments/dev + modules）
├── docs/             # 設計ドキュメント・構成図
└── .github/workflows/  # deploy-app.yml, deploy-pipeline.yml
```

## GCP リソース（dev 環境）

| 種別 | 名前 |
|---|---|
| Cloud Run Service | `heat-risk-dev-api`, `heat-risk-dev-enricher` |
| Cloud Run Job | `heat-risk-dev-collector` |
| Pub/Sub Topic | `heat-risk-dev-events-raw`, `heat-risk-dev-events-dlq` |
| Pub/Sub Subscription | `heat-risk-dev-events-enricher` |
| Cloud Scheduler | `heat-risk-dev-collect-hourly` |
| Artifact Registry | `heat-risk-dev-images` |
| Firebase Hosting | `heat-risk-dev` |
| BigQuery Dataset | `heat_risk_dev` |
| Firestore Collection | `risk_statuses` |

## ローカル開発

### 前提

- Python 3.13 + [uv](https://docs.astral.sh/uv/)
- Node.js 20+
- gcloud CLI（GCP デプロイ時）

### API

```bash
cd backend
uv sync
uv run uvicorn main:app --app-dir src --reload --port 8000
```

### フロントエンド

```bash
cd frontend
npm install
npm run dev
```

`.env` に `VITE_API_BASE_URL=http://localhost:8000` を設定（未設定時はデフォルトで localhost:8000）。

### パイプライン

```bash
cd pipeline
uv sync

# collector（要: PROJECT_ID, PUBSUB_RAW_TOPIC_NAME）
$env:PYTHONPATH="src"
uv run python src/collector/main.py

# enricher
uv run uvicorn main:app --app-dir src/enricher --reload --port 8080
```

## デプロイ

### インフラ（Terraform）

```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

### アプリ（GitHub Actions）

| ワークフロー | 対象 | トリガー |
|---|---|---|
| `deploy-app.yml` | API | `backend/**` の push / 手動 |
| `deploy-pipeline.yml` | collector, enricher | `pipeline/**` の push / 手動 |

認証は Workload Identity Federation（鍵ファイルなし）。

### フロントエンド（手動）

```bash
cd frontend
npm run build
firebase deploy --only hosting
```

`frontend/.env.production` に本番 API の URL を設定してからビルドしてください。

## API エンドポイント

| Method | Path | 説明 |
|---|---|---|
| `GET` | `/cities` | 対象都市 ID 一覧 |
| `GET` | `/cities/{city_id}/risk` | 都市の最新リスク |

## 対象都市

`sapporo`, `sendai`, `tokyo`, `nagoya`, `osaka`, `kyoto`, `hiroshima`, `fukuoka`, `nagasaki`, `naha`

## 今後の予定

- [ ] BigQuery 集計ビュー `v_heat_risk_metrics` + Looker Studio
- [ ] Cloud Monitoring アラート（収集失敗・DLQ）
- [ ] フロントエンドの CI/CD（Firebase Hosting）
- [ ] Terraform CI（`terraform.yml` の有効化）

## 参考

- [実装計画](docs/implementation-plan.md)
- [Open-Meteo JMA API](docs/open-meteo-jma-api.md)
