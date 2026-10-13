#!/usr/bin/env bash
set -euo pipefail

# =========================================================
# Instala 2 entradas no crontab LOCAL (WSL) pra ligar/desligar uma EC2
# automaticamente, chamando ligar_ec2.sh/desligar_ec2.sh via AWS CLI.
#
# Alternativa "100% shell script + AWS CLI" ao scripts/agendar_porteiro.sh
# (que delega o agendamento pro EventBridge Scheduler, do lado da AWS).
# Veja a comparação na seção 1.4 do docs/dia-4-porteiro-tunel-ssm-tutorial.md.
#
# Limitação real: só dispara se o WSL estiver ligado e o cron rodando no
# horário marcado — diferente do EventBridge, que funciona mesmo com o
# notebook desligado.
#
# Uso: ./scripts/agendar_ec2_crontab.sh <instance-id> [HH:MM liga] [HH:MM desliga] [dias]
# Exemplo (padrão, seg-sex): ./scripts/agendar_ec2_crontab.sh i-074bcbdb1642ec026
# Exemplo (customizado):     ./scripts/agendar_ec2_crontab.sh i-074bcbdb1642ec026 07:30 23:00 1-6
# "dias" segue a sintaxe de day-of-week do cron: 0=domingo ... 6=sábado, 1-5=seg-sex
# =========================================================

INSTANCE_ID="${1:?Uso: $0 <instance-id> [HH:MM liga] [HH:MM desliga] [dias]}"
HORA_LIGA="${2:-08:00}"
HORA_DESLIGA="${3:-22:00}"
DIAS="${4:-1-5}"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIGAR_SCRIPT="$REPO_DIR/scripts/ligar_ec2.sh"
DESLIGAR_SCRIPT="$REPO_DIR/scripts/desligar_ec2.sh"
LOG_FILE="$REPO_DIR/scripts/ec2_agendamento.log"

MIN_LIGA="${HORA_LIGA#*:}"
HORA_LIGA_H="${HORA_LIGA%%:*}"
MIN_DESLIGA="${HORA_DESLIGA#*:}"
HORA_DESLIGA_H="${HORA_DESLIGA%%:*}"

TAG="# bia-ec2-auto:${INSTANCE_ID}"
CRON_LIGA="${MIN_LIGA} ${HORA_LIGA_H} * * ${DIAS} ${LIGAR_SCRIPT} ${INSTANCE_ID} >> ${LOG_FILE} 2>&1 ${TAG}"
CRON_DESLIGA="${MIN_DESLIGA} ${HORA_DESLIGA_H} * * ${DIAS} ${DESLIGAR_SCRIPT} ${INSTANCE_ID} >> ${LOG_FILE} 2>&1 ${TAG}"

CURRENT_CRONTAB=$(crontab -l 2>/dev/null || true)

# O cron roda com um PATH mínimo (geralmente sem /usr/local/bin, onde o
# aws cli costuma estar) — sem isso, o job falha silenciosamente com
# "aws: command not found" e só aparece no log. Garante a PATH certa
# uma única vez, sem duplicar se já existir.
if ! echo "$CURRENT_CRONTAB" | grep -q "^PATH="; then
    PATH_LINE="PATH=/usr/local/bin:/usr/bin:/bin:${HOME}/.local/bin"
    CURRENT_CRONTAB="${PATH_LINE}
${CURRENT_CRONTAB}"
fi

# Remove entradas antigas dessa mesma instância (idempotente) e adiciona as novas
NEW_CRONTAB=$(echo "$CURRENT_CRONTAB" | grep -vF "$TAG")
NEW_CRONTAB="${NEW_CRONTAB}
${CRON_LIGA}
${CRON_DESLIGA}"

echo "$NEW_CRONTAB" | crontab -

echo "Agendado no crontab local (usuário $(whoami)):"
echo "  liga    ${HORA_LIGA} (dias ${DIAS})"
echo "  desliga ${HORA_DESLIGA} (dias ${DIAS})"
echo "Log de cada execução em: ${LOG_FILE}"
echo "Conferir: crontab -l"
echo "Remover depois: ./scripts/remover_agendamento_ec2_crontab.sh ${INSTANCE_ID}"
