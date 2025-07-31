./build.sh
aws ecs update-service --cluster cluster-bia --service service-bia  --force-new-deployment
