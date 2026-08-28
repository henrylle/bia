#!/usr/bin/env bash
set -euo pipefail

# =========================================================
# Liga (start) qualquer instância EC2 pelo instance-id, com checagem de
# estado antes de agir. Genérico de propósito — serve pro porteiro, pra
# bia-dev, ou qualquer EC2 futura — pra poder ser chamado direto ou
# agendado via crontab (ver scripts/agendar_ec2_crontab.sh).
#
# Uso: ./scripts/ligar_ec2.sh <instance-id> [regiao]
# Exemplo: ./scripts/ligar_ec2.sh i-074bcbdb1642ec026
# =========================================================

INSTANCE_ID="${1:?Uso: $0 <instance-id> [regiao]}"
REGION="${2:-us-east-1}"

get_state() {
    aws ec2 describe-instances --region "$REGION" --instance-ids "$INSTANCE_ID" \
        --query 'Reservations[0].Instances[0].State.Name' --output text
}

STATE=$(get_state)
echo "$(date '+%F %T') - ${INSTANCE_ID} está '${STATE}'"

case "$STATE" in
    running)
        echo "Já está ligada, nada a fazer."
        ;;
    stopped)
        echo "Ligando..."
        aws ec2 start-instances --region "$REGION" --instance-ids "$INSTANCE_ID" > /dev/null
        aws ec2 wait instance-running --region "$REGION" --instance-ids "$INSTANCE_ID"
        echo "$(date '+%F %T') - ${INSTANCE_ID} está no ar."
        ;;
    pending|stopping)
        echo "Em transição (${STATE}), aguardando estabilizar em 'running'..."
        aws ec2 wait instance-running --region "$REGION" --instance-ids "$INSTANCE_ID" || true
        ;;
    terminated|shutting-down)
        echo ">[ERRO] ${INSTANCE_ID} foi terminada — não é possível religar. Lance uma nova." >&2
        exit 1
        ;;
    *)
        echo ">[ERRO] Estado inesperado: ${STATE}" >&2
        exit 1
        ;;
esac
