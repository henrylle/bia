#!/bin/bash

# Script para reiniciar as tasks do ECS após mudança no security group

CLUSTER="cluster-bia-alb"
SERVICE="service-bia-alb"

echo "Forçando novo deployment do serviço..."
aws ecs update-service \
  --cluster $CLUSTER \
  --service $SERVICE \
  --force-new-deployment \
  --region us-east-1

echo ""
echo "Aguardando deployment..."
aws ecs wait services-stable \
  --cluster $CLUSTER \
  --services $SERVICE \
  --region us-east-1

echo ""
echo "Testando conectividade..."
sleep 10
curl http://bia-alb-881249403.us-east-1.elb.amazonaws.com/api/tarefas

echo ""
echo "Deployment concluído!"
