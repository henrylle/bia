# Regras para Dockerfile - Projeto BIA

## Filosofia de Desenvolvimento
- **Público-alvo:** Alunos em aprendizado
- **Abordagem:** Simplicidade acima de complexidade
- **Objetivo:** Facilitar compreensão de quem que está na etapa inicial da jornada

## Regras Obrigatórias para Dockerfiles

### 1. Análise Prévia Obrigatória
- **SEMPRE** verificar o package.json do projeto raiz
- **SEMPRE** verificar o package.json do client (se existir)
- **IDENTIFICAR** versão do Node.js necessária
- **IDENTIFICAR** todas as tecnologias envolvidas (React, Vite, etc.)
- **VERIFICAR** scripts de build e dependências
- **VERIFICAR** variáveis de ambiente necessárias (ex: VITE_API_URL)
- **ANALISAR** o Dockerfile original para configurações específicas

### 2. Configurações Importantes (NÃO IGNORAR)
- **Imagem base:** Sempre usar ECR (`public.ecr.aws/docker/library/node:XX-slim`)
- **Upgrade do npm:** Busque incluir, para estarmos sempre mais atualizados
- **WORKDIR:** Trabalhar com (`/usr/src/app`)
- **Instalação do curl:** Incluir para health checks
- **Flags do npm:** Manter `--loglevel=error`, `--legacy-peer-deps` se necessário

### 3. Single Stage Sempre
- **NUNCA** usar multi-stage builds
- **NUNCA** sugerir otimizações complexas
- Manter uma única etapa de build

### 4. Simplicidade Máxima
- **EVITAR** mudanças de permissões (chmod, chown)
- **EVITAR** criação de usuários não-root
- **EVITAR** otimizações avançadas de camadas
- Usar comandos básicos e diretos

### 5. Processo de Validação
- **SEMPRE** perguntar se é para testar o Dockerfile
- **QUANDO TESTAR:** Executar o projeto e verificar a rota de health check
- **ROTA DE HEALTH:** Confirmar que `/api/versao` está respondendo corretamente

### 6. Criação de Arquivos
- **NUNCA** sobrescrever Dockerfile existente
- **SEMPRE** avisar ao usuário onde o novo Dockerfile está sendo criado
- **SUGERIR** nome alternativo se já existir (ex: Dockerfile.new, Dockerfile.backup)

## Comandos de Teste
```bash
# Build da imagem
docker build -t bia-app .

# Execução do container
docker run -p 3001:8080 bia-app

# Teste do health check
curl http://localhost:3000/api/versao
```

## O que NÃO fazer
- ❌ Multi-stage builds
- ❌ Otimizações de segurança complexas
- ❌ Mudanças de usuário/permissões
- ❌ Configurações avançadas de networking

## O que SEMPRE fazer
- ✅ Single stage
- ✅ Comandos simples e claros
- ✅ Perguntar sobre teste
- ✅ Validar health check quando testando
