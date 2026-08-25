#!/bin/bash
BASE_URL="http://localhost:3001/api/tarefas"

echo "Buscando tarefas..."
UUIDS=$(curl -s "$BASE_URL" | python3 -c "import json,sys; [print(t['uuid']) for t in json.load(sys.stdin)]")
TOTAL=$(echo "$UUIDS" | wc -l | tr -d ' ')
echo "Total: $TOTAL tarefas | Deletando 3 em paralelo com intervalo de 0.3s entre lotes..."

echo "$UUIDS" | xargs -P 5 -I {} sh -c 'curl -s -o /dev/null -w "Deletado {} -> HTTP %{http_code}\n" -X DELETE "'$BASE_URL'/{}"; sleep 0.3'

echo "Exclusão finalizada!"
