# N8N HA Single Mode - Plano de Implementação

## Visão Geral

Deploy do n8n na AWS usando ECS com instâncias EC2, ALB com HTTPS e RDS PostgreSQL.

## Dados do Projeto

| Item | Valor |
|---|---|
| Região | us-east-2 |
| VPC | Default |
| Subnets | us-east-2a e us-east-2b |
| Imagem | `n8nio/n8n:2.22.6` (Docker Hub) |
| Porta do container | 5678 |
| Domínio | `n8n.bia-aws.com.br` |
| Implementação | AWS CLI (profile: `n8n`) |

---

## Etapa 1 — Preparação Local

- Criar pasta `n8n/` no projeto
- Gerar senha do banco e criar arquivo `n8n/.env` com a variável `DB_PASSWORD`

---

## Etapa 2 — Security Groups

### 2.1 — n8n-alb
| Protocolo | Porta | Source | Descrição |
|---|---|---|---|
| TCP | 443 | 0.0.0.0/0 | acesso público HTTPS |

### 2.2 — n8n-ec2
| Protocolo | Porta | Source | Descrição |
|---|---|---|---|
| All TCP | 0-65535 | n8n-alb | acesso vindo de n8n-alb |

### 2.3 — n8n-db
| Protocolo | Porta | Source | Descrição |
|---|---|---|---|
| TCP | 5432 | n8n-ec2 | acesso vindo de n8n-ec2 |

---

## Etapa 3 — RDS PostgreSQL

| Item | Valor |
|---|---|
| DB Instance Identifier | n8n |
| Engine | PostgreSQL |
| Classe | db.t3.micro |
| Storage | 20 GB (gp2) |
| Backup Retention | 0 (desabilitado) |
| DB Name | n8n |
| Master Username | n8n |
| Master Password | (valor do .env) |
| Security Group | n8n-db |
| Multi-AZ | Não |
| Subnets | us-east-2a, us-east-2b |
| Public Access | Não |

---

## Etapa 4 — ACM (Certificate Manager)

| Item | Valor |
|---|---|
| Domínio | *.bia-aws.com.br |
| Validação | DNS (Route 53) |

---

## Etapa 5 — ALB + Target Group

### 5.1 — Target Group: `tg-n8n`
| Item | Valor |
|---|---|
| Protocolo | HTTP |
| Porta | 5678 |
| Target Type | instance |
| Health Check Path | /healthz |
| Health Check Protocol | HTTP |
| Deregistration Delay | 30 segundos |

### 5.2 — ALB
| Item | Valor |
|---|---|
| Nome | n8n-alb |
| Scheme | internet-facing |
| Subnets | us-east-2a, us-east-2b |
| Security Group | n8n-alb |

### 5.3 — Listener
| Item | Valor |
|---|---|
| Porta | 443 |
| Protocolo | HTTPS |
| Certificado | *.bia-aws.com.br (ACM) |
| Default Action | Forward → tg-n8n |

---

## Etapa 6 — ECS Cluster + EC2 (ASG + Launch Template)

| Item | Valor |
|---|---|
| Cluster | cluster-n8n |
| Capacity Provider | cp-n8n (vinculado ao ASG) |

### 6.1 — Launch Template: `lt-n8n`
| Item | Valor |
|---|---|
| Instância | t3.micro |
| AMI | ECS-optimized Amazon Linux 2023 (via SSM: `/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id`) |
| Security Group | n8n-ec2 |
| IAM Instance Profile | ecsInstanceRole |
| User Data | Registrar no cluster-n8n |
| Tag | Name=ecs-n8n |

### 6.2 — Auto Scaling Group: `asg-n8n`
| Item | Valor |
|---|---|
| Launch Template | lt-n8n |
| Min | 1 |
| Max | 1 |
| Desired | 1 |
| Subnets | us-east-2a, us-east-2b |

### 6.3 — Capacity Provider: `cp-n8n`
| Item | Valor |
|---|---|
| ASG | asg-n8n |
| Managed Scaling | Disabled |
| Managed Termination Protection | Disabled |

---

## Etapa 7 — CloudWatch Logs

| Item | Valor |
|---|---|
| Log Group | /ecs/n8n |
| Região | us-east-2 |

---

## Etapa 8 — Task Definition

| Item | Valor |
|---|---|
| Family | task-def-n8n |
| Network Mode | bridge |
| Requires Compatibilities | EC2 |

### Container: n8n
| Item | Valor |
|---|---|
| Image | n8nio/n8n:2.22.6 |
| Memory Soft Limit (memoryReservation) | 650 MB |
| Port Mapping | hostPort: 0, containerPort: 5678 |
| Log Driver | awslogs |
| Log Group | /ecs/n8n |
| Log Stream Prefix | n8n |

### Variáveis de Ambiente
| Variável | Valor |
|---|---|
| DB_TYPE | postgresdb |
| DB_POSTGRESDB_HOST | (endpoint RDS) |
| DB_POSTGRESDB_PORT | 5432 |
| DB_POSTGRESDB_DATABASE | n8n |
| DB_POSTGRESDB_USER | n8n |
| DB_POSTGRESDB_PASSWORD | (valor do .env) |
| DB_POSTGRESDB_SSL_ENABLED | true |
| DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED | false |
| N8N_HOST | n8n.bia-aws.com.br |
| N8N_PROTOCOL | https |
| WEBHOOK_URL | https://n8n.bia-aws.com.br/ |

---

## Etapa 9 — ECS Service

| Item | Valor |
|---|---|
| Service Name | service-n8n |
| Cluster | cluster-n8n |
| Task Definition | task-def-n8n |
| Desired Count | 1 |
| Load Balancer | ALB → tg-n8n |
| Container Name | n8n |
| Container Port | 5678 |
| Deployment Min Healthy | 0% |
| Deployment Max | 100% |
| AZ Rebalancing | DISABLED |

---

## Etapa 10 — Route 53

| Item | Valor |
|---|---|
| Record | n8n.bia-aws.com.br |
| Type | A (Alias) |
| Target | ALB DNS Name |
| Hosted Zone | bia-aws.com.br (existente) |

---

## Ordem de Dependências

```
.env → Security Groups → RDS → ACM → ALB + TG + Listener → ECS Cluster + EC2 → CloudWatch Logs → Task Def → Service → Route 53
```

---

## Validação Final

1. Acessar `https://n8n.bia-aws.com.br`
2. Verificar tela de setup inicial do n8n
3. Confirmar conectividade com banco via criação de conta admin
