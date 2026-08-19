# Task 008 - Implementar Tela Completa de Versão da API

## 🔧 Configuração Inicial (LEIA ANTES DE INICIAR)

### Agent Responsável
**dev** (.kiro/agents/dev.json)

### Branch Base
**SEMPRE `ia-main`**

### Worktree
Esta task será implementada em worktree isolado em `.kiro/worktrees/008-feat-tela-versao-completa/`

---

## ⚠️ CHECKLIST DE INÍCIO (OBRIGATÓRIO)

Antes de começar a implementar, o agent deve:

- [ ] **Verificar branch atual:** `git branch --show-current`
  - Se não estiver em `ia-main`, **PERGUNTAR** ao usuário se pode trocar
  - Aguardar autorização
  - Após autorização: `git checkout ia-main && git pull origin ia-main`

- [ ] **Mover task para doing:**
  ```bash
  mv .kiro/tasks/008-feat-tela-versao-completa.md .kiro/tasks/doing/
  git add .kiro/tasks/
  git commit -m "move: task 008 para doing"
  git push origin ia-main
  ```

- [ ] **Criar worktree:**
  ```bash
  git worktree add .kiro/worktrees/008-feat-tela-versao-completa -b feature/008-feat-tela-versao-completa ia-main
  cd .kiro/worktrees/008-feat-tela-versao-completa
  git branch --show-current  # Confirmar branch correto
  ```

---

## 📋 Descrição da Tarefa

Implementar uma **tela completa e dedicada** para exibir informações detalhadas sobre a versão da API BIA, seguindo o mesmo padrão visual e estrutural das telas existentes (Tasks e Analytics).

### Contexto
Atualmente existe o componente `Version.jsx` que exibe informações básicas da API. Esta task visa criar uma **experiência mais completa e visualmente consistente** com o restante da aplicação, permitindo:
- Visualização detalhada de informações da versão
- Status da API em tempo real
- Informações do ambiente (local, produção, ALB, etc.)
- Integração com o sistema de logs da aplicação

---

## 🎯 Objetivos

1. **Criar componente VersionPage** seguindo padrão de `Tasks.jsx` e `Analytics.jsx`
2. **Manter consistência visual** com o restante da aplicação
3. **Integrar com contexto de Logs** (LogContext) para rastreabilidade
4. **Exibir informações detalhadas** da API de forma organizada
5. **Implementar refresh manual** das informações
6. **Estados de loading e erro** bem definidos

---

## 📐 Especificação Técnica

### 1. Estrutura do Componente

**Arquivo:** `client/src/components/VersionPage.jsx`

```jsx
import React, { useState, useEffect } from "react";
import { useLog } from "../contexts/LogContext.jsx";
```

### 2. Funcionalidades Principais

#### 2.1 Estado do Componente
- `loading`: boolean - estado de carregamento
- `versionData`: object - dados da API
  ```javascript
  {
    version: string,        // ex: "Bia 4.2.0"
    status: string,         // "online" | "offline"
    timestamp: string,      // data/hora da última verificação
    responseTime: number,   // tempo de resposta em ms
    environment: object     // info do ambiente
  }
  ```
- `error`: string | null - mensagem de erro

#### 2.2 Integração com API
- **Endpoint:** `${apiUrl}/api/versao`
- **Método:** GET
- **Timeout:** 10 segundos
- **Cache:** no-cache
- **Logs:** Integrar com LogContext
  - logApiRequest ao iniciar
  - logApiResponse em sucesso
  - logApiError em falha

#### 2.3 Informações do Ambiente
Detectar e exibir:
- **Local:** localhost/127.0.0.1 → 🏠 Local
- **IP Direto HTTP:** IP sem HTTPS → 🌐 IP Direto
- **ALB HTTP:** ELB sem HTTPS → ⚖️ ALB HTTP
- **Produção HTTPS:** Domínio com HTTPS → 🔒 Produção
- **Outro:** Casos não mapeados → ❓ Outro

### 3. Layout e Estrutura Visual

#### 3.1 Estrutura de Cards
```
┌─────────────────────────────────────┐
│  Status da API          [🔄 Atualizar]│
├─────────────────────────────────────┤
│  Card 1: Informações da Versão       │
│  - Versão da API                     │
│  - Status (🟢/🔴/🟡)                │
│  - Última verificação                │
│  - Tempo de resposta                 │
├─────────────────────────────────────┤
│  Card 2: Ambiente                    │
│  - Tipo de ambiente (ícone + label)  │
│  - URL da aplicação                  │
│  - URL da API                        │
│  - Protocolo e porta                 │
├─────────────────────────────────────┤
│  Card 3: Health Check                │
│  - Status detalhado                  │
│  - Endpoint de verificação           │
│  - Botão para abrir endpoint         │
└─────────────────────────────────────┘
```

#### 3.2 Classes CSS
Seguir padrão existente:
- `.version-page` - container principal
- `.version-header` - cabeçalho com título e botão
- `.version-cards` - container dos cards
- `.version-card` - card individual
- `.card-header` - cabeçalho do card
- `.card-content` - conteúdo do card
- `.status-badge` - badge de status (online/offline)
- `.refresh-btn` - botão de atualizar
- `.loading-state` - estado de carregamento
- `.error-state` - estado de erro
- `.success-state` - estado de sucesso

### 4. Estados Visuais

#### 4.1 Loading
```
🟡 Verificando...
Carregando informações da API...
```

#### 4.2 Sucesso (Online)
```
🟢 Online
Versão: Bia 4.2.0
Última verificação: 18/08/2026 22:30:26
Tempo de resposta: 45ms
```

#### 4.3 Erro (Offline)
```
🔴 Offline
Erro: Failed to fetch
URL: http://localhost:8080/api/versao
```

### 5. Integração com Roteamento

**Atualizar:** `client/src/App.jsx`

```jsx
import VersionPage from "./components/VersionPage.jsx";

// Na área de Routes:
<Route path="/versao" element={<VersionPage />} />
```

⚠️ **IMPORTANTE:** A rota `/versao` já existe e aponta para `Version.jsx`. Avaliar:
- **Opção 1:** Substituir `Version.jsx` por `VersionPage.jsx` na rota existente
- **Opção 2:** Criar nova rota `/versao-detalhada` temporariamente
- **Recomendação:** Opção 1 - substituir diretamente

---

## ✅ Checklist de Implementação

### Frontend - Componente VersionPage

- [ ] Criar arquivo `client/src/components/VersionPage.jsx`
- [ ] Implementar estrutura básica do componente
- [ ] Adicionar estados (loading, versionData, error)
- [ ] Implementar função `fetchVersionInfo()` com:
  - [ ] Timeout de 10 segundos
  - [ ] Medição de tempo de resposta
  - [ ] Tratamento de erros
  - [ ] Integração com LogContext
- [ ] Implementar função `getEnvironmentInfo()`
- [ ] Implementar `useEffect` para carregar dados ao montar
- [ ] Implementar função `handleRefresh()`
- [ ] Criar estrutura de cards:
  - [ ] Card de Informações da Versão
  - [ ] Card de Ambiente
  - [ ] Card de Health Check
- [ ] Adicionar estados visuais (loading/success/error)
- [ ] Adicionar botão de refresh
- [ ] Adicionar botão para abrir endpoint

### Integração

- [ ] Atualizar `client/src/App.jsx`:
  - [ ] Importar `VersionPage`
  - [ ] Atualizar rota `/versao` para usar `VersionPage`
- [ ] Testar navegação para `/versao`
- [ ] Verificar se componente carrega corretamente

### Estilização

- [ ] Adicionar estilos no `client/src/index.css` (se necessário)
- [ ] Garantir consistência visual com Analytics e Tasks
- [ ] Testar responsividade
- [ ] Validar cores dos status (verde/vermelho/amarelo)
- [ ] Validar ícones dos ambientes

### Testes de Integração

- [ ] Testar com API online (localhost)
- [ ] Testar com API offline (servidor parado)
- [ ] Testar timeout (simulando lentidão)
- [ ] Testar botão de refresh
- [ ] Testar botão de abrir endpoint
- [ ] Verificar logs no DebugLogs
- [ ] Testar em diferentes ambientes:
  - [ ] Localhost
  - [ ] IP direto
  - [ ] Produção (se disponível)

### Validação Final

- [ ] Código limpo e comentado
- [ ] Sem console.logs desnecessários
- [ ] Componente segue padrão do projeto
- [ ] Integração com LogContext funcionando
- [ ] Mensagens de erro amigáveis
- [ ] Loading states bem definidos
- [ ] Todas as informações exibidas corretamente

---

## 🧪 Critérios de Aceitação

### Funcionais
1. ✅ Página carrega e exibe status da API
2. ✅ Informações de versão são exibidas corretamente
3. ✅ Status visual (🟢/🔴/🟡) reflete estado real da API
4. ✅ Botão "Atualizar" recarrega informações
5. ✅ Detecção de ambiente funciona corretamente
6. ✅ Tempo de resposta é calculado e exibido
7. ✅ Botão para abrir endpoint abre em nova aba
8. ✅ Estados de loading/error/success são exibidos

### Não-Funcionais
1. ✅ Código segue padrões do projeto (React, hooks)
2. ✅ Integração com LogContext presente
3. ✅ Timeout configurado (10s)
4. ✅ Visual consistente com restante da aplicação
5. ✅ Responsivo em diferentes tamanhos de tela
6. ✅ Sem erros no console do navegador
7. ✅ Performance adequada (carregamento rápido)

### Logs
1. ✅ Log ao montar componente: "INFO: Tela de versão carregada"
2. ✅ Log de request: logApiRequest('GET', url)
3. ✅ Log de sucesso: "SUCCESS: Versão carregada"
4. ✅ Log de erro: "ERROR: Falha ao carregar versão"

---

## 📚 Referências

### Componentes Existentes para Consulta
- `client/src/components/Analytics.jsx` - Padrão de página completa
- `client/src/components/Tasks.jsx` - Estrutura de listagem
- `client/src/components/Version.jsx` - Lógica de versão existente
- `client/src/components/VersionInfo.jsx` - Detecção de ambiente
- `client/src/App.jsx` - Integração de rotas

### Contextos
- `client/src/contexts/LogContext.jsx` - Sistema de logs

### API
- **Endpoint:** `/api/versao`
- **Controller:** `api/controllers/versao.js`
- **Route:** `api/routes/versao.js`

### Workflow
- [Worktree Workflow](.kiro/docs/worktree-workflow.md)
- [Worktree Steering](.kiro/docs/worktree-steering.md)
- [Task Template](.kiro/docs/task-template-with-worktree.md)

---

## 🎨 Exemplo de Implementação (Estrutura Base)

```jsx
const VersionPage = () => {
  const [loading, setLoading] = useState(true);
  const [versionData, setVersionData] = useState(null);
  const [error, setError] = useState(null);
  const { logApiRequest, logApiResponse, logApiError, addLog } = useLog();

  const apiUrl = import.meta.env.VITE_API_URL || "http://localhost:8080";

  const fetchVersionInfo = async () => {
    setLoading(true);
    setError(null);
    
    const url = `${apiUrl}/api/versao`;
    const startTime = Date.now();
    
    logApiRequest('GET', url);
    
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 10000);
      
      const res = await fetch(url, {
        signal: controller.signal,
        method: 'GET',
        cache: 'no-cache'
      });
      
      clearTimeout(timeoutId);
      const responseTime = Date.now() - startTime;
      
      if (!res.ok) {
        throw new Error(`HTTP ${res.status}: ${res.statusText}`);
      }
      
      const data = await res.text();
      
      logApiResponse('GET', url, res.status, data);
      
      setVersionData({
        version: data,
        status: 'online',
        timestamp: new Date().toLocaleString('pt-BR'),
        responseTime: responseTime
      });
      
      addLog('SUCCESS', 'Versão carregada', `API respondeu em ${responseTime}ms: ${data}`);
    } catch (error) {
      logApiError('GET', url, error);
      setError(error.message);
      addLog('ERROR', 'Falha ao carregar versão', error.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    addLog('INFO', 'Tela de versão carregada', `Verificando API: ${apiUrl}`);
    fetchVersionInfo();
  }, []);

  // ... resto da implementação
};
```

---

## ⚠️ FINALIZAÇÃO DA TASK (OBRIGATÓRIO)

Quando o agent concluir a implementação:

### 1. Verificação Final
```bash
# Garantir que está no worktree correto
pwd
# Deve estar em: /caminho/do/projeto/.kiro/worktrees/008-feat-tela-versao-completa

# Verificar branch
git branch --show-current
# Deve mostrar: feature/008-feat-tela-versao-completa
```

### 2. Commit e Push Final
```bash
git add .
git commit -m "feat: implementa tela completa de versão da API"
git push origin feature/008-feat-tela-versao-completa
```

### 3. Voltar para Raiz e Notificar PO
```bash
cd ../../..  # Voltar para raiz do projeto
```

**NOTIFICAR O PO:**
> "Task 008 concluída. Todos os itens do checklist marcados. Branch `feature/008-feat-tela-versao-completa` com push realizado. Tela de versão implementada seguindo padrão de Analytics e Tasks. Aguardando revisão do PO para encerramento e abertura de PR."

**⚠️ NÃO REMOVER O WORKTREE. Apenas o PO faz isso após o PR ser mergeado.**

---

## 🎯 ENCERRAMENTO PELO PO (QUANDO NOTIFICADO)

### 1. Revisão
```bash
# Entrar no worktree para revisar
cd .kiro/worktrees/008-feat-tela-versao-completa

# Revisar código, testar funcionalidade
# Verificar se todos os itens estão ✅

# Testar aplicação
cd client
npm run dev
# Navegar para http://localhost:5173/versao
# Validar funcionamento

cd ../..  # Voltar para raiz do worktree
```

### 2. Aprovar e Mover para Done
```bash
# Voltar para raiz do projeto
cd ../../..

# Mover task para done
mv .kiro/tasks/doing/008-feat-tela-versao-completa.md .kiro/tasks/done/

# Commit e push no ia-main
git checkout ia-main
git add .kiro/tasks/
git commit -m "move: task 008 para done"
git push origin ia-main
```

### 3. Abrir Pull Request
```bash
# ANTES de abrir PR: confirmar que está no branch da feature
cd .kiro/worktrees/008-feat-tela-versao-completa
git branch --show-current
# Deve mostrar: feature/008-feat-tela-versao-completa

# Abrir PR contra ia-main
gh pr create --base ia-main --title "008: Implementar tela completa de versão da API" --body "Closes task 008

## Implementações
- ✅ Componente VersionPage completo
- ✅ Integração com LogContext
- ✅ Estados de loading/error/success
- ✅ Detecção de ambiente
- ✅ Medição de tempo de resposta
- ✅ Botão de refresh
- ✅ Visual consistente com Analytics e Tasks

## Testes Realizados
- ✅ API online
- ✅ API offline
- ✅ Refresh manual
- ✅ Logs funcionando
- ✅ Responsividade"
```

### 4. Após PR Mergeado
```bash
# Voltar para raiz
cd ../../..

# Remover worktree
git worktree remove .kiro/worktrees/008-feat-tela-versao-completa

# Ou com força se necessário:
# git worktree remove --force .kiro/worktrees/008-feat-tela-versao-completa

# Limpar registros
git worktree prune

# (Opcional) Deletar branch local
git branch -d feature/008-feat-tela-versao-completa

# Notificar conclusão
```

**Notificar:** "Task 008 finalizada. Worktree removido. PR #<número> mergeado com sucesso. Tela de versão completa está disponível em produção." ✅
