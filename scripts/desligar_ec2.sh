#!/usr/bin/env bash
set -euo pipefail

# =========================================================
# Desliga (stop) qualquer instância EC2 pelo instance-id, com checagem de
# estado antes de agir. Espelha ligar_ec2.sh — mesmo par, sentido oposto.
#
# Uso: ./scripts/desligar_ec2.sh <instance-id> [regiao]
# Exemplo: ./scripts/desligar_ec2.sh i-074bcbdb1642ec026
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
    stopped)
        echo "Já está desligada, nada a fazer."
        ;;
    running)
        echo "Desligando..."
        aws ec2 stop-instances --region "$REGION" --instance-ids "$INSTANCE_ID" > /dev/null
        aws ec2 wait instance-stopped --region "$REGION" --instance-ids "$INSTANCE_ID"
        echo "$(date '+%F %T') - ${INSTANCE_ID} está parada."
        ;;
    pending|stopping)
        echo "Em transição (${STATE}), aguardando estabilizar em 'stopped'..."
        aws ec2 wait instance-stopped --region "$REGION" --instance-ids "$INSTANCE_ID" || true
        ;;
    terminated|shutting-down)
        echo ">[ERRO] ${INSTANCE_ID} já foi terminada — nada a desligar." >&2
        exit 1
        ;;
    *)
        echo ">[ERRO] Estado inesperado: ${STATE}" >&2
        exit 1
        ;;
esac
