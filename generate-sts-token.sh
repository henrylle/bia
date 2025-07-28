#!/bin/bash

# Script universal para gerar token STS com base no profile AWS
# Funciona em: Windows (Git Bash/WSL), macOS e Linux
# Uso: ./generate-sts-token.sh <profile-name> [duration-seconds] [--export]

# Detecta o sistema operacional
detect_os() {
    case "$(uname -s)" in
        CYGWIN*|MINGW*|MSYS*)
            echo "windows"
            ;;
        Darwin*)
            echo "macos"
            ;;
        Linux*)
            echo "linux"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Função para mostrar ajuda
show_help() {
    local os_type=$(detect_os)
    echo "Uso: $0 <profile-name> [duration-seconds] [--export]"
    echo ""
    echo "Sistema detectado: $os_type"
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
    echo ""
    
    if [[ "$os_type" == "windows" ]]; then
        echo "Para Windows (Git Bash/PowerShell/CMD):"
        echo "  # Git Bash:"
        echo "  source <($0 meu-profile --export)"
        echo "  # PowerShell:"
        echo "  Invoke-Expression \$(./$0 meu-profile --export-ps)"
        echo "  # CMD:"
        echo "  ./$0 meu-profile --export-cmd > temp.bat && temp.bat && del temp.bat"
    else
        echo "Para Unix/Linux/macOS:"
        echo "  source <($0 meu-profile --export)"
    fi
    
    echo ""
    echo "Nota: Duração mínima é de 15 minutos (900 segundos)"
    echo "      Duração máxima é de 12 horas (43200 segundos)"
}

# Função para verificar dependências
check_dependencies() {
    local os_type=$(detect_os)
    local missing_deps=()
    
    # Verifica AWS CLI
    if ! command -v aws &> /dev/null; then
        missing_deps+=("aws-cli")
    fi
    
    # Verifica jq
    if ! command -v jq &> /dev/null; then
        missing_deps+=("jq")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo "Erro: Dependências não encontradas: ${missing_deps[*]}"
        echo ""
        case "$os_type" in
            "windows")
                echo "Para instalar no Windows:"
                echo "  AWS CLI: https://aws.amazon.com/cli/"
                echo "  jq: choco install jq (via Chocolatey) ou baixe de https://stedolan.github.io/jq/"
                ;;
            "macos")
                echo "Para instalar no macOS:"
                echo "  brew install awscli jq"
                ;;
            "linux")
                echo "Para instalar no Linux:"
                echo "  # Ubuntu/Debian:"
                echo "  sudo apt-get install awscli jq"
                echo "  # CentOS/RHEL:"
                echo "  sudo yum install awscli jq"
                ;;
        esac
        exit 1
    fi
}

# Inicializa variáveis
PROFILE_NAME=""
DURATION=3600  # Default: 1 hora
EXPORT_MODE=false
EXPORT_PS=false
EXPORT_CMD=false

# Processa argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        --export)
            EXPORT_MODE=true
            shift
            ;;
        --export-ps)
            EXPORT_PS=true
            shift
            ;;
        --export-cmd)
            EXPORT_CMD=true
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

# Verifica dependências
check_dependencies

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

# Detecta sistema operacional
OS_TYPE=$(detect_os)

# Mostra informações iniciais (exceto em modos de export)
if [[ "$EXPORT_MODE" == false && "$EXPORT_PS" == false && "$EXPORT_CMD" == false ]]; then
    echo "Sistema: $OS_TYPE"
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

# Saída baseada no modo e sistema operacional
if [[ "$EXPORT_MODE" == true ]]; then
    # Modo export Unix/Linux/macOS
    echo "export AWS_ACCESS_KEY_ID=${ACCESS_KEY}"
    echo "export AWS_SECRET_ACCESS_KEY=${SECRET_KEY}"
    echo "export AWS_SESSION_TOKEN=${SESSION_TOKEN}"
    echo "# Credenciais exportadas para a sessão atual!"
    echo "# Sistema: $OS_TYPE"
    echo "# Expira em: ${EXPIRATION}"
elif [[ "$EXPORT_PS" == true ]]; then
    # Modo export PowerShell
    echo "\$env:AWS_ACCESS_KEY_ID='${ACCESS_KEY}'"
    echo "\$env:AWS_SECRET_ACCESS_KEY='${SECRET_KEY}'"
    echo "\$env:AWS_SESSION_TOKEN='${SESSION_TOKEN}'"
    echo "# Credenciais exportadas para PowerShell!"
    echo "# Expira em: ${EXPIRATION}"
elif [[ "$EXPORT_CMD" == true ]]; then
    # Modo export CMD
    echo "set AWS_ACCESS_KEY_ID=${ACCESS_KEY}"
    echo "set AWS_SECRET_ACCESS_KEY=${SECRET_KEY}"
    echo "set AWS_SESSION_TOKEN=${SESSION_TOKEN}"
    echo "REM Credenciais exportadas para CMD!"
    echo "REM Expira em: ${EXPIRATION}"
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
    
    # Instruções específicas por sistema operacional
    case "$OS_TYPE" in
        "windows")
            echo "=== Para usar no Git Bash ==="
            echo "export AWS_ACCESS_KEY_ID=${ACCESS_KEY}"
            echo "export AWS_SECRET_ACCESS_KEY=${SECRET_KEY}"
            echo "export AWS_SESSION_TOKEN=${SESSION_TOKEN}"
            echo ""
            echo "=== Para usar no PowerShell ==="
            echo "\$env:AWS_ACCESS_KEY_ID='${ACCESS_KEY}'"
            echo "\$env:AWS_SECRET_ACCESS_KEY='${SECRET_KEY}'"
            echo "\$env:AWS_SESSION_TOKEN='${SESSION_TOKEN}'"
            echo ""
            echo "=== Para usar no CMD ==="
            echo "set AWS_ACCESS_KEY_ID=${ACCESS_KEY}"
            echo "set AWS_SECRET_ACCESS_KEY=${SECRET_KEY}"
            echo "set AWS_SESSION_TOKEN=${SESSION_TOKEN}"
            echo ""
            echo "=== Export automático ==="
            echo "# Git Bash:"
            echo "source <($0 ${PROFILE_NAME} ${DURATION} --export)"
            echo "# PowerShell:"
            echo "Invoke-Expression \$(./$0 ${PROFILE_NAME} ${DURATION} --export-ps)"
            echo "# CMD:"
            echo "$0 ${PROFILE_NAME} ${DURATION} --export-cmd > temp.bat && temp.bat && del temp.bat"
            ;;
        *)
            echo "=== Para usar no terminal ==="
            echo "export AWS_ACCESS_KEY_ID=${ACCESS_KEY}"
            echo "export AWS_SECRET_ACCESS_KEY=${SECRET_KEY}"
            echo "export AWS_SESSION_TOKEN=${SESSION_TOKEN}"
            echo ""
            echo "=== Export automático ==="
            echo "source <($0 ${PROFILE_NAME} ${DURATION} --export)"
            ;;
    esac
    
    echo ""
    echo "=== Para usar em arquivo .env ==="
    echo "AWS_ACCESS_KEY_ID=${ACCESS_KEY}"
    echo "AWS_SECRET_ACCESS_KEY=${SECRET_KEY}"
    echo "AWS_SESSION_TOKEN=${SESSION_TOKEN}"
    echo ""
    echo "=== Para salvar em arquivo ==="
    echo "Para salvar as variáveis em um arquivo:"
    echo "$0 ${PROFILE_NAME} ${DURATION} > sts-credentials.env"
fi
