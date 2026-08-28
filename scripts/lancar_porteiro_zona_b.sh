#!/usr/bin/env bash
set -euo pipefail

# =========================================================
# Lança o "porteiro" (bastion host) na zona B.
#
# O porteiro não roda a aplicação, não guarda nada — a única função dele
# é existir dentro da VPC pra servir de ponte de um túnel SSM até recursos
# privados (RDS, a instância da bia) que seu notebook nunca alcança direto.
#
# Baseado no mesmo padrão de scripts/lancar_ec2_zona_a.sh, com 2 diferenças:
#   1. Zona B em vez de zona A (subnet default da us-east-1b)
#   2. Dois Security Groups anexados: bia-dev (base, sem porta pública
#      necessária) + bia-web-sg — porque o RDS só aceita conexão de quem
#      está no bia-web-sg (ver docs/desafio-4-porteiro-rds-orientacao.md,
#      seção 4). Sem o bia-web-sg, o túnel pro RDS trava sem erro nenhum.
#
# Uso: ./scripts/lancar_porteiro_zona_b.sh
# =========================================================

REGION="us-east-1"
AMI_ID="ami-02f3f602d23f1659d"   # mesma AMI usada pela bia-dev, já tem o agente SSM
STATE_FILE=".porteiro_instance_id"

vpc_id=$(aws ec2 describe-vpcs --region "$REGION" \
  --filters Name=isDefault,Values=true \
  --query "Vpcs[0].VpcId" --output text)

subnet_id=$(aws ec2 describe-subnets --region "$REGION" \
  --filters Name=vpc-id,Values="$vpc_id" Name=availabilityZone,Values=us-east-1b \
  --query "Subnets[0].SubnetId" --output text)

sg_bia_dev=$(aws ec2 describe-security-groups --region "$REGION" \
  --group-names "bia-dev" --query "SecurityGroups[0].GroupId" --output text 2>/dev/null)

sg_bia_web=$(aws ec2 describe-security-groups --region "$REGION" \
  --group-names "bia-web-sg" --query "SecurityGroups[0].GroupId" --output text 2>/dev/null)

if [ -z "$sg_bia_dev" ] || [ -z "$sg_bia_web" ]; then
    echo ">[ERRO] Security group bia-dev ou bia-web-sg não encontrado na VPC $vpc_id"
    exit 1
fi

echo "Lançando porteiro na subnet $subnet_id (zona B), com SGs $sg_bia_dev + $sg_bia_web..."

instance_id=$(aws ec2 run-instances --region "$REGION" \
  --image-id "$AMI_ID" --count 1 --instance-type t3.micro \
  --security-group-ids "$sg_bia_dev" "$sg_bia_web" \
  --subnet-id "$subnet_id" --associate-public-ip-address \
  --block-device-mappings '[{"DeviceName":"/dev/xvda","Ebs":{"VolumeSize":15,"VolumeType":"gp2"}}]' \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=bia-porteiro}]' \
  --iam-instance-profile Name=role-acesso-ssm \
  --query "Instances[0].InstanceId" --output text)

# Diferente do lancar_ec2_zona_a.sh original: aqui SEMPRE checamos se o
# run-instances de fato devolveu um ID antes de seguir (ver seção 15 do
# aws_cli_conhecimento.md — essa checagem estava faltando no script original).
if [ -z "$instance_id" ] || [ "$instance_id" == "None" ]; then
    echo ">[ERRO] run-instances não retornou um InstanceId — o lançamento falhou."
    exit 1
fi

echo "Porteiro lançado: $instance_id"
echo "Aguardando ficar 'running' (pode levar até ~1 min)..."
aws ec2 wait instance-running --region "$REGION" --instance-ids "$instance_id"

echo "$instance_id" > "$STATE_FILE"
echo "OK. ID salvo em $STATE_FILE — os outros scripts (tunel_rds.sh, tunel_bia.sh, parar_porteiro.sh) leem esse arquivo."
echo "Espere ~30-60s a mais pro agente SSM registrar antes de abrir um túnel."
echo "Pra conferir: aws ssm describe-instance-information --region $REGION --filters \"Key=InstanceIds,Values=$instance_id\""
