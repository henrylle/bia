#!/bin/bash
BASE_URL="http://localhost:3001/api/tarefas"
TOTAL=1000

echo "Inserindo $TOTAL tarefas | 3 em paralelo..."

seq 1 $TOTAL | xargs -P 3 -I {} sh -c \
  'curl -s -o /dev/null -w "Tarefa {} -> HTTP %{http_code}\n" -X POST -H "Content-Type: application/json" -d "{\"titulo\":\"Tarefa {}\"}" "'$BASE_URL'"'

echo "Inserção finalizada!"
