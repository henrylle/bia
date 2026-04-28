#!/bin/bash
set -e

# ─── Configurações ────────────────────────────────────────────────────────────
CLUSTER="cluster-bia"
SERVICE="service-bia-td-cluster"
TASK_FAMILY="td-cluster-bia"
ECR_URI="241585213334.dkr.ecr.us-east-1.amazonaws.com/bia"
REGIAO="us-east-1"

# ─── Funções auxiliares ───────────────────────────────────────────────────────
erro() { echo "❌ ERRO: $1" >&2; exit 1; }
info() { echo "ℹ️  $1"; }
ok()   { echo "✅ $1"; }

ajuda() {
  cat <<EOF

Uso: $(basename "$0") <comando> [opções]

COMANDOS:
  deploy <commit-hash>          Faz deploy de uma imagem pelo commit hash
  rollback <task-def-revision>  Faz rollback para uma revisão específica da task definition
  listar                        Lista as últimas 10 revisões da task definition com suas imagens
  status                        Exibe o status atual do serviço

EXEMPLOS:
  $(basename "$0") deploy a1b2c3d
  $(basename "$0") rollback 5
  $(basename "$0") listar
  $(basename "$0") status

EOF
  exit 0
}

aguardar_deploy() {
  info "Aguardando estabilização do serviço..."
  aws ecs wait services-stable \
    --cluster "$CLUSTER" \
    --services "$SERVICE" \
    --region "$REGIAO"
  ok "Serviço estabilizado com sucesso."
}

atualizar_servico() {
  local task_def_arn="$1"
  info "Atualizando serviço para: $task_def_arn"
  aws ecs update-service \
    --cluster "$CLUSTER" \
    --service "$SERVICE" \
    --task-definition "$task_def_arn" \
    --region "$REGIAO" \
    --output json | jq -r '.service | "Revisão ativa: \(.taskDefinition)"'
  aguardar_deploy
}

# ─── Comandos ─────────────────────────────────────────────────────────────────
cmd_deploy() {
  local commit_hash="$1"
  [ -z "$commit_hash" ] && erro "Informe o commit hash. Ex: deploy a1b2c3d"

  local imagem="$ECR_URI:$commit_hash"

  info "Verificando imagem no ECR: $imagem"
  aws ecr describe-images \
    --repository-name bia \
    --image-ids imageTag="$commit_hash" \
    --region "$REGIAO" > /dev/null 2>&1 \
    || erro "Imagem com tag '$commit_hash' não encontrada no ECR."

  info "Obtendo configuração atual da task definition..."
  local task_def_json
  task_def_json=$(aws ecs describe-task-definition \
    --task-definition "$TASK_FAMILY" \
    --region "$REGIAO" \
    --query 'taskDefinition' \
    --output json)

  # Monta nova task definition com a nova imagem
  local nova_task_def
  nova_task_def=$(echo "$task_def_json" | jq \
    --arg img "$imagem" \
    'del(.taskDefinitionArn,.revision,.status,.requiresAttributes,.compatibilities,.registeredAt,.registeredBy)
     | .containerDefinitions[0].image = $img')

  info "Registrando nova task definition com imagem: $imagem"
  local nova_arn
  nova_arn=$(aws ecs register-task-definition \
    --cli-input-json "$nova_task_def" \
    --region "$REGIAO" \
    --query 'taskDefinition.taskDefinitionArn' \
    --output text)

  ok "Nova task definition registrada: $nova_arn"
  atualizar_servico "$nova_arn"
}

cmd_rollback() {
  local revisao="$1"
  [ -z "$revisao" ] && erro "Informe a revisão. Ex: rollback 3"

  local task_def_arn="$TASK_FAMILY:$revisao"

  info "Verificando revisão $revisao..."
  aws ecs describe-task-definition \
    --task-definition "$task_def_arn" \
    --region "$REGIAO" > /dev/null 2>&1 \
    || erro "Revisão '$revisao' não encontrada para a family '$TASK_FAMILY'."

  ok "Iniciando rollback para revisão $revisao"
  atualizar_servico "$task_def_arn"
}

cmd_listar() {
  info "Últimas 10 revisões da task definition '$TASK_FAMILY':"
  echo ""
  printf "%-10s %-12s %s\n" "REVISÃO" "STATUS" "IMAGEM"
  echo "─────────────────────────────────────────────────────────────────────"

  aws ecs list-task-definitions \
    --family-prefix "$TASK_FAMILY" \
    --sort DESC \
    --max-items 10 \
    --region "$REGIAO" \
    --query 'taskDefinitionArns[]' \
    --output text | tr '\t' '\n' | while read -r arn; do
      local revisao status imagem
      revisao=$(echo "$arn" | awk -F: '{print $NF}')
      read -r status imagem < <(aws ecs describe-task-definition \
        --task-definition "$arn" \
        --region "$REGIAO" \
        --query '[taskDefinition.status, taskDefinition.containerDefinitions[0].image]' \
        --output text)
      printf "%-10s %-12s %s\n" "$revisao" "$status" "$imagem"
  done
}

cmd_status() {
  info "Status do serviço '$SERVICE' no cluster '$CLUSTER':"
  echo ""
  aws ecs describe-services \
    --cluster "$CLUSTER" \
    --services "$SERVICE" \
    --region "$REGIAO" \
    --query 'services[0].{
      Status: status,
      Desejado: desiredCount,
      Rodando: runningCount,
      Pendente: pendingCount,
      TaskDefinition: taskDefinition
    }' \
    --output table
}

# ─── Entrada principal ────────────────────────────────────────────────────────
[ $# -eq 0 ] && ajuda

case "$1" in
  deploy)   cmd_deploy   "$2" ;;
  rollback) cmd_rollback "$2" ;;
  listar)   cmd_listar       ;;
  status)   cmd_status       ;;
  -h|--help|help) ajuda      ;;
  *) erro "Comando desconhecido: '$1'. Use --help para ver os comandos disponíveis." ;;
esac
