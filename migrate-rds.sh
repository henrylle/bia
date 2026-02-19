#!/bin/bash
# Script otimizado para migrations no RDS

echo "Testando conectividade com RDS..."
docker compose exec server bash -c 'pg_isready -h $DB_HOST -p $DB_PORT'

if [ $? -eq 0 ]; then
    echo "Executando migrations..."
    docker compose exec server bash -c 'npx sequelize db:migrate --timeout 60000'
else
    echo "Erro: Não foi possível conectar ao RDS"
    exit 1
fi
