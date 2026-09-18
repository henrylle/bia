#!/usr/bin/env bash
set -euo pipefail

# =========================================================
# Remove do crontab local as 2 entradas de liga/desliga automático
# criadas por agendar_ec2_crontab.sh para uma instância específica.
# Não mexe em nenhuma outra entrada do seu crontab.
#
# Uso: ./scripts/remover_agendamento_ec2_crontab.sh <instance-id>
# =========================================================

INSTANCE_ID="${1:?Uso: $0 <instance-id>}"
TAG="# bia-ec2-auto:${INSTANCE_ID}"

CURRENT_CRONTAB=$(crontab -l 2>/dev/null || true)

if ! echo "$CURRENT_CRONTAB" | grep -qF "$TAG"; then
    echo "Nenhum agendamento encontrado no crontab pra ${INSTANCE_ID}."
    exit 0
fi

echo "$CURRENT_CRONTAB" | grep -vF "$TAG" | crontab -
echo "Removidas as entradas de crontab de ${INSTANCE_ID}."
