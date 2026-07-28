# Task 006 - Implementar Calendário no Campo Data/Prazo

## 🔧 Configuração Inicial (LEIA ANTES DE INICIAR)

### Agent Responsável
**dev** - Este agent deve iniciar a implementação.

### Branch Base
**SEMPRE `ia-main`**

### Worktree
Esta task será implementada em worktree isolado em `.kiro/worktrees/006-feat-calendario-data-prazo/`

---

## ⚠️ CHECKLIST DE INÍCIO (OBRIGATÓRIO)

Antes de começar a implementar, o agent deve:

- [ ] **Verificar branch atual:** `git branch --show-current`
  - Se não estiver em `ia-main`, **PERGUNTAR** ao usuário se pode trocar
  - Aguardar autorização
  - Após autorização: `git checkout ia-main && git pull origin ia-main`

- [ ] **Mover task para doing:**
  ```bash
  mv .kiro/tasks/006-feat-calendario-data-prazo.md .kiro/tasks/doing/
  git add .kiro/tasks/
  git commit -m "move: task 006 para doing"
  git push origin ia-main
  ```

- [ ] **Criar worktree:**
  ```bash
  git worktree add .kiro/worktrees/006-feat-calendario-data-prazo -b feature/006-feat-calendario-data-prazo ia-main
  cd .kiro/worktrees/006-feat-calendario-data-prazo
  git branch --show-current  # Confirmar branch correto
  ```

---

## 📋 Descrição

Implementar um componente de calendário (date picker) no campo "Data/Prazo" da tela Home da BIA, substituindo o input text atual por um seletor de data visual e intuitivo.

**Contexto Importante:** 
- Os dados no banco são persistidos como **STRING** (campo `dia_atividade`)
- A conversão entre Date e String deve ser feita no frontend
- Manter compatibilidade com o formato atual de data (dd/mm/yyyy ou localização pt-BR)

---

## 🎯 Objetivo

Melhorar a UX permitindo que o usuário selecione a data através de um calendário visual ao invés de digitar manualmente, mantendo a compatibilidade com o backend que persiste datas como string.

---

## 📝 História de Usuário

**Como** usuário da BIA  
**Quero** selecionar a data/prazo através de um calendário visual  
**Para que** eu possa escolher datas de forma mais rápida e intuitiva, evitando erros de digitação

---

## ✅ Critérios de Aceitação

1. ✅ O campo "Data/Prazo" deve exibir um ícone de calendário
2. ✅ Ao clicar no campo ou no ícone, um calendário visual deve aparecer
3. ✅ O usuário deve conseguir navegar entre meses/anos no calendário
4. ✅ Ao selecionar uma data, o campo deve ser preenchido automaticamente
5. ✅ O formato da data deve ser mantido como string no padrão brasileiro (dd/mm/yyyy)
6. ✅ O campo ainda deve aceitar digitação manual (fallback)
7. ✅ A data selecionada deve ser persistida corretamente no banco como string
8. ✅ O calendário deve ter boa usabilidade em mobile e desktop
9. ✅ O visual do calendário deve seguir o tema da aplicação (dark/light mode)

---

## 🛠️ Implementação

### 1. Escolha da Biblioteca de Date Picker

Analisar e escolher uma biblioteca leve e compatível com React 18:

**Opções sugeridas:**
- `react-datepicker` (mais popular, 13.7k stars)
- `react-day-picker` (moderna, TypeScript-first)
- Input nativo HTML5 `type="date"` (sem dependência, mas com limitações de estilo)

**Recomendação inicial:** `react-datepicker` por ser robusta e ter boa documentação.

### 2. Instalação da Dependência

```bash
cd client
npm install react-datepicker --save
npm install --save-dev @types/react-datepicker  # Se usar TypeScript
```

### 3. Modificação do Componente AddTask.jsx

**Arquivo:** `client/src/components/AddTask.jsx`

**Mudanças necessárias:**

- [ ] Importar o componente DatePicker
- [ ] Importar o CSS do date picker
- [ ] Alterar o estado `dia` para trabalhar com objeto Date
- [ ] Substituir o input text por DatePicker
- [ ] Configurar o DatePicker com:
  - Formato de exibição: `dd/MM/yyyy`
  - Localização: `pt-BR`
  - Placeholder: "Quando?"
  - Opção de limpar data
- [ ] Converter a data selecionada para string no formato pt-BR antes de enviar para o backend
- [ ] Manter fallback para o caso de data vazia (usar data atual)

**Exemplo de conversão Date → String:**
```javascript
const formatDateToString = (date) => {
  if (!date) return '';
  return date.toLocaleDateString('pt-BR');
};
```

### 4. Estilização do Date Picker

**Arquivo:** Criar `client/src/styles/datepicker.css` ou adicionar ao CSS existente

- [ ] Importar CSS padrão do react-datepicker
- [ ] Customizar cores para combinar com tema dark/light
- [ ] Garantir responsividade
- [ ] Ajustar z-index se necessário

**Dica:** O react-datepicker vem com CSS próprio que pode ser customizado.

### 5. Testes Manuais

- [ ] Testar seleção de data pelo calendário
- [ ] Testar navegação entre meses/anos
- [ ] Testar limpeza de data
- [ ] Testar digitação manual (se mantida)
- [ ] Testar salvamento da tarefa com data selecionada
- [ ] Testar formato da data no banco (verificar se está como string)
- [ ] Testar em mobile (responsividade)
- [ ] Testar mudança de tema (dark/light mode)

---

## 🔍 Validações Técnicas

### Backend
- ✅ Não precisa alteração (campo `dia_atividade` já é string)
- ✅ Verificar se o formato dd/mm/yyyy é mantido

### Frontend
- ✅ Conversão correta de Date para String
- ✅ Tratamento de data nula/vazia
- ✅ Compatibilidade com React 18
- ✅ Bundle size aceitável (react-datepicker é ~230KB)

---

## 📦 Dependências

- `react-datepicker`: ^4.x ou superior
- Compatível com React 18.3.1

---

## 🎨 UX/UI

### Comportamento Esperado:
1. Usuário clica no campo "Data/Prazo"
2. Calendário abre automaticamente
3. Usuário navega até o mês/ano desejado
4. Usuário clica na data
5. Calendário fecha
6. Campo é preenchido com a data no formato dd/mm/yyyy

### Estados do Campo:
- **Vazio:** Exibir placeholder "Quando?"
- **Com data:** Exibir data formatada (ex: 28/07/2026)
- **Foco:** Abrir calendário
- **Hover:** Indicar interatividade (cursor pointer, borda destacada)

---

## 📚 Referências

- [React DatePicker Docs](https://reactdatepicker.com/)
- [Localização pt-BR do date-fns](https://date-fns.org/v2.29.3/docs/Locale)
- [Worktree Workflow](.kiro/docs/worktree-workflow.md)
- [Worktree Steering](.kiro/docs/worktree-steering.md)

---

## 📊 Estimativa

**Complexidade:** Baixa  
**Tempo estimado:** 2-3 horas  
**Impacto:** Alto (melhora significativa na UX)

---

## ⚠️ Observações Importantes

1. **Manter formato string no banco:** A conversão Date → String deve ser transparente para o backend
2. **Não quebrar funcionalidade existente:** Se o calendário falhar, o campo deve continuar funcionando
3. **Acessibilidade:** Garantir que o date picker seja acessível via teclado (Tab, Enter, Esc)
4. **Performance:** Lazy load do CSS se possível

---

## 🔄 Definition of Done (DoD)

- [ ] Biblioteca de date picker instalada e configurada
- [ ] Componente AddTask.jsx atualizado com DatePicker
- [ ] Data convertida corretamente para string (dd/mm/yyyy)
- [ ] Calendário funcional em desktop
- [ ] Calendário funcional em mobile
- [ ] Visual integrado ao tema da aplicação
- [ ] Testes manuais realizados com sucesso
- [ ] Data persistida corretamente no banco como string
- [ ] Código commitado com mensagens descritivas
- [ ] Push realizado para o branch feature/006-feat-calendario-data-prazo

---

## ⚠️ FINALIZAÇÃO DA TASK (OBRIGATÓRIO)

Quando o agent concluir a implementação:

### 1. Verificação Final
```bash
# Garantir que está no worktree correto
pwd
# Deve estar em: /Users/henrylle/Projetos/formacaoaws/bia/.kiro/worktrees/006-feat-calendario-data-prazo

# Verificar branch
git branch --show-current
# Deve mostrar: feature/006-feat-calendario-data-prazo
```

### 2. Commit e Push Final
```bash
git add .
git commit -m "feat: implementa calendário no campo Data/Prazo"
git push origin feature/006-feat-calendario-data-prazo
```

### 3. Voltar para Raiz e Notificar PO
```bash
cd ../../..  # Voltar para raiz do projeto
```

**NOTIFICAR O PO:**
> "Task 006 concluída. Todos os itens do checklist marcados. Branch `feature/006-feat-calendario-data-prazo` com push realizado. Calendário implementado com react-datepicker, mantendo compatibilidade com formato string no banco. Aguardando revisão do PO para encerramento e abertura de PR."

**⚠️ NÃO REMOVER O WORKTREE. Apenas o PO faz isso após o PR ser mergeado.**

---

## 🎯 ENCERRAMENTO PELO PO (QUANDO NOTIFICADO)

### 1. Revisão
```bash
# Entrar no worktree para revisar
cd .kiro/worktrees/006-feat-calendario-data-prazo

# Testar a funcionalidade:
# - Abrir a aplicação
# - Testar o calendário em diferentes cenários
# - Verificar formato da data salva
# - Testar responsividade
# - Verificar integração com tema

# Revisar código
# Verificar se todos os itens estão ✅
```

### 2. Aprovar e Mover para Done
```bash
# Voltar para raiz
cd ../../..

# Mover task para done
mv .kiro/tasks/doing/006-feat-calendario-data-prazo.md .kiro/tasks/done/

# Commit e push no ia-main
git checkout ia-main
git add .kiro/tasks/
git commit -m "move: task 006 para done"
git push origin ia-main
```

### 3. Abrir Pull Request
```bash
# ANTES de abrir PR: confirmar que está no branch da feature
cd .kiro/worktrees/006-feat-calendario-data-prazo
git branch --show-current
# Deve mostrar: feature/006-feat-calendario-data-prazo

# Abrir PR contra ia-main
gh pr create --base ia-main --title "006: Implementar calendário no campo Data/Prazo" --body "Closes task 006

## Mudanças
- Adicionado react-datepicker como dependência
- Substituído input text por DatePicker no componente AddTask
- Mantida compatibilidade com formato string (dd/mm/yyyy) no banco
- Customizado visual para seguir tema da aplicação

## Testes realizados
- ✅ Seleção de data via calendário
- ✅ Navegação entre meses/anos
- ✅ Persistência correta como string
- ✅ Responsividade mobile/desktop
- ✅ Integração com tema dark/light"
```

### 4. Após PR Mergeado
```bash
# Voltar para raiz
cd ../../..

# Remover worktree
git worktree remove .kiro/worktrees/006-feat-calendario-data-prazo

# Ou com força se necessário:
# git worktree remove --force .kiro/worktrees/006-feat-calendario-data-prazo

# Limpar registros
git worktree prune

# (Opcional) Deletar branch local
git branch -d feature/006-feat-calendario-data-prazo

# Notificar conclusão
```

**Notificação:** "Task 006 finalizada. Worktree removido. PR #X mergeado com sucesso. Calendário implementado com sucesso na tela Home."
