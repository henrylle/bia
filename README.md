# 🚀 MeddiFlux Systems — Modernização da Arquitetura AWS

![AWS](https://img.shields.io/badge/AWS-Cloud-%23FF9900.svg?style=for-the-badge&logo=amazonaws&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Containers-%232496ED.svg?style=for-the-badge&logo=docker&logoColor=white)
![ECS](https://img.shields.io/badge/Amazon%20ECS-Fargate-%23FF9900.svg?style=for-the-badge&logo=amazonecs&logoColor=white)
![ECR](https://img.shields.io/badge/Amazon%20ECR-Registry-%23232F3E.svg?style=for-the-badge&logo=amazonaws&logoColor=white)
![S3](https://img.shields.io/badge/Amazon%20S3-Storage-%23569A31.svg?style=for-the-badge&logo=amazons3&logoColor=white)
![IAM](https://img.shields.io/badge/AWS%20IAM-Security-%23DD344C.svg?style=for-the-badge&logo=amazoniam&logoColor=white)
![CloudWatch](https://img.shields.io/badge/CloudWatch-Logs%2FMetrics-%23FF4F8B.svg?style=for-the-badge&logo=amazoncloudwatch&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white)

---

## 📌 Visão Geral

Este repositório documenta a **modernização da arquitetura AWS da MeddiFlux Systems**, aplicando **Cloud/DevOps, Segurança (Security by Design) e FinOps**, com foco em:

- 💸 Redução de custos operacionais
- ⚙️ Escalabilidade, automação e eficiência
- 🔐 Segurança, governança e mitigação de riscos
- 🎓 Aprendizado prático com arquitetura baseada em cenário real

A iniciativa é voltada para **uso acadêmico e profissional**, com documentação objetiva, evidências técnicas e racional arquitetural claro.

---

## 🎯 Objetivos do Projeto

- Modernizar a arquitetura legada para **containers em ECS Fargate**
- Automatizar **CI/CD por ambiente (DEV, HOM, PROD)**
- Garantir **segurança por padrão** (Least Privilege, Secrets, auditoria)
- Aplicar **FinOps** para controle e otimização de custos
- Manter um **roadmap evolutivo, rastreável e explicável**

---

## 🧩 Visão Geral da Arquitetura

### Ambientes isolados

- **DEV:** desenvolvimento contínuo e testes
- **HOM:** validação funcional (uso controlado – 220h/mês)
- **PROD:** alta disponibilidade, escalabilidade e segurança reforçada

### Componentes principais

- **VPC + Subnets + Security Groups:** isolamento de rede por ambiente
- **ECS Fargate:** execução de containers sem gestão de servidores
- **ECR:** versionamento e armazenamento de imagens Docker
- **ALB:** balanceamento de carga para as aplicações
- **RDS Multi-AZ:** persistência de dados com alta disponibilidade
- **S3 (Infra & Conteúdo):**
  - armazenamento de artefatos (ex.: frontend estático, evidências, exports)
  - suporte a estados/artefatos de infraestrutura quando aplicável
- **CloudFront + S3 (conteúdo estático):** cache e distribuição global (quando usado)
- **CloudWatch:** observabilidade da infraestrutura e aplicações, permitindo monitoramento de métricas, logs, alarmes e eventos para garantir desempenho, disponibilidade e resposta a incidentes.


---

## 🏗️ Stack Tecnológica

| Categoria              | Tecnologia                                |
|------------------------|-------------------------------------------|
| Cloud                  | AWS                                       |
| Containers             | Docker                                    |
| Orquestração           | ECS Fargate                               |
| Registry               | Amazon ECR                                |
| Storage (Infra/Assets) | Amazon S3                                 |                             |
| CI/CD                  | GitHub Actions                            |
| Observabilidade        | CloudWatch                                |
| Auditoria              | CloudTrail                                |
| Segurança              | IAM, Secrets Manager                      |
| CDN                    | CloudFront (quando aplicável)             |
| Banco de Dados         | RDS (PostgreSQL / SQL Server)             |

---

