import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';

const getApiUrl = () => {
  if (import.meta.env.VITE_API_URL) {
    return import.meta.env.VITE_API_URL;
  }
  if (window.location.port === '8080') {
    return window.location.origin;
  }
  return 'http://localhost:8080';
};

const getEnvironmentInfo = () => {
  const { protocol, hostname, port } = window.location;

  if (hostname === 'localhost' || hostname === '127.0.0.1') {
    return { type: 'local', icon: '🏠', label: 'Local', description: `${hostname}:${port}`, color: '#3b82f6' };
  }

  if (/^\d+\.\d+\.\d+\.\d+$/.test(hostname) && protocol === 'http:') {
    return { type: 'ip-http', icon: '🌐', label: 'IP Direto', description: `${hostname}${port ? ':' + port : ''}`, color: '#f59e0b' };
  }

  if (protocol === 'http:' && hostname.includes('.elb.')) {
    return { type: 'alb-http', icon: '⚖️', label: 'ALB HTTP', description: hostname, color: '#ef4444' };
  }

  if (protocol === 'https:') {
    return { type: 'domain-https', icon: '🔒', label: 'Produção', description: hostname, color: '#22c55e' };
  }

  return { type: 'other', icon: '❓', label: 'Outro', description: `${hostname}${port ? ':' + port : ''}`, color: '#6b7280' };
};

const VersionPage = () => {
  const [apiStatus, setApiStatus] = useState('checking');
  const [apiVersion, setApiVersion] = useState('—');
  const [cacheConfig, setCacheConfig] = useState(null);
  const [lastChecked, setLastChecked] = useState(null);

  const apiUrl = getApiUrl();
  const env = getEnvironmentInfo();

  const checkApiHealth = async () => {
    setApiStatus('checking');
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 5000);

      const response = await fetch(`${apiUrl}/api/versao`, {
        signal: controller.signal,
        method: 'GET',
        cache: 'no-cache',
      });

      clearTimeout(timeoutId);

      if (response.ok) {
        const versionText = await response.text();
        setApiVersion(versionText);
        setApiStatus('online');

        try {
          const cacheRes = await fetch(`${apiUrl}/api/cache-config`, { cache: 'no-cache' });
          if (cacheRes.ok) setCacheConfig(await cacheRes.json());
        } catch {
          // cache-config opcional
        }
      } else {
        setApiStatus('offline');
      }
    } catch (error) {
      setApiStatus('offline');
    }

    setLastChecked(new Date().toLocaleTimeString('pt-BR'));
  };

  useEffect(() => {
    checkApiHealth();
  }, []);

  const statusConfig = {
    online: { icon: '🟢', label: 'Online', className: 'status-online' },
    offline: { icon: '🔴', label: 'Offline', className: 'status-offline' },
    checking: { icon: '🟡', label: 'Verificando...', className: 'status-checking' },
  };

  const { icon: statusIcon, label: statusLabel, className: statusClass } = statusConfig[apiStatus] || statusConfig.checking;

  return (
    <div className="version-page">
      <div className="version-page-header">
        <h2>Status da Aplicação</h2>
        <p className="version-page-subtitle">Informações de versão e conectividade com a API</p>
      </div>

      <div className="version-page-cards">

        <div className="version-card">
          <div className="version-card-label">Versão</div>
          <div className="version-card-value version-card-version">{apiVersion}</div>
        </div>

        <div className="version-card">
          <div className="version-card-label">Status da API</div>
          <div className={`version-card-value version-card-status ${statusClass}`}>
            <span className="status-dot">{statusIcon}</span>
            {statusLabel}
          </div>
        </div>

        <div className="version-card">
          <div className="version-card-label">Ambiente</div>
          <div className="version-card-value" style={{ color: env.color }}>
            <span>{env.icon}</span> {env.label}
            <div className="version-card-sub">{env.description}</div>
          </div>
        </div>

        <div className="version-card">
          <div className="version-card-label">URL da API</div>
          <div className="version-card-value version-card-url">{apiUrl}</div>
        </div>

        {cacheConfig && (
          <div className="version-card">
            <div className="version-card-label">Cache</div>
            <div className="version-card-value">
              {cacheConfig.enabled ? (
                <>
                  <span style={{ color: '#10b981' }}>🟢 Habilitado</span>
                  <div className="version-card-sub">
                    {cacheConfig.endpoint}:{cacheConfig.port} — TTL: {cacheConfig.ttl}s
                  </div>
                </>
              ) : (
                <span style={{ color: '#6b7280' }}>⚪ Desabilitado</span>
              )}
            </div>
          </div>
        )}

        {lastChecked && (
          <div className="version-card version-card-muted">
            <div className="version-card-label">Última verificação</div>
            <div className="version-card-value">{lastChecked}</div>
          </div>
        )}
      </div>

      <div className="version-page-actions">
        <button
          className="btn version-refresh-btn"
          onClick={checkApiHealth}
          disabled={apiStatus === 'checking'}
        >
          🔄 {apiStatus === 'checking' ? 'Verificando...' : 'Atualizar'}
        </button>
      </div>

      <div className="version-page-footer">
        <Link to="/" className="back-button">
          ← Voltar
        </Link>
      </div>
    </div>
  );
};

export default VersionPage;
