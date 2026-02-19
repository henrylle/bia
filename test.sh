#!/bin/bash

# Configurações
BUCKET_NAME="desafio-fundamentos"
LOCAL_DIR="/caminho/para/pasta/local"
S3_DESTINATION="s3://${BUCKET_NAME}"

# Verifica se AWS CLI está instalado
if ! command -v aws &> /dev/null; then
    echo "Erro: AWS CLI não está instalado"
    exit 1
fi

# Verifica se a pasta local existe
if [ ! -d "$LOCAL_DIR" ]; then
    echo "Erro: Diretório local não existe: $LOCAL_DIR"
    exit 1
fi

# Sincroniza pasta local com bucket S3
echo "Sincronizando $LOCAL_DIR com $S3_DESTINATION..."
aws s3 sync "$LOCAL_DIR" "$S3_DESTINATION"

# Verifica se o comando foi bem-sucedido
if [ $? -eq 0 ]; then
    echo "Sincronização concluída com sucesso!"
else
    echo "Erro na sincronização"
    exit 1
fi
. react.sh
. s3.sh

echo "Finalizando deploy"
