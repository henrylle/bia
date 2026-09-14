# 009 · feat · GitHub Actions CI Melhorado — Pipeline Robusto e Otimizado

## 🔧 Configuração Inicial (LEIA ANTES DE INICIAR)

### Agent Responsável
**devops** - Este agent deve iniciar a implementação.

### Branch Base
**SEMPRE `ia-main`**

### Worktree
Esta task será implementada em worktree isolado em `.kiro/worktrees/009-feat-github-actions-ci-melhorado/`

---

## ⚠️ CHECKLIST DE INÍCIO (OBRIGATÓRIO)

Antes de começar a implementar, o agent deve:

- [ ] **Verificar branch atual:** `git branch --show-current`
  - Se não estiver em `ia-main`, **PERGUNTAR** ao usuário se pode trocar
  - Aguardar autorização
  - Após autorização: `git checkout ia-main && git pull origin ia-main`

- [ ] **Mover task para doing:**
  ```bash
  mv .kiro/tasks/009-feat-github-actions-ci-melhorado.md .kiro/tasks/doing/
  git add .kiro/tasks/
  git commit -m "move: task 009 para doing"
  git push origin ia-main
  ```

- [ ] **Criar worktree:**
  ```bash
  git worktree add .kiro/worktrees/009-feat-github-actions-ci-melhorado -b feature/009-feat-github-actions-ci-melhorado ia-main
  cd .kiro/worktrees/009-feat-github-actions-ci-melhorado
  git branch --show-current  # Confirmar branch correto
  ```

---

## Contexto

O projeto BIA já possui um workflow básico de CI (`.github/workflows/testes-pr.yml`) que executa testes unitários a cada PR contra `ia-main`. Esta task visa **evoluir esse workflow** com melhorias de performance, confiabilidade e visibilidade.

### Workflow Atual (Limitações)
- ✅ Executa testes unitários
- ❌ Sem cache de dependências (lento)
- ❌ Testa apenas em uma versão do Node
- ❌ Sem cobertura de código visível
- ❌ Sem validação de linting
- ❌ Sem timeout configurado
- ❌ Sem feedback visual no PR

---

## História de Usuário

> **Como** desenvolvedor do projeto BIA,  
> **Quero** um pipeline de CI robusto, rápido e informativo,  
> **Para que** eu tenha feedback completo sobre qualidade, cobertura e compatibilidade do código antes do merge.

---

## Objetivos da Melhoria

### 1. Performance
- **Cache de dependências:** Reduzir tempo de instalação do `npm install`
- **Paralelização:** Executar jobs independentes em paralelo

### 2. Confiabilidade
- **Matrix Strategy:** Testar em múltiplas versões do Node (18, 20, 22)
- **Timeout:** Evitar builds travados
- **Retry:** Tentar novamente em caso de falha temporária

### 3. Visibilidade
- **Code Coverage:** Gerar e exibir cobertura de testes
- **Comentários no PR:** Feedback automático com resultados
- **Status Badges:** Badge de status do CI no README

### 4. Qualidade
- **Linting:** Validar padrões de código (se ESLint estiver configurado)
- **Security Audit:** Verificar vulnerabilidades em dependências

---

## Critérios de Aceite

### Performance
- [ ] Cache de `node_modules` configurado e funcionando
- [ ] Tempo de build reduzido em pelo menos 30% (comparar com workflow atual)

### Confiabilidade
- [ ] Workflow testa em Node.js 18, 20 e 22 (matrix strategy)
- [ ] Timeout de 10 minutos configurado por job
- [ ] Build não falha por problemas temporários de rede

### Visibilidade
- [ ] Cobertura de código gerada pelo Jest (`--coverage`)
- [ ] Relatório de cobertura disponível como artifact do workflow
- [ ] Comentário automático no PR com resumo dos resultados (opcional, se tempo permitir)

### Qualidade
- [ ] `npm audit` executado para verificar vulnerabilidades
- [ ] Se ESLint estiver configurado, executar validação de linting

### Documentação
- [ ] README atualizado com badge do status do workflow
- [ ] Comentários no workflow explicando cada seção

---

## Checklist de Implementação — Agent `devops`

### Análise Prévia
- [ ] Verificar versões do Node.js a serem testadas (sugestão: 18, 20, 22)
- [ ] Confirmar se Jest está configurado para gerar cobertura
- [ ] Verificar se existe configuração de ESLint no projeto
- [ ] Analisar o workflow atual (`.github/workflows/testes-pr.yml`)

### Implementação do Workflow Melhorado

#### 1. Criar novo workflow principal
- [ ] Criar `.github/workflows/ci.yml` (workflow melhorado e completo)
- [ ] Configurar trigger para `pull_request` contra `ia-main` e `push` em `ia-main`
- [ ] Implementar **cache de dependências**:
  ```yaml
  - uses: actions/setup-node@v4
    with:
      node-version: ${{ matrix.node-version }}
      cache: 'npm'
  ```

#### 2. Implementar Matrix Strategy
- [ ] Configurar matrix com versões do Node: `[18, 20, 22]`
- [ ] Garantir que testes rodem em todas as versões em paralelo

#### 3. Job de Testes com Cobertura
- [ ] Atualizar comando de teste para incluir coverage: `npm test -- --coverage`
- [ ] Configurar Jest para gerar relatório de cobertura (se ainda não estiver)
- [ ] Upload do relatório de cobertura como artifact:
  ```yaml
  - uses: actions/upload-artifact@v4
    with:
      name: coverage-report
      path: coverage/
  ```

#### 4. Job de Linting (se ESLint existir)
- [ ] Verificar se `.eslintrc` ou config no `package.json` existe
- [ ] Se existir, adicionar job separado de linting:
  ```yaml
  lint:
    runs-on: ubuntu-latest
    steps:
      - checkout
      - setup-node com cache
      - npm install
      - npm run lint (ou npx eslint .)
  ```

#### 5. Job de Security Audit
- [ ] Criar job separado para `npm audit`:
  ```yaml
  security:
    runs-on: ubuntu-latest
    steps:
      - checkout
      - setup-node
      - npm audit --audit-level=moderate
  ```
- [ ] Configurar para não falhar o build, apenas avisar (usar `continue-on-error: true` se necessário)

#### 6. Configurações de Confiabilidade
- [ ] Adicionar `timeout-minutes: 10` em cada job
- [ ] Considerar adicionar retry em steps críticos (opcional)

#### 7. Atualizar ou Manter Workflow Original
- [ ] Decidir: substituir `.github/workflows/testes-pr.yml` ou manter ambos
- [ ] Se manter ambos, renomear o antigo para `.github/workflows/testes-pr.yml.backup`
- [ ] Se substituir, fazer backup do conteúdo original

### Configuração do Jest para Coverage
- [ ] Verificar se `jest.config.js` existe ou configurar no `package.json`
- [ ] Adicionar configuração de coverage:
  ```json
  "jest": {
    "collectCoverage": true,
    "coverageDirectory": "coverage",
    "coverageReporters": ["text", "lcov", "html"]
  }
  ```

### Atualização do README
- [ ] Adicionar badge do workflow no topo do README.md:
  ```markdown
  ![CI Status](https://github.com/henrylle/bia/workflows/CI/badge.svg)
  ```
- [ ] Adicionar seção explicando o workflow de CI

### Validação Local
- [ ] Executar `npm test -- --coverage` localmente para garantir que funciona
- [ ] Se houver linting, executar localmente: `npm run lint` ou `npx eslint .`
- [ ] Executar `npm audit` para verificar se há vulnerabilidades críticas

### Validação no GitHub
- [ ] Fazer commit e push do branch `feature/009-feat-github-actions-ci-melhorado`
- [ ] Abrir PR de teste contra `ia-main`
- [ ] Confirmar que todos os jobs do workflow são executados
- [ ] Verificar se o cache está funcionando (2ª execução deve ser mais rápida)
- [ ] Confirmar que matrix strategy está rodando em todas as versões do Node
- [ ] Verificar artifacts gerados (relatório de cobertura)
- [ ] Confirmar que badge aparece no README

### Documentação Adicional
- [ ] Criar ou atualizar `.kiro/docs/ci-workflow.md` explicando o pipeline
- [ ] Documentar como interpretar os resultados do workflow
- [ ] Documentar como fazer debug de falhas no CI

---

## Detalhes Técnicos

### Estrutura Proposta

```
.github/
└── workflows/
    ├── ci.yml (novo - workflow completo e otimizado)
    └── testes-pr.yml (existente - manter como backup ou remover)
```

### Exemplo de Workflow Melhorado (Referência)

```yaml
name: CI Pipeline

on:
  pull_request:
    branches:
      - ia-main
  push:
    branches:
      - ia-main

jobs:
  test:
    name: Testes (Node ${{ matrix.node-version }})
    runs-on: ubuntu-latest
    timeout-minutes: 10
    
    strategy:
      matrix:
        node-version: [18, 20, 22]
    
    steps:
      - name: Checkout código
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
      
      - name: Instalar dependências
        run: npm ci
      
      - name: Executar testes com cobertura
        run: npm test -- --coverage
      
      - name: Upload relatório de cobertura
        uses: actions/upload-artifact@v4
        if: matrix.node-version == 22
        with:
          name: coverage-report
          path: coverage/
          retention-days: 7

  security:
    name: Security Audit
    runs-on: ubuntu-latest
    timeout-minutes: 5
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: 'npm'
      
      - name: Verificar vulnerabilidades
        run: npm audit --audit-level=moderate
        continue-on-error: true
```

> ⚠️ **Nota:** O workflow acima é uma referência. O agent deve adaptar conforme a análise do projeto.

### Configuração Recomendada do Jest

```json
{
  "jest": {
    "testEnvironment": "node",
    "collectCoverage": true,
    "coverageDirectory": "coverage",
    "coverageReporters": ["text", "lcov", "html"],
    "collectCoverageFrom": [
      "controllers/**/*.js",
      "routes/**/*.js",
      "models/**/*.js",
      "!**/node_modules/**"
    ],
    "coverageThreshold": {
      "global": {
        "branches": 50,
        "functions": 50,
        "lines": 50
      }
    }
  }
}
```

---

## Definition of Done (DoD)

### Funcionalidade
- [ ] Novo workflow `.github/workflows/ci.yml` criado e funcionando
- [ ] Cache de dependências reduz tempo de build
- [ ] Testes executam em Node 18, 20 e 22 com sucesso
- [ ] Cobertura de código é gerada e disponível como artifact
- [ ] Security audit é executado (mesmo que com warnings)

### Qualidade
- [ ] Todos os testes existentes passam no CI
- [ ] Workflow não falha por timeout
- [ ] Logs são claros e informativos

### Documentação
- [ ] README atualizado com badge do CI
- [ ] Workflow possui comentários explicativos
- [ ] Documentação de CI criada/atualizada

### Validação
- [ ] PR de teste aberto e todos os checks passam
- [ ] Badge do CI aparece corretamente no README
- [ ] Artifacts de cobertura acessíveis no GitHub
- [ ] Segunda execução do workflow é mais rápida (cache funcionando)

---

## ⚠️ FINALIZAÇÃO DA TASK (OBRIGATÓRIO)

Quando o agent concluir a implementação:

### 1. Verificação Final
```bash
# Garantir que está no worktree correto
pwd
# Deve estar em: /home/vboxuser/bia/.kiro/worktrees/009-feat-github-actions-ci-melhorado

# Verificar branch
git branch --show-current
# Deve mostrar: feature/009-feat-github-actions-ci-melhorado
```

### 2. Commit e Push Final
```bash
git add .
git commit -m "feat: implementa CI melhorado com cache, matrix e coverage"
git push -u origin feature/009-feat-github-actions-ci-melhorado
```

### 3. Voltar para Raiz e Notificar PO
```bash
cd ../../..  # Voltar para raiz do projeto
```

**NOTIFICAR O PO:**
> "Task 009 concluída. Todos os itens do checklist marcados. Branch `feature/009-feat-github-actions-ci-melhorado` com push realizado. Aguardando revisão do PO para encerramento e abertura de PR."

**⚠️ NÃO REMOVER O WORKTREE. Apenas o PO faz isso após o PR ser mergeado.**

---

## 🎯 ENCERRAMENTO PELO PO (QUANDO NOTIFICADO)

### 1. Revisão
```bash
# Entrar no worktree para revisar
cd .kiro/worktrees/009-feat-github-actions-ci-melhorado

# Revisar workflow, testar funcionalidade
# Verificar se todos os itens estão ✅
```

### 2. Aprovar e Mover para Done
```bash
# Voltar para raiz
cd ../../..

# Mover task para done
mv .kiro/tasks/doing/009-feat-github-actions-ci-melhorado.md .kiro/tasks/done/

# Commit e push no ia-main
git checkout ia-main
git add .kiro/tasks/
git commit -m "move: task 009 para done"
git push origin ia-main
```

### 3. Abrir Pull Request
```bash
# ANTES de abrir PR: confirmar que está no branch da feature
cd .kiro/worktrees/009-feat-github-actions-ci-melhorado
git branch --show-current
# Deve mostrar: feature/009-feat-github-actions-ci-melhorado

# Abrir PR contra ia-main
gh pr create --base ia-main --title "009: GitHub Actions CI melhorado com cache, matrix e coverage" --body "Closes task 009

## Melhorias Implementadas
- ✅ Cache de dependências para builds mais rápidos
- ✅ Matrix strategy testando Node 18, 20 e 22
- ✅ Cobertura de código com Jest
- ✅ Security audit automático
- ✅ Badge de status no README
- ✅ Timeout e retry para confiabilidade

## Testes
- Todos os testes unitários passando
- Coverage report disponível como artifact
- Badge aparecendo corretamente no README"
```

### 4. Após PR Mergeado
```bash
# Voltar para raiz
cd ../../..

# Remover worktree
git worktree remove .kiro/worktrees/009-feat-github-actions-ci-melhorado

# Ou com força se necessário:
# git worktree remove --force .kiro/worktrees/009-feat-github-actions-ci-melhorado

# Limpar registros
git worktree prune

# (Opcional) Deletar branch local
git branch -d feature/009-feat-github-actions-ci-melhorado

# Notificar conclusão
```

**Notificação Final:**
> "Task 009 finalizada. Worktree removido. PR #XX mergeado com sucesso. CI melhorado está ativo e operacional."

---

## 📚 Referências
- [GitHub Actions - Caching dependencies](https://docs.github.com/en/actions/using-workflows/caching-dependencies-to-speed-up-workflows)
- [GitHub Actions - Matrix Strategy](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs)
- [Jest - Code Coverage](https://jestjs.io/docs/configuration#collectcoverage-boolean)
- [Worktree Workflow](.kiro/docs/worktree-workflow.md)
- [Worktree Steering](.kiro/docs/worktree-steering.md)

---

## Observações Importantes

### Sobre Simplificidade
Esta task adiciona complexidade ao CI, mas de forma **educacional e incremental**:
- Cada melhoria é independente
- Agent pode implementar por partes
- Comentários no código explicam cada seção
- Foco em aprendizado, não em over-engineering

### Sobre Performance
- Cache pode reduzir build de ~2min para ~30s
- Matrix roda em paralelo (não aumenta tempo total)
- Coverage adiciona ~10s ao tempo de teste

### Sobre Compatibilidade
- Node 18 é LTS até 2025-04-30
- Node 20 é LTS atual
- Node 22 é a versão mais recente (testar para futuro)

### Decisões de Trade-off
- **Não incluído:** Deploy automático (fora do escopo de CI)
- **Não incluído:** Integração com SonarQube (muito complexo para alunos)
- **Não incluído:** Testes E2E (projeto tem apenas testes unitários)
- **Incluído:** Features que agregam aprendizado sem complexidade excessiva
