#!/usr/bin/env bash
set -euo pipefail

# =========================================================
# Para (stop, não terminate) o porteiro depois de usar.
# "Parar" preserva a instância pra religar rápido depois; "terminate"
# apagaria de vez. Como o porteiro não guarda estado nenhum, terminate
# também seria defensável — mas stop é mais barato de reativar.
#
# Uso: ./scripts/parar_porteiro.sh
# =========================================================

REGION="us-east-1"
STATE_FILE=".porteiro_instance_id"

if [ ! -f "$STATE_FILE" ]; then
    echo ">[ERRO] $STATE_FILE não encontrado — nada pra parar."
    exit 1
fi
INSTANCE_ID=$(cat "$STATE_FILE")

echo "Parando porteiro $INSTANCE_ID..."
aws ec2 stop-instances --region "$REGION" --instance-ids "$INSTANCE_ID" > /dev/null
aws ec2 wait instance-stopped --region "$REGION" --instance-ids "$INSTANCE_ID"
echo "Parado."
echo "Pra religar: aws ec2 start-instances --region $REGION --instance-ids $INSTANCE_ID"
echo "Pra apagar de vez: aws ec2 terminate-instances --region $REGION --instance-ids $INSTANCE_ID && rm $STATE_FILE"
