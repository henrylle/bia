# Regras de Infraestrutura - Projeto BIA

## Arquitetura Base
- **Plataforma:** ECS com cluster de instâncias EC2
- **Evolução:** Iniciar sem ALB → Evoluir para incluir ALB

## Tipos de Instância
- **RDS (Database):** t3.micro
- **EC2 (ECS Cluster):** t3.micro

## Filosofia de Simplicidade
- **Público-alvo:** Alunos em aprendizado
- **Abordagem:** Simplicidade acima de complexidade
- **Objetivo:** Facilitar compreensão de quem está na etapa inicial da jornada

## Recursos Avançados - NÃO INCLUIR
- **Secrets Manager:** É um estágio mais avançado do aprendizado
- **Multi-AZ deployments:** Manter configuração simples
- **Auto Scaling complexo:** Usar configurações básicas

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

### Sufixos dos Security Groups

#### Cenário 1: Sem ALB (Inicial)
- **Database (RDS):** `bia-db`
- **EC2 (ECS Cluster):** `bia-web`

#### Cenário 2: Com ALB (Evolução)
- **Database (RDS):** `bia-db`
- **Application Load Balancer:** `bia-alb`
- **EC2 (ECS Cluster):** `bia-ec2`

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

### EC2 com ALB (bia-ec2)
**Inbound Rules:**
- **Protocolo:** All TCP
- **Source:** `bia-alb` → Descrição: "acesso vindo de bia-alb"
- **Motivo:** Portas aleatórias do ECS Service

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

## Banco de Dados
- **Aproveitamento:** Usar banco existente na infraestrutura
- **Não criar:** Novos recursos RDS nos templates
- **Security Group:** Manter `bia-db` preparado para conexão

### Observações
- As regras seguem o princípio de menor privilégio
- Security Groups referenciam outros Security Groups para maior flexibilidade
- Configuração permite evolução da arquitetura sem grandes mudanças
