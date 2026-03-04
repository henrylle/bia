./build.sh
aws ecs update-service --cluster cluster-bia-alb --service service-bia-alb  --force-new-deployment
