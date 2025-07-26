# Regras de Infraestrutura - Projeto BIA

## Arquitetura Base
- **Plataforma:** ECS com cluster de instâncias EC2
- **Evolução:** Iniciar sem ALB → Evoluir para incluir ALB

## Tipos de Instância
- **RDS (Database):** t3.micro
- **EC2 (ECS Cluster):** t3.micro

## Padrão de Nomenclatura dos Security Groups

### Prefixo Padrão
- **Prefixo:** `bia` (nome do projeto)

### Sufixos por Componente

#### Cenário 1: Sem ALB (Inicial)
- **Database (RDS):** `bia-db`
- **EC2 (ECS Cluster):** `bia-web`

#### Cenário 2: Com ALB (Evolução)
- **Database (RDS):** `bia-db`
- **Application Load Balancer:** `bia-alb`
- **EC2 (ECS Cluster):** `bia-ec2`

## Regras de Security Groups

### Database (bia-db)
**Inbound Rules:**
- **Porta:** 5432 (PostgreSQL)
- **Sources:** 
  - `bia-dev` (ambiente de desenvolvimento)
  - `bia-ec2` (quando com ALB)
  - `bia-web` (quando sem ALB)

### EC2 com ALB (bia-ec2)
**Inbound Rules:**
- **Protocolo:** All TCP
- **Source:** `bia-alb`
- **Motivo:** Portas aleatórias do ECS Service

### Observações
- As regras seguem o princípio de menor privilégio
- Security Groups referenciam outros Security Groups para maior flexibilidade
- Configuração permite evolução da arquitetura sem grandes mudanças
