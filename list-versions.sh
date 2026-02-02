#!/bin/bash

# Listar Versões - Projeto BIA
# Script para listar versões disponíveis no ECR

REGION="us-east-1"
ECR_REPO="bia"

echo "📋 Versões disponíveis no ECR:"
echo ""

aws ecr describe-images \
    --repository-name $ECR_REPO \
    --region $REGION \
    --query 'sort_by(imageDetails,&imagePushedAt)[*].[imageTags[0],imagePushedAt]' \
    --output table

echo ""
echo "💡 Para fazer rollback: ./rollback-versioned.sh <commit-hash>"
