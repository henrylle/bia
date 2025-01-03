URL="https://www.uol.com.br"
while true; do 
  START=$(date '+%Y-%m-%d %H:%M:%S')
  START_MS=$(gdate +%s%3N)
  VALUE=$(curl -s -I -X GET $URL | grep -i x-cache | awk -F ': ' '{print $2}')
  END_MS=$(gdate +%s%3N)
  DURATION=$((END_MS - START_MS))
  echo "$START - $DURATION ms - $VALUE";
  sleep 2;
done
