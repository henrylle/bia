#!/usr/bin/env bash
set -euo pipefail

# =========================================================
# Cria uma rotina 100% gerenciada pela AWS pra ligar e desligar o porteiro
# sozinho, sem depender do seu notebook estar ligado no horário certo.
#
# Usa o Amazon EventBridge Scheduler com "universal target" — ele chama a
# API do EC2 (StartInstances/StopInstances) diretamente, sem precisar de
# Lambda no meio. É o equivalente gerenciado de um crontab, só que rodando
# dentro da AWS, não na sua máquina.
#
# Cron do EventBridge é sempre em UTC. Brasil (sem horário de verão) = UTC-3.
#   liga  08:00 BRT = 11:00 UTC, seg-sex
#   desliga 22:00 BRT = 01:00 UTC do dia seguinte, ou seja, ter-sáb em UTC
#
# Uso: ./scripts/agendar_porteiro.sh
# =========================================================

REGION="us-east-1"
STATE_FILE=".porteiro_instance_id"
ROLE_NAME="scheduler-porteiro-role"

if [ ! -f "$STATE_FILE" ]; then
    echo ">[ERRO] $STATE_FILE não encontrado — rode ./scripts/lancar_porteiro_zona_b.sh primeiro."
    exit 1
fi
INSTANCE_ID=$(cat "$STATE_FILE")
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"

# 1) IAM role que o EventBridge Scheduler assume pra poder chamar o EC2
if aws iam get-role --role-name "$ROLE_NAME" >/dev/null 2>&1; then
    echo "Role $ROLE_NAME já existe, reaproveitando."
else
    echo "Criando IAM role $ROLE_NAME..."
    aws iam create-role --role-name "$ROLE_NAME" \
      --assume-role-policy-document '{
        "Version": "2012-10-17",
        "Statement": [{
          "Effect": "Allow",
          "Principal": {"Service": "scheduler.amazonaws.com"},
          "Action": "sts:AssumeRole"
        }]
      }' > /dev/null

    aws iam put-role-policy --role-name "$ROLE_NAME" \
      --policy-name "ec2-start-stop" \
      --policy-document "{
        \"Version\": \"2012-10-17\",
        \"Statement\": [{
          \"Effect\": \"Allow\",
          \"Action\": [\"ec2:StartInstances\", \"ec2:StopInstances\"],
          \"Resource\": \"arn:aws:ec2:${REGION}:${ACCOUNT_ID}:instance/${INSTANCE_ID}\"
        }]
      }" > /dev/null

    echo "Aguardando propagação da role (~10s)..."
    sleep 10
fi

# 2) Os dois agendamentos
echo "Criando agendamento 'ligar-porteiro' (08h BRT, seg-sex)..."
aws scheduler create-schedule --region "$REGION" \
  --name "ligar-porteiro" \
  --schedule-expression "cron(0 11 ? * MON-FRI *)" \
  --flexible-time-window '{"Mode":"OFF"}' \
  --target "{
    \"Arn\": \"arn:aws:scheduler:::aws-sdk:ec2:startInstances\",
    \"RoleArn\": \"${ROLE_ARN}\",
    \"Input\": \"{\\\"InstanceIds\\\":[\\\"${INSTANCE_ID}\\\"]}\"
  }"

echo "Criando agendamento 'desligar-porteiro' (22h BRT, seg-sex à noite)..."
aws scheduler create-schedule --region "$REGION" \
  --name "desligar-porteiro" \
  --schedule-expression "cron(0 1 ? * TUE-SAT *)" \
  --flexible-time-window '{"Mode":"OFF"}' \
  --target "{
    \"Arn\": \"arn:aws:scheduler:::aws-sdk:ec2:stopInstances\",
    \"RoleArn\": \"${ROLE_ARN}\",
    \"Input\": \"{\\\"InstanceIds\\\":[\\\"${INSTANCE_ID}\\\"]}\"
  }"

echo ""
echo "Agendado. Pra conferir: aws scheduler list-schedules --region $REGION"
echo "Pra remover depois:"
echo "  aws scheduler delete-schedule --region $REGION --name ligar-porteiro"
echo "  aws scheduler delete-schedule --region $REGION --name desligar-porteiro"
