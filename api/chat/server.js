const { Server } = require('socket.io');

// Armazena mensagens em memória (preparado para evoluir para Redis)
const messages = [];
const users = new Map();

function initChatServer(httpServer) {
  const io = new Server(httpServer, {
    cors: {
      origin: "*",
      methods: ["GET", "POST"]
    }
  });

  io.on('connection', (socket) => {
    console.log(`[CHAT] Usuário conectado: ${socket.id}`);

    socket.on('join', (username) => {
      users.set(socket.id, username);
      socket.emit('history', messages);
      io.emit('user_joined', { username, count: users.size });
      socket.emit('users_list', Array.from(users.values()));
      socket.broadcast.emit('users_list', Array.from(users.values()));
    });

    socket.on('message', (data) => {
      const msg = {
        id: Date.now(),
        username: users.get(socket.id) || 'Anônimo',
        text: data.text,
        timestamp: new Date().toISOString()
      };
      messages.push(msg);
      io.emit('message', msg);
    });

    socket.on('disconnect', () => {
      const username = users.get(socket.id);
      users.delete(socket.id);
      console.log(`[CHAT] Usuário desconectado: ${socket.id}`);
      if (username) {
        io.emit('user_left', { username, count: users.size });
        io.emit('users_list', Array.from(users.values()));
      }
    });
  });

  return io;
}

module.exports = { initChatServer };
