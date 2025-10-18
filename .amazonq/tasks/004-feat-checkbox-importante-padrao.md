# Task 004 - Checkbox Importante Marcado por Padrão

## Informações da Task
- **Número:** 004
- **Tipo:** feat
- **Branch:** feature/004-feat-checkbox-importante-padrao
- **Branch Base:** ia-main
- **Agent Responsável:** dev

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

## Instruções para o Agent
1. Verificar se está no branch ia-main
2. Mover task para pasta doing/
3. Fazer commit e push no ia-main
4. Criar branch feature/004-feat-checkbox-importante-padrao
5. Implementar a funcionalidade
6. Testar localmente
7. Fazer commit e push da implementação
