#!/bin/bash
set -e

# Configurações
CLUSTER_NAME="cluster-bia"
SERVICE_NAME="service-bia"
ECR_REPO="794038217446.dkr.ecr.us-east-1.amazonaws.com/bia"
REGION="us-east-1"
TASK_FAMILY="task-def-bia"

# Captura commit hash
COMMIT_HASH=$(git rev-parse --short=7 HEAD)
echo "📦 Deploy da versão: $COMMIT_HASH"

# Obtém IP público da instância EC2
echo "🔍 Obtendo IP público do cluster..."
INSTANCE_ID=$(aws ecs list-container-instances --cluster $CLUSTER_NAME --region $REGION --query 'containerInstanceArns[0]' --output text | xargs -I {} aws ecs describe-container-instances --cluster $CLUSTER_NAME --container-instances {} --region $REGION --query 'containerInstances[0].ec2InstanceId' --output text)
PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --region $REGION --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
echo "✅ IP público: $PUBLIC_IP"

# Login no ECR
echo "🔐 Login no ECR..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_REPO

# Build da imagem
echo "🏗️  Build da imagem com VITE_API_URL=http://$PUBLIC_IP"
docker build --build-arg VITE_API_URL=http://$PUBLIC_IP -t bia:$COMMIT_HASH .

# Tag e push
echo "📤 Push para ECR..."
docker tag bia:$COMMIT_HASH $ECR_REPO:$COMMIT_HASH
docker tag bia:$COMMIT_HASH $ECR_REPO:latest
docker push $ECR_REPO:$COMMIT_HASH
docker push $ECR_REPO:latest

# Obtém task definition atual e cria nova com imagem atualizada
echo "📋 Criando nova task definition..."
aws ecs describe-task-definition --task-definition $TASK_FAMILY --region $REGION | \
  jq --arg IMAGE "$ECR_REPO:$COMMIT_HASH" \
  '.taskDefinition | 
   .containerDefinitions[0].image = $IMAGE | 
   {family, networkMode, requiresCompatibilities, cpu, memory, executionRoleArn, runtimePlatform, containerDefinitions}' > /tmp/taskdef.json

# Registra nova task definition
echo "✍️  Registrando task definition..."
NEW_REVISION=$(aws ecs register-task-definition --cli-input-json file:///tmp/taskdef.json --region $REGION --query 'taskDefinition.revision' --output text)
echo "✅ Task definition revisão: $NEW_REVISION"

# Atualiza service
echo "🚀 Atualizando service..."
aws ecs update-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --task-definition $TASK_FAMILY:$NEW_REVISION --region $REGION --query 'service.taskDefinition' --output text

echo ""
echo "✅ Deploy concluído!"
echo "📌 Versão: $COMMIT_HASH"
echo "📌 Task Definition: $TASK_FAMILY:$NEW_REVISION"
echo "📌 Imagem: $ECR_REPO:$COMMIT_HASH"
echo "🌐 URL: http://$PUBLIC_IP"
