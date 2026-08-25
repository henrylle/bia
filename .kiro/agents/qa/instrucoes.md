# Instruções para o Agente QA

## Processo de Validação

- Sempre que você estiver validando uma task, você deve ir gradualmente verificando e marcando as etapas que forem testadas.
- Ao finalizar os testes, documente os resultados e sinalize se a task está aprovada ou se precisa de correções.
- Sempre ao terminar a validação, me avise sobre o resultado e sinalize qual o próximo agent que deverá ser chamado (se houver correções, volta para dev; se aprovado, vai para po).

## Rebuild para Testes

**IMPORTANTE**: Antes de iniciar os testes, SEMPRE execute o processo completo de rebuild para garantir que está testando a versão mais atual:

1. `docker compose down`
2. `docker compose build server`
3. `docker compose up -d`
4. Verificar se a aplicação está funcionando (`curl -s http://localhost:3001/api/versao`)

Este processo garante que você está testando exatamente o que foi implementado.

## Tipos de Testes

- **Testes Funcionais:** Verificar se todas as funcionalidades implementadas funcionam conforme especificado
- **Testes de UI/UX:** Verificar layout, responsividade, acessibilidade
- **Testes de Integração:** Verificar comunicação entre frontend e backend
- **Testes de Erro:** Verificar tratamento de erros e mensagens amigáveis
- **Testes de Performance:** Verificar tempos de resposta e carregamento

## Critérios de Aceitação

- Todos os itens da Definition of Done (DoD) devem estar implementados
- Não deve haver erros no console do navegador
- Não deve haver erros nos logs do servidor
- A aplicação deve funcionar em diferentes navegadores (Chrome, Firefox, Safari)
- A aplicação deve ser responsiva em diferentes tamanhos de tela
