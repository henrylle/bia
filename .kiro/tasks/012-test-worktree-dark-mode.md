# Task 012 - Teste Worktree - Adicionar Dark Mode Toggle

## 🔧 Configuração Inicial (LEIA ANTES DE INICIAR)

### Agent Responsável
**dev** - Este agent deve iniciar a implementação.

### Branch Base
**SEMPRE `ia-main`**

### Worktree
Esta task será implementada em worktree isolado em `.kiro/worktrees/012-test-worktree-dark-mode/`

---

## ⚠️ CHECKLIST DE INÍCIO (OBRIGATÓRIO)

Antes de começar a implementar, o agent deve:

- [ ] **Verificar branch atual:** `git branch --show-current`
  - Se não estiver em `ia-main`, **PERGUNTAR** ao usuário se pode trocar
  - Aguardar autorização
  - Após autorização: `git checkout ia-main && git pull origin ia-main`

- [ ] **Mover task para doing:**
  ```bash
  mv .kiro/tasks/012-test-worktree-dark-mode.md .kiro/tasks/doing/
  git add .kiro/tasks/
  git commit -m "move: task 012 para doing"
  git push origin ia-main
  ```

- [ ] **Criar worktree:**
  ```bash
  git worktree add .kiro/worktrees/012-test-worktree-dark-mode -b feature/012-test-worktree-dark-mode ia-main
  cd .kiro/worktrees/012-test-worktree-dark-mode
  git branch --show-current  # Confirmar branch correto
  ```

---

## 📋 Descrição da Task
Implementar um botão toggle para alternar entre modo claro e escuro na tela de versão da API.

## 🎯 Critérios de Aceitação
- [ ] Adicionar botão de toggle (ícone de sol/lua)
- [ ] Implementar estado para gerenciar tema (useState)
- [ ] Criar classes CSS para dark mode
- [ ] Aplicar tema dinamicamente no componente
- [ ] Salvar preferência no localStorage (opcional)

## ✅ Definição de Pronto (DoD)
- [ ] Código implementado no worktree isolado
- [ ] Build do frontend realizado
- [ ] Teste visual do toggle confirmado
- [ ] Tema alternando corretamente
- [ ] Commit e push no branch `feature/012-test-worktree-dark-mode`

## 🔧 Observações Técnicas
- **Arquivo principal:** `client/src/pages/Versao.jsx`
- **Arquivo CSS:** `client/src/index.css`
- **Estado:** `const [darkMode, setDarkMode] = useState(false)`
- **Classes CSS:** `.version-page.dark-mode`

## 💡 Estrutura Sugerida

### JSX (Versao.jsx)
```jsx
const [darkMode, setDarkMode] = useState(false);

return (
  <div className={`version-page ${darkMode ? 'dark-mode' : ''}`}>
    <button 
      onClick={() => setDarkMode(!darkMode)}
      className="theme-toggle"
    >
      {darkMode ? '☀️' : '🌙'}
    </button>
    {/* resto do conteúdo */}
  </div>
);
```

### CSS (index.css)
```css
.version-page.dark-mode {
  background-color: #1a1a1a;
  color: #f5f5f5;
}

.theme-toggle {
  position: fixed;
  top: 20px;
  right: 20px;
  font-size: 1.5rem;
  background: none;
  border: none;
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 50%;
  transition: all 0.3s ease;
}

.theme-toggle:hover {
  background-color: rgba(0, 0, 0, 0.1);
  transform: rotate(20deg);
}
```

---

## ⚠️ FINALIZAÇÃO DA TASK (OBRIGATÓRIO)

Quando o agent concluir a implementação:

### 1. Verificação Final
```bash
# Garantir que está no worktree correto
pwd
# Deve estar em: /caminho/.kiro/worktrees/012-test-worktree-dark-mode

# Verificar branch
git branch --show-current
# Deve mostrar: feature/012-test-worktree-dark-mode
```

### 2. Commit e Push Final
```bash
git add .
git commit -m "test: adiciona toggle de dark mode na tela de versão"
git push -u origin feature/012-test-worktree-dark-mode
```

### 3. Voltar para Raiz e Notificar PO
```bash
cd ../../..  # Voltar para raiz do projeto
```

**NOTIFICAR O PO:**
> "Task 012 concluída. Todos os itens do checklist marcados. Branch `feature/012-test-worktree-dark-mode` com push realizado. Aguardando revisão do PO para encerramento e abertura de PR."

**⚠️ NÃO REMOVER O WORKTREE. Apenas o PO faz isso após o PR ser mergeado.**

---

## 🎯 ENCERRAMENTO PELO PO (QUANDO NOTIFICADO)

### 1. Revisão
```bash
# Entrar no worktree para revisar
cd .kiro/worktrees/012-test-worktree-dark-mode

# Revisar código, testar funcionalidade
# Verificar se todos os itens estão ✅
```

### 2. Aprovar e Mover para Done
```bash
# Voltar para raiz
cd ../../..

# Mover task para done
mv .kiro/tasks/doing/012-test-worktree-dark-mode.md .kiro/tasks/done/

# Commit e push no ia-main
git checkout ia-main
git add .kiro/tasks/
git commit -m "move: task 012 para done"
git push origin ia-main
```

### 3. Abrir Pull Request
```bash
# ANTES de abrir PR: confirmar que está no branch da feature
cd .kiro/worktrees/012-test-worktree-dark-mode
git branch --show-current
# Deve mostrar: feature/012-test-worktree-dark-mode

# Abrir PR contra ia-main
gh pr create --base ia-main --title "012: Adiciona dark mode toggle" --body "Closes task 012"
```

### 4. Após PR Mergeado
```bash
# Voltar para raiz
cd ../../..

# Remover worktree
git worktree remove .kiro/worktrees/012-test-worktree-dark-mode

# Ou com força se necessário:
# git worktree remove --force .kiro/worktrees/012-test-worktree-dark-mode

# Limpar registros
git worktree prune

# (Opcional) Deletar branch local
git branch -d feature/012-test-worktree-dark-mode

# Notificar conclusão
```

---

## 📚 Referências
- [Worktree Workflow](.kiro/docs/worktree-workflow.md)
- [Worktree Steering](.kiro/docs/worktree-steering.md)
- [Task Template](.kiro/docs/task-template-with-worktree.md)
- [Demo Isolamento](.kiro/docs/demo-isolamento-worktrees.md)
