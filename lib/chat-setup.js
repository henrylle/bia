const http = require('http');
const path = require('path');

function setupChatServer(app) {
  const server = http.createServer(app);
  
  // Inicializar WebSocket se ENABLE_CHAT estiver ativo
  if (process.env.ENABLE_CHAT === 'true') {
    try {
      const chatServerPath = path.join(__dirname, '..', 'api', 'chat', 'server');
      const { initChatServer } = require(chatServerPath);
      initChatServer(server);
      console.log('[CHAT] WebSocket habilitado');
    } catch (error) {
      console.log('[CHAT] Erro ao carregar módulo:', error.message);
    }
  }
  
  return server;
}

module.exports = { setupChatServer };
