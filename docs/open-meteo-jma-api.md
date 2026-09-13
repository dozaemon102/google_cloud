# Open-Meteo JMA API リファレンス

最終確認日: 2026-09-08  
公式ドキュメント: <https://open-meteo.com/en/docs/jma-api>

## 概要

Open-Meteo の JMA API は、気象庁（JMA）の数値予報モデルを利用して、日本・韓国などの予報値を返す API です。

- エンドポイント: `https://api.open-meteo.com/v1/jma`
- 認証: 非商用利用では API キー不要
- 返却形式: JSON
- 座標系: WGS84（緯度・経度）

> [!NOTE]
> API が返すのは気象モデルによる**予報値**です。`past_days` は直近の予報データを含める指定であり、観測された実績値そのものを取得する指定ではありません。

## 熱中症リスクダッシュボードで使うリクエスト

東京の時系列データを日本時間で取得する例です。

```text
https://api.open-meteo.com/v1/jma?latitude=35.6762&longitude=139.6503&hourly=temperature_2m,relative_humidity_2m,precipitation,wind_speed_10m&timezone=Asia%2FTokyo&forecast_days=4
```

このプロジェクトで WBGT の簡易推定と注意レベル判定に最低限必要な値は、`temperature_2m`（気温）と `relative_humidity_2m`（相対湿度）です。降水量・風速は画面表示や将来の判定ロジック拡張用に取得します。

## URL パラメータ

| パラメータ | 必須 | 形式・既定値 | 説明 |
| --- | --- | --- | --- |
| `latitude` | 必須 | 浮動小数点数 | 取得地点の緯度。例: 東京は `35.6762`。 |
| `longitude` | 必須 | 浮動小数点数 | 取得地点の経度。例: 東京は `139.6503`。 |
| `hourly` | 任意 | カンマ区切りの変数名 | 時間ごとの値として返す項目。複数指定できる。 |
| `daily` | 任意 | カンマ区切りの変数名 | 日ごとの集計値として返す項目。指定時は `timezone` も必須。 |
| `current` | 任意 | カンマ区切りの変数名 | 現在時点の気象条件として返す項目。時間別データで利用可能な項目も指定できる。 |
| `timezone` | 任意 | 既定値: `GMT` | 時刻のタイムゾーン。日本の都市では `Asia/Tokyo` を指定する。`auto` は座標から自動判定する。 |
| `forecast_days` | 任意 | 整数、既定値: `7`、最大: `11` | 今日以降の予報日数。JMA MSM の高解像度データは4日間であるため、本プロジェクトでは `4` を推奨する。 |
| `past_days` | 任意 | 整数、既定値: `0` | 今日より前の日のデータも返す。直近の予報を確認したいときに使う。 |
| `forecast_hours` | 任意 | 正の整数 | 現在時刻を基準に、返す将来の時間数を指定する。 |
| `past_hours` | 任意 | 正の整数 | 現在時刻を基準に、返す過去の時間数を指定する。 |
| `start_date` / `end_date` | 任意 | `YYYY-MM-DD` | 取得する日付範囲を指定する。開始日と終了日を組み合わせて使う。 |
| `start_hour` / `end_hour` | 任意 | `YYYY-MM-DDTHH:MM` | 時間別データの取得範囲を指定する。 |
| `elevation` | 任意 | 浮動小数点数 | 統計的ダウンスケーリングに使う標高（m）。通常は指定不要。`nan` を指定するとダウンスケーリングを無効化する。 |
| `cell_selection` | 任意 | 既定値: `land` | 格子点の選択方法。`land` は標高が近い陸地、`sea` は海上、`nearest` は最も近い格子点を優先する。 |
| `temperature_unit` | 任意 | 既定値: `celsius` | 気温の単位。`fahrenheit` を指定すると華氏になる。 |
| `wind_speed_unit` | 任意 | 既定値: `kmh` | 風速の単位。`kmh`、`ms`、`mph`、`kn` から選ぶ。 |
| `precipitation_unit` | 任意 | 既定値: `mm` | 降水量の単位。`mm` または `inch`。 |
| `timeformat` | 任意 | 既定値: `iso8601` | 時刻形式。`unixtime` を指定すると UNIX 時刻（秒）になる。この場合の時刻は GMT+0。 |
| `apikey` | 任意 | 文字列 | 商用契約で予約リソースを使用する場合に必要。通常の非商用利用では不要。 |

複数の都市を一度に取得する場合は、緯度・経度を同じ順序でカンマ区切りにします。

```text
latitude=35.6762,34.6937&longitude=139.6503,135.5023
```

この場合、レスポンスは都市ごとのオブジェクト配列になります。

## 熱中症リスクで使用する時間別変数

`hourly` に指定する変数です。指定した各変数は、`hourly.time` と同じ添字で対応します。

| 変数 | 単位 | 内容 | プロジェクトでの用途 |
| --- | --- | --- | --- |
| `temperature_2m` | °C | 地上2 mの気温 | WBGT 簡易推定の入力 |
| `relative_humidity_2m` | % | 地上2 mの相対湿度 | WBGT 簡易推定の入力 |
| `precipitation` | mm | 直前1時間の総降水量 | 表示・気象状況の補助情報 |
| `wind_speed_10m` | km/h（変更可） | 地上10 mの風速 | 表示・将来の判定拡張 |
| `apparent_temperature` | °C | 風・湿度・日射を加味した体感温度 | 画面表示の補助情報 |
| `dew_point_2m` | °C | 地上2 mの露点温度 | 湿度分析の補助情報 |
| `weather_code` | WMO 天気コード | 天気の状態を表す数値 | 天気アイコン・表示文言への変換 |
| `cloud_cover` | % | 全雲量 | 日射・天候の補助情報 |
| `surface_pressure` | hPa | 地表面の気圧 | 詳細分析用 |
| `shortwave_radiation` | W/m² | 直前1時間平均の短波放射（日射） | WBGT 推定の将来拡張用 |

> [!IMPORTANT]
> 日射関連の変数と、日射を必要とする `apparent_temperature` は JMA MSM で利用できます。一方、JMA GSM には日射データがないため利用できません。

## 日別・現在値でよく使う変数

### `daily` の主な指定値

| 変数 | 単位 | 内容 |
| --- | --- | --- |
| `temperature_2m_max` | °C | 日最高気温 |
| `temperature_2m_min` | °C | 日最低気温 |
| `apparent_temperature_max` | °C | 日最高体感温度 |
| `precipitation_sum` | mm | 日降水量の合計 |
| `weather_code` | WMO 天気コード | その日の中で最も強い気象状態 |
| `sunrise` / `sunset` | ISO 8601 | 日の出・日の入り時刻 |
| `wind_speed_10m_max` | km/h | 日最大風速 |

### `current` の主な指定値

`temperature_2m`、`relative_humidity_2m`、`apparent_temperature`、`precipitation`、`weather_code`、`wind_speed_10m` などを指定できます。リアルタイム性が必要な画面の補助表示に使用します。

## レスポンスの読み方

リクエストで `hourly=temperature_2m,relative_humidity_2m` を指定した場合、概ね次の形式で返ります。

```json
{
  "latitude": 35.7,
  "longitude": 139.7,
  "timezone": "Asia/Tokyo",
  "hourly_units": {
    "temperature_2m": "°C",
    "relative_humidity_2m": "%"
  },
  "hourly": {
    "time": ["2026-09-08T00:00", "2026-09-08T01:00"],
    "temperature_2m": [25.1, 24.8],
    "relative_humidity_2m": [82, 85]
  }
}
```

- `hourly.time[0]`、`temperature_2m[0]`、`relative_humidity_2m[0]` は同じ時刻のデータです。
- `hourly_units` を保存しておくと、表示や BigQuery 分析で単位を誤りません。
- 返された緯度・経度は実際に選ばれた予報格子点の中心であり、リクエスト値と数 km 程度異なる場合があります。

## JMA モデルの特徴と注意点

| モデル | 対象範囲 | 空間解像度 | 時間解像度 | 予報期間 | 更新頻度 |
| --- | --- | --- | --- | --- | --- |
| MSM | 日本・韓国 | 約5 km | 1時間 | 4日 | 3時間ごと |
| GSM | 全世界 | 約55 km | 6時間（API上では1時間に補間） | 11日 | 6時間ごと |
| MSM 気圧面 | 日本・韓国 | 約11 km | 3時間 | 4日 | 3時間ごと |

- Open-Meteo は JMA の複数モデルをつなぐ `JMA Seamless` も提供しています。
- GSM は日射量を持たないため、日射由来の項目は使えません。
- `weather_code` は雲量・降水量・降雪量から Open-Meteo が算出した値です。JMA の大気安定度情報が限定的なため、雷・霧の推定は十分ではありません。
- API のデータは更新されるため、BigQuery には `collected_at`（収集日時）と `forecast_time`（対象時刻）を分けて保存します。

## 実装時の推奨

収集処理では次を固定します。

```text
timezone=Asia/Tokyo
temperature_unit=celsius
wind_speed_unit=kmh
precipitation_unit=mm
```

都市ごとに API を呼び出し、レスポンスの各時刻データを Pub/Sub メッセージに分割して送信します。後段の Enricher は、気温と相対湿度を使って WBGT 簡易推定値と注意レベルを付与します。
