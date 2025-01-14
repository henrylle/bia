URL="https://www.uol.com.br"
while true; do 
  START=$(date '+%Y-%m-%d %H:%M:%S')
  START_MS=$(gdate +%s%3N)
  
  # Captura todos os cabeçalhos
  HEADERS=$(curl -s -I -X GET $URL)
  
  # Extração dos valores desejados
  X_CACHE=$(echo "$HEADERS" | grep -i x-cache | awk -F ': ' '{print $2}' | tr -d '\r')
  CACHE_CONTROL=$(echo "$HEADERS" | grep -i cache-control | awk -F ': ' '{print $2}' | tr -d '\r')
  
  END_MS=$(gdate +%s%3N)
  DURATION=$((END_MS - START_MS))
  
  # Adiciona o Cache-Control apenas se X-Cache contiver "Miss from cloudfront"
  if [[ "$X_CACHE" == *"Miss from cloudfront"* ]]; then
    X_CACHE="$X_CACHE ($CACHE_CONTROL)"
  fi
  
  # Exibe o log com os cabeçalhos desejados
  echo "$START - $DURATION ms - ${X_CACHE:-N/A}"
  
  sleep 2;
done
