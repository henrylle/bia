# Task 011 - Teste Worktree - Estilizar Botão de Atualizar

## 🔧 Configuração Inicial (LEIA ANTES DE INICIAR)

### Agent Responsável
**dev** - Este agent deve iniciar a implementação.

### Branch Base
**SEMPRE `ia-main`**

### Worktree
Esta task será implementada em worktree isolado em `.kiro/worktrees/011-test-worktree-estilo-botao/`

---

## ⚠️ CHECKLIST DE INÍCIO (OBRIGATÓRIO)

Antes de começar a implementar, o agent deve:

- [ ] **Verificar branch atual:** `git branch --show-current`
  - Se não estiver em `ia-main`, **PERGUNTAR** ao usuário se pode trocar
  - Aguardar autorização
  - Após autorização: `git checkout ia-main && git pull origin ia-main`

- [ ] **Mover task para doing:**
  ```bash
  mv .kiro/tasks/011-test-worktree-estilo-botao.md .kiro/tasks/doing/
  git add .kiro/tasks/
  git commit -m "move: task 011 para doing"
  git push origin ia-main
  ```

- [ ] **Criar worktree:**
  ```bash
  git worktree add .kiro/worktrees/011-test-worktree-estilo-botao -b feature/011-test-worktree-estilo-botao ia-main
  cd .kiro/worktrees/011-test-worktree-estilo-botao
  git branch --show-current  # Confirmar branch correto
  ```

---

## 📋 Descrição da Task
Aplicar estilos modernos ao botão "Atualizar" da tela de versão, incluindo hover effects e transições suaves.

## 🎯 Critérios de Aceitação
- [ ] Botão com cores mais vibrantes (azul moderno)
- [ ] Adicionar efeito hover (mudança de cor)
- [ ] Transição suave nos estados
- [ ] Border radius mais arredondado
- [ ] Aumentar padding para melhor UX

## ✅ Definição de Pronto (DoD)
- [ ] Código implementado no worktree isolado
- [ ] Build do frontend realizado
- [ ] Teste visual do hover confirmado
- [ ] Commit e push no branch `feature/011-test-worktree-estilo-botao`

## 🔧 Observações Técnicas
- **Arquivo:** `client/src/index.css`
- **Classe CSS:** `.button-update` ou criar nova classe
- **Cores sugeridas:** 
  - Normal: `#3b82f6` (blue-500)
  - Hover: `#2563eb` (blue-600)
- **Transição:** `transition: all 0.3s ease`

## 💡 Exemplo de CSS
```css
.button-update {
  background-color: #3b82f6;
  color: white;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  border: none;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s ease;
}

.button-update:hover {
  background-color: #2563eb;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.4);
}
```

---

## ⚠️ FINALIZAÇÃO DA TASK (OBRIGATÓRIO)

Quando o agent concluir a implementação:

### 1. Verificação Final
```bash
# Garantir que está no worktree correto
pwd
# Deve estar em: /caminho/.kiro/worktrees/011-test-worktree-estilo-botao

# Verificar branch
git branch --show-current
# Deve mostrar: feature/011-test-worktree-estilo-botao
```

### 2. Commit e Push Final
```bash
git add .
git commit -m "test: estiliza botão de atualizar com hover effects"
git push -u origin feature/011-test-worktree-estilo-botao
```

### 3. Voltar para Raiz e Notificar PO
```bash
cd ../../..  # Voltar para raiz do projeto
```

**NOTIFICAR O PO:**
> "Task 011 concluída. Todos os itens do checklist marcados. Branch `feature/011-test-worktree-estilo-botao` com push realizado. Aguardando revisão do PO para encerramento e abertura de PR."

**⚠️ NÃO REMOVER O WORKTREE. Apenas o PO faz isso após o PR ser mergeado.**

---

## 🎯 ENCERRAMENTO PELO PO (QUANDO NOTIFICADO)

### 1. Revisão
```bash
# Entrar no worktree para revisar
cd .kiro/worktrees/011-test-worktree-estilo-botao

# Revisar código, testar funcionalidade
# Verificar se todos os itens estão ✅
```

### 2. Aprovar e Mover para Done
```bash
# Voltar para raiz
cd ../../..

# Mover task para done
mv .kiro/tasks/doing/011-test-worktree-estilo-botao.md .kiro/tasks/done/

# Commit e push no ia-main
git checkout ia-main
git add .kiro/tasks/
git commit -m "move: task 011 para done"
git push origin ia-main
```

### 3. Abrir Pull Request
```bash
# ANTES de abrir PR: confirmar que está no branch da feature
cd .kiro/worktrees/011-test-worktree-estilo-botao
git branch --show-current
# Deve mostrar: feature/011-test-worktree-estilo-botao

# Abrir PR contra ia-main
gh pr create --base ia-main --title "011: Estiliza botão de atualizar" --body "Closes task 011"
```

### 4. Após PR Mergeado
```bash
# Voltar para raiz
cd ../../..

# Remover worktree
git worktree remove .kiro/worktrees/011-test-worktree-estilo-botao

# Ou com força se necessário:
# git worktree remove --force .kiro/worktrees/011-test-worktree-estilo-botao

# Limpar registros
git worktree prune

# (Opcional) Deletar branch local
git branch -d feature/011-test-worktree-estilo-botao

# Notificar conclusão
```

---

## 📚 Referências
- [Worktree Workflow](.kiro/docs/worktree-workflow.md)
- [Worktree Steering](.kiro/docs/worktree-steering.md)
- [Task Template](.kiro/docs/task-template-with-worktree.md)
- [Demo Isolamento](.kiro/docs/demo-isolamento-worktrees.md)
