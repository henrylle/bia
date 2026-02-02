#!/bin/bash

# Deploy Versionado - Projeto BIA
# Script simples para deploy com versionamento por commit hash

set -e

# Configurações
REGION="us-east-1"
ECR_REPO="bia"
CLUSTER="cluster-bia"
SERVICE="bia-service"
TASK_FAMILY="task-def-bia"

# Obter commit hash (7 caracteres)
COMMIT_HASH=$(git rev-parse --short=7 HEAD)
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPO"

echo "🚀 Deploy Versionado - BIA"
echo "📦 Versão: $COMMIT_HASH"
echo "🏗️  ECR: $ECR_URI"
echo ""

# 1. Login ECR
echo "🔐 Login no ECR..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_URI

# 2. Build da imagem
echo "🔨 Build da imagem..."
docker build -t bia-app:$COMMIT_HASH -t $ECR_URI:$COMMIT_HASH .

# 3. Push para ECR
echo "📤 Push para ECR..."
docker push $ECR_URI:$COMMIT_HASH

# 4. Obter task definition atual
echo "📋 Obtendo task definition atual..."
CURRENT_TASK_DEF=$(aws ecs describe-task-definition --task-definition $TASK_FAMILY --region $REGION --query 'taskDefinition')

# 5. Criar nova task definition
echo "🆕 Criando nova task definition..."
NEW_TASK_DEF=$(echo "$CURRENT_TASK_DEF" | jq --arg image "$ECR_URI:$COMMIT_HASH" '
    .containerDefinitions[0].image = $image |
    del(.taskDefinitionArn, .revision, .status, .requiresAttributes, .placementConstraints, .compatibilities, .registeredAt, .registeredBy)
')

# 6. Registrar task definition
echo "$NEW_TASK_DEF" > /tmp/task-def-$COMMIT_HASH.json
NEW_REVISION=$(aws ecs register-task-definition --region $REGION --cli-input-json file:///tmp/task-def-$COMMIT_HASH.json --query 'taskDefinition.revision' --output text)

# 7. Atualizar serviço
echo "🔄 Atualizando serviço ECS..."
aws ecs update-service \
    --region $REGION \
    --cluster $CLUSTER \
    --service $SERVICE \
    --task-definition $TASK_FAMILY:$NEW_REVISION

# 8. Aguardar estabilização
echo "⏳ Aguardando estabilização..."
aws ecs wait services-stable --region $REGION --cluster $CLUSTER --services $SERVICE

# Cleanup
rm -f /tmp/task-def-$COMMIT_HASH.json

echo ""
echo "✅ Deploy concluído!"
echo "📌 Versão: $COMMIT_HASH"
echo "📋 Task Definition: $TASK_FAMILY:$NEW_REVISION"
echo "🔗 ECR Image: $ECR_URI:$COMMIT_HASH"
