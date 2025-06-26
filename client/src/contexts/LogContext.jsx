import React, { createContext, useContext, useState, useEffect } from 'react';

const LogContext = createContext();

export const useLog = () => {
  const context = useContext(LogContext);
  if (!context) {
    throw new Error('useLog deve ser usado dentro de um LogProvider');
  }
  return context;
};

export const LogProvider = ({ children }) => {
  const [logs, setLogs] = useState([]);
  const [isLogVisible, setIsLogVisible] = useState(false);
  const [debugMode, setDebugMode] = useState(false);

  useEffect(() => {
    // Verifica se o modo debug está habilitado via environment variable
    const debugEnabled = import.meta.env.VITE_DEBUG_MODE === 'true';
    setDebugMode(debugEnabled);
    
    if (debugEnabled) {
      addLog('INFO', 'Modo debug habilitado', 'Sistema inicializado com logs visíveis');
    }
  }, []);

  const addLog = (type, message, details = null) => {
    const timestamp = new Date().toLocaleTimeString('pt-BR');
    const logEntry = {
      id: Date.now() + Math.random(),
      timestamp,
      type, // INFO, ERROR, SUCCESS, WARNING
      message,
      details,
    };

    setLogs(prev => [logEntry, ...prev].slice(0, 50)); // Mantém apenas os 50 logs mais recentes
    
    // Log no console também
    const logMethod = type === 'ERROR' ? 'error' : type === 'WARNING' ? 'warn' : 'log';
    console[logMethod](`[${timestamp}] ${type}: ${message}`, details || '');
  };

  const clearLogs = () => {
    setLogs([]);
    addLog('INFO', 'Logs limpos', 'Histórico de logs foi resetado');
  };

  const toggleLogVisibility = () => {
    setIsLogVisible(prev => !prev);
  };

  // Função para interceptar e logar requests da API
  const logApiRequest = (method, url, payload = null) => {
    addLog('INFO', `API ${method}`, `${url}${payload ? ' | Payload: ' + JSON.stringify(payload) : ''}`);
  };

  const logApiResponse = (method, url, status, data = null) => {
    const type = status >= 200 && status < 300 ? 'SUCCESS' : 'ERROR';
    const message = `API ${method} - ${status}`;
    const details = `${url} | Response: ${data ? JSON.stringify(data).substring(0, 100) : 'Sem dados'}`;
    addLog(type, message, details);
  };

  const logApiError = (method, url, error) => {
    addLog('ERROR', `API ${method} FALHOU`, `${url} | Erro: ${error.message}`);
  };

  return (
    <LogContext.Provider value={{
      logs,
      isLogVisible,
      debugMode,
      addLog,
      clearLogs,
      toggleLogVisibility,
      logApiRequest,
      logApiResponse,
      logApiError,
    }}>
      {children}
    </LogContext.Provider>
  );
}; 