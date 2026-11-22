#!/bin/bash
# Mostra, a cada rodada, quanto do trafego caiu em cada versao da BIA.
# Serve para ver o canary (e o linear/blue-green) acontecendo pela rota /api/versao.
# Cada revisao da task definition precisa ter um VERSAO_API diferente (ex.: 4.5.0, 4.6.0).
#
# A cada volta tambem chama /api/tarefas (a rota que a tela usa para listar as tarefas)
# e conta quantas responderam ok e quantas deram erro. Isso gera o trafego que alimenta
# o alarme de 5xx do ALB no cenario de rollback automatico.
#
# Uso: ./check-canary.sh https://<seu-dominio> [voltas-por-rodada]
# Com CLUSTER e SERVICE definidos, mostra tambem a fase do deploy:
#   CLUSTER=cluster-bia SERVICE=service-bia ./check-canary.sh https://<seu-dominio>
URL="${1:?Uso: $0 https://<seu-dominio> [voltas-por-rodada]}"
N="${2:-100}"

fase() {
  [ -z "$CLUSTER" ] || [ -z "$SERVICE" ] && return
  local arn
  arn=$(aws ecs list-service-deployments --cluster "$CLUSTER" --service "$SERVICE" \
    --query 'sort_by(serviceDeployments,&createdAt)[-1].serviceDeploymentArn' --output text 2>/dev/null)
  [ -z "$arn" ] || [ "$arn" = "None" ] && { echo "sem deploy"; return; }
  aws ecs describe-service-deployments --service-deployment-arns "$arn" \
    --query 'serviceDeployments[0].[status,lifecycleStage]' --output text 2>/dev/null | tr '\t' ' '
}

while true; do
  printf "%s  " "$(date +%H:%M:%S)"
  [ -n "$CLUSTER" ] && printf "%-38s " "[$(fase)]"
  for i in $(seq "$N"); do
    codigo=$(curl -s -m 2 -o /tmp/check-canary.$$ -w '%{http_code}' "$URL/api/versao")
    echo "V $codigo $(cat /tmp/check-canary.$$ 2>/dev/null)"
    echo "T $(curl -s -m 2 -o /dev/null -w '%{http_code}' "$URL/api/tarefas")"
  done | awk -v n="$N" '
    $1 == "T" { if ($2 == 200) t_ok++; else t_erro++; next }
    $2 != 200 { erros++; next }
    { $1 = ""; $2 = ""; sub(/^  /, ""); versoes[$0]++ }
    END {
      for (v in versoes) printf "%-18s %3d%%   ", v, versoes[v] * 100 / n
      printf "erros %d   |  /api/tarefas: %d ok, %d erro\n", erros, t_ok, t_erro
    }'
  sleep 1
done
