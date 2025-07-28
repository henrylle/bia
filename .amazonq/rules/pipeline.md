# Regras de Pipeline - Projeto BIA

## Definição de Pipeline
Sempre que falarmos de **pipeline** para este projeto, estamos nos referindo à combinação de:
- **AWS CodePipeline** (orquestração)
- **AWS CodeBuild** (build e deploy)

## Arquitetura do Pipeline

### Componentes Principais
1. **Source Stage:** GitHub como repositório de código
2. **Build Stage:** CodeBuild para build da aplicação
3. **Deploy Stage:** Deploy automático para ECS

### Configuração Base
- **Buildspec:** Já configurado no arquivo `buildspec.yml` na raiz do projeto
- **ECR:** Registry para armazenar imagens Docker
- **ECS:** Target de deploy da aplicação

## Fluxo do Pipeline

### 1. Source (GitHub)
- Trigger automático em push para branch principal
- Webhook configurado para detectar mudanças

### 2. Build (CodeBuild)
- Executa comandos definidos no `buildspec.yml`
- Build da imagem Docker
- Push da imagem para ECR

### 3. Deploy (ECS)
- Deploy automático da nova imagem
- Rolling update do serviço ECS
- Health check da aplicação

## Configurações Importantes

### Variáveis de Ambiente
- Configuradas no CodeBuild project
- Variáveis específicas por ambiente (dev/prod)

### Permissões IAM
- Role do CodeBuild com permissões para:
  - ECR (push/pull de imagens)
  - ECS (deploy de serviços)

### Monitoramento
- CloudWatch Logs para logs do build
- Métricas de build e deploy

## Boas Práticas

### Performance
- Cache de dependências do npm
- Otimização de layers do Docker

### Confiabilidade
- Health checks após deploy
- Rollback automático em caso de falha

## Troubleshooting Comum

### Build Failures
- Verificar logs no CloudWatch
- Validar permissões IAM
- Confirmar configuração do buildspec.yml

### Deploy Issues
- Verificar health checks do ECS
- Validar configuração do service
- Confirmar conectividade com RDS

## Evolução do Pipeline

### Fase Inicial
- Pipeline simples: Source → Build → Deploy
- Deploy direto para ECS

### Fase Avançada
- Múltiplos ambientes (dev/staging/prod)
- Aprovações manuais para produção
