#!/bin/bash

# ============================================================================
# Script: Extrair Configurações de Deploy
# Propósito: Demonstrar como extrair informações necessárias via bash
# ============================================================================

set -e  # Parar se houver erro

echo "=========================================="
echo "EXTRAÇÃO DE CONFIGURAÇÕES DE DEPLOY - BIA"
echo "=========================================="
echo ""

# ============================================================================
# 1. VALIDAR FERRAMENTAS NECESSÁRIAS
# ============================================================================

echo "1️⃣  VALIDANDO FERRAMENTAS..."
echo ""

# Função auxiliar pra verificar comando
verificar_comando() {
    if command -v "$1" &> /dev/null; then
        echo "   ✅ $1 encontrado"
        return 0
    else
        echo "   ❌ $1 NÃO ENCONTRADO"
        return 1
    fi
}

# Verificar tudo
ferramentas_ok=true
verificar_comando "aws" || ferramentas_ok=false
verificar_comando "node" || ferramentas_ok=false
verificar_comando "npm" || ferramentas_ok=false

if [ "$ferramentas_ok" = false ]; then
    echo ""
    echo "⚠️  Algumas ferramentas estão faltando. Instale e tente novamente."
    exit 1
fi

echo ""

# ============================================================================
# 2. EXTRAIR BUCKET S3
# ============================================================================

echo "2️⃣  EXTRAINDO BUCKET S3..."
echo ""

# Listar todos os buckets
BUCKETS=$(aws s3 ls --output text | awk '{print $3}')

# Procurar por "bia-frontend"
BIA_BUCKET=$(echo "$BUCKETS" | grep -i "bia-frontend" | head -1)

if [ -z "$BIA_BUCKET" ]; then
    echo "   ❌ Nenhum bucket com 'bia-frontend' encontrado."
    echo ""
    echo "   Buckets disponíveis:"
    aws s3 ls | awk '{print "   - " $3}'
    exit 1
fi

echo "   ✅ Bucket encontrado: $BIA_BUCKET"
echo ""

# ============================================================================
# 3. EXTRAIR REGIÃO DO AWS CLI
# ============================================================================

echo "3️⃣  EXTRAINDO REGIÃO..."
echo ""

# Método 1: Verificar configuração do AWS CLI
REGION_CONFIG=$(aws configure get region)

if [ -z "$REGION_CONFIG" ]; then
    # Método 2: Verificar variável de ambiente
    REGION="${AWS_REGION:-us-east-1}"
    echo "   ⚠️  Não configurado no AWS CLI, usando padrão: $REGION"
else
    REGION="$REGION_CONFIG"
    echo "   ✅ Região extraída do AWS CLI: $REGION"
fi

echo ""

# ============================================================================
# 4. EXTRAIR CAMINHO DO PROJETO
# ============================================================================

echo "4️⃣  EXTRAINDO CAMINHO DO PROJETO..."
echo ""

# Procurar por diretório "client" com package.json
if [ -f "client/package.json" ]; then
    PROJECT_PATH="./client"
    echo "   ✅ Projeto encontrado em: $PROJECT_PATH"
elif [ -f "package.json" ]; then
    PROJECT_PATH="."
    echo "   ✅ Projeto encontrado em: $PROJECT_PATH"
else
    echo "   ❌ Nenhum projeto React encontrado"
    echo "      Procurando em: client/package.json ou package.json"
    exit 1
fi

echo ""

# ============================================================================
# 5. EXTRAIR INFORMAÇÕES DO PROJETO (package.json)
# ============================================================================

echo "5️⃣  LENDO INFORMAÇÕES DO PROJETO..."
echo ""

# Usar 'jq' se disponível, senão usar grep simples
if command -v jq &> /dev/null; then
    PROJECT_NAME=$(jq -r '.name' "$PROJECT_PATH/package.json")
    PROJECT_VERSION=$(jq -r '.version' "$PROJECT_PATH/package.json")
else
    # Fallback: grep + sed
    PROJECT_NAME=$(grep '"name"' "$PROJECT_PATH/package.json" | head -1 | sed 's/.*"name": "\([^"]*\)".*/\1/')
    PROJECT_VERSION=$(grep '"version"' "$PROJECT_PATH/package.json" | head -1 | sed 's/.*"version": "\([^"]*\)".*/\1/')
fi

echo "   📦 Projeto: $PROJECT_NAME"
echo "   🏷️  Versão: $PROJECT_VERSION"
echo ""

# ============================================================================
# 6. VALIDAR .env.local
# ============================================================================

echo "6️⃣  VALIDANDO .env.local..."
echo ""

if [ ! -f "$PROJECT_PATH/.env.local" ]; then
    echo "   ⚠️  .env.local não encontrado!"
    echo "      Criando arquivo de exemplo..."
    cat > "$PROJECT_PATH/.env.local.example" << 'EOF'
VITE_API_URL=http://54.83.241.43:3001
EOF
    echo "   📝 Criado: $PROJECT_PATH/.env.local.example"
else
    API_URL=$(grep "VITE_API_URL" "$PROJECT_PATH/.env.local" | cut -d'=' -f2)
    echo "   ✅ .env.local encontrado"
    echo "   🔗 API URL configurada: $API_URL"
fi

echo ""

# ============================================================================
# 7. EXTRAIR URL DO WEBSITE S3
# ============================================================================

echo "7️⃣  EXTRAINDO URL DO WEBSITE S3..."
echo ""

# Fórmula: https://{bucket}.s3-website-{region}.amazonaws.com
WEBSITE_URL="https://${BIA_BUCKET}.s3-website-${REGION}.amazonaws.com"

echo "   🌐 URL do site: $WEBSITE_URL"
echo ""

# ============================================================================
# 8. VERIFICAR SE BUILD ANTERIOR EXISTE
# ============================================================================

echo "8️⃣  VERIFICANDO BUILD..."
echo ""

if [ -d "$PROJECT_PATH/build" ]; then
    BUILD_SIZE=$(du -sh "$PROJECT_PATH/build" | cut -f1)
    BUILD_FILES=$(find "$PROJECT_PATH/build" -type f | wc -l)
    echo "   ✅ Pasta build/ encontrada"
    echo "      Tamanho: $BUILD_SIZE"
    echo "      Arquivos: $BUILD_FILES"
else
    echo "   ⚠️  Pasta build/ não existe (precisa fazer npm run build)"
fi

echo ""

# ============================================================================
# 9. RESUMO FINAL
# ============================================================================

echo "=========================================="
echo "RESUMO DE CONFIGURAÇÕES"
echo "=========================================="
echo ""
echo "Variáveis extraídas:"
echo ""
echo "  BUCKET_S3=\"$BIA_BUCKET\""
echo "  REGION=\"$REGION\""
echo "  PROJECT_PATH=\"$PROJECT_PATH\""
echo "  PROJECT_NAME=\"$PROJECT_NAME\""
echo "  WEBSITE_URL=\"$WEBSITE_URL\""
echo ""

# ============================================================================
# 10. EXPORTAR PARA USO EM SCRIPTS
# ============================================================================

echo "Para usar em outros scripts, exporte as variáveis:"
echo ""
echo "  export BUCKET_S3=\"$BIA_BUCKET\""
echo "  export REGION=\"$REGION\""
echo "  export PROJECT_PATH=\"$PROJECT_PATH\""
echo "  export WEBSITE_URL=\"$WEBSITE_URL\""
echo ""

# ============================================================================
# 11. GERAR ARQUIVO DE CONFIGURAÇÃO
# ============================================================================

CONFIG_FILE="deploy-config.md"

echo "Salvando configurações em: $CONFIG_FILE"

cat > "$CONFIG_FILE" << EOF
# Configuração de Deploy — BIA

> Gerado automaticamente por \`extrair_config_deploy.sh\` em $(date).
> Lido por \`deploy-bia.sh\` — **só o bloco de código abaixo é processado**
> pelo script; o resto é documentação, pra você conferir os valores extraídos
> antes de rodar um deploy de verdade.

## Valores extraídos

| Variável | Valor |
|---|---|
| Projeto | $PROJECT_NAME (v$PROJECT_VERSION) |
| Bucket S3 | $BIA_BUCKET |
| Região | $REGION |
| Caminho do projeto | $PROJECT_PATH |
| URL do website | $WEBSITE_URL |

## Configuração usada pelos scripts

\`\`\`bash
export BUCKET_S3="$BIA_BUCKET"
export REGION="$REGION"
export PROJECT_PATH="$PROJECT_PATH"
export PROJECT_NAME="$PROJECT_NAME"
export PROJECT_VERSION="$PROJECT_VERSION"
export WEBSITE_URL="$WEBSITE_URL"
\`\`\`
EOF

echo "✅ Arquivo $CONFIG_FILE criado"
echo ""

# ============================================================================
# 12. VERIFICAÇÃO FINAL
# ============================================================================

echo "=========================================="
echo "✅ TODAS AS CONFIGURAÇÕES EXTRAÍDAS"
echo "=========================================="
echo ""
echo "Próximas ações:"
echo ""
echo "  1. Rodar o deploy (ele lê deploy-config.md automaticamente):"
echo "     ./deploy-bia.sh"
echo ""
echo "  2. Ou carregar as variáveis manualmente no terminal:"
echo "     source <(sed -n '/^\`\`\`bash\$/,/^\`\`\`\$/p' deploy-config.md | sed '1d;\$d')"
echo "     echo \$BUCKET_S3"
echo "     echo \$WEBSITE_URL"
echo ""
echo "  3. Teste a conexão com S3:"
echo "     aws s3 ls s3://\$BUCKET_S3/"
echo ""
echo "  4. Teste acessar o website:"
echo "     curl -I \$WEBSITE_URL"
echo ""
