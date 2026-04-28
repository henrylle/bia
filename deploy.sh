./build.sh
aws ecs update-service --cluster cluster-bia --service service-bia-td-cluster --force-new-deployment
