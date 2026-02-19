#!/bin/bash

function envio_s3(){
    local BUCKET_NAME="desafio-fundamentos"
    
    echo "=== [S3] Enviando para o bucket: $BUCKET_NAME ==="
    
    # --delete: remove lixo do bucket
    # --cache-control: força o browser a não usar o cache antigo (resolve o 304)
    aws s3 sync ./client/build/ "s3://$BUCKET_NAME" \
        --profile fundamentos \
        --delete \
        --cache-control "max-age=0, no-cache, no-store, must-revalidate"
    
    echo "=== [S3] Envio finalizado! ==="
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    envio_s3
fi