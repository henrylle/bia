#!/bin/bash
# shellcheck disable=SC2016  # crases são literais do JMESPath (--query), não substituição de comando
# Deploy e rollback da BIA no ECS usando o short commit hash como tag da imagem.
#
# Uso:
#   ./scripts/ecs/unix/deploy-versionado.sh deploy            build + push com a tag do commit atual e deploy
#   ./scripts/ecs/unix/deploy-versionado.sh rollback <hash>   volta para a imagem de um commit que já está no ECR
#   ./scripts/ecs/unix/deploy-versionado.sh rollback          volta para a revisão anterior da task definition
#   ./scripts/ecs/unix/deploy-versionado.sh status            mostra a versão no ar e o estado do deploy
#   ./scripts/ecs/unix/deploy-versionado.sh versoes           lista as tags disponíveis no ECR
#   ./scripts/ecs/unix/deploy-versionado.sh circuit-breaker on|off   liga/desliga o circuit breaker (com rollback)
#   ./scripts/ecs/unix/deploy-versionado.sh deploy-quebrado   deploy de uma imagem que não existe (para testar falha)
#
# Variáveis que podem ser sobrescritas: REGION, CLUSTER, SERVICE, CONTAINER, REPO
# Exemplo: CLUSTER=cluster-bia SERVICE=service-bia ./scripts/ecs/unix/deploy-versionado.sh deploy

set -euo pipefail

REGION=${REGION:-us-east-1}
CLUSTER=${CLUSTER:-cluster-bia-alb}
SERVICE=${SERVICE:-service-bia-alb}
CONTAINER=${CONTAINER:-bia}
REPO=${REPO:-bia}

export AWS_REGION=$REGION

task_def_atual() {
  aws ecs describe-services --cluster "$CLUSTER" --services "$SERVICE" \
    --query 'services[0].taskDefinition' --output text
}

imagem_da_task_def() {
  aws ecs describe-task-definition --task-definition "$1" \
    --query "taskDefinition.containerDefinitions[?name=='$CONTAINER'].image | [0]" --output text
}

registry() {
  echo "$(aws sts get-caller-identity --query Account --output text).dkr.ecr.$REGION.amazonaws.com"
}

# Cria uma nova revisão da task definition atual trocando só a imagem do container.
nova_task_def() {
  local imagem=$1 arquivo
  arquivo=$(mktemp)
  aws ecs describe-task-definition --task-definition "$(task_def_atual)" --query taskDefinition --output json \
    | jq --arg img "$imagem" --arg c "$CONTAINER" '
        if any(.containerDefinitions[]; .name == $c) then . else error("container \($c) não existe na task definition") end
        | (.containerDefinitions[] | select(.name == $c) | .image) = $img
        | del(.taskDefinitionArn, .revision, .status, .requiresAttributes, .compatibilities,
              .registeredAt, .registeredBy, .deregisteredAt)' > "$arquivo"
  aws ecs register-task-definition --cli-input-json "file://$arquivo" \
    --query taskDefinition.taskDefinitionArn --output text
  rm -f "$arquivo"
}

# Atualiza o service e acompanha o deploy até COMPLETED ou FAILED (circuit breaker).
atualizar_service() {
  local task_def=$1 deploy_id estado motivo
  echo ">> Atualizando $SERVICE para ${task_def##*/}"
  deploy_id=$(aws ecs update-service --cluster "$CLUSTER" --service "$SERVICE" --task-definition "$task_def" \
    --query 'service.deployments[?status==`PRIMARY`].id | [0]' --output text)

  echo ">> Acompanhando o deploy $deploy_id (Ctrl+C para de acompanhar, o deploy continua)"
  echo "   Com o circuit breaker desligado, um deploy quebrado nunca vira FAILED: fica IN_PROGRESS para sempre."
  while true; do
    read -r estado motivo < <(aws ecs describe-services --cluster "$CLUSTER" --services "$SERVICE" \
      --query "services[0].deployments[?id=='$deploy_id'] | [0].[rolloutState, rolloutStateReason]" --output text)
    echo "   $(date +%H:%M:%S) $estado"
    case $estado in
      COMPLETED) echo ">> Deploy concluído: ${task_def##*/} está no ar."; return 0 ;;
      FAILED)    echo ">> Deploy FALHOU: $motivo"
                 echo ">> Se o rollback do circuit breaker estiver ligado, o ECS já está voltando sozinho. Veja com: $0 status"
                 return 1 ;;
      None|"")   echo ">> O deploy saiu da lista do service (foi substituído). Veja com: $0 status"; return 1 ;;
    esac
    sleep 15
  done
}

deploy() {
  local raiz tag imagem
  raiz=$(git rev-parse --show-toplevel)
  tag=$(git rev-parse --short=7 HEAD)
  if [ -n "$(git -C "$raiz" status --porcelain)" ]; then
    echo "!! Existem alterações não commitadas. A imagem $tag não vai bater com o commit $tag."
    read -r -p "   Continuar mesmo assim? [s/N] " ok
    [ "$ok" = "s" ] || exit 1
  fi
  imagem="$(registry)/$REPO:$tag"

  echo ">> Login no ECR"
  aws ecr get-login-password | docker login --username AWS --password-stdin "${imagem%%/*}"
  echo ">> Build de $imagem"
  # linux/amd64: as EC2 do cluster são x86. Sem isso, um Mac M1/M2/M3 gera imagem ARM que não roda lá.
  docker build --platform linux/amd64 -t "$imagem" "$raiz"
  echo ">> Push de $imagem"
  docker push "$imagem"

  atualizar_service "$(nova_task_def "$imagem")"
}

rollback() {
  local alvo=${1:-} atual familia rev_atual imagem
  if [ -n "$alvo" ]; then
    # Rollback para um commit: a imagem tem que existir no ECR.
    aws ecr describe-images --repository-name "$REPO" --image-ids imageTag="$alvo" >/dev/null 2>&1 \
      || { echo "!! A imagem $REPO:$alvo não existe no ECR. Veja as disponíveis com: $0 versoes"; exit 1; }
    imagem="$(registry)/$REPO:$alvo"
    echo ">> Rollback para o commit $alvo ($imagem)"
    atualizar_service "$(nova_task_def "$imagem")"
    return
  fi

  # Sem argumento: revisão anterior da mesma família de task definition.
  atual=$(task_def_atual)
  familia=$(echo "${atual##*/}" | cut -d: -f1)
  rev_atual=${atual##*:}
  alvo=$(aws ecs list-task-definitions --family-prefix "$familia" --sort DESC --query 'taskDefinitionArns' --output text \
    | tr '\t' '\n' | awk -F'[/:]' -v f="$familia" -v r="$rev_atual" '$(NF-1)==f && $NF<r {print; exit}')
  [ -n "$alvo" ] || { echo "!! Não existe revisão anterior a $familia:$rev_atual."; exit 1; }
  echo ">> Rollback de $familia:$rev_atual para ${alvo##*/} (imagem $(imagem_da_task_def "$alvo"))"
  atualizar_service "$alvo"
}

status() {
  local atual
  atual=$(task_def_atual)
  echo "Task definition: ${atual##*/}"
  echo "Imagem:          $(imagem_da_task_def "$atual")"
  echo "Circuit breaker: $(aws ecs describe-services --cluster "$CLUSTER" --services "$SERVICE" \
    --query 'services[0].deploymentConfiguration.deploymentCircuitBreaker.[enable, rollback]' --output text \
    | awk '{print ($1=="True" ? "ligado" : "desligado") ", rollback " ($2=="True" ? "ligado" : "desligado")}')"
  aws ecs describe-services --cluster "$CLUSTER" --services "$SERVICE" \
    --query 'services[0].deployments[].{status:status,rollout:rolloutState,taskDef:taskDefinition,running:runningCount,desired:desiredCount,motivo:rolloutStateReason}' \
    --output table
}

versoes() {
  aws ecr describe-images --repository-name "$REPO" \
    --query 'reverse(sort_by(imageDetails[?imageTags], &imagePushedAt))[:15].{tag:join(`,`, imageTags), enviada:imagePushedAt}' \
    --output table
}

circuit_breaker() {
  local liga
  case ${1:-} in
    on)  liga=true ;;
    off) liga=false ;;
    *)   echo "!! Use: $0 circuit-breaker on|off"; exit 1 ;;
  esac
  # min/max repetidos de propósito: são os valores do projeto (50% / 100%).
  aws ecs update-service --cluster "$CLUSTER" --service "$SERVICE" \
    --deployment-configuration "deploymentCircuitBreaker={enable=$liga,rollback=$liga},minimumHealthyPercent=50,maximumPercent=100" \
    --query 'service.deploymentConfiguration.deploymentCircuitBreaker' --output table
}

# Imagem que não existe: a task não consegue fazer pull e falha antes de chegar a RUNNING (estágio 1).
deploy_quebrado() {
  local imagem
  imagem="$(registry)/$REPO:nao-existe"
  echo ">> Deploy QUEBRADO de propósito com $imagem"
  atualizar_service "$(nova_task_def "$imagem")"
}

case ${1:-} in
  deploy)          deploy ;;
  rollback)        rollback "${2:-}" ;;
  status)          status ;;
  versoes)         versoes ;;
  circuit-breaker) circuit_breaker "${2:-}" ;;
  deploy-quebrado) deploy_quebrado ;;
  *)               sed -n '3,15p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac
