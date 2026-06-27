# N8N Queue Mode - Plano de Implementação

## Visão Geral

Evolução do n8n single mode para queue mode, adicionando Redis (ElastiCache Valkey) como
message broker e workers separados para processar execuções de workflows de forma escalável.

## Dados do Projeto

| Item | Valor |
|---|---|
| Região | us-east-2 |
| VPC | Default |
| Subnets | us-east-2a e us-east-2b |
| Imagem n8n | `n8nio/n8n:2.22.6` |
| Porta do container | 5678 |
| Domínio | `n8n.bia-aws.com.br` |
| Implementação | AWS CLI (profile: `n8n`) |

## Estado Inicial (o que sobreviveu da aula anterior)

| Recurso | Status |
|---|---|
| ACM `*.bia-aws.com.br` | ✅ ISSUED — não recriar |
| Route 53 `bia-aws.com.br` | ✅ Existe — não recriar |
| Todo o resto (SGs, RDS, ECS, ALB, ElastiCache) | ❌ Derrubado — recriar |

---

## Diagrama de Arquitetura

```
                         us-east-2
┌─────────────────────────────────────────────────────────────────────────────────┐
│                               AWS Cloud                                         │
│                                                                                 │
│  Route 53 ──► ALB (n8n-alb) ──► tg-n8n ──────────────────────────┐            │
│  n8n.bia-aws.com.br   HTTPS:443   HTTP:5678                       │            │
│                                                                    ▼            │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                    ECS Cluster (cluster-n8n)                            │   │
│  │                    EC2 t3.small (n8n-ec2)                               │   │
│  │                                                                         │   │
│  │   ┌──────────────────────────────────┐                                  │   │
│  │   │  service-n8n-main (desired: 1)   │                                  │   │
│  │   │  task-def-n8n-main               │                                  │   │
│  │   │  container: n8n (webhook+sched.) │◄─── ALB tg-n8n                  │   │
│  │   │  EXECUTIONS_MODE=queue           │                                  │   │
│  │   └───────────┬──────────────────────┘                                  │   │
│  │               │ publica execuções                                        │   │
│  │               ▼                                                          │   │
│  │   ┌──────────────────────────────────┐                                  │   │
│  │   │  ElastiCache Valkey              │                                  │   │
│  │   │  cache.t4g.micro ($9.34/mês)     │                                  │   │
│  │   │  porta: 6379                     │                                  │   │
│  │   └──────────┬───────────────────────┘                                  │   │
│  │              │ consome fila                                              │   │
│  │              ▼                                                           │   │
│  │   ┌──────────────────────────────────┐                                  │   │
│  │   │  service-n8n-worker (desired: 2) │                                  │   │
│  │   │  task-def-n8n-worker             │                                  │   │
│  │   │  ┌────────────┐ ┌────────────┐  │                                  │   │
│  │   │  │  worker w1 │ │  worker w2 │  │                                  │   │
│  │   │  └────────────┘ └────────────┘  │                                  │   │
│  │   └──────────────────────────────────┘                                  │   │
│  │                         │                                                │   │
│  └─────────────────────────┼────────────────────────────────────────────── ┘   │
│                            │ lê/escreve resultados                              │
│                            ▼                                                    │
│                   RDS PostgreSQL (n8n-db)                                       │
│                   db.t3.micro                                                   │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘

Security Groups:
  n8n-alb    ──► inbound 443 de 0.0.0.0/0
  n8n-ec2    ──► inbound All TCP de n8n-alb
  n8n-db     ──► inbound 5432 de n8n-ec2
  n8n-redis  ──► inbound 6379 de n8n-ec2

Fluxo de execução:
  User → Route53 → ALB → main (recebe trigger) → Redis (fila) → worker (executa) → RDS (salva resultado)
```

---

## Ordem de Dependências

```
.env → Security Groups (4x) → RDS → ElastiCache Valkey → ACM (já existe) →
ALB + TG + Listener → ECS Cluster + EC2 (ASG + LT) → CloudWatch Logs →
task-def-n8n-main → task-def-n8n-worker → service-n8n-main → service-n8n-worker → Route 53
```

---

## Etapa 1 — Preparação Local

- Criar pasta `n8n/` no projeto (se não existir)
- Gerar `N8N_ENCRYPTION_KEY` (32 bytes hex) e senha do banco
- Criar/atualizar arquivo `n8n/.env`:

```bash
DB_PASSWORD=<senha_gerada>
N8N_ENCRYPTION_KEY=<chave_hex_32bytes>
```

> ⚠️ `N8N_ENCRYPTION_KEY` é obrigatório no queue mode. Main e workers DEVEM usar a mesma chave
> para que os workers consigam descriptografar as credenciais salvas no banco.

Gerar a chave:
```bash
openssl rand -hex 32
```

---

## Etapa 1.5 — SSM Parameter Store ⭐ NOVO

Armazenar as variáveis sensíveis no SSM Parameter Store (SecureString) para não expô-las
como texto plano nas task definitions.

| Parâmetro SSM | Variável | Tipo |
|---|---|---|
| `/n8n/DB_POSTGRESDB_PASSWORD` | Senha do RDS | SecureString |
| `/n8n/N8N_ENCRYPTION_KEY` | Chave de criptografia | SecureString |

```bash
aws ssm put-parameter --name /n8n/DB_POSTGRESDB_PASSWORD --value <senha> --type SecureString --region us-east-2
aws ssm put-parameter --name /n8n/N8N_ENCRYPTION_KEY --value <chave> --type SecureString --region us-east-2
```

### IAM — ecsTaskExecutionRole
Adicionar inline policy `n8n-ssm-access` na `ecsTaskExecutionRole`:
- `ssm:GetParameters` em `arn:aws:ssm:us-east-2:<account>:parameter/n8n/*`
- `kms:Decrypt` para descriptografar SecureStrings

### Referência nas Task Definitions
Usar o campo `secrets` (não `environment`) nas task definitions:
```json
"secrets": [
  {"name": "DB_POSTGRESDB_PASSWORD", "valueFrom": "arn:aws:ssm:us-east-2:<account>:parameter/n8n/DB_POSTGRESDB_PASSWORD"},
  {"name": "N8N_ENCRYPTION_KEY",     "valueFrom": "arn:aws:ssm:us-east-2:<account>:parameter/n8n/N8N_ENCRYPTION_KEY"}
]
```
Aplicar em **ambas** as task definitions: `task-def-n8n-main` e `task-def-n8n-worker`.

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

### 2.4 — n8n-redis ⭐ NOVO
| Protocolo | Porta | Source | Descrição |
|---|---|---|---|
| TCP | 6379 | n8n-ec2 | acesso vindo de n8n-ec2 |

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

## Etapa 4 — ElastiCache Valkey ⭐ NOVO

| Item | Valor |
|---|---|
| Cluster ID | n8n-redis |
| Engine | valkey |
| Versão | 8.0 |
| Node Type | cache.t4g.micro |
| Número de Nodes | 1 |
| Security Group | n8n-redis |
| Subnet Group | subnets us-east-2a e us-east-2b |
| Multi-AZ | Não |
| Preço | $0.0128/hr (~$9.34/mês) |

> ✅ `cache.t4g.micro` é a menor instância disponível para Valkey e ~6% mais barata que `cache.t3.micro`
> ($0.0128/hr vs $0.0136/hr). Ambas são suportadas pelo Valkey.

---

## Etapa 5 — ACM (Certificate Manager)

| Item | Valor |
|---|---|
| Domínio | *.bia-aws.com.br |
| Status | ✅ ISSUED — já existe, não recriar |
| ARN | arn:aws:acm:us-east-1:310189683227:certificate/9c154648-89a1-458a-b078-606d31dabcd5 |

---

## Etapa 6 — ALB + Target Group

### 6.1 — Target Group: `tg-n8n`
| Item | Valor |
|---|---|
| Protocolo | HTTP |
| Porta | 5678 |
| Target Type | instance |
| Health Check Path | /healthz |
| Health Check Protocol | HTTP |
| Deregistration Delay | 30 segundos |

### 6.2 — ALB
| Item | Valor |
|---|---|
| Nome | n8n-alb |
| Scheme | internet-facing |
| Subnets | us-east-2a, us-east-2b |
| Security Group | n8n-alb |

### 6.3 — Listener
| Item | Valor |
|---|---|
| Porta | 443 |
| Protocolo | HTTPS |
| Certificado | *.bia-aws.com.br (ACM) |
| Default Action | Forward → tg-n8n |

---

## Etapa 7 — ECS Cluster + EC2

| Item | Valor |
|---|---|
| Cluster | cluster-n8n |
| Capacity Provider | cp-n8n (vinculado ao ASG) |

### 7.1 — Launch Template: `lt-n8n`
| Item | Valor |
|---|---|
| Instância | t3.small ⭐ (era t3.micro — precisa de mais memória para 3 containers) |
| AMI | ECS-optimized Amazon Linux 2023 (SSM: `/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id`) |
| Security Group | n8n-ec2 |
| IAM Instance Profile | ecsInstanceRole |
| User Data | Registrar no cluster-n8n |
| Tag | Name=ecs-n8n |

### 7.2 — Auto Scaling Group: `asg-n8n`
| Item | Valor |
|---|---|
| Launch Template | lt-n8n |
| Min | 1 |
| Max | 1 |
| Desired | 1 |
| Subnets | us-east-2a, us-east-2b |

### 7.3 — Capacity Provider: `cp-n8n`
| Item | Valor |
|---|---|
| ASG | asg-n8n |
| Managed Scaling | Disabled |
| Managed Termination Protection | Disabled |

---

## Etapa 8 — CloudWatch Logs

| Item | Valor |
|---|---|
| Log Group (main) | /ecs/n8n-main |
| Log Group (worker) | /ecs/n8n-worker |
| Região | us-east-2 |

---

## Etapa 9 — Task Definition: Main ⭐ ATUALIZADA

| Item | Valor |
|---|---|
| Family | task-def-n8n-main |
| Network Mode | bridge |
| Requires Compatibilities | EC2 |

### Container: n8n
| Item | Valor |
|---|---|
| Image | n8nio/n8n:2.22.6 |
| Memory Soft Limit | 650 MB |
| Port Mapping | hostPort: 0, containerPort: 5678 |
| Log Group | /ecs/n8n-main |

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
| **EXECUTIONS_MODE** | **queue** ⭐ NOVO |
| **N8N_ENCRYPTION_KEY** | **(valor do .env)** ⭐ NOVO |
| **QUEUE_BULL_REDIS_HOST** | **(endpoint ElastiCache)** ⭐ NOVO |
| **QUEUE_BULL_REDIS_PORT** | **6379** ⭐ NOVO |

---

## Etapa 10 — Task Definition: Worker ⭐ NOVA

| Item | Valor |
|---|---|
| Family | task-def-n8n-worker |
| Network Mode | bridge |
| Requires Compatibilities | EC2 |

### Container: n8n-worker
| Item | Valor |
|---|---|
| Image | n8nio/n8n:2.22.6 |
| Memory Soft Limit | 300 MB |
| Command | `["worker"]` |
| Port Mapping | nenhum (workers não recebem tráfego HTTP) |
| Log Group | /ecs/n8n-worker |

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
| EXECUTIONS_MODE | queue |
| N8N_ENCRYPTION_KEY | (valor do .env — MESMO DO MAIN) |
| QUEUE_BULL_REDIS_HOST | (endpoint ElastiCache) |
| QUEUE_BULL_REDIS_PORT | 6379 |

---

## Etapa 11 — ECS Services

### 11.1 — service-n8n-main
| Item | Valor |
|---|---|
| Service Name | service-n8n-main |
| Cluster | cluster-n8n |
| Task Definition | task-def-n8n-main |
| Desired Count | 1 |
| Load Balancer | ALB → tg-n8n |
| Container Name | n8n |
| Container Port | 5678 |
| Deployment Min Healthy | 0% |
| Deployment Max | 100% |
| AZ Rebalancing | DISABLED |

### 11.2 — service-n8n-worker ⭐ NOVO
| Item | Valor |
|---|---|
| Service Name | service-n8n-worker |
| Cluster | cluster-n8n |
| Task Definition | task-def-n8n-worker |
| Desired Count | 2 |
| Load Balancer | nenhum |
| Deployment Min Healthy | 0% |
| Deployment Max | 100% |
| AZ Rebalancing | DISABLED |

---

## Etapa 12 — Route 53

| Item | Valor |
|---|---|
| Hosted Zone | bia-aws.com.br (ID: Z00684123Q7EMJ9D1M9I) — já existe |
| Record | n8n.bia-aws.com.br |
| Type | A (Alias) |
| Target | ALB DNS Name |

---

## Resumo de Custos (estimativa mensal)

| Recurso | Tipo | Custo/mês |
|---|---|---|
| EC2 t3.small (ECS) | ~$15.18/mês | |
| RDS db.t3.micro | ~$13.10/mês | |
| ElastiCache cache.t4g.micro (Valkey) | $9.34/mês | |
| ALB | ~$18.00/mês (base) | |
| **Total estimado** | | **~$55/mês** |

---

## Validação Final

1. Acessar `https://n8n.bia-aws.com.br` → tela do n8n (servida pelo main)
2. Login com conta admin
3. Criar workflow simples com trigger manual
4. Verificar nos logs `/ecs/n8n-worker` que o worker processou a execução
5. Confirmar no n8n UI que a execução aparece como concluída
