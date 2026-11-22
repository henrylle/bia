ECR_REGISTRY="${ECR_REGISTRY:-SEU_REGISTRY}"
TAG="${TAG:-latest}"
# PLATFORM: linux/amd64 (x86, padrao) ou linux/arm64 (ARM/Graviton).
# Tem que bater com a arquitetura da task definition no ECS.
PLATFORM="${PLATFORM:-linux/amd64}"
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_REGISTRY
docker build --platform $PLATFORM -t bia .
docker tag bia:latest $ECR_REGISTRY/bia:$TAG
docker push $ECR_REGISTRY/bia:$TAG
