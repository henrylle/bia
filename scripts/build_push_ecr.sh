#!/bin/bash

REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REPO_NAME="bia"
IMAGE_TAG="latest"

echo "==> Criando repositório ECR (se não existir)..."
aws ecr create-repository --repository-name $REPO_NAME --region $REGION 2>/dev/null || echo "Repositório já existe"

echo ""
echo "==> Fazendo login no ECR..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

echo ""
echo "==> Fazendo build da imagem Docker..."
docker build -t $REPO_NAME:$IMAGE_TAG .

echo ""
echo "==> Tagueando imagem para ECR..."
docker tag $REPO_NAME:$IMAGE_TAG $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:$IMAGE_TAG

echo ""
echo "==> Fazendo push para ECR..."
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:$IMAGE_TAG

echo ""
echo "✓ Build e push concluídos com sucesso!"
echo "Imagem: $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:$IMAGE_TAG"
