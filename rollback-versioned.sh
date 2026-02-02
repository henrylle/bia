#!/bin/bash

# Rollback Simples - Projeto BIA
# Script para rollback usando commit hash

set -e

# Verificar se foi passado o commit hash
if [ -z "$1" ]; then
    echo "❌ Uso: ./rollback-versioned.sh <commit-hash>"
    echo "📋 Para listar versões: aws ecr describe-images --repository-name bia --query 'imageDetails[*].imageTags[0]' --output table"
    exit 1
fi

# Configurações
REGION="us-east-1"
ECR_REPO="bia"
CLUSTER="cluster-bia"
SERVICE="bia-service"
TASK_FAMILY="task-def-bia"
TARGET_VERSION="$1"

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPO"

echo "🔄 Rollback - BIA"
echo "📦 Versão de destino: $TARGET_VERSION"
echo ""

# 1. Verificar se a imagem existe
echo "🔍 Verificando se a versão existe..."
if ! aws ecr describe-images --repository-name $ECR_REPO --region $REGION --image-ids imageTag=$TARGET_VERSION > /dev/null 2>&1; then
    echo "❌ Versão $TARGET_VERSION não encontrada no ECR"
    exit 1
fi

# 2. Obter task definition atual
echo "📋 Obtendo task definition atual..."
CURRENT_TASK_DEF=$(aws ecs describe-task-definition --task-definition $TASK_FAMILY --region $REGION --query 'taskDefinition')

# 3. Criar nova task definition com versão anterior
echo "🆕 Criando task definition para rollback..."
NEW_TASK_DEF=$(echo "$CURRENT_TASK_DEF" | jq --arg image "$ECR_URI:$TARGET_VERSION" '
    .containerDefinitions[0].image = $image |
    del(.taskDefinitionArn, .revision, .status, .requiresAttributes, .placementConstraints, .compatibilities, .registeredAt, .registeredBy)
')

# 4. Registrar task definition
echo "$NEW_TASK_DEF" > /tmp/rollback-task-def-$TARGET_VERSION.json
NEW_REVISION=$(aws ecs register-task-definition --region $REGION --cli-input-json file:///tmp/rollback-task-def-$TARGET_VERSION.json --query 'taskDefinition.revision' --output text)

# 5. Atualizar serviço
echo "🔄 Executando rollback..."
aws ecs update-service \
    --region $REGION \
    --cluster $CLUSTER \
    --service $SERVICE \
    --task-definition $TASK_FAMILY:$NEW_REVISION

# 6. Aguardar estabilização
echo "⏳ Aguardando estabilização..."
aws ecs wait services-stable --region $REGION --cluster $CLUSTER --services $SERVICE

# Cleanup
rm -f /tmp/rollback-task-def-$TARGET_VERSION.json

echo ""
echo "✅ Rollback concluído!"
echo "📌 Versão atual: $TARGET_VERSION"
echo "📋 Task Definition: $TASK_FAMILY:$NEW_REVISION"
