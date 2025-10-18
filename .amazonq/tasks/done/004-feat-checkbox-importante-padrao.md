# Task 004 - Checkbox Importante Marcado por Padrão

## Informações da Task
- **Número:** 004
- **Tipo:** feat
- **Branch:** feature/004-feat-checkbox-importante-padrao
- **Branch Base:** ia-main
- **Agent Responsável:** dev

## Modelo de Trabalho
- **Modelo:** feature/branch - cada task tem seu próprio branch
- **Branch Base:** SEMPRE derivar do branch `ia-main`
- **Verificação Inicial:** Agent deve verificar se está no branch `ia-main` antes de iniciar
- **Autorização:** Se não estiver no `ia-main`, deve informar e pedir autorização para retornar

## Descrição
Implementar funcionalidade para que o checkbox "importante" venha marcado por padrão na tela de cadastro de nova tarefa.

## História de Usuário
**Como** usuário do sistema  
**Eu quero** que o checkbox "importante" venha marcado por padrão ao cadastrar uma nova tarefa  
**Para que** eu não precise lembrar de marcar essa opção nas tarefas que considero importantes  

## Critérios de Aceitação
- [ ] O checkbox "importante" deve estar marcado (checked) por padrão na tela de cadastro
- [ ] O usuário pode desmarcar o checkbox se desejar
- [ ] A funcionalidade não deve afetar a edição de tarefas existentes
- [ ] O comportamento deve ser consistente em todos os navegadores

## Definição de Pronto
- [ ] Código implementado e testado
- [ ] Funcionalidade validada no frontend
- [ ] Não há regressões em outras funcionalidades

## Observações Técnicas
- Modificar apenas o estado inicial do checkbox no componente de cadastro
- Manter a lógica de salvamento inalterada
- Verificar se existe validação específica para o campo "importante"

## Checklist de Atividades (Agent Dev)
- [x] **Verificação Inicial:** Confirmar se está no branch `ia-main`
- [x] **Autorização:** Se necessário, pedir autorização para retornar ao `ia-main`
- [x] **Movimentação:** Mover task para `.amazonq/tasks/doing/`
- [x] **Commit Base:** Fazer commit e push no branch `ia-main`
- [x] **Criação Branch:** Criar branch `feature/004-feat-checkbox-importante-padrao`
- [x] **Análise Código:** Identificar componente de cadastro de tarefas
- [x] **Implementação:** Modificar estado inicial do checkbox "importante"
- [x] **Teste Local:** Validar funcionalidade no ambiente local
- [x] **Commit Feature:** Fazer commit e push da implementação
- [x] **Finalização:** Informar ao PO que a task está concluída para encerramento

## Processo de Finalização (PO)
**Quando o agent dev concluir todas as atividades acima, deve informar que a task precisa ser passada para o PO para encerramento.**

### Atividades do PO para Encerramento:
- [x] Verificar se todos os itens do checklist foram marcados
- [x] Validar se a implementação atende aos critérios de aceitação
- [x] Confirmar que não há regressões
- [x] Mover task para `.amazonq/tasks/done/`
- [x] Fazer commit e push final
- [x] Informar conclusão da task
