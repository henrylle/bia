# Task 008 - Implementar Tela de Versão Melhorada

## 🔧 Configuração Inicial (LEIA ANTES DE INICIAR)

### Agent Responsável
**dev** - Este agent deve iniciar a implementação.

### Branch Base
**SEMPRE `ia-main`**

### Worktree
Esta task será implementada em worktree isolado em `.kiro/worktrees/008-feat-tela-versao-melhorada/`

---

## ⚠️ CHECKLIST DE INÍCIO (OBRIGATÓRIO)

Antes de começar a implementar, o agent deve:

- [ ] **Verificar branch atual:** `git branch --show-current`
  - Se não estiver em `ia-main`, **PERGUNTAR** ao usuário se pode trocar
  - Aguardar autorização
  - Após autorização: `git checkout ia-main && git pull origin ia-main`

- [ ] **Mover task para doing:**
  ```bash
  mv .kiro/tasks/008-feat-tela-versao-melhorada.md .kiro/tasks/doing/
  git add .kiro/tasks/
  git commit -m "move: task 008 para doing"
  git push origin ia-main
  ```

- [ ] **Criar worktree:**
  ```bash
  git worktree add .kiro/worktrees/008-feat-tela-versao-melhorada -b feature/008-feat-tela-versao-melhorada ia-main
  cd .kiro/worktrees/008-feat-tela-versao-melhorada
  git branch --show-current  # Confirmar branch correto
  ```

---

## 📋 Descrição da Task

Atualmente, a tela de versão (`client/src/components/Version.jsx`) exibe apenas informações básicas da API. Esta task tem como objetivo **melhorar a tela de versão** seguindo o mesmo padrão visual e estrutural da **tela de tarefas**, incluindo informações mais ricas sobre o sistema.

### Objetivo
Transformar a tela de versão em uma página completa com cards informativos, seguindo o padrão de UI já estabelecido no projeto.

---

## 🎯 Requisitos Funcionais

### 1. Informações a Serem Exibidas
A tela deve exibir os seguintes cards:

#### Card 1: Status da API
- Status de conectividade (Online/Offline)
- Versão da API retornada pelo endpoint `/api/versao`
- URL da API sendo utilizada
- Timestamp da última verificação

#### Card 2: Informações do Frontend
- Versão do frontend (pode ser hardcoded ou vir do package.json)
- Tecnologias utilizadas (React, Vite, etc.)
- Modo de build (development/production)
- Porta/URL do frontend

#### Card 3: Estatísticas do Sistema (Opcional)
- Tempo de resposta da API (em ms)
- Uptime da sessão
- Número de requisições feitas (pode usar o LogContext)

### 2. Funcionalidades
- Botão para **atualizar/refresh** as informações
- Loading states durante requisições
- Error handling visual quando API estiver offline
- Badges de status com cores (verde=online, vermelho=offline, amarelo=verificando)

---

## 🎨 Padrão Visual

### Referência
Seguir o padrão visual da tela de tarefas (`Tasks.jsx` e `Task.jsx`):
- Layout com cards
- Espaçamento consistente
- Uso das classes CSS já existentes
- Responsividade
- Animações suaves

### Estrutura Sugerida
```jsx
<div className="version-page">
  <div className="version-header">
    <h2>Informações do Sistema</h2>
    <button className="refresh-btn">🔄 Atualizar</button>
  </div>
  
  <div className="version-cards">
    <div className="version-card">
      {/* Card de Status da API */}
    </div>
    
    <div className="version-card">
      {/* Card de Informações do Frontend */}
    </div>
    
    <div className="version-card">
      {/* Card de Estatísticas (opcional) */}
    </div>
  </div>
</div>
```

---

## ✅ Checklist de Implementação

### Frontend (client/src/components/Version.jsx)

- [ ] **Analisar componente atual**
  - Ler o arquivo `client/src/components/Version.jsx` atual
  - Entender a lógica de requisição existente
  - Identificar o que pode ser reutilizado

- [ ] **Refatorar componente Version.jsx**
  - Implementar layout com múltiplos cards
  - Card 1: Status da API (já existe parcialmente)
  - Card 2: Informações do Frontend
  - Card 3: Estatísticas do Sistema (se houver tempo)
  - Adicionar botão de refresh funcional
  - Implementar estados de loading/error/success

- [ ] **Integração com LogContext**
  - Utilizar `useLog` para registrar ações
  - Logar quando página é carregada
  - Logar quando refresh é acionado
  - Logar erros de conexão

- [ ] **Estilização CSS**
  - Verificar se há CSS específico para versão em `client/src/index.css`
  - Criar/atualizar estilos seguindo padrão das tasks
  - Garantir responsividade mobile
  - Adicionar badges de status com cores

### Validação e Testes

- [ ] **Testar localmente**
  - Executar `npm run dev` no client
  - Verificar se a página `/versao` carrega corretamente
  - Testar botão de refresh
  - Testar com API online
  - Testar com API offline (desligar o backend)
  - Verificar responsividade em diferentes tamanhos de tela

- [ ] **Verificar console de logs**
  - Abrir DebugLogs e verificar se logs estão sendo registrados
  - Confirmar que não há erros no console do browser

- [ ] **Code review interno**
  - Revisar código para garantir boas práticas
  - Verificar se está seguindo padrão do projeto
  - Remover console.logs de debug

- [ ] **Commit e push**
  - Commitar alterações com mensagem descritiva
  - Push para o branch `feature/008-feat-tela-versao-melhorada`

---

## 📝 Critérios de Aceitação (DoD)

- [ ] Tela de versão exibe múltiplos cards informativos
- [ ] Layout segue o padrão visual da tela de tarefas
- [ ] Status da API é exibido com badge colorido
- [ ] Botão de refresh atualiza as informações
- [ ] Loading states funcionam corretamente
- [ ] Error handling visual quando API offline
- [ ] Logs são registrados no LogContext
- [ ] Tela é responsiva em mobile
- [ ] Código está limpo e sem console.logs desnecessários
- [ ] Todos os itens do checklist marcados

---

## ⚠️ FINALIZAÇÃO DA TASK (OBRIGATÓRIO)

Quando o agent concluir a implementação:

### 1. Verificação Final
```bash
# Garantir que está no worktree correto
pwd
# Deve estar em: /home/vboxuser/bia/.kiro/worktrees/008-feat-tela-versao-melhorada

# Verificar branch
git branch --show-current
# Deve mostrar: feature/008-feat-tela-versao-melhorada
```

### 2. Commit e Push Final
```bash
git add .
git commit -m "feat: implementa tela de versão melhorada seguindo padrão de tasks"
git push -u origin feature/008-feat-tela-versao-melhorada
```

### 3. Voltar para Raiz e Notificar PO
```bash
cd ../../..  # Voltar para raiz do projeto
```

**NOTIFICAR O PO:**
> "Task 008 concluída. Todos os itens do checklist marcados. Branch `feature/008-feat-tela-versao-melhorada` com push realizado. Aguardando revisão do PO para encerramento e abertura de PR."

**⚠️ NÃO REMOVER O WORKTREE. Apenas o PO faz isso após o PR ser mergeado.**

---

## 🎯 ENCERRAMENTO PELO PO (QUANDO NOTIFICADO)

### 1. Revisão
```bash
# Entrar no worktree para revisar
cd .kiro/worktrees/008-feat-tela-versao-melhorada

# Revisar código
# Testar funcionalidade: npm run dev no client
# Verificar se todos os itens estão ✅
```

### 2. Aprovar e Mover para Done
```bash
# Voltar para raiz
cd ../../..

# Mover task para done
mv .kiro/tasks/doing/008-feat-tela-versao-melhorada.md .kiro/tasks/done/

# Commit e push no ia-main
git checkout ia-main
git add .kiro/tasks/
git commit -m "move: task 008 para done"
git push origin ia-main
```

### 3. Abrir Pull Request
```bash
# ANTES de abrir PR: confirmar que está no branch da feature
cd .kiro/worktrees/008-feat-tela-versao-melhorada
git branch --show-current
# Deve mostrar: feature/008-feat-tela-versao-melhorada

# Abrir PR contra ia-main
gh pr create --base ia-main --title "008: Implementa tela de versão melhorada" --body "Closes task 008

## Resumo
Implementa tela de versão seguindo padrão visual da tela de tarefas.

## Alterações
- ✅ Layout com múltiplos cards informativos
- ✅ Card de Status da API com badge colorido
- ✅ Card de Informações do Frontend
- ✅ Botão de refresh funcional
- ✅ Loading e error states
- ✅ Integração com LogContext
- ✅ Responsividade mobile

## Testes Realizados
- [x] Tela carrega corretamente em /versao
- [x] Botão refresh funciona
- [x] Error handling quando API offline
- [x] Responsividade mobile testada
- [x] Logs registrados corretamente"
```

### 4. Após PR Mergeado
```bash
# Voltar para raiz
cd ../../..

# Remover worktree
git worktree remove .kiro/worktrees/008-feat-tela-versao-melhorada

# Ou com força se necessário:
# git worktree remove --force .kiro/worktrees/008-feat-tela-versao-melhorada

# Limpar registros
git worktree prune

# (Opcional) Deletar branch local
git branch -d feature/008-feat-tela-versao-melhorada

# Notificar conclusão
```

**Notificar:** "Task 008 finalizada. Worktree removido. PR #<número> mergeado com sucesso."

---

## 📚 Referências
- [Worktree Workflow](.kiro/docs/worktree-workflow.md)
- [Worktree Steering](.kiro/docs/worktree-steering.md)
- [Task Template](.kiro/docs/task-template-with-worktree.md)
- Componente de referência: `client/src/components/Tasks.jsx`
- Componente atual: `client/src/components/Version.jsx`

---

## 🏷️ Tags
`frontend` `react` `ui` `feature` `version` `dev`
