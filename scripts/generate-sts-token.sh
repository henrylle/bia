#!/bin/bash

# Script para gerar token STS com base no profile AWS
# Uso: ./generate-sts-token.sh <profile-name> [duration-seconds] [--export]

# Função para mostrar ajuda
show_help() {
    echo "Uso: $0 <profile-name> [duration-seconds] [--export]"
    echo ""
    echo "Parâmetros:"
    echo "  profile-name      Nome do profile AWS (obrigatório)"
    echo "  duration-seconds  Duração em segundos (opcional, padrão: 3600)"
    echo "  --export          Exporta as credenciais na sessão atual (opcional)"
    echo ""
    echo "Exemplos:"
    echo "  $0 meu-profile                    # Token de 1 hora"
    echo "  $0 meu-profile 7200               # Token de 2 horas"
    echo "  $0 meu-profile 3600 --export      # Token de 1 hora + export automático"
    echo "  $0 meu-profile --export           # Token de 1 hora + export automático"
    echo "  source <($0 meu-profile --export) # Alternativa para export"
    echo ""
    echo "Nota: Duração mínima é de 15 minutos (900 segundos)"
    echo "      Duração máxima é de 12 horas (43200 segundos)"
}

# Inicializa variáveis
PROFILE_NAME=""
DURATION=3600  # Default: 1 hora
EXPORT_MODE=false

# Processa argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        --export)
            EXPORT_MODE=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            if [[ -z "$PROFILE_NAME" ]]; then
                PROFILE_NAME="$1"
            elif [[ "$1" =~ ^[0-9]+$ ]]; then
                DURATION="$1"
            else
                echo "Erro: Argumento inválido '$1'"
                show_help
                exit 1
            fi
            shift
            ;;
    esac
done

# Verifica se profile foi informado
if [[ -z "$PROFILE_NAME" ]]; then
    echo "Erro: Profile AWS não informado"
    echo ""
    show_help
    exit 1
fi

# Valida duração mínima (15 minutos = 900 segundos)
if [ "$DURATION" -lt 900 ]; then
    echo "Erro: Duração mínima é de 15 minutos (900 segundos)"
    echo "Duração informada: ${DURATION} segundos"
    echo "Use: $0 ${PROFILE_NAME} 900 (ou maior)"
    exit 1
fi

# Verifica se o profile existe
PROFILES=$(aws configure list-profiles 2>/dev/null)
if ! echo "${PROFILES}" | grep -q "^${PROFILE_NAME}$"; then
    echo "Erro: Profile '${PROFILE_NAME}' não encontrado"
    echo "Profiles disponíveis:"
    echo "${PROFILES}"
    exit 1
fi

if [ "$EXPORT_MODE" = false ]; then
    echo "Gerando token STS para o profile: ${PROFILE_NAME}"
    echo "Duração: ${DURATION} segundos"
    echo "----------------------------------------"
fi

# Gera o token STS
STS_OUTPUT=$(aws sts get-session-token \
    --profile "${PROFILE_NAME}" \
    --duration-seconds "${DURATION}" \
    --output json 2>/dev/null)

if [ $? -ne 0 ]; then
    echo "Erro ao gerar token STS. Verifique suas credenciais e permissões."
    exit 1
fi

# Extrai as credenciais do output
ACCESS_KEY=$(echo "${STS_OUTPUT}" | jq -r '.Credentials.AccessKeyId')
SECRET_KEY=$(echo "${STS_OUTPUT}" | jq -r '.Credentials.SecretAccessKey')
SESSION_TOKEN=$(echo "${STS_OUTPUT}" | jq -r '.Credentials.SessionToken')
EXPIRATION=$(echo "${STS_OUTPUT}" | jq -r '.Credentials.Expiration')

if [ "$EXPORT_MODE" = true ]; then
    # Modo export: só mostra os comandos export para serem executados via source
    echo "export AWS_ACCESS_KEY_ID=${ACCESS_KEY}"
    echo "export AWS_SECRET_ACCESS_KEY=${SECRET_KEY}"
    echo "export AWS_SESSION_TOKEN=${SESSION_TOKEN}"
    echo "# Credenciais exportadas para a sessão atual!"
    echo "# Expira em: ${EXPIRATION}"
else
    # Modo normal: mostra todas as informações
    echo "Token STS gerado com sucesso!"
    echo "Expira em: ${EXPIRATION}"
    echo ""
    echo "=== Credenciais temporárias ==="
    echo "AWS_ACCESS_KEY_ID=${ACCESS_KEY}"
    echo "AWS_SECRET_ACCESS_KEY=${SECRET_KEY}"
    echo "AWS_SESSION_TOKEN=${SESSION_TOKEN}"
    echo ""
    echo "=== Para usar no terminal ==="
    echo "export AWS_ACCESS_KEY_ID=${ACCESS_KEY}"
    echo "export AWS_SECRET_ACCESS_KEY=${SECRET_KEY}"
    echo "export AWS_SESSION_TOKEN=${SESSION_TOKEN}"
    echo ""
    echo "=== Para usar em arquivo .env ==="
    echo "AWS_ACCESS_KEY_ID=${ACCESS_KEY}"
    echo "AWS_SECRET_ACCESS_KEY=${SECRET_KEY}"
    echo "AWS_SESSION_TOKEN=${SESSION_TOKEN}"
    echo ""
    echo "=== Para exportar automaticamente ==="
    echo "source <($0 ${PROFILE_NAME} ${DURATION} --export)"
    echo ""
    echo "=== Para salvar em arquivo ==="
    echo "Para salvar as variáveis em um arquivo:"
    echo "$0 ${PROFILE_NAME} ${DURATION} > sts-credentials.env"
fi
