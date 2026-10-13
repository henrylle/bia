#!/usr/bin/env bash
set -euo pipefail

# =========================================================
# Roda o Desafio 4 inteiro numa tacada só: reaproveita (ou lança) o
# porteiro, abre o túnel do RDS, insere 1 registro, confirma na aplicação
# via o outro túnel, e desliga tudo no final — capturando a saída de cada
# etapa num log com timestamp (bom material pra print/documentação, sem
# precisar repetir os passos na mão em janelas separadas).
#
# Como os túneis (tunel_rds.sh / tunel_bia.sh) bloqueiam o terminal de
# propósito, aqui eles rodam em segundo plano (&): o script espera a
# porta local abrir, executa o passo seguinte, e MATA o túnel antes de
# seguir pro próximo — não fica nada pendurado ao final.
#
# Uso: ./scripts/orquestrar_desafio4.sh
# =========================================================

REGION="us-east-1"
RDS_PORT_LOCAL="${LOCAL_PORT:-5433}"
BIA_PORT_LOCAL=3002
STATE_FILE=".porteiro_instance_id"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$REPO_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/desafio4_$(date +%Y%m%d_%H%M%S).log"

# A partir daqui, tudo que passar por stdout/stderr também vai pro log,
# em tempo real (mesmo espírito do "tail -f": você acompanha ao vivo E
# fica um arquivo pra revisar/printar depois).
exec > >(tee -a "$LOG_FILE") 2>&1

for cmd in aws psql curl; do
    command -v "$cmd" >/dev/null 2>&1 || { echo ">[ERRO] '$cmd' não encontrado no PATH."; exit 1; }
done

RDS_TUNNEL_PID=""
BIA_TUNNEL_PID=""

cleanup() {
    [ -n "$RDS_TUNNEL_PID" ] && kill "$RDS_TUNNEL_PID" 2>/dev/null || true
    [ -n "$BIA_TUNNEL_PID" ] && kill "$BIA_TUNNEL_PID" 2>/dev/null || true
}
trap cleanup EXIT

is_port_busy() {
    (exec 3<>"/dev/tcp/127.0.0.1/${1}") 2>/dev/null && { exec 3>&- 3<&- 2>/dev/null || true; return 0; }
    return 1
}

wait_for_port() {
    local port=$1 tries=30
    while ! is_port_busy "$port"; do
        tries=$((tries - 1))
        [ "$tries" -le 0 ] && { echo ">[ERRO] Porta ${port} não abriu a tempo."; return 1; }
        sleep 1
    done
}

echo "=== [1/6] Porteiro ==="
if [ -f "$STATE_FILE" ]; then
    INSTANCE_ID=$(cat "$STATE_FILE")
    CURRENT_STATE=$(aws ec2 describe-instances --region "$REGION" --instance-ids "$INSTANCE_ID" \
        --query 'Reservations[0].Instances[0].State.Name' --output text 2>/dev/null || echo "not-found")
    case "$CURRENT_STATE" in
        running)
            echo "Reaproveitando porteiro existente ($INSTANCE_ID), já 'running'."
            ;;
        stopped)
            echo "Reaproveitando porteiro existente ($INSTANCE_ID), religando..."
            "$REPO_DIR/scripts/ligar_ec2.sh" "$INSTANCE_ID" "$REGION"
            ;;
        *)
            echo "Estado '$CURRENT_STATE' não reaproveitável — lançando um porteiro novo."
            "$REPO_DIR/scripts/lancar_porteiro_zona_b.sh"
            INSTANCE_ID=$(cat "$STATE_FILE")
            ;;
    esac
else
    "$REPO_DIR/scripts/lancar_porteiro_zona_b.sh"
    INSTANCE_ID=$(cat "$STATE_FILE")
fi

echo ""
echo "=== [2/6] Aguardando o SSM reconhecer a instância ==="
SSM_STATUS="None"
for i in $(seq 1 20); do
    SSM_STATUS=$(aws ssm describe-instance-information --region "$REGION" \
        --filters "Key=InstanceIds,Values=${INSTANCE_ID}" \
        --query "InstanceInformationList[0].PingStatus" --output text 2>/dev/null || echo "None")
    [ "$SSM_STATUS" == "Online" ] && break
    echo "  ainda não (tentativa ${i}/20)..."
    sleep 5
done
[ "$SSM_STATUS" == "Online" ] || { echo ">[ERRO] SSM não ficou Online a tempo."; exit 1; }
echo "Online."

echo ""
# Se a porta pedida pro RDS já estiver ocupada por OUTRA coisa (ex: um
# container Docker local seu, sem relação com esse projeto — já aconteceu
# aqui com um "my-postgres" na 5433), o túnel SSM perderia a corrida
# silenciosamente e o psql acabaria "autenticando" contra o serviço
# errado. Checa ANTES de tentar abrir o túnel e pula pra próxima porta
# livre automaticamente, em vez de deixar isso se repetir sem avisar.
if is_port_busy "$RDS_PORT_LOCAL"; then
    OCUPANTE=$(docker ps --format '{{.Names}} ({{.Ports}})' 2>/dev/null | grep ":${RDS_PORT_LOCAL}->" || true)
    echo ">[AVISO] Porta ${RDS_PORT_LOCAL} já ocupada localmente${OCUPANTE:+ por: $OCUPANTE} — não é o nosso túnel."
    RDS_PORT_LOCAL=$((RDS_PORT_LOCAL + 1))
    while is_port_busy "$RDS_PORT_LOCAL"; do RDS_PORT_LOCAL=$((RDS_PORT_LOCAL + 1)); done
    echo "Usando ${RDS_PORT_LOCAL} em vez disso."
fi

echo "=== [3/6] Túnel para o RDS (localhost:${RDS_PORT_LOCAL}) ==="
LOCAL_PORT="$RDS_PORT_LOCAL" "$REPO_DIR/scripts/tunel_rds.sh" &
RDS_TUNNEL_PID=$!
wait_for_port "$RDS_PORT_LOCAL"
echo "Túnel do RDS pronto (PID ${RDS_TUNNEL_PID})."

echo ""
echo "=== [4/6] Inserindo 1 registro manualmente ==="
# A senha nunca é impressa: fica só numa variável de ambiente exportada
# pro psql, nunca ecoada em echo/log. Se este passo falhar com
# "database/relation does not exist", ver seção 6 (Troubleshooting) do
# docs/dia-4-porteiro-tunel-ssm-tutorial.md.
DB_PWD=$(aws ecs describe-task-definition --task-definition task-def-bia \
    --query "taskDefinition.containerDefinitions[0].environment[?name=='DB_PWD'].value | [0]" \
    --output text)
TITULO="Inserido via orquestrador em $(date '+%F %T')"
export PGPASSWORD="$DB_PWD"
psql -h localhost -p "$RDS_PORT_LOCAL" -U postgres -d bia \
    -c "INSERT INTO \"Tarefas\" (titulo, dia_atividade, importante) VALUES ('${TITULO}', CURRENT_DATE, false);"
unset PGPASSWORD DB_PWD
echo "Registro inserido: ${TITULO}"

echo ""
echo "=== [5/6] Fechando túnel do RDS, abrindo túnel para a bia (localhost:${BIA_PORT_LOCAL}) ==="
kill "$RDS_TUNNEL_PID" 2>/dev/null || true
RDS_TUNNEL_PID=""
"$REPO_DIR/scripts/tunel_bia.sh" &
BIA_TUNNEL_PID=$!
wait_for_port "$BIA_PORT_LOCAL"
sleep 2
echo "Túnel da bia pronto (PID ${BIA_TUNNEL_PID}). Confirmando via API:"
curl -s "http://localhost:${BIA_PORT_LOCAL}/api/tarefas"
echo ""

echo ""
echo "=== [6/6] Encerrando tudo ==="
kill "$BIA_TUNNEL_PID" 2>/dev/null || true
BIA_TUNNEL_PID=""
"$REPO_DIR/scripts/parar_porteiro.sh"

echo ""
echo "=== Concluído. Log completo em: ${LOG_FILE} ==="
