#!/bin/bash

REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "==> Testando autenticação com ECR..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

if [ $? -eq 0 ]; then
    echo "✓ Autenticação com ECR bem-sucedida!"
else
    echo "✗ Falha na autenticação com ECR"
    exit 1
fi

echo ""
echo "==> Listando repositórios ECR..."
aws ecr describe-repositories --region $REGION
