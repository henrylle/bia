./build.sh
aws ecs update-service --cluster cluster-bia --service bia-service  --force-new-deployment
