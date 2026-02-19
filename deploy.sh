#!/bin/bash
set -e

# --- Configurações ---
API_HOM="http://54.144.81.161"
BUCKET_HOM="desafio-fundamentos"
START_TIME=$(date +%s)

# Importa as funções (certifique-se que os arquivos estão no mesmo diretório)
source ./react.sh
source ./s3.sh

echo "-----------------------------------------------------"
echo "🚀 INICIANDO DEPLOY DETALHADO - AMBIENTE: HOMOLOGAÇÃO"
echo "📅 Data: $(date '+%d/%m/%Y %H:%M:%S')"
echo "-----------------------------------------------------"

# 1. Validação de Dependências
echo "🔍 [1/4] Validando ferramentas necessárias..."
command -v aws &> /dev/null || { echo "❌ Erro: AWS CLI não encontrado."; exit 1; }
command -v npm &> /dev/null || { echo "❌ Erro: NPM não encontrado."; exit 1; }
echo "Ferramentas prontas."

# 2. Execução do Build com Verificação
echo "[2/4] Iniciando Build do React..."
build "$API_HOM"

# Validação Técnica: O IP está mesmo no build?
echo "[3/4] Verificando integridade do build (Injeção de API)..."
if grep -r "http://54.144.81.161" ./client/build/ > /dev/null; then
    echo "Sucesso: IP $API_HOM encontrado nos arquivos estáticos."
else
    echo "AVISO: O IP da API não foi encontrado no build! Verifique o REACT_APP_API_URL."
    # Opcional: exit 1 aqui se quiser interromper se falhar a injeção
fi


# 3. Envio para o S3
echo "[4/4] Sincronizando com S3 (Bucket: $BUCKET_HOM)..."
envio_s3 "$BUCKET_HOM"

# --- Finalização ---
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "-----------------------------------------------------"
echo "✅ DEPLOY FINALIZADO COM SUCESSO!"
echo "⏱️  Tempo total: ${DURATION}s"
echo "🔗 URL: http://${BUCKET_HOM}.s3-website-us-east-1.amazonaws.com"
echo "💡 Dica: Se não vir as mudanças, use Ctrl+F5 ou aba anônima."
echo "-----------------------------------------------------"