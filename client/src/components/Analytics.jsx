import React, { useMemo } from "react"
import { Link } from "react-router-dom"
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Cell,
  ResponsiveContainer,
  Tooltip,
} from "recharts"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "./ui/card"

const COLORS = {
  importantes: "#f59e0b",
  normais: "#10b981",
}

// Tooltip customizado para o gráfico
const CustomTooltip = ({ active, payload }) => {
  if (active && payload && payload.length) {
    const item = payload[0]
    return (
      <div
        style={{
          background: "var(--bg-card)",
          border: "1px solid var(--border-color)",
          borderRadius: "8px",
          padding: "0.75rem 1rem",
          boxShadow: "var(--shadow)",
        }}
      >
        <p style={{ color: "var(--text-primary)", fontWeight: 600, margin: 0 }}>
          {item.payload.category}
        </p>
        <p style={{ color: item.payload.color, margin: "0.25rem 0 0" }}>
          {item.value} {item.value === 1 ? "tarefa" : "tarefas"}
        </p>
      </div>
    )
  }
  return null
}

// Label customizado para as barras
const CustomBarLabel = ({ x, y, width, value }) => {
  if (value === 0) return null
  return (
    <text
      x={x + width / 2}
      y={y - 6}
      fill="var(--text-secondary)"
      textAnchor="middle"
      fontSize={13}
      fontWeight={600}
    >
      {value}
    </text>
  )
}

export default function Analytics({ tasks = [] }) {
  const stats = useMemo(() => {
    const importantesCount = tasks.filter((t) => t.importante).length
    const normaisCount = tasks.filter((t) => !t.importante).length
    const total = tasks.length
    const pctImportantes = total > 0 ? Math.round((importantesCount / total) * 100) : 0
    const pctNormais = total > 0 ? Math.round((normaisCount / total) * 100) : 0

    return { importantesCount, normaisCount, total, pctImportantes, pctNormais }
  }, [tasks])

  const chartData = [
    {
      category: "⭐ Importantes",
      count: stats.importantesCount,
      color: COLORS.importantes,
    },
    {
      category: "📋 Normais",
      count: stats.normaisCount,
      color: COLORS.normais,
    },
  ]

  return (
    <div className="analytics-page">
      {/* Cabeçalho */}
      <div className="analytics-header">
        <Link to="/" className="back-button" aria-label="Voltar para Home">
          ← Voltar
        </Link>
        <h1 className="analytics-title">📊 Analytics</h1>
        <p className="analytics-subtitle">Distribuição das suas tarefas por prioridade</p>
      </div>

      {tasks.length === 0 ? (
        /* Estado vazio */
        <div className="analytics-empty">
          <div className="analytics-empty-icon">📊</div>
          <h2>Nenhuma tarefa ainda</h2>
          <p>Adicione tarefas para ver suas estatísticas aqui!</p>
          <Link to="/" className="back-button" style={{ marginTop: "1.5rem" }}>
            ← Adicionar Tarefas
          </Link>
        </div>
      ) : (
        <>
          {/* Gráfico de Barras */}
          <Card className="analytics-card">
            <CardHeader>
              <CardTitle className="analytics-card-title">
                Tasks por Prioridade
              </CardTitle>
              <CardDescription>
                Total: {stats.total} {stats.total === 1 ? "tarefa" : "tarefas"}
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div
                className="analytics-chart-wrapper"
                role="img"
                aria-label={`Gráfico: ${stats.importantesCount} tarefas importantes e ${stats.normaisCount} tarefas normais`}
              >
                <ResponsiveContainer width="100%" height={280}>
                  <BarChart
                    data={chartData}
                    margin={{ top: 20, right: 20, left: 0, bottom: 10 }}
                    barCategoryGap="35%"
                  >
                    <CartesianGrid
                      strokeDasharray="3 3"
                      stroke="var(--border-color)"
                      vertical={false}
                    />
                    <XAxis
                      dataKey="category"
                      tick={{ fill: "var(--text-secondary)", fontSize: 13 }}
                      axisLine={{ stroke: "var(--border-color)" }}
                      tickLine={false}
                    />
                    <YAxis
                      allowDecimals={false}
                      tick={{ fill: "var(--text-secondary)", fontSize: 12 }}
                      axisLine={false}
                      tickLine={false}
                      width={30}
                    />
                    <Tooltip content={<CustomTooltip />} cursor={{ fill: "rgba(0,0,0,0.05)" }} />
                    <Bar dataKey="count" radius={[6, 6, 0, 0]} label={<CustomBarLabel />}>
                      {chartData.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={entry.color} />
                      ))}
                    </Bar>
                  </BarChart>
                </ResponsiveContainer>
              </div>

              {/* Legenda visual */}
              <div className="analytics-legend">
                <div className="analytics-legend-item">
                  <span
                    className="analytics-legend-dot"
                    style={{ backgroundColor: COLORS.importantes }}
                    aria-hidden="true"
                  />
                  <span>Importantes</span>
                </div>
                <div className="analytics-legend-item">
                  <span
                    className="analytics-legend-dot"
                    style={{ backgroundColor: COLORS.normais }}
                    aria-hidden="true"
                  />
                  <span>Normais</span>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Cards de Estatísticas */}
          <div className="analytics-stats-grid">
            <Card className="analytics-stat-card">
              <CardContent className="analytics-stat-content">
                <div className="analytics-stat-icon">📋</div>
                <div>
                  <p className="analytics-stat-label">Total de Tasks</p>
                  <p className="analytics-stat-value">{stats.total}</p>
                </div>
              </CardContent>
            </Card>

            <Card
              className="analytics-stat-card"
              style={{ borderColor: COLORS.importantes }}
            >
              <CardContent className="analytics-stat-content">
                <div className="analytics-stat-icon">⭐</div>
                <div>
                  <p className="analytics-stat-label">Importantes</p>
                  <p className="analytics-stat-value" style={{ color: COLORS.importantes }}>
                    {stats.importantesCount}
                    <span className="analytics-stat-pct">({stats.pctImportantes}%)</span>
                  </p>
                </div>
              </CardContent>
            </Card>

            <Card
              className="analytics-stat-card"
              style={{ borderColor: COLORS.normais }}
            >
              <CardContent className="analytics-stat-content">
                <div className="analytics-stat-icon">✅</div>
                <div>
                  <p className="analytics-stat-label">Normais</p>
                  <p className="analytics-stat-value" style={{ color: COLORS.normais }}>
                    {stats.normaisCount}
                    <span className="analytics-stat-pct">({stats.pctNormais}%)</span>
                  </p>
                </div>
              </CardContent>
            </Card>
          </div>
        </>
      )}
    </div>
  )
}
