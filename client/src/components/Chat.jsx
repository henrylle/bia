import React, { useState, useEffect, useRef } from 'react';
import { io } from 'socket.io-client';
import './Chat.css';

const apiUrl = import.meta.env.VITE_API_URL || "http://localhost:8080";

// Som de notificação simples
const playNotificationSound = () => {
  const audioContext = new (window.AudioContext || window.webkitAudioContext)();
  const oscillator = audioContext.createOscillator();
  const gainNode = audioContext.createGain();
  
  oscillator.connect(gainNode);
  gainNode.connect(audioContext.destination);
  
  oscillator.frequency.value = 800;
  oscillator.type = 'sine';
  
  gainNode.gain.setValueAtTime(0.3, audioContext.currentTime);
  gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.3);
  
  oscillator.start(audioContext.currentTime);
  oscillator.stop(audioContext.currentTime + 0.3);
};

function Chat() {
  const [socket, setSocket] = useState(null);
  const [messages, setMessages] = useState([]);
  const [inputMessage, setInputMessage] = useState('');
  const [username, setUsername] = useState('');
  const [isJoined, setIsJoined] = useState(false);
  const [onlineCount, setOnlineCount] = useState(0);
  const [onlineUsers, setOnlineUsers] = useState([]);
  const [showSuggestions, setShowSuggestions] = useState(false);
  const [mentionSearch, setMentionSearch] = useState('');
  const [soundEnabled, setSoundEnabled] = useState(true);
  const [showUsersList, setShowUsersList] = useState(false);
  const messagesEndRef = useRef(null);
  const inputRef = useRef(null);
  const lastMessageCountRef = useRef(0);

  const handleLeaveChat = () => {
    if (socket) {
      socket.close();
    }
    setIsJoined(false);
    setMessages([]);
    setUsername('');
    setOnlineUsers([]);
  };

  useEffect(() => {
    const newSocket = io(apiUrl);
    setSocket(newSocket);

    newSocket.on('history', (history) => {
      setMessages(history);
    });

    newSocket.on('message', (msg) => {
      setMessages(prev => [...prev, msg]);
    });

    newSocket.on('user_joined', (data) => {
      setOnlineCount(data.count);
    });

    newSocket.on('user_left', (data) => {
      setOnlineCount(data.count);
    });

    newSocket.on('users_list', (users) => {
      setOnlineUsers(users);
    });

    return () => newSocket.close();
  }, []);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
    
    // Tocar som quando chegar nova mensagem (exceto a própria)
    if (messages.length > lastMessageCountRef.current && lastMessageCountRef.current > 0) {
      const lastMessage = messages[messages.length - 1];
      if (lastMessage.username !== username && soundEnabled) {
        playNotificationSound();
      }
    }
    lastMessageCountRef.current = messages.length;
  }, [messages, username, soundEnabled]);

  const handleJoin = (e) => {
    e.preventDefault();
    if (username.trim() && socket) {
      socket.emit('join', username.trim());
      setIsJoined(true);
    }
  };

  const handleInputChange = (e) => {
    const value = e.target.value;
    setInputMessage(value);

    const lastAtIndex = value.lastIndexOf('@');
    if (lastAtIndex !== -1 && lastAtIndex === value.length - 1) {
      setShowSuggestions(true);
      setMentionSearch('');
    } else if (lastAtIndex !== -1 && value[lastAtIndex] === '@') {
      const searchTerm = value.slice(lastAtIndex + 1);
      if (!searchTerm.includes(' ')) {
        setMentionSearch(searchTerm);
        setShowSuggestions(true);
      } else {
        setShowSuggestions(false);
      }
    } else {
      setShowSuggestions(false);
    }
  };

  const handleMentionSelect = (user) => {
    const lastAtIndex = inputMessage.lastIndexOf('@');
    const newMessage = inputMessage.slice(0, lastAtIndex) + `@${user} `;
    setInputMessage(newMessage);
    setShowSuggestions(false);
    inputRef.current?.focus();
  };

  const handleSendMessage = (e) => {
    e.preventDefault();
    if (inputMessage.trim() && socket) {
      socket.emit('message', { text: inputMessage.trim() });
      setInputMessage('');
      setShowSuggestions(false);
    }
  };

  const renderMessage = (text) => {
    const parts = text.split(/(@\w+)/g);
    return parts.map((part, i) => {
      if (part.startsWith('@')) {
        return <span key={i} className="mention">{part}</span>;
      }
      return part;
    });
  };

  const isMentioned = (text) => {
    return text.includes(`@${username}`);
  };

  const filteredUsers = onlineUsers.filter(user => 
    user !== username && user.toLowerCase().includes(mentionSearch.toLowerCase())
  );

  if (!isJoined) {
    return (
      <div className="chat-container">
        <div className="chat-join">
          <h2>💬 Chat BIA</h2>
          <p>Entre com seu nome para participar</p>
          <form onSubmit={handleJoin}>
            <input
              type="text"
              placeholder="Seu nome..."
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              maxLength={20}
            />
            <button type="submit">Entrar</button>
          </form>
        </div>
      </div>
    );
  }

  return (
    <div className="chat-container">
      <div className="chat-header">
        <h2>💬 Chat BIA</h2>
        <div className="header-actions">
          <button 
            onClick={() => setShowUsersList(!showUsersList)}
            className="users-toggle"
            title="Ver usuários online"
          >
            👥 {onlineCount}
          </button>
          <button 
            onClick={() => setSoundEnabled(!soundEnabled)}
            className="sound-toggle"
            title={soundEnabled ? "Desativar som" : "Ativar som"}
          >
            {soundEnabled ? '🔔' : '🔕'}
          </button>
          <button 
            onClick={handleLeaveChat}
            className="leave-button"
            title="Sair do chat"
          >
            🚪
          </button>
        </div>
      </div>
      
      <div className="chat-messages">
        {messages.map((msg) => (
          <div 
            key={msg.id} 
            className={`message ${msg.username === username ? 'own' : ''} ${isMentioned(msg.text) ? 'mentioned' : ''}`}
          >
            <strong>{msg.username}:</strong> {renderMessage(msg.text)}
          </div>
        ))}
        <div ref={messagesEndRef} />
      </div>

      {showUsersList && (
        <div className="users-list">
          <div className="users-list-header">
            <span>Usuários Online ({onlineUsers.length})</span>
            <button onClick={() => setShowUsersList(false)}>✕</button>
          </div>
          <div className="users-list-content">
            {onlineUsers.map((user, i) => (
              <div key={i} className={`user-item ${user === username ? 'current' : ''}`}>
                <span className="user-status">●</span>
                {user}
                {user === username && <span className="you-badge">você</span>}
              </div>
            ))}
          </div>
        </div>
      )}

      <form className="chat-input" onSubmit={handleSendMessage}>
        <div className="input-wrapper">
          <input
            ref={inputRef}
            type="text"
            placeholder="Digite sua mensagem... (use @ para mencionar)"
            value={inputMessage}
            onChange={handleInputChange}
          />
          {showSuggestions && filteredUsers.length > 0 && (
            <div className="mention-suggestions">
              {filteredUsers.map((user, i) => (
                <div 
                  key={i} 
                  className="mention-item"
                  onClick={() => handleMentionSelect(user)}
                >
                  @{user}
                </div>
              ))}
            </div>
          )}
        </div>
        <button type="submit">Enviar</button>
      </form>
    </div>
  );
}

export default Chat;
