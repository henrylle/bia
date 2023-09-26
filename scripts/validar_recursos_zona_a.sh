vpc_id=$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true --query "Vpcs[0].VpcId" --output text 2>/dev/null)
if [ $? -eq 0 ]; then
  echo "[OK] Tudo certo com a VPC"
else
  echo "[ERRO] Tenho um problema ao retornar a VPC default. Será se ela existe?"
fi

subnet_id=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$vpc_id Name=availabilityZone,Values=us-east-1a --query "Subnets[0].SubnetId" --output text 2>/dev/null)
if [ $? -eq 0 ]; then
  echo "[OK] Tudo certo com a Subnet"
else
  echo "[ERRO] Tenho um problema ao retornar a subnet da zona a. Será se existe uma subnet na zona A?"
fi

security_group_id=$(aws ec2 describe-security-groups --group-names "bia-dev" --query "SecurityGroups[0].GroupId" --output text 2>/dev/null)
if [ $? -eq 0 ]; then
  echo "[OK] Tudo certo com o Security Group"
else
  echo "[ERRO] Não achei o security group bia-dev. Ele foi criado?"
fi

if aws iam get-role --role-name role-acesso-ssm &>/dev/null; then
    echo "[OK] Tudo certo com a role 'role-acesso-ssm'"
else
    echo "[ERRO] A role 'role-acesso-ssm' não existe"
fi
