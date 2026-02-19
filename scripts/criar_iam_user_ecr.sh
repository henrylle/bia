#!/bin/bash

USER_NAME="bia-ecr-user"

echo "==> Criando usuário IAM: $USER_NAME"
aws iam create-user --user-name $USER_NAME 2>/dev/null || echo "Usuário já existe"

echo "==> Anexando política ECR ao usuário"
aws iam attach-user-policy --user-name $USER_NAME --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser

echo "==> Criando access key"
aws iam create-access-key --user-name $USER_NAME --output json > /tmp/bia-ecr-credentials.json

echo ""
echo "==> Credenciais salvas em: /tmp/bia-ecr-credentials.json"
echo "==> Use estas credenciais para configurar AWS CLI na VM"
cat /tmp/bia-ecr-credentials.json
