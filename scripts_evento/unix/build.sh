ECR_REPOSITORY="SEU_REPOSITORIO"
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_REPOSITORY
docker build -t bia .
docker tag bia:latest $ECR_REPOSITORY/bia:latest
docker push $ECR_REPOSITORY/bia:latest
