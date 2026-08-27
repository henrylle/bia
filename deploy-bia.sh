#!/bin/bash

# ============================================================================
# Script: Deploy Automático BIA
# Propósito: Automatizar todo o processo de build → upload S3 → validação
# Requisitos: AWS CLI, Node.js, npm, jq (opcional)
# ============================================================================

set -e  # Parar se houver erro

# Cores pra output legível
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# FUNÇÕES AUXILIARES
# ============================================================================

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_header() {
    echo ""
    echo -e "${BLUE}=========================================="
    echo "$1"
    echo "==========================================${NC}"
    echo ""
}

# ============================================================================
# PARTE 1: CARREGAR CONFIGURAÇÕES
# ============================================================================

log_header "INICIANDO DEPLOY BIA"

CONFIG_FILE="deploy-config.md"

# Verificar se arquivo de config existe
if [ -f "$CONFIG_FILE" ]; then
    log_success "Arquivo $CONFIG_FILE encontrado"
    # O .md tem texto + tabela pra leitura humana, mas só o bloco ```bash
    # é config de verdade. Extrai só esse bloco e carrega no shell atual
    # (process substitution: "source <(...)" roda no shell atual, não numa
    # subshell — por isso os export ficam disponíveis no resto do script).
    source <(sed -n '/^```bash$/,/^```$/p' "$CONFIG_FILE" | sed '1d;$d')
else
    log_warning "Arquivo $CONFIG_FILE não encontrado"
    log_info "Execute primeiro: ./extrair_config_deploy.sh"
    exit 1
fi

# ============================================================================
# PARTE 2: VALIDAR VARIÁVEIS
# ============================================================================

log_header "VALIDANDO CONFIGURAÇÕES"

[ -z "$BUCKET_S3" ] && log_error "BUCKET_S3 não definido" && exit 1
[ -z "$REGION" ] && log_error "REGION não definido" && exit 1
[ -z "$PROJECT_PATH" ] && log_error "PROJECT_PATH não definido" && exit 1

log_success "Bucket: $BUCKET_S3"
log_success "Região: $REGION"
log_success "Caminho: $PROJECT_PATH"
log_success "URL: $WEBSITE_URL"

# ============================================================================
# PARTE 3: VERIFICAR PRÉ-REQUISITOS
# ============================================================================

log_header "VERIFICANDO PRÉ-REQUISITOS"

# Verificar AWS CLI
if ! command -v aws &> /dev/null; then
    log_error "AWS CLI não encontrado. Instale: https://aws.amazon.com/cli/"
    exit 1
fi
log_success "AWS CLI ✓"

# Verificar Node.js e npm
if ! command -v node &> /dev/null; then
    log_error "Node.js não encontrado"
    exit 1
fi
log_success "Node.js ✓"

if ! command -v npm &> /dev/null; then
    log_error "npm não encontrado"
    exit 1
fi
log_success "npm ✓"

# Verificar conectividade AWS
log_info "Testando conectividade com AWS..."
if ! aws sts get-caller-identity --region "$REGION" > /dev/null 2>&1; then
    log_error "Não conseguiu conectar à AWS. Verifique credenciais."
    exit 1
fi
log_success "Conectividade AWS ✓"

# ============================================================================
# PARTE 4: VALIDAR PROJETO
# ============================================================================

log_header "VALIDANDO PROJETO"

if [ ! -f "$PROJECT_PATH/package.json" ]; then
    log_error "package.json não encontrado em $PROJECT_PATH"
    exit 1
fi
log_success "package.json encontrado"

if [ ! -f "$PROJECT_PATH/.env.local" ]; then
    log_error ".env.local não encontrado"
    log_info "Crie o arquivo: $PROJECT_PATH/.env.local"
    exit 1
fi
log_success ".env.local encontrado"

# ============================================================================
# PARTE 5: INSTALAR DEPENDÊNCIAS (se necessário)
# ============================================================================

log_header "PREPARANDO AMBIENTE"

cd "$PROJECT_PATH"

# Verificar se node_modules existe
if [ ! -d "node_modules" ]; then
    log_info "Instalando dependências..."
    npm install
    log_success "Dependências instaladas"
else
    log_success "node_modules já existe"
fi

# ============================================================================
# PARTE 6: FAZER BUILD
# ============================================================================

log_header "COMPILANDO PROJETO"

log_info "Limpando build anterior..."
rm -rf build

log_info "Executando: npm run build"
npm run build

# Validar se build foi bem-sucedido
if [ ! -d "build" ]; then
    log_error "Build falhou! Pasta 'build' não foi criada."
    exit 1
fi

BUILD_SIZE=$(du -sh build | cut -f1)
BUILD_FILES=$(find build -type f | wc -l)
log_success "Build concluído! ($BUILD_FILES arquivos, $BUILD_SIZE)"

# ============================================================================
# PARTE 7: VALIDAR BUILD
# ============================================================================

log_header "VALIDANDO BUILD"

# Verificar arquivos críticos
if [ ! -f "build/index.html" ]; then
    log_error "index.html não encontrado em build/"
    exit 1
fi
log_success "index.html ✓"

if [ ! -d "build/assets" ]; then
    log_error "Pasta assets não encontrada"
    exit 1
fi
log_success "assets/ ✓"

# Procurar por variável compilada (lida do .env.local, não fixa no script —
# o IP público da EC2 pode mudar a qualquer restart, sem Elastic IP associado)
API_URL_ATUAL=$(grep "VITE_API_URL" .env.local | cut -d'=' -f2)

if [ -z "$API_URL_ATUAL" ]; then
    log_warning "VITE_API_URL não encontrada em .env.local, pulando checagem"
elif grep -qF "$API_URL_ATUAL" build/assets/*.js; then
    log_success "Variável API_URL ($API_URL_ATUAL) compilada corretamente ✓"
else
    log_warning "API_URL ($API_URL_ATUAL) pode não estar compilada corretamente"
    log_info "Verifique .env.local e refaça o build"
fi

# ============================================================================
# PARTE 8: UPLOAD PARA S3
# ============================================================================

log_header "ENVIANDO PARA S3"

log_info "Sincronizando com S3..."
log_info "Comando: aws s3 sync build/ s3://$BUCKET_S3/ --delete --region $REGION"

# Fazer sync
SYNC_OUTPUT=$(aws s3 sync build/ "s3://$BUCKET_S3/" \
    --delete \
    --region "$REGION" \
    --output text 2>&1)

# Contar arquivos enviados
UPLOAD_COUNT=$(echo "$SYNC_OUTPUT" | grep -c "upload:" || echo "?")

if [ "$UPLOAD_COUNT" != "?" ]; then
    log_success "Upload concluído! ($UPLOAD_COUNT arquivos enviados)"
else
    log_success "Upload concluído!"
fi

# ============================================================================
# PARTE 9: VALIDAR UPLOAD
# ============================================================================

log_header "VALIDANDO UPLOAD"

log_info "Verificando arquivos no S3..."

# Listar arquivos no bucket
FILES_IN_S3=$(aws s3 ls "s3://$BUCKET_S3/" --recursive --region "$REGION" | wc -l)
log_success "Arquivos em S3: $FILES_IN_S3"

# Testar index.html específico
if aws s3 ls "s3://$BUCKET_S3/index.html" --region "$REGION" > /dev/null 2>&1; then
    log_success "index.html existe no S3 ✓"
else
    log_error "index.html não encontrado no S3!"
    exit 1
fi

# ============================================================================
# PARTE 10: TESTAR CONECTIVIDADE DO WEBSITE
# ============================================================================

log_header "TESTANDO WEBSITE"

log_info "Testando URL: $WEBSITE_URL"

# Tentar acessar e verificar status HTTP
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$WEBSITE_URL" 2>/dev/null || echo "000")

if [ "$HTTP_STATUS" = "200" ]; then
    log_success "Website respondendo! (HTTP $HTTP_STATUS)"
else
    log_warning "Website retornou HTTP $HTTP_STATUS (pode estar em cache)"
    log_info "Espere alguns segundos e tente manualmente: $WEBSITE_URL"
fi

# ============================================================================
# PARTE 11: RELATÓRIO FINAL
# ============================================================================

log_header "✅ DEPLOY CONCLUÍDO COM SUCESSO"

cat << EOF
Resumo do Deploy:
  📦 Projeto: $PROJECT_NAME (v$PROJECT_VERSION)
  🪣 Bucket S3: $BUCKET_S3
  🌍 Região: $REGION
  🌐 Website: $WEBSITE_URL
  📊 Arquivos: $BUILD_FILES
  💾 Tamanho: $BUILD_SIZE
  ⏰ Data/Hora: $(date)

Próximos passos:
  1. Abrir no navegador: $WEBSITE_URL
  2. Verificar DevTools Console pra logs
  3. Testar funcionalidades principais

Troubleshooting:
  - Refresh forçado: Ctrl+Shift+R (Chrome) ou Cmd+Shift+R (Mac)
  - Ver logs: aws s3api get-bucket-logging --bucket $BUCKET_S3
  - Invalidar cache CloudFront: aws cloudfront create-invalidation --distribution-id <ID> --paths "/*"

EOF

# ============================================================================
# PARTE 12: SALVAR LOGS
# ============================================================================

DEPLOY_LOG="deploy-$(date +%Y%m%d-%H%M%S).log"

log_info "Salvando logs em: $DEPLOY_LOG"

cat > "$DEPLOY_LOG" << EOF
Deploy Log - BIA
Data: $(date)

Configurações:
  Bucket: $BUCKET_S3
  Região: $REGION
  URL: $WEBSITE_URL

Resultado:
  Build: OK ($BUILD_FILES arquivos, $BUILD_SIZE)
  Upload: OK
  Teste: HTTP $HTTP_STATUS

Tempo: $(date)
EOF

log_success "Deploy log salvo!"

echo ""
log_success "FIM DO DEPLOY"
echo ""
