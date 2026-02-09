./build.sh
aws ecs update-service --cluster cluster-alb-bia --service service-bia-alb  --force-new-deployment
