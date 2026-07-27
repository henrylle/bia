- Sempre que você estiver implementando uma task, você deve ir gradualmente marcado as etapas que forem concluídas.
- Sempre ao terminar a implementação da task, me avise que tudo está pronto e sinalize qual o próximo agent que deverá ser chamado.
- **OBRIGATÓRIO**: Ao finalizar qualquer implementação, você DEVE executar o processo completo de rebuild:
  1. `docker compose down`
  2. `docker compose build server`
  3. `docker compose up -d`
  4. Testar se a aplicação está funcionando (`curl -s http://localhost:3001/api/versao`)
- Este processo garante que todas as mudanças no código sejam aplicadas corretamente no container.