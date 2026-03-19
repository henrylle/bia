const app = require("./config/express")();
const port = app.get("port");
const { setupChatServer } = require('./lib/chat-setup');

// Criar servidor HTTP com suporte a chat
const server = setupChatServer(app);

// RODANDO NOSSA APLICAÇÃO NA PORTA SETADA
server.listen(port, () => {
  console.log(`Servidor rodando na porta ${port}`);
});
