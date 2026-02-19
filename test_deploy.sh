#!/bin/bash

# Test script for deploy_s3.sh

echo "=== Iniciando testes do deploy_s3.sh ==="

# Test 1: Verifica se AWS CLI está instalado
echo -e "\n[TEST 1] Verificando AWS CLI..."
if command -v aws &> /dev/null; then
    echo "✓ AWS CLI instalado"
else
    echo "✗ AWS CLI não encontrado"
fi

# Test 2: Verifica se o bucket existe
echo -e "\n[TEST 2] Verificando bucket S3..."
BUCKET_NAME="desafio-fundamentos"
if aws s3 ls "s3://${BUCKET_NAME}" &> /dev/null; then
    echo "✓ Bucket ${BUCKET_NAME} existe"
else
    echo "✗ Bucket ${BUCKET_NAME} não encontrado ou sem permissão"
fi

# Test 3: Verifica se react.sh existe
echo -e "\n[TEST 3] Verificando react.sh..."
if [ -f "react.sh" ]; then
    echo "✓ react.sh encontrado"
else
    echo "✗ react.sh não encontrado"
fi

# Test 4: Verifica se s3.sh existe
echo -e "\n[TEST 4] Verificando s3.sh..."
if [ -f "s3.sh" ]; then
    echo "✓ s3.sh encontrado"
else
    echo "✗ s3.sh não encontrado"
fi

# Test 5: Testa criação de diretório temporário
echo -e "\n[TEST 5] Testando criação de diretório..."
TEST_DIR="/tmp/test_deploy_$$"
mkdir -p "$TEST_DIR"
if [ -d "$TEST_DIR" ]; then
    echo "✓ Diretório de teste criado"
    rm -rf "$TEST_DIR"
else
    echo "✗ Falha ao criar diretório"
fi

echo -e "\n=== Testes concluídos ==="
