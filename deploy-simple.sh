#!/bin/bash

echo "Registrando nova task definition..."
aws ecs register-task-definition \
  --cli-input-json file:///home/ec2-user/bia/task-def-bia-simple.json \
  --region us-east-1

echo ""
echo "Aguardando 3 segundos..."
sleep 3

echo ""
echo "Atualizando serviço para usar nova task definition..."
aws ecs update-service \
  --cluster cluster-bia \
  --service service-bia \
  --task-definition task-def-bia \
  --force-new-deployment \
  --region us-east-1

echo ""
echo "Aguardando 10 segundos..."
sleep 10

echo ""
echo "Verificando status do serviço..."
aws ecs describe-services \
  --cluster cluster-bia \
  --services service-bia \
  --region us-east-1 \
  --query 'services[0].{desiredCount:desiredCount,runningCount:runningCount,pendingCount:pendingCount}' \
  --output table

echo ""
echo "Listando tasks..."
aws ecs list-tasks \
  --cluster cluster-bia \
  --region us-east-1
