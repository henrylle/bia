INSTANCE_ID=$1
echo $INSTANCE_ID
#aws ssm start-session --target $INSTANCE_ID --document-name AWS-StartInteractiveCommand --parameters command="bash -l"