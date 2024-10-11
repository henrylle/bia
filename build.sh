versao=$(git rev-parse HEAD | cut -c 1-7)
aws ecr get-login-password --region us-east-1 --profile bia | docker login --username AWS --password-stdin 471112700544.dkr.ecr.us-east-1.amazonaws.com
docker build -t bia .
docker tag bia:latest 471112700544.dkr.ecr.us-east-1.amazonaws.com/bia:$versao
docker push 471112700544.dkr.ecr.us-east-1.amazonaws.com/bia:$versao
rm .env
./gerar-compose.sh
rm bia-versao-*zip
zip -r bia-versao-$versao.zip docker-compose.yml
git checkout docker-compose.yml