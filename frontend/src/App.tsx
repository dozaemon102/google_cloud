import { useState } from 'react'
import './App.css'

type RiskLevel = '危険' | '厳重警戒' | '警戒' | '注意' | 'ほぼ安全'

type RiskStatus = {
  city_id: string
  forecast_at: string
  wbgt_estimate: number
  risk_level: RiskLevel
}

function App() {
  const [city, setCity] = useState('')
  const [risk, setRisk] = useState<RiskStatus | null>(null)
  const [error, setError] = useState('')
  const [isLoading, setIsLoading] = useState(false)

  const checkRisk = async () => {
    const normalizedCity = city.trim()

    if (!normalizedCity) {
      setRisk(null)
      setError('都市IDを入力してください。例: tokyo')
      return
    }

    setIsLoading(true)
    setError('')

    try {
      const response = await fetch(
        `${import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8000'}/cities/${encodeURIComponent(normalizedCity)}/risk`,
      )

      if (response.status === 404) {
        throw new Error('この都市のリスク情報はまだありません。')
      }
      if (!response.ok) {
        throw new Error('リスク情報の取得に失敗しました。')
      }

      setRisk((await response.json()) as RiskStatus)
    } catch (error) {
      setRisk(null)
      setError(error instanceof Error ? error.message : '通信エラーが発生しました。')
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <main className="app">
      <h1>熱中症リスク</h1>
      <p className="description">都市IDを入力して、今日の注意度を確認します。</p>
      <div className="search">
        <input
          value={city}
          onChange={(event) => setCity(event.target.value)}
          onKeyDown={(event) => event.key === 'Enter' && checkRisk()}
          placeholder="例：tokyo"
          aria-label="都市ID"
        />
        <button type="button" onClick={checkRisk} disabled={isLoading}>
          {isLoading ? '確認中...' : '確認'}
        </button>
      </div>

      {risk && (
        <section className={`risk-card risk-${risk.risk_level}`} aria-live="polite">
          <p>{risk.city_id}の今日の注意度</p>
          <strong>{risk.risk_level}</strong>
          <small>WBGT推定値: {risk.wbgt_estimate}℃</small>
        </section>
      )}
      {error && <p className="error-message" role="alert">{error}</p>}
    </main>
  )
}

export default App
