# Relatório da Aplicação BIA no Amazon ECS

**Data:** 22/02/2026  
**Versão da Aplicação:** 4.2.0  
**URL de Acesso:** http://52.90.110.147

---

## 1. ARQUITETURA IMPLEMENTADA

A aplicação BIA está rodando em uma arquitetura **ECS com instâncias EC2** (sem Application Load Balancer), seguindo o modelo de simplicidade para fins educacionais.

---

## 2. CLUSTER ECS

**Nome do Cluster:** cluster-bia  
**Status:** ACTIVE  
**Instâncias EC2:** 1  
**Tasks Rodando:** 1  
**Serviços Ativos:** 1

**ARN do Cluster:**
```
arn:aws:ecs:us-east-1:794038217446:cluster/cluster-bia
```

---

## 3. SERVIÇO ECS

**Nome do Serviço:** service-bia  
**Cluster:** cluster-bia  
**Task Definition:** task-def-bia:16  
**Status:** ACTIVE  
**Desired Count:** 1  
**Running Count:** 1  
**Launch Type:** EC2

**ARN do Serviço:**
```
arn:aws:ecs:us-east-1:794038217446:service/cluster-bia/service-bia
```

---

## 4. TASK DEFINITION

**Nome:** task-def-bia  
**Revisão Atual:** 16  
**Network Mode:** bridge  
**CPU:** 1024  
**Memory:** 410 MB

### Port Mapping (Comprovação da Porta 80)

| Container Port | Host Port | Protocol |
|----------------|-----------|----------|
| 8080           | **80**    | tcp      |

**Explicação:** O container escuta na porta 8080 internamente, mas é exposto na porta 80 do host (instância EC2).

### Variáveis de Ambiente (Conexão RDS)

| Nome     | Valor                                          |
|----------|------------------------------------------------|
| DB_HOST  | bia-db.c4zy4cykm0n7.us-east-1.rds.amazonaws.com |
| DB_PORT  | 5432                                           |
| DB_USER  | postgres                                       |
| DB_PWD   | Ajkluj65z3s3GLCI5CIY                           |

---

## 5. TASK EM EXECUÇÃO

**Task ARN:**
```
arn:aws:ecs:us-east-1:794038217446:task/cluster-bia/5a8e793c654241ce9a2d0a96abdd404d
```

**Status:** RUNNING  
**Health Status:** UNKNOWN  
**Criada em:** 2026-02-22T23:24:16

---

## 6. INSTÂNCIA EC2 (Container Instance)

### Por que o IP 52.90.110.147?

A aplicação está acessível neste IP porque:
1. A task está rodando em uma instância EC2 do cluster ECS
2. O port mapping está configurado como `hostPort: 80`
3. A instância EC2 tem um IP público: **52.90.110.147**

### Detalhes da Instância

| Instance ID        | IP Público     | IP Privado     | Status  |
|--------------------|----------------|----------------|---------|
| i-0201766e8bb78bbd5 | **52.90.110.147** | 172.31.82.196  | running |

### Security Group: bia-web (sg-04721b37b7a06da28)

**Inbound Rules - Comprovação da Porta 80:**

| Protocol | Port | Source      | Descrição                    |
|----------|------|-------------|------------------------------|
| TCP      | **80** | 0.0.0.0/0   | Acesso HTTP público          |

**Outbound Rules:**
- All traffic para 0.0.0.0/0 (permite conexão com RDS)

---

## 7. BANCO DE DADOS RDS

**Identificador:** bia-db  
**Status:** available  
**Endpoint:** bia-db.c4zy4cykm0n7.us-east-1.rds.amazonaws.com  
**Porta:** 5432  
**Engine:** postgres  
**Classe:** db.t3.micro

### Security Group: bia-db (sg-04eb26de8b00feb9b)

**Inbound Rules - Porta 5432:**

| Source Security Group    | Descrição           |
|--------------------------|---------------------|
| sg-04721b37b7a06da28 (bia-web) | acesso bia-web      |
| sg-01cf577e0933cffe6 (bia-dev) | acesso do bia-dev   |

**Comprovação:** O security group `bia-web` (da instância EC2) tem permissão para acessar o RDS na porta 5432.

---

## 8. TESTES DE CONECTIVIDADE

### Teste 1: Health Check (sem banco de dados)
```bash
$ curl http://52.90.110.147/api/versao
Bia 4.2.0
```
✅ **Status:** 200 OK

### Teste 2: API com Banco de Dados
```bash
$ curl http://52.90.110.147/api/tarefas
[]
```
✅ **Status:** 200 OK (retorna array vazio - banco conectado)

### Teste 3: Logs da Aplicação
```
2026-02-22T23:24:32 Servidor rodando na porta 8080
2026-02-22T23:25:20 Executing (default): SELECT "uuid", "titulo", "dia_atividade", "importante", "createdAt", "updatedAt" FROM "Tarefas" AS "Tarefas";
```
✅ **Comprovação:** Query SQL executada com sucesso no RDS

---

## 9. DIAGRAMA DA ARQUITETURA

```
┌─────────────────────────────────────────────────────────────┐
│                    INTERNET (0.0.0.0/0)                     │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTP (porta 80)
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              EC2 Instance (52.90.110.147)                   │
│              Security Group: bia-web                        │
│  ┌───────────────────────────────────────────────────────┐  │
│  │         ECS Task (task-def-bia:16)                    │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │   Container: bia                                │  │  │
│  │  │   Port Mapping: 80 → 8080                       │  │  │
│  │  │   Image: ECR bia:latest                         │  │  │
│  │  └─────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────┘  │
└────────────────────────┬────────────────────────────────────┘
                         │ PostgreSQL (porta 5432)
                         ▼
┌─────────────────────────────────────────────────────────────┐
│         RDS PostgreSQL (bia-db.c4zy4cykm0n7...)             │
│         Security Group: bia-db                              │
│         Database: bia-db                                    │
└─────────────────────────────────────────────────────────────┘
```

---

## 10. FLUXO DE REQUISIÇÃO

1. **Usuário** acessa http://52.90.110.147
2. **Requisição** chega na porta 80 da instância EC2 (i-0201766e8bb78bbd5)
3. **Security Group bia-web** permite tráfego na porta 80
4. **Port Mapping** redireciona porta 80 → 8080 do container
5. **Container** processa a requisição (Node.js/Express)
6. **Aplicação** conecta no RDS via porta 5432
7. **Security Group bia-db** permite conexão do bia-web
8. **RDS** retorna dados para o container
9. **Container** retorna resposta para o usuário

---

## 11. CONCLUSÃO

### ✅ Comprovações Realizadas

| Componente       | Status | Comprovação                                    |
|------------------|--------|------------------------------------------------|
| **Cluster ECS**  | ✅ ACTIVE | cluster-bia com 1 instância e 1 task rodando |
| **Service ECS**  | ✅ ACTIVE | service-bia com 1/1 tasks (desired=running)   |
| **Task Definition** | ✅ Revisão 16 | Port mapping 80→8080 configurado           |
| **Task Rodando** | ✅ RUNNING | Task ativa desde 23:24:16                     |
| **Instância EC2** | ✅ running | IP público 52.90.110.147                     |
| **Porta 80**     | ✅ Exposta | Security group permite 0.0.0.0/0:80          |
| **RDS**          | ✅ available | bia-db conectado e respondendo queries       |
| **Conectividade** | ✅ OK | API retorna 200 OK em ambos endpoints         |

### 📍 Por que o IP 52.90.110.147?

**Resposta:** A aplicação está acessível neste IP porque:
- É o **IP público da instância EC2** (i-0201766e8bb78bbd5) que hospeda o container ECS
- O **port mapping da task definition** expõe a porta 80 do host (hostPort: 80)
- O **security group bia-web** permite tráfego HTTP (porta 80) de qualquer origem (0.0.0.0/0)
- O **ECS em modo bridge** usa a rede do host, expondo diretamente a porta 80

### 🎯 Arquitetura Validada

A aplicação BIA está rodando com sucesso em uma arquitetura ECS simplificada:
- ✅ 1 Cluster ECS
- ✅ 1 Service gerenciando a aplicação
- ✅ 1 Task Definition (revisão 16)
- ✅ 1 Task rodando em 1 instância EC2
- ✅ 1 RDS PostgreSQL conectado
- ✅ Porta 80 exposta publicamente
- ✅ Aplicação 100% funcional
