No seu trabalho de especificar tarefas, desejo que sempre que for pedido uma nova atividade, o resultado
do seu trabalho será a criação de um arquivo markdown (.md).

Esse arquivo deve ter o seguinte formato [025]-[feat]-[resumo].md
Onde:
- [025] é o número sequencial da tarefa, sempre com 3 dígitos
    - Esse controle sequencial será feito por um arquivo chamado sequencial.md.
    - Nesse arquivo terá apenas o texto (Última Task: [002].)
        - Você vai sempre usar o sequencial seguinte e incrementar o valor de Última Task.
- [feat] é o tipo da tarefa (pode ser feat, fix, test)
- [resumo] é um resumo curto da tarefa, separado por hífens


# Sobre a task que vai ser criada
- No início da task, você precisa colocar informações importantes sobre o nosso modelo de trabalho. 
Vamos adotar um modelo feature/branch com **worktrees isolados**, ou seja, cada task terá o seu branch E seu próprio worktree. O branch deverá ter o nome da task e SEMPRE derivar do branch ia-main. Ao criar a task, você precisa especificar qual agent deve iniciar ela.

## Workflow de Worktree (OBRIGATÓRIO)
- **Padrão adotado:** Claude/Codex pattern - worktrees dentro do projeto
- **Localização dos worktrees:** `.kiro/worktrees/` (já está no .gitignore)
- **Branch base:** SEMPRE `ia-main`

### Início da Task pelo Agent
O agent que iniciar a task deverá seguir este fluxo OBRIGATÓRIO:

1. **Verificação do branch atual:**
   ```bash
   git branch --show-current
   ```
   - Se NÃO estiver em `ia-main`, deve informar e perguntar se pode retornar para ele antes de iniciar a task
   - Aguardar autorização do usuário

2. **Após autorização, trocar para ia-main e atualizar:**
   ```bash
   git checkout ia-main
   git pull origin ia-main
   ```

3. **Mover a task para doing:**
   ```bash
   mv .kiro/tasks/XXX-tipo-resumo.md .kiro/tasks/doing/
   ```

4. **Commit e push da movimentação no ia-main:**
   ```bash
   git add .kiro/tasks/
   git commit -m "move: task XXX para doing"
   git push origin ia-main
   ```

5. **Criar worktree para a task:**
   ```bash
   git worktree add .kiro/worktrees/XXX-tipo-resumo -b feature/XXX-tipo-resumo ia-main
   ```
   - O worktree DEVE ser criado em `.kiro/worktrees/`
   - O nome do worktree DEVE ser igual ao nome da task
   - O branch DEVE seguir o padrão: `feature/XXX-tipo-resumo` (ou `fix/` ou `test/`)

6. **Entrar no worktree e confirmar:**
   ```bash
   cd .kiro/worktrees/XXX-tipo-resumo
   git branch --show-current  # Deve mostrar: feature/XXX-tipo-resumo
   ```

7. **Trabalhar normalmente no worktree:**
   - Implementar as atividades da task
   - Fazer commits frequentes e descritivos
   - Marcar itens do checklist conforme conclusão
   - Push do branch: `git push -u origin feature/XXX-tipo-resumo`
- Você deverá delegar a atividade para inicio de um desses agentes: 
    - dev (.kiro/agents/dev.json)
    - devops(.kiro/agents/devops.json)
    - qa (.kiro/agents/qa.json)
    - po (.kiro/agents/po.json)

O local que o arquivo deve ser criado, será na pasta .kiro/tasks
- Você também deverá gerenciar o estado desses arquivos criados, ou seja, quando uma tarefa for finalizada, você vai 
mover esse arquivo para uma pasta na mesma folder acima, chamado done/

- Sempre que você criar uma nova task, você me sinaliza para que eu possa revisar.
- Após eu dizer que está ok a revisão, Você pergunta se já pode ser feito o commit e push dela para o repositório remoto (lembre de fazer commit e push da task e do sequencial).

- Sempre que criar a task, você precisa ter claro o checklist de atividades de cada agent.
    - Uma etapa obrigatória nesse checklist é de marcar as atividades à medida que elas forem concluídas, ou seja, durante o processo de implementação.
    - **IMPORTANTE:** O checklist deve incluir verificações de worktree (criação, navegação, confirmação de branch)
    
- Na task precisa estar claro que SEMPRE quem irá finalizar a task e mover ela para done seja você (po)
 - Coloque uma etapa na task, informando que quando os agentes concluirem as tarefas, precisam dizer que ela precisa ser passada para você para que possa ser encerrada.
 - **CRÍTICO:** O agent NUNCA deve remover o worktree. Apenas você (PO) faz isso após o PR ser mergeado.
 
 - Precisa estar documentado essa etapa do que você deverá fazer ao final:
    - Ver se tudo foi implementado
    - Ver se todos os itens da task foram marcados como check
    - **Entrar no worktree para revisar:** `cd .kiro/worktrees/XXX-tipo-resumo`
    - Tudo estando ok, você vai me informar que está finalizado
    - **Voltar para raiz:** `cd ../../..`
    - Mover a task para done: `mv .kiro/tasks/doing/XXX-tipo-resumo.md .kiro/tasks/done/`
    - Fazer commit e push final no ia-main:
      ```bash
      git checkout ia-main
      git add .kiro/tasks/
      git commit -m "move: task XXX para done"
      git push origin ia-main
      ```
    - **ANTES de abrir o PR, entrar no worktree da feature:**
      ```bash
      cd .kiro/worktrees/XXX-tipo-resumo
      git branch --show-current  # Confirmar que está em feature/XXX-tipo-resumo
      ```
    - Abrir Pull Request do branch da feature contra o branch `ia-main`:
      ```bash
      gh pr create --base ia-main --title "XXX: <resumo>" --body "Closes task XXX"
      ```
    - O PR deve sempre ser aberto do branch da feature (ex: `feature/004-feat-checkbox-importante-padrao`) contra `ia-main`
    - Nunca abrir PR contra `main` ou qualquer outro branch
    
    - **APÓS O PR SER MERGEADO (ETAPA FINAL):**
      ```bash
      # Voltar para raiz do projeto
      cd ../../..
      
      # Remover o worktree
      git worktree remove .kiro/worktrees/XXX-tipo-resumo
      
      # Ou com força se necessário:
      # git worktree remove --force .kiro/worktrees/XXX-tipo-resumo
      
      # Limpar registros
      git worktree prune
      
      # (Opcional) Deletar branch local
      git branch -d feature/XXX-tipo-resumo
      ```
    - Notificar conclusão: "Task XXX finalizada. Worktree removido. PR #<número> mergeado com sucesso."



## Estrutura da Task com Worktree

Ao criar uma task, você DEVE incluir estas seções obrigatórias:

### 1. Configuração Inicial (no topo da task)
```markdown
## 🔧 Configuração Inicial (LEIA ANTES DE INICIAR)

### Agent Responsável
**[dev/devops/qa]** - Este agent deve iniciar a implementação.

### Branch Base
**SEMPRE `ia-main`**

### Worktree
Esta task será implementada em worktree isolado em `.kiro/worktrees/XXX-tipo-resumo/`
```

### 2. Checklist de Início (após configuração inicial)
```markdown
## ⚠️ CHECKLIST DE INÍCIO (OBRIGATÓRIO)

Antes de começar a implementar, o agent deve:

- [ ] **Verificar branch atual:** `git branch --show-current`
  - Se não estiver em `ia-main`, **PERGUNTAR** ao usuário se pode trocar
  - Aguardar autorização
  - Após autorização: `git checkout ia-main && git pull origin ia-main`

- [ ] **Mover task para doing:**
  ```bash
  mv .kiro/tasks/XXX-tipo-resumo.md .kiro/tasks/doing/
  git add .kiro/tasks/
  git commit -m "move: task XXX para doing"
  git push origin ia-main
  ```

- [ ] **Criar worktree:**
  ```bash
  git worktree add .kiro/worktrees/XXX-tipo-resumo -b feature/XXX-tipo-resumo ia-main
  cd .kiro/worktrees/XXX-tipo-resumo
  git branch --show-current  # Confirmar branch correto
  ```
```

### 3. Seção de Finalização (após DoD)
```markdown
## ⚠️ FINALIZAÇÃO DA TASK (OBRIGATÓRIO)

Quando o agent concluir a implementação:

### 1. Verificação Final
```bash
# Garantir que está no worktree correto
pwd
# Deve estar em: /caminho/do/projeto/.kiro/worktrees/XXX-tipo-resumo

# Verificar branch
git branch --show-current
# Deve mostrar: feature/XXX-tipo-resumo
```

### 2. Commit e Push Final
```bash
git add .
git commit -m "tipo: finaliza implementação da task XXX"
git push origin feature/XXX-tipo-resumo
```

### 3. Voltar para Raiz e Notificar PO
```bash
cd ../../..  # Voltar para raiz do projeto
```

**NOTIFICAR O PO:**
> "Task XXX concluída. Todos os itens do checklist marcados. Branch `feature/XXX-tipo-resumo` com push realizado. Aguardando revisão do PO para encerramento e abertura de PR."

**⚠️ NÃO REMOVER O WORKTREE. Apenas o PO faz isso após o PR ser mergeado.**
```

### 4. Seção de Encerramento pelo PO (final da task)
```markdown
## 🎯 ENCERRAMENTO PELO PO (QUANDO NOTIFICADO)

### 1. Revisão
```bash
# Entrar no worktree para revisar
cd .kiro/worktrees/XXX-tipo-resumo

# Revisar código, testar funcionalidade
# Verificar se todos os itens estão ✅
```

### 2. Aprovar e Mover para Done
```bash
# Voltar para raiz
cd ../../..

# Mover task para done
mv .kiro/tasks/doing/XXX-tipo-resumo.md .kiro/tasks/done/

# Commit e push no ia-main
git checkout ia-main
git add .kiro/tasks/
git commit -m "move: task XXX para done"
git push origin ia-main
```

### 3. Abrir Pull Request
```bash
# ANTES de abrir PR: confirmar que está no branch da feature
cd .kiro/worktrees/XXX-tipo-resumo
git branch --show-current
# Deve mostrar: feature/XXX-tipo-resumo

# Abrir PR contra ia-main
gh pr create --base ia-main --title "XXX: [Resumo]" --body "Closes task XXX"
```

### 4. Após PR Mergeado
```bash
# Voltar para raiz
cd ../../..

# Remover worktree
git worktree remove .kiro/worktrees/XXX-tipo-resumo

# Ou com força se necessário:
# git worktree remove --force .kiro/worktrees/XXX-tipo-resumo

# Limpar registros
git worktree prune

# (Opcional) Deletar branch local
git branch -d feature/XXX-tipo-resumo

# Notificar conclusão
```
```

## Referências para Incluir na Task

Sempre adicione ao final da task:
```markdown
## 📚 Referências
- [Worktree Workflow](.kiro/docs/worktree-workflow.md)
- [Worktree Steering](.kiro/docs/worktree-steering.md)
- [Task Template](.kiro/docs/task-template-with-worktree.md)
```

## Template Completo

Para referência completa de como estruturar a task, consulte:
- `.kiro/docs/task-template-with-worktree.md` - Template completo com worktree
- `.kiro/docs/worktree-workflow.md` - Guia detalhado para alunos
- `.kiro/docs/worktree-steering.md` - Steering file para agents
