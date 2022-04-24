aws ecr get-login-password --region us-east-1 --profile [SEU_PROFILE] | docker login --username AWS --password-stdin [SEU_ECR]
docker build -t bia .
docker tag bia:latest [SEU_ECR]/bia:latest
docker push [SEU_ECR]/bia:latest