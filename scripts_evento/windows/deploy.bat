call build.bat
aws ecs update-service --cluster [SEU_CLUSTER] --service [SEU_SERVICE]  --force-new-deployment --profile [SEU_PROFILE]
