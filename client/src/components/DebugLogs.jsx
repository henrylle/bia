import React from 'react';
import { FaBug, FaTimes, FaTrash, FaChevronDown, FaChevronUp } from 'react-icons/fa';
import { useLog } from '../contexts/LogContext.jsx';

const DebugLogs = () => {
  const { logs, isLogVisible, debugMode, clearLogs, toggleLogVisibility } = useLog();

  if (!debugMode) return null;

  const getLogIcon = (type) => {
    switch (type) {
      case 'ERROR': return '🔴';
      case 'SUCCESS': return '🟢';
      case 'WARNING': return '🟡';
      default: return '🔵';
    }
  };

  const getLogClass = (type) => {
    switch (type) {
      case 'ERROR': return 'log-error';
      case 'SUCCESS': return 'log-success';
      case 'WARNING': return 'log-warning';
      default: return 'log-info';
    }
  };

  return (
    <div className="debug-logs">
      <div className="debug-header">
        <button 
          className="debug-toggle"
          onClick={toggleLogVisibility}
          title={isLogVisible ? "Ocultar logs" : "Mostrar logs"}
        >
          <FaBug />
          <span>Debug ({logs.length})</span>
          {isLogVisible ? <FaChevronUp /> : <FaChevronDown />}
        </button>
        
        {isLogVisible && (
          <button 
            className="debug-clear"
            onClick={clearLogs}
            title="Limpar logs"
          >
            <FaTrash />
          </button>
        )}
      </div>

      {isLogVisible && (
        <div className="debug-content">
          <div className="debug-info">
            <h4>🔧 Área de Debug</h4>
            <p>Esta área mostra logs da API para facilitar o debug durante o desenvolvimento.</p>
            <p><strong>URL da API:</strong> {import.meta.env.VITE_API_URL || "http://localhost:8080"}</p>
          </div>
          
          <div className="logs-container">
            {logs.length === 0 ? (
              <div className="no-logs">
                <p>Nenhum log ainda. Interaja com a aplicação para ver os logs aparecerem aqui.</p>
              </div>
            ) : (
              logs.map((log) => (
                <div key={log.id} className={`log-entry ${getLogClass(log.type)}`}>
                  <div className="log-header">
                    <span className="log-icon">{getLogIcon(log.type)}</span>
                    <span className="log-time">{log.timestamp}</span>
                    <span className="log-type">{log.type}</span>
                    <span className="log-message">{log.message}</span>
                  </div>
                  {log.details && (
                    <div className="log-details">
                      {log.details}
                    </div>
                  )}
                </div>
              ))
            )}
          </div>
        </div>
      )}
    </div>
  );
};

export default DebugLogs; 