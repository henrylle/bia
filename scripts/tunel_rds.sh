#!/usr/bin/env bash
set -euo pipefail

# =========================================================
# Abre um túnel SSM: localhost:5433 -> RDS "bia":5432, passando pelo porteiro.
# (porta 5433 = a pedida no enunciado do Desafio 4)
#
# Usa AWS-StartPortForwardingSessionToRemoteHost (não o
# AWS-StartPortForwardingSession comum) porque o destino final NÃO é o
# porteiro em si — é outra máquina (o RDS) que só o porteiro alcança.
#
# Esse comando BLOQUEIA o terminal enquanto o túnel estiver ativo
# (Ctrl+C fecha). Rode o psql numa SEGUNDA janela, apontando pra
# localhost:5433 (ou a porta que você tiver sobrescrito, ver abaixo).
#
# Se a 5433 já estiver ocupada na sua máquina (ex: outro container Docker
# seu usando a mesma porta localmente — já aconteceu aqui), sobrescreva
# sem editar o script:
#   LOCAL_PORT=5434 ./scripts/tunel_rds.sh
#
# Uso: ./scripts/tunel_rds.sh
# =========================================================

REGION="us-east-1"
RDS_HOST="bia.csl22kw6cnmi.us-east-1.rds.amazonaws.com"
RDS_PORT=5432
LOCAL_PORT="${LOCAL_PORT:-5433}"
STATE_FILE=".porteiro_instance_id"

if [ ! -f "$STATE_FILE" ]; then
    echo ">[ERRO] $STATE_FILE não encontrado — rode ./scripts/lancar_porteiro_zona_b.sh primeiro."
    exit 1
fi
INSTANCE_ID=$(cat "$STATE_FILE")

# Preflight: falha alto e claro se a porta já estiver ocupada, em vez de
# deixar o túnel "abrir" silenciosamente contra o serviço errado — foi
# exatamente isso que aconteceu com um container Docker local (my-postgres)
# ocupando a 5433 (ver seção 6, Troubleshooting, do
# docs/dia-4-porteiro-tunel-ssm-tutorial.md).
if (exec 3<>"/dev/tcp/127.0.0.1/${LOCAL_PORT}") 2>/dev/null; then
    exec 3>&- 3<&- 2>/dev/null || true
    echo ">[ERRO] A porta local ${LOCAL_PORT} já está em uso por outro processo — não é o nosso túnel." >&2
    OCUPANTE=$(docker ps --format '{{.Names}} ({{.Ports}})' 2>/dev/null | grep ":${LOCAL_PORT}->" || true)
    [ -n "$OCUPANTE" ] && echo "  Provável ocupante (Docker): ${OCUPANTE}" >&2
    echo "  Use outra porta sem editar o script: LOCAL_PORT=5434 $0" >&2
    exit 1
fi

echo "Túnel: localhost:${LOCAL_PORT} -> ${RDS_HOST}:${RDS_PORT} (via porteiro $INSTANCE_ID)"
echo "Deixe esse terminal aberto. Em outro terminal, rode algo como:"
echo "  psql -h localhost -p ${LOCAL_PORT} -U postgres -d bia"
echo "(usuário/senha reais: aws ecs describe-task-definition --task-definition task-def-bia --query \"taskDefinition.containerDefinitions[0].environment\")"

# "exec" (não só "aws ssm ...") de propósito: substitui o processo deste
# script pelo do aws cli, em vez de criar um processo filho. Isso faz o
# PID desse script SER o PID do aws ssm start-session — o que permite um
# orquestrador (scripts/orquestrar_desafio4.sh) matar o túnel de forma
# limpa com um `kill $PID` direto, sem deixar processo órfão pra trás.
# Não muda em nada o uso manual normal deste script.
exec aws ssm start-session --region "$REGION" \
  --target "$INSTANCE_ID" \
  --document-name AWS-StartPortForwardingSessionToRemoteHost \
  --parameters "{\"host\":[\"${RDS_HOST}\"],\"portNumber\":[\"${RDS_PORT}\"],\"localPortNumber\":[\"${LOCAL_PORT}\"]}"
