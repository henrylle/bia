#!/bin/bash

# Script para corrigir Auto Scaling Groups dos clusters ECS
# Execute este script para recriar os ASGs que foram deletados

set -e

# Variáveis
REGION="us-east-1"
AMI_ID="ami-06cc69030d77088a1"  # AMI ECS mais recente (20260226)
INSTANCE_TYPE="t3.micro"
KEY_NAME=""  # Deixe vazio se não tiver key pair
IAM_INSTANCE_PROFILE="ecsInstanceRole"
VPC_ID="vpc-007e5bf38148c7121"

# Subnets (todas as disponíveis)
SUBNETS="subnet-004fc006f214f0ad1,subnet-03bd03829c971a89a,subnet-0d259130444e06be5,subnet-0e6a06050127a7bb2,subnet-0c51d68011edb0d67,subnet-0feaa97a0f0e77857"

# Security Groups
SG_WEB="sg-04721b37b7a06da28"  # bia-web (para cluster-bia)
SG_EC2="sg-0dfdd93e3ddae2f4b"  # bia-ec2-teste (para cluster-alb-bia)

echo "=========================================="
echo "CORREÇÃO DOS AUTO SCALING GROUPS"
echo "=========================================="
echo ""

# ==========================================
# CLUSTER-BIA (sem ALB)
# ==========================================
echo "1. Criando Launch Template para cluster-bia..."

USER_DATA_BIA=$(cat <<'EOF'
#!/bin/bash
echo ECS_CLUSTER=cluster-bia >> /etc/ecs/ecs.config
EOF
)

aws ec2 create-launch-template \
  --region $REGION \
  --launch-template-name "lt-bia-v2" \
  --version-description "Launch template for cluster-bia" \
  --launch-template-data "{
    \"ImageId\": \"$AMI_ID\",
    \"InstanceType\": \"$INSTANCE_TYPE\",
    \"IamInstanceProfile\": {
      \"Name\": \"$IAM_INSTANCE_PROFILE\"
    },
    \"SecurityGroupIds\": [\"$SG_WEB\"],
    \"UserData\": \"$(echo "$USER_DATA_BIA" | base64 -w 0)\",
    \"TagSpecifications\": [{
      \"ResourceType\": \"instance\",
      \"Tags\": [
        {\"Key\": \"Name\", \"Value\": \"ecs-cluster-bia\"},
        {\"Key\": \"Cluster\", \"Value\": \"cluster-bia\"}
      ]
    }]
  }"

echo "✓ Launch Template criado: lt-bia-v2"
echo ""

echo "2. Aguardando deleção do ASG anterior (se existir)..."
for i in {1..12}; do
  if aws autoscaling describe-auto-scaling-groups --region $REGION --auto-scaling-group-names asg-bia-v2 2>&1 | grep -q "AutoScalingGroup not found"; then
    echo "✓ Pronto para criar novo ASG"
    break
  fi
  echo "  Aguardando... ($i/12)"
  sleep 5
done
echo ""

echo "3. Criando Auto Scaling Group para cluster-bia..."

aws autoscaling create-auto-scaling-group \
  --region $REGION \
  --auto-scaling-group-name "asg-bia-v2" \
  --launch-template "LaunchTemplateName=lt-bia-v2,Version=\$Latest" \
  --min-size 1 \
  --max-size 3 \
  --desired-capacity 1 \
  --vpc-zone-identifier "$SUBNETS" \
  --health-check-type EC2 \
  --health-check-grace-period 300 \
  --tags "Key=Name,Value=ecs-cluster-bia,PropagateAtLaunch=true" \
         "Key=Cluster,Value=cluster-bia,PropagateAtLaunch=true"

echo "✓ Auto Scaling Group criado: asg-bia-v2"
echo ""

echo "4. Criando Capacity Provider para cluster-bia..."

# Buscar ARN do ASG
ASG_ARN_BIA=$(aws autoscaling describe-auto-scaling-groups \
  --region $REGION \
  --auto-scaling-group-names "asg-bia-v2" \
  --query 'AutoScalingGroups[0].AutoScalingGroupARN' \
  --output text)

aws ecs create-capacity-provider \
  --region $REGION \
  --name "cp-bia-v2" \
  --auto-scaling-group-provider "autoScalingGroupArn=$ASG_ARN_BIA,managedScaling={status=ENABLED,targetCapacity=100,minimumScalingStepSize=1,maximumScalingStepSize=10000,instanceWarmupPeriod=300},managedTerminationProtection=DISABLED,managedDraining=ENABLED"

echo "✓ Capacity Provider criado: cp-bia-v2"
echo ""

echo "5. Removendo Capacity Providers órfãos do cluster-bia..."

aws ecs put-cluster-capacity-providers \
  --region $REGION \
  --cluster cluster-bia \
  --capacity-providers FARGATE FARGATE_SPOT cp-bia-v2 \
  --default-capacity-provider-strategy "capacityProvider=cp-bia-v2,weight=1,base=0"

echo "✓ Capacity Providers atualizados no cluster-bia"
echo ""

# ==========================================
# CLUSTER-ALB-BIA (com ALB)
# ==========================================
echo "6. Criando Launch Template para cluster-alb-bia..."

USER_DATA_ALB=$(cat <<'EOF'
#!/bin/bash
echo ECS_CLUSTER=cluster-alb-bia >> /etc/ecs/ecs.config
EOF
)

aws ec2 create-launch-template \
  --region $REGION \
  --launch-template-name "lt-alb-bia-v2" \
  --version-description "Launch template for cluster-alb-bia" \
  --launch-template-data "{
    \"ImageId\": \"$AMI_ID\",
    \"InstanceType\": \"$INSTANCE_TYPE\",
    \"IamInstanceProfile\": {
      \"Name\": \"$IAM_INSTANCE_PROFILE\"
    },
    \"SecurityGroupIds\": [\"$SG_EC2\"],
    \"UserData\": \"$(echo "$USER_DATA_ALB" | base64 -w 0)\",
    \"TagSpecifications\": [{
      \"ResourceType\": \"instance\",
      \"Tags\": [
        {\"Key\": \"Name\", \"Value\": \"ecs-cluster-alb-bia\"},
        {\"Key\": \"Cluster\", \"Value\": \"cluster-alb-bia\"}
      ]
    }]
  }"

echo "✓ Launch Template criado: lt-alb-bia-v2"
echo ""

echo "7. Aguardando deleção do ASG anterior (se existir)..."
for i in {1..12}; do
  if aws autoscaling describe-auto-scaling-groups --region $REGION --auto-scaling-group-names asg-alb-bia-v2 2>&1 | grep -q "AutoScalingGroup not found"; then
    echo "✓ Pronto para criar novo ASG"
    break
  fi
  echo "  Aguardando... ($i/12)"
  sleep 5
done
echo ""

echo "8. Criando Auto Scaling Group para cluster-alb-bia..."

aws autoscaling create-auto-scaling-group \
  --region $REGION \
  --auto-scaling-group-name "asg-alb-bia-v2" \
  --launch-template "LaunchTemplateName=lt-alb-bia-v2,Version=\$Latest" \
  --min-size 1 \
  --max-size 3 \
  --desired-capacity 2 \
  --vpc-zone-identifier "$SUBNETS" \
  --health-check-type EC2 \
  --health-check-grace-period 300 \
  --tags "Key=Name,Value=ecs-cluster-alb-bia,PropagateAtLaunch=true" \
         "Key=Cluster,Value=cluster-alb-bia,PropagateAtLaunch=true"

echo "✓ Auto Scaling Group criado: asg-alb-bia-v2"
echo ""

echo "9. Criando Capacity Provider para cluster-alb-bia..."

# Buscar ARN do ASG
ASG_ARN_ALB=$(aws autoscaling describe-auto-scaling-groups \
  --region $REGION \
  --auto-scaling-group-names "asg-alb-bia-v2" \
  --query 'AutoScalingGroups[0].AutoScalingGroupARN' \
  --output text)

aws ecs create-capacity-provider \
  --region $REGION \
  --name "cp-alb-bia-v2" \
  --auto-scaling-group-provider "autoScalingGroupArn=$ASG_ARN_ALB,managedScaling={status=ENABLED,targetCapacity=100,minimumScalingStepSize=1,maximumScalingStepSize=10000,instanceWarmupPeriod=300},managedTerminationProtection=DISABLED,managedDraining=ENABLED"

echo "✓ Capacity Provider criado: cp-alb-bia-v2"
echo ""

echo "10. Removendo Capacity Providers órfãos do cluster-alb-bia..."

aws ecs put-cluster-capacity-providers \
  --region $REGION \
  --cluster cluster-alb-bia \
  --capacity-providers FARGATE FARGATE_SPOT cp-alb-bia-v2 \
  --default-capacity-provider-strategy "capacityProvider=cp-alb-bia-v2,weight=1,base=0"

echo "✓ Capacity Providers atualizados no cluster-alb-bia"
echo ""

echo "=========================================="
echo "CORREÇÃO CONCLUÍDA!"
echo "=========================================="
echo ""
echo "Próximos passos:"
echo "1. Aguarde 2-3 minutos para as instâncias EC2 iniciarem"
echo "2. Verifique se as instâncias foram registradas nos clusters:"
echo "   aws ecs list-container-instances --cluster cluster-bia"
echo "   aws ecs list-container-instances --cluster cluster-alb-bia"
echo ""
echo "3. Os serviços devem iniciar automaticamente as tasks"
echo ""
