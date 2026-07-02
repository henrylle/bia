# Regras de Infraestrutura - Projeto BIA

## Arquitetura Base
- **Plataforma:** ECS com cluster de instâncias EC2
- **Evolução:** Iniciar sem ALB → Evoluir para incluir ALB

## Tipos de Instância
- **RDS (Database):** t3.micro
- **EC2 (ECS Cluster) — Cenário 1 e 2:** t3.micro
- **EC2 (ECS Cluster) — Cenário 3 (awsvpc):** t3.small (necessário por conta do limite de ENIs no modo awsvpc)

## Filosofia de Simplicidade
- **Público-alvo:** Alunos em aprendizado
- **Abordagem:** Simplicidade acima de complexidade
- **Objetivo:** Facilitar compreensão de quem está na etapa inicial da jornada

## Recursos Avançados - NÃO INCLUIR
- **Secrets Manager:** É um estágio mais avançado do aprendizado
- **Multi-AZ deployments:** Manter configuração simples
- **Auto Scaling complexo:** Usar configurações básicas

## Availability Zones (Cenário com ALB)
- **Zonas utilizadas:** Apenas zona A e zona B da região
- **ALB:** Configurado nas subnets da zona A e zona B
- **EC2 (ECS):** 1 instância na zona A + 1 instância na zona B
- **Motivo:** Simplicidade para o aluno, alta disponibilidade mínima com 2 zonas e redução de custo com IPv4 público no ALB

## Padrão de Nomenclatura

### Prefixo Padrão
- **Prefixo:** `bia` (nome do projeto)

### Nomenclatura de Recursos ECS
- **Cluster com ALB:** `cluster-bia-alb`
- **Cluster sem ALB:** `cluster-bia`
- **Task Definition com ALB:** `task-def-bia-alb` (prefixo task-def e sufixo -alb)
- **Task Definition sem ALB:** `task-def-bia` (prefixo task-def)
- **Service:** `service-bia` (sem alb)
- **Service:** `service-bia-alb` (com alb)

### Configuração do Container (Task Definition)
- **Memory Soft Limit:** 400 MB
- **CPU:** 1 vCPU (1024 units)
- **Nota:** Configuração na área do container, NÃO na parte de Fargate/Task size

### Estratégia de Deploy (ECS Service)
- **Tipo:** Rolling Update
- **Minimum healthy percent:** 50%
- **Maximum percent:** 100%
- **AZ Rebalancing:** Desativado

### Target Group (ALB)
- **Deregistration Delay:** 30 segundos
- **Cenário 2 (com ALB):** `tg-bia-alb` — tipo instance
- **Cenário 3 (com ALB + Cache):** `tg-bia-app` — tipo ip (necessário para awsvpc)

### Sufixos dos Security Groups

#### Cenário 1: Sem ALB (Inicial)
- **Database (RDS):** `bia-db`
- **EC2 (ECS Cluster):** `bia-web`

#### Cenário 2: Com ALB (Evolução)
- **Database (RDS):** `bia-db`
- **Application Load Balancer:** `bia-alb`
- **EC2 (ECS Cluster):** `bia-ec2`

#### Cenário 3: Com ALB + Cache (Evolução com Cache)
- **Database (RDS):** `bia-db`
- **Application Load Balancer:** `bia-alb`
- **EC2 (ECS Cluster):** `bia-cluster`
- **Serviço da aplicação (ECS):** `bia-app`
- **Serviço de cache (ECS):** `bia-cache`

## Nomenclatura de Serviços ECS (Cenário 3: Com ALB + Cache)
- **Cluster:** `cluster-bia-app`
- **Serviço da aplicação:** `service-bia-app`
- **Serviço de cache:** `service-bia-cache`

### Network Mode (Cenário 3)
- **Modo:** `awsvpc` — cada task recebe ENI própria com IP privado dedicado
- **Impacto:** Security Groups aplicados diretamente na ENI da task, não na EC2
- **EC2 (bia-cluster):** inbound vazio — controle de acesso é feito nos SGs das tasks

### Service Discovery — Cache (Cenário 3)
- **Serviço:** `service-bia-cache` registrado no AWS Cloud Map
- **Acesso:** `service-bia-app` resolve o endereço do cache via DNS interno (Cloud Map)
- **Benefício:** Sem necessidade de hardcodar IP do cache como variável de ambiente
- **Alternativa possível:** Em vez de cache como serviço ECS, poderia ser utilizado o **Amazon ElastiCache** (Redis/Memcached gerenciado), que oferece alta disponibilidade e gerenciamento automático — porém é um estágio mais avançado do aprendizado

## Regras de Security Groups

### Padrão de Descrição das Inbound Rules
- **Formato obrigatório:** "acesso vindo de (nome do security group)"
- **Exemplo:** "acesso vindo de bia-dev"
- **Aplicação:** APENAS para inbound rules

### Database (bia-db)
**Inbound Rules:**
- **Porta:** 5432 (PostgreSQL)
- **Sources:** 
  - `bia-dev` → Descrição: "acesso vindo de bia-dev"
  - `bia-ec2` (quando com ALB) → Descrição: "acesso vindo de bia-ec2"
  - `bia-web` (quando sem ALB) → Descrição: "acesso vindo de bia-web"
  - `bia-app` (quando com ALB + Cache) → Descrição: "acesso vindo de bia-app"

### EC2 com ALB (bia-ec2)
**Inbound Rules:**
- **Protocolo:** All TCP
- **Source:** `bia-alb` → Descrição: "acesso vindo de bia-alb"
- **Motivo:** Portas aleatórias do ECS Service

### EC2 com ALB + Cache (bia-cluster)
**Inbound Rules:** nenhuma — controle de acesso feito nos SGs das tasks via awsvpc
**Outbound:** `0.0.0.0/0`

### Serviço da aplicação (bia-app) — Cenário 3
**Inbound Rules:**
- **Porta:** 8080
- **Source:** `bia-alb` → Descrição: "acesso vindo de bia-alb"

### Serviço de cache (bia-cache) — Cenário 3
**Inbound Rules:**
- **Porta:** 6379 (Redis)
- **Source:** `bia-app` → Descrição: "acesso vindo de bia-app"

### Application Load Balancer (bia-alb)
**Inbound Rules:**
- **Porta:** 80/443
- **Source:** 0.0.0.0/0 → Descrição: "acesso público HTTP/HTTPS"

## EC2 de Desenvolvimento (bia-dev)

### Configuração da Instância
- **Nome (Tag Name):** `bia-dev`
- **Tipo:** `t3.micro`
- **AMI:** Amazon Linux 2023 (última versão disponível)
- **Key Pair:** `bia-dev`
- **Security Group:** `bia-dev`
- **Região:** `us-east-1` (Virginia)
- **Subnet:** zona A (`us-east-1a`)
- **IP Público:** habilitado

### User Data
- **Script:** `scripts/user_data_ec2_zona_a.sh`
- **O script instala:**
  - Docker + Docker Compose v2.23.3
  - Git, jq
  - AWS CLI v2
  - Node.js 21.x + npm
  - Python 3.11 + uv (para MCP servers da AWS)
  - Swap de 4GB (128M × 32)
  - Adiciona `ec2-user` e `ssm-user` ao grupo `docker`

### Lançamento via AWS CLI (run-instances) — Regras Obrigatórias

#### User Data — passar sempre em base64 inline
- A AWS CLI **não aceita `file://`** para `--user-data` em ambientes restritos (ex: MCP/agentes)
- **Solução:** Encodar o script em base64 e passar o conteúdo diretamente no parâmetro
- **Comando para gerar:** `base64 -i scripts/user_data_ec2_zona_a.sh | tr -d '\n'`

## Banco de Dados
- **Aproveitamento:** Usar banco existente na infraestrutura
- **Não criar:** Novos recursos RDS nos templates
- **Security Group:** Manter `bia-db` preparado para conexão

### Observações
- As regras seguem o princípio de menor privilégio
- Security Groups referenciam outros Security Groups para maior flexibilidade
- Configuração permite evolução da arquitetura sem grandes mudanças
