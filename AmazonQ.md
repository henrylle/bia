# Projeto BIA - Contexto e Análise

## Visão Geral do Projeto
**Nome:** BIA  
**Versão:** 3.2.0  
**Período do Bootcamp:** 28/07 a 03/08/2025 (Online e ao Vivo às 20h)  
**Repositório:** https://github.com/henrylle/bia

## Impressões Iniciais do Desenvolvedor
O projeto da BIA é um projeto educacional criado pelo Henrylle Maia (@henryllemaia) para ser usado nos eventos que ele realiza e servir de base para o treinamento Formação AWS.

É um projeto concebido no ano de 2021 e que vem evoluindo usando as melhores práticas dentro da AWS.

O foco base dele é fornecer uma estrutura educacional em que o aluno possa evoluir gradualmente, desde problemas simples até situações mais complexas.


---

## Análise Técnica (Amazon Q)

### Arquitetura Identificada
- **Frontend:** React 17.0.2 com Vite para build
- **Backend:** Node.js com Express 4.17.1
- **Banco de Dados:** PostgreSQL 16.1
- **ORM:** Sequelize 6.6.5
- **Containerização:** Docker com Docker Compose

### Stack Tecnológica
**Frontend:**
- React com React Router DOM
- React Icons para ícones
- Vite como bundler (configurado no Dockerfile)

**Backend:**
- Express.js como framework web
- Sequelize como ORM
- Morgan para logging
- CORS habilitado
- Express Session para gerenciamento de sessões
- EJS e HBS como template engines

**Infraestrutura:**
- Docker containerizado
- AWS SDK integrado (Secrets Manager, STS)
- PostgreSQL como banco principal
- Suporte a variáveis de ambiente

### Estrutura do Projeto
```
/bia
├── api/                 # APIs do backend
├── client/             # Aplicação React
├── config/             # Configurações
├── database/           # Migrations e seeds
├── scripts/            # Scripts auxiliares
├── tests/              # Testes unitários (Jest)
├── docs/               # Documentação
├── compose.yml         # Docker Compose
├── Dockerfile          # Container da aplicação
├── buildspec.yml       # AWS CodeBuild
└── package.json        # Dependências Node.js
```

### Recursos AWS Identificados
- **ECR:** Registry para imagens Docker (configurado no buildspec.yml)
- **CodeBuild:** Pipeline de CI/CD já configurado
- **Secrets Manager:** Gerenciamento de credenciais
- **STS:** Tokens temporários de acesso

### Pontos de Atenção
1. **Segurança:** Credenciais hardcoded no compose.yml (apenas para desenvolvimento)
2. **Escalabilidade:** Aplicação monolítica, mas bem estruturada
3. **Monitoramento:** Healthcheck comentado no Docker Compose
4. **Testes:** Estrutura de testes presente com Jest

---
