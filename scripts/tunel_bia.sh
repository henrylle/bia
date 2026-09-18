#!/usr/bin/env bash
set -euo pipefail

# =========================================================
# Abre um túnel SSM: localhost:3002 -> app "bia" (produção via ECS),
# passando pelo porteiro. Serve pra confirmar visualmente, na aplicação
# real, que o registro inserido na mão via tunel_rds.sh apareceu.
#
# Hoje existem DUAS candidatas na conta pra "onde a bia está rodando"
# (checado ao vivo via describe-instances/describe-tasks):
#   - ECS "cluster-bia" (produção real, task-def-bia, container mapeado
#     hostPort 80 -> containerPort 8080) — IP privado 172.31.0.138
#   - bia-dev (ambiente de estudo, container solto na porta 3001)
#     — IP privado 172.31.0.186
# Por padrão este script aponta pra do ECS, porque é ela que fala com o
# MESMO banco onde você insere o registro manual (ver
# docs/desafio-4-porteiro-rds-orientacao.md). Se quiser testar a bia-dev
# em vez disso, troque as duas variáveis abaixo.
#
# Uso: ./scripts/tunel_bia.sh
# =========================================================

REGION="us-east-1"
BIA_HOST="172.31.0.138"   # instância EC2 por trás do ECS (produção)
BIA_PORT=80
LOCAL_PORT=3002
STATE_FILE=".porteiro_instance_id"

if [ ! -f "$STATE_FILE" ]; then
    echo ">[ERRO] $STATE_FILE não encontrado — rode ./scripts/lancar_porteiro_zona_b.sh primeiro."
    exit 1
fi
INSTANCE_ID=$(cat "$STATE_FILE")

echo "Túnel: localhost:${LOCAL_PORT} -> ${BIA_HOST}:${BIA_PORT} (via porteiro $INSTANCE_ID)"
echo "Depois de conectar, abra http://localhost:${LOCAL_PORT} no navegador."

# "exec" (não só "aws ssm ...") de propósito: substitui o processo deste
# script pelo do aws cli, em vez de criar um processo filho. Isso faz o
# PID desse script SER o PID do aws ssm start-session — o que permite um
# orquestrador (scripts/orquestrar_desafio4.sh) matar o túnel de forma
# limpa com um `kill $PID` direto, sem deixar processo órfão pra trás.
# Não muda em nada o uso manual normal deste script.
exec aws ssm start-session --region "$REGION" \
  --target "$INSTANCE_ID" \
  --document-name AWS-StartPortForwardingSessionToRemoteHost \
  --parameters "{\"host\":[\"${BIA_HOST}\"],\"portNumber\":[\"${BIA_PORT}\"],\"localPortNumber\":[\"${LOCAL_PORT}\"]}"
