import React, { useMemo } from "react"
import { Link } from "react-router-dom"
import { Bar, BarChart, CartesianGrid, Cell, LabelList, XAxis } from "recharts"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "./ui/card"
import { ChartContainer, ChartTooltip, ChartTooltipContent } from "./ui/chart"

// Mesmas cores usadas anteriormente na implementação com Recharts puro,
// agora expostas via ChartConfig do shadcn/ui (gera as CSS vars --color-*
// consumidas pelo ChartContainer, incluindo suporte nativo a dark mode).
const COLORS = {
  importantes: "#f59e0b",
  normais: "#10b981",
}

const chartConfig = {
  importante: {
    label: "⭐ Importantes",
    color: COLORS.importantes,
  },
  normal: {
    label: "📋 Normais",
    color: COLORS.normais,
  },
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
      priority: "importante",
      count: stats.importantesCount,
    },
    {
      category: "📋 Normais",
      priority: "normal",
      count: stats.normaisCount,
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
                <ChartContainer
                  config={chartConfig}
                  className="aspect-auto h-[280px] w-full"
                >
                  <BarChart
                    data={chartData}
                    margin={{ top: 20, right: 20, left: 0, bottom: 10 }}
                    barCategoryGap="35%"
                  >
                    <CartesianGrid vertical={false} />
                    <XAxis
                      dataKey="category"
                      tickLine={false}
                      axisLine={false}
                      tickMargin={10}
                    />
                    <ChartTooltip
                      cursor={{ fill: "hsl(var(--muted))" }}
                      content={
                        <ChartTooltipContent hideLabel nameKey="priority" />
                      }
                    />
                    <Bar dataKey="count" radius={[6, 6, 0, 0]}>
                      <LabelList
                        dataKey="count"
                        position="top"
                        offset={8}
                        className="fill-foreground"
                        fontSize={13}
                        fontWeight={600}
                      />
                      {chartData.map((entry) => (
                        <Cell
                          key={entry.priority}
                          fill={`var(--color-${entry.priority})`}
                        />
                      ))}
                    </Bar>
                  </BarChart>
                </ChartContainer>
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
