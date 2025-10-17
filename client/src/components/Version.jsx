import React, { useState, useEffect } from "react";
import { useLog } from "../contexts/LogContext.jsx";

const Version = () => {
  const [loading, setLoading] = useState(true);
  const [apiData, setApiData] = useState(null);
  const [error, setError] = useState(null);
  const { logApiRequest, logApiResponse, logApiError, addLog } = useLog();

  const apiUrl = import.meta.env.VITE_API_URL || "http://localhost:8080";

  const getEnvironmentInfo = () => {
    const { protocol, hostname, port } = window.location;
    
    if (hostname === 'localhost' || hostname === '127.0.0.1') {
      return { type: 'Local', icon: '🏠', color: '#3b82f6' };
    }
    
    if (/^\d+\.\d+\.\d+\.\d+$/.test(hostname) && protocol === 'http:') {
      return { type: 'IP Direto', icon: '🌐', color: '#f59e0b' };
    }
    
    if (protocol === 'http:' && hostname.includes('.elb.')) {
      return { type: 'ALB HTTP', icon: '⚖️', color: '#ef4444' };
    }
    
    if (protocol === 'https:') {
      return { type: 'Produção', icon: '🔒', color: '#22c55e' };
    }
    
    return { type: 'Outro', icon: '❓', color: '#6b7280' };
  };

  const fetchVersionInfo = async () => {
    setLoading(true);
    setError(null);
    
    const url = `${apiUrl}/api/versao`;
    logApiRequest('GET', url);
    
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 10000);
      
      const res = await fetch(url, {
        signal: controller.signal,
        method: 'GET',
        cache: 'no-cache'
      });
      
      clearTimeout(timeoutId);
      
      if (!res.ok) {
        throw new Error(`HTTP ${res.status}: ${res.statusText}`);
      }
      
      const data = await res.text();
      
      logApiResponse('GET', url, res.status, data);
      
      setApiData({
        version: data,
        status: 'online',
        timestamp: new Date().toLocaleString()
      });
      
      addLog('SUCCESS', 'Versão carregada', `API respondeu: ${data}`);
    } catch (error) {
      logApiError('GET', url, error);
      setError(error.message);
      addLog('ERROR', 'Falha ao carregar versão', error.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    addLog('INFO', 'Tela de versão carregada', `Verificando API: ${apiUrl}`);
    fetchVersionInfo();
  }, []);

  const handleRefresh = () => {
    fetchVersionInfo();
  };

  const environment = getEnvironmentInfo();

  return (
    <div className="version-page">
      <div className="version-header">
        <h2>Informações de Versão</h2>
        <button 
          className="refresh-btn"
          onClick={handleRefresh}
          disabled={loading}
          title="Atualizar informações"
        >
          🔄 {loading ? 'Verificando...' : 'Atualizar'}
        </button>
      </div>

      <div className="version-cards">
        {/* Card da API */}
        <div className="version-card">
          <div className="card-header">
            <h3>🔌 Status da API</h3>
            <span className={`status-badge ${error ? 'offline' : 'online'}`}>
              {loading ? '🟡 Verificando...' : error ? '🔴 Offline' : '🟢 Online'}
            </span>
          </div>
          
          <div className="card-content">
            {loading ? (
              <div className="loading-state">
                <p>Verificando conectividade com a API...</p>
              </div>
            ) : error ? (
              <div className="error-state">
                <p><strong>Erro:</strong> {error}</p>
                <p><strong>URL:</strong> {apiUrl}/api/versao</p>
              </div>
            ) : (
              <div className="success-state">
                <p><strong>Versão:</strong> {apiData.version}</p>
                <p><strong>URL:</strong> {apiUrl}</p>
                <p><strong>Última verificação:</strong> {apiData.timestamp}</p>
              </div>
            )}
          </div>
        </div>

        {/* Card do Ambiente */}
        <div className="version-card">
          <div className="card-header">
            <h3>{environment.icon} Ambiente</h3>
            <span 
              className="env-badge"
              style={{ backgroundColor: environment.color }}
            >
              {environment.type}
            </span>
          </div>
          
          <div className="card-content">
            <p><strong>Tipo:</strong> {environment.type}</p>
            <p><strong>Protocolo:</strong> {window.location.protocol}</p>
            <p><strong>Host:</strong> {window.location.hostname}</p>
            <p><strong>Porta:</strong> {window.location.port || 'Padrão'}</p>
            <p><strong>URL Completa:</strong> {window.location.href}</p>
          </div>
        </div>

        {/* Card do Cliente */}
        <div className="version-card">
          <div className="card-header">
            <h3>💻 Cliente</h3>
            <span className="status-badge online">🟢 Ativo</span>
          </div>
          
          <div className="card-content">
            <p><strong>Aplicação:</strong> BIA Client</p>
            <p><strong>Framework:</strong> React + Vite</p>
            <p><strong>Navegador:</strong> {navigator.userAgent.split(' ').pop()}</p>
            <p><strong>Plataforma:</strong> {navigator.platform}</p>
          </div>
        </div>
      </div>

      {/* Ações rápidas */}
      <div className="version-actions">
        <button 
          className="action-btn"
          onClick={() => window.open(`${apiUrl}/api/versao`, '_blank')}
          title="Abrir endpoint de versão em nova aba"
        >
          🔗 Abrir /api/versao
        </button>
        
        <button 
          className="action-btn"
          onClick={() => window.open(`${apiUrl}/api/tarefas`, '_blank')}
          title="Abrir endpoint de tarefas em nova aba"
        >
          📋 Abrir /api/tarefas
        </button>
      </div>
    </div>
  );
};

export default Version;
