#!/bin/bash
set -e

# Configurações
CLUSTER_NAME="cluster-bia"
SERVICE_NAME="service-bia"
REGION="us-east-1"
TASK_FAMILY="task-def-bia"

# Verifica parâmetro
if [ -z "$1" ]; then
  echo "❌ Uso: ./rollback.sh <revisao>"
  echo "Exemplo: ./rollback.sh 11"
  echo ""
  echo "📋 Últimas 5 revisões:"
  aws ecs list-task-definitions --family-prefix $TASK_FAMILY --region $REGION --sort DESC --max-items 5 --query 'taskDefinitionArns' --output table
  exit 1
fi

REVISION=$1

# Atualiza service
echo "⏪ Rollback para task definition $TASK_FAMILY:$REVISION"
aws ecs update-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --task-definition $TASK_FAMILY:$REVISION --region $REGION --query 'service.taskDefinition' --output text

echo "✅ Rollback concluído!"
