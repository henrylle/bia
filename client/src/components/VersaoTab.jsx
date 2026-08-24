import React, { useState, useEffect } from 'react';

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
    return { icon: '🏠', label: 'Local', description: `${hostname}:${port}`, color: '#3b82f6' };
  }
  if (/^\d+\.\d+\.\d+\.\d+$/.test(hostname) && protocol === 'http:') {
    return { icon: '🌐', label: 'IP Direto', description: `${hostname}${port ? ':' + port : ''}`, color: '#f59e0b' };
  }
  if (protocol === 'http:' && hostname.includes('.elb.')) {
    return { icon: '⚖️', label: 'ALB HTTP', description: hostname, color: '#ef4444' };
  }
  if (protocol === 'https:') {
    return { icon: '🔒', label: 'Produção', description: hostname, color: '#22c55e' };
  }
  return { icon: '❓', label: 'Outro', description: `${hostname}${port ? ':' + port : ''}`, color: '#6b7280' };
};

const VersaoTab = () => {
  const [apiStatus, setApiStatus] = useState('checking');
  const [versaoInfo, setVersaoInfo] = useState(null);

  const apiUrl = getApiUrl();
  const env = getEnvironmentInfo();

  const checkApiInfo = async () => {
    setApiStatus('checking');
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 5000);

      const response = await fetch(`${apiUrl}/api/versao/info`, {
        signal: controller.signal,
        cache: 'no-cache',
      });

      clearTimeout(timeoutId);

      if (response.ok) {
        const data = await response.json();
        setVersaoInfo(data);
        setApiStatus('online');
      } else {
        setApiStatus('offline');
      }
    } catch {
      setApiStatus('offline');
    }
  };

  useEffect(() => {
    checkApiInfo();
  }, []);

  const statusConfig = {
    online: { icon: '🟢', label: 'Online', className: 'status-online' },
    offline: { icon: '🔴', label: 'Offline', className: 'status-offline' },
    checking: { icon: '🟡', label: 'Verificando...', className: 'status-checking' },
  };

  const { icon: statusIcon, label: statusLabel, className: statusClass } =
    statusConfig[apiStatus] || statusConfig.checking;

  return (
    <div className="versao-tab">
      <div className="versao-tab-cards">

        <div className="versao-tab-card">
          <div className="versao-tab-card-label">Versão</div>
          <div className="versao-tab-card-value versao-tab-version">
            {versaoInfo ? `${versaoInfo.nome} ${versaoInfo.versao}` : '—'}
          </div>
        </div>

        <div className="versao-tab-card">
          <div className="versao-tab-card-label">Status da API</div>
          <div className={`versao-tab-card-value versao-tab-status ${statusClass}`}>
            <span>{statusIcon}</span> {statusLabel}
          </div>
        </div>

        <div className="versao-tab-card">
          <div className="versao-tab-card-label">Ambiente</div>
          <div className="versao-tab-card-value" style={{ color: env.color }}>
            {env.icon} {env.label}
            <div className="versao-tab-card-sub">{env.description}</div>
          </div>
        </div>

        <div className="versao-tab-card">
          <div className="versao-tab-card-label">URL da API</div>
          <div className="versao-tab-card-value versao-tab-url">{apiUrl}</div>
        </div>

      </div>

      <div className="versao-tab-actions">
        <button
          className="btn version-refresh-btn"
          onClick={checkApiInfo}
          disabled={apiStatus === 'checking'}
        >
          🔄 {apiStatus === 'checking' ? 'Verificando...' : 'Atualizar'}
        </button>
      </div>
    </div>
  );
};

export default VersaoTab;
