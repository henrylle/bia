# 💬 Chat BIA - Guia Rápido

## ✅ O que foi implementado

Sistema de chat em tempo real com WebSocket integrado ao projeto BIA, seguindo a filosofia educacional de simplicidade e evolução gradual.

## 🎯 Características

- ✅ WebSocket com Socket.IO
- ✅ Interface estilo Discord
- ✅ Mensagens em tempo real
- ✅ Contador de usuários online
- ✅ Feature flag (ENABLE_CHAT)
- ✅ Preparado para evoluções (Redis, cache, etc)

## 🚀 Como usar

### Opção 1: Docker Compose (Recomendado)

```bash
# O chat já está habilitado por padrão no compose.yml
docker compose up --build

# Acesse: http://localhost:3001/chat
```

### Opção 2: Desenvolvimento local

**1. Instalar dependências:**
```bash
npm install
cd client && npm install
```

**2. Ativar o chat:**

Backend - Criar arquivo `.env` na raiz:
```bash
ENABLE_CHAT=true
```

Frontend - Criar arquivo `client/.env`:
```bash
VITE_ENABLE_CHAT=true
VITE_API_URL=http://localhost:8080
```

**3. Rodar:**
```bash
npm start
cd client && npm run dev
```

### 3. Desativar o chat (opcional)

Para desativar, basta comentar ou mudar para `false`:

**compose.yml:**
```yaml
environment:
  ENABLE_CHAT: "false"  # ou comente a linha
```

**Dockerfile:**
```dockerfile
# Remova VITE_ENABLE_CHAT=true da linha de build
RUN cd client && VITE_API_URL=http://localhost:3001 npm run build
```

### 4. Acessar o chat

**Com Docker Compose:**
```
http://localhost:3001/chat
```

**Desenvolvimento local:**
```
http://localhost:8080/chat
```

## 📱 Como testar

1. Abra múltiplas abas do navegador
2. Entre com nomes diferentes em cada aba
3. Envie mensagens e veja a sincronização em tempo real
4. Observe o contador de usuários online

## 🔧 Troubleshooting

**Chat não aparece no menu?**
- Verifique se `VITE_ENABLE_CHAT=true` está no `client/.env`
- Rebuild do frontend: `cd client && npm run build`

**WebSocket não conecta?**
- Verifique se `ENABLE_CHAT=true` está no backend
- Confirme que o servidor está rodando
- Verifique o console do navegador para erros

**Mensagens não aparecem?**
- Abra o DevTools e veja a aba Network > WS
- Verifique se a conexão WebSocket está estabelecida