# CI Workflow - Documentação Completa

## 📋 Visão Geral

O pipeline de CI (Continuous Integration) do projeto BIA é implementado através do GitHub Actions e está configurado no arquivo `.github/workflows/ci.yml`.

Este documento explica como o pipeline funciona, como interpretar os resultados e como fazer debug de falhas.

---

## 🎯 Objetivos do CI

1. **Garantir qualidade:** Todos os testes devem passar antes do merge
2. **Compatibilidade:** Validar que o código funciona em múltiplas versões do Node.js
3. **Segurança:** Detectar vulnerabilidades conhecidas nas dependências
4. **Visibilidade:** Fornecer métricas de cobertura de código
5. **Rapidez:** Feedback em menos de 5 minutos (com cache)

---

## 🏗️ Estrutura do Pipeline

O pipeline é composto por 4 jobs que executam em paralelo:

### 1. Test (Testes Unitários)
- **Propósito:** Executar testes unitários em múltiplas versões do Node.js
- **Versões testadas:** 18, 20, 22
- **Matrix Strategy:** Os testes rodam em paralelo em cada versão
- **Coverage:** Gerado apenas no Node 22 para economizar tempo
- **Timeout:** 10 minutos

**Por que testar em 3 versões?**
- Node 18: LTS até 2025-04-30 (garantir compatibilidade com versões antigas)
- Node 20: LTS atual (versão recomendada para produção)
- Node 22: Versão mais recente (preparar para o futuro)

### 2. Lint (Validação de Código)
- **Propósito:** Garantir que o código segue padrões de qualidade
- **Ferramenta:** ESLint
- **Node.js:** Versão 22 (apenas uma versão necessária)
- **Timeout:** 5 minutos

**Nota:** Se o script `lint` não estiver configurado no `package.json`, o job apenas avisa mas não falha.

### 3. Security (Auditoria de Segurança)
- **Propósito:** Detectar vulnerabilidades conhecidas nas dependências
- **Ferramenta:** `npm audit`
- **Nível:** Moderate (ignora vulnerabilidades de baixo risco)
- **Comportamento:** Não bloqueia o build, apenas avisa
- **Timeout:** 5 minutos

**Por que não bloquear?**
- Permite que o time avalie o risco e priorize correções
- Evita falsos positivos bloqueando desenvolvimento
- Mantém o pipeline educacional e não punitivo

### 4. Build Check (Validação de Build)
- **Propósito:** Verificar se a aplicação consegue iniciar sem erros
- **Valida:** Sintaxe do JavaScript e imports
- **Timeout:** 5 minutos

---

## ⚡ Performance e Otimizações

### Cache de Dependências

O workflow utiliza o cache automático do `actions/setup-node@v4`:

```yaml
- uses: actions/setup-node@v4
  with:
    node-version: ${{ matrix.node-version }}
    cache: 'npm'
```

**Como funciona:**
1. Na primeira execução, `npm ci` instala todas as dependências (~2 minutos)
2. O cache é criado baseado no hash do `package-lock.json`
3. Nas execuções seguintes, se o `package-lock.json` não mudou, restaura o cache (~10 segundos)
4. Se mudou, invalida o cache e instala novamente

**Benefícios:**
- Reduz tempo de build de ~2min para ~30s
- Economiza recursos do GitHub Actions
- Feedback mais rápido para os desenvolvedores

### Paralelização

Os 4 jobs rodam em paralelo, não em sequência:

```
Test (Node 18)  ━━━━━━━━━ ✅ (2min)
Test (Node 20)  ━━━━━━━━━ ✅ (2min)
Test (Node 22)  ━━━━━━━━━━━ ✅ (2min + coverage)
Lint            ━━━━━ ✅ (1min)
Security        ━━━━━ ✅ (1min)
Build Check     ━━━━━ ✅ (1min)

Tempo total: ~3 minutos (ao invés de ~8min se fosse sequencial)
```

---

## 📊 Cobertura de Código

### Como é Gerada

O Jest é executado com as flags `--coverage` no Node 22:

```bash
npm test -- --coverage --coverageReporters=text --coverageReporters=lcov --coverageReporters=html
```

**Formatos gerados:**
- **text:** Saída no console (visível nos logs)
- **lcov:** Formato padrão para integração com outras ferramentas
- **html:** Relatório navegável em HTML

### Como Acessar

1. Acesse a aba **Actions** no GitHub
2. Clique na execução do workflow
3. Na seção **Artifacts**, baixe o `coverage-report`
4. Descompacte e abra o arquivo `index.html` no navegador

### Métricas Incluídas

- **Statements:** Quantas linhas de código foram executadas
- **Branches:** Quantos caminhos de decisão (if/else) foram testados
- **Functions:** Quantas funções foram chamadas
- **Lines:** Cobertura total de linhas

### Interpretação

```
---------------------------|---------|----------|---------|---------|
File                       | % Stmts | % Branch | % Funcs | % Lines |
---------------------------|---------|----------|---------|---------|
All files                  |   78.45 |    65.32 |   82.15 |   78.45 |
 controllers               |   85.20 |    70.00 |   90.00 |   85.20 |
  usuarioController.js     |   85.20 |    70.00 |   90.00 |   85.20 |
 routes                    |   72.50 |    60.00 |   75.00 |   72.50 |
  usuarioRoutes.js         |   72.50 |    60.00 |   75.00 |   72.50 |
---------------------------|---------|----------|---------|---------|
```

**Recomendações:**
- ✅ **Acima de 80%:** Excelente cobertura
- ⚠️  **60-80%:** Boa cobertura, mas pode melhorar
- ❌ **Abaixo de 60%:** Cobertura insuficiente

---

## 🐛 Troubleshooting - Como Debugar Falhas

### Falha nos Testes

**Sintoma:** Job "Test" falha com ❌

**Como investigar:**
1. Clique no job "Test" que falhou
2. Expanda o step "Executar testes unitários"
3. Leia a mensagem de erro do Jest
4. Identifique qual teste falhou e por quê

**Causas comuns:**
- Teste flaky (depende de tempo/ordem)
- Mudança no código que quebrou o teste
- Teste não atualizado após refactor

**Como resolver:**
1. Rode o teste localmente: `npm test`
2. Corrija o teste ou o código
3. Commit e push novamente

### Falha no Cache

**Sintoma:** Build demora muito mesmo com cache

**Como investigar:**
1. Verifique se o `package-lock.json` mudou
2. Cache é invalidado se o lock file mudar

**Como resolver:**
- Normal se você adicionou/atualizou dependências
- Se não mudou dependências, tente re-executar o workflow

### Falha no Security Audit

**Sintoma:** Job "Security" reporta vulnerabilidades

**Como investigar:**
1. Expanda o step "Verificar vulnerabilidades"
2. Leia quais pacotes têm vulnerabilidades
3. Verifique a severidade (crítica, alta, moderada)

**Como resolver:**
```bash
# Ver detalhes localmente
npm audit

# Tentar atualizar automaticamente
npm audit fix

# Atualizar manualmente
npm update [pacote]

# Se não houver correção disponível, documentar e monitorar
```

**Importante:** Este job não bloqueia o merge, apenas avisa.

### Falha no Lint

**Sintoma:** Job "Lint" falha com erros de ESLint

**Como investigar:**
1. Expanda o step "Executar ESLint"
2. Leia quais arquivos e linhas têm problemas

**Como resolver:**
```bash
# Rodar localmente
npm run lint

# Auto-fix quando possível
npm run lint -- --fix

# Ou configurar no package.json:
"lint:fix": "eslint . --fix"
```

### Timeout

**Sintoma:** Job cancelado após 10 minutos (Test) ou 5 minutos (outros)

**Causas comuns:**
- Teste travado (esperando promise que nunca resolve)
- Loop infinito
- Operação de rede que não responde

**Como resolver:**
1. Identifique qual teste estava rodando
2. Adicione timeout no teste específico
3. Verifique se há operações assíncronas não tratadas

---

## 🔧 Configuração Local

### Executar Testes com Coverage Localmente

```bash
# Igual ao CI
npm test -- --coverage --coverageReporters=text --coverageReporters=lcov --coverageReporters=html

# Abrir relatório HTML
open coverage/index.html  # macOS
xdg-open coverage/index.html  # Linux
start coverage/index.html  # Windows
```

### Executar Linting Localmente

```bash
# Se configurado
npm run lint

# Ou diretamente
npx eslint .
```

### Executar Security Audit Localmente

```bash
# Ver vulnerabilidades
npm audit

# Tentar corrigir automaticamente
npm audit fix

# Ver apenas críticas e altas
npm audit --audit-level=high
```

---

## 📈 Métricas e Monitoramento

### Badge de Status

O badge no README mostra o status da última execução:

![CI Pipeline](https://github.com/henrylle/bia/workflows/CI%20Pipeline/badge.svg)

- 🟢 **Passing:** Todos os checks passaram
- 🔴 **Failing:** Pelo menos um check falhou
- 🟡 **Pending:** Workflow em execução

### Histórico de Execuções

Acesse a aba **Actions** > **CI Pipeline** para ver:
- Todas as execuções do workflow
- Tempo de cada execução
- Taxa de sucesso/falha
- Tendências ao longo do tempo

---

## 🚀 Evolução Futura

### Melhorias Possíveis (Não Implementadas)

1. **Comentários Automáticos no PR:**
   - Postar resumo da cobertura de código no PR
   - Comparar cobertura atual vs branch base
   - Exige configuração de token com permissões

2. **Deploy Automático:**
   - Após merge em `ia-main`, fazer deploy para staging/produção
   - Fora do escopo de CI (seria CD - Continuous Deployment)

3. **Testes E2E:**
   - Adicionar testes de ponta a ponta
   - Exige ambiente de banco de dados no CI

4. **Análise de Código Estática:**
   - Integração com SonarQube ou CodeClimate
   - Detectar code smells e duplicação

5. **Performance Testing:**
   - Benchmark de performance da API
   - Detectar regressões de performance

---

## 🎓 Recursos Educacionais

### Para Alunos da Formação AWS

Este CI foi projetado com simplicidade e aprendizado em mente:

- **Comentários extensivos:** Cada linha importante tem explicação
- **Timeouts configurados:** Evita builds travados
- **Não bloqueia desenvolvimento:** Security audit apenas avisa
- **Feedback claro:** Logs legíveis e informativos

### Links Úteis

- [GitHub Actions - Documentação Oficial](https://docs.github.com/en/actions)
- [GitHub Actions - Caching](https://docs.github.com/en/actions/using-workflows/caching-dependencies-to-speed-up-workflows)
- [GitHub Actions - Matrix Strategy](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs)
- [Jest - Code Coverage](https://jestjs.io/docs/configuration#collectcoverage-boolean)
- [npm audit - Documentação](https://docs.npmjs.com/cli/v10/commands/npm-audit)

---

## 📝 Checklist de Validação

Use este checklist para validar se o CI está funcionando corretamente:

### Primeira Execução
- [ ] Workflow é disparado automaticamente ao abrir PR
- [ ] Os 4 jobs iniciam (Test, Lint, Security, Build Check)
- [ ] Test roda em Node 18, 20 e 22
- [ ] Todos os testes passam
- [ ] Coverage report é gerado (Node 22)
- [ ] Artifact de cobertura está disponível para download
- [ ] Badge aparece no README

### Segunda Execução (Validar Cache)
- [ ] Cache de dependências é restaurado
- [ ] Tempo de instalação reduzido para ~10s
- [ ] Tempo total de build reduzido em pelo menos 30%

### Validação de Qualidade
- [ ] Testes falham se houver erros no código
- [ ] Security audit reporta vulnerabilidades (se houver)
- [ ] Lint reporta erros de estilo (se configurado)
- [ ] Relatório de cobertura está completo e navegável

---

## 🤝 Contribuindo

Se você encontrar problemas no CI ou tiver sugestões de melhorias:

1. Abra uma issue descrevendo o problema ou sugestão
2. Se for fazer mudanças no workflow, teste localmente com [act](https://github.com/nektos/act)
3. Documente as mudanças neste arquivo
4. Atualize o README se necessário

---

**Última atualização:** Task 009 - GitHub Actions CI Melhorado  
**Responsável:** DevOps Team - Formação AWS
