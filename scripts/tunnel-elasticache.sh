#!/bin/bash

INSTANCE_ID="INSTANCE_ID_BIA_DEV"
CACHE_HOST="CLUSTER_ELASTICACHE_ENDPOINT"
CACHE_PORT="6379"
LOCAL_PORT="6379"
REGION="us-east-1"

echo "Abrindo túnel SSM para o ElastiCache..."
echo "Host remoto: $CACHE_HOST:$CACHE_PORT"
echo "Porta local: $LOCAL_PORT"
echo ""
echo "Após o túnel abrir, em outro terminal execute:"
echo "  redis-cli -h 127.0.0.1 -p $LOCAL_PORT --tls ping"
echo "  redis-cli -h 127.0.0.1 -p $LOCAL_PORT --tls info server"
echo "  redis-cli -h 127.0.0.1 -p $LOCAL_PORT --tls set teste bia"
echo "  redis-cli -h 127.0.0.1 -p $LOCAL_PORT --tls get teste"
echo ""
echo "Pressione Ctrl+C para encerrar o túnel."
echo ""

aws ssm start-session \
  --target "$INSTANCE_ID" \
  --document-name AWS-StartPortForwardingSessionToRemoteHost \
  --parameters "{\"host\":[\"$CACHE_HOST\"],\"portNumber\":[\"$CACHE_PORT\"],\"localPortNumber\":[\"$LOCAL_PORT\"]}" \
  --region "$REGION"
