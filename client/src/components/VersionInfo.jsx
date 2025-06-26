import React, { useState, useEffect } from 'react';

const VersionInfo = () => {
  const [showVersion, setShowVersion] = useState(false);
  const [apiStatus, setApiStatus] = useState('checking'); // 'checking', 'online', 'offline'
  const [apiVersion, setApiVersion] = useState('4.0.0');

  const getApiUrl = () => {
    // Se estiver definido no ambiente (Docker/Produção)
    if (import.meta.env.VITE_API_URL) {
      return import.meta.env.VITE_API_URL;
    }
    
    // Se estiver rodando no mesmo domínio (produção integrada)
    if (window.location.port === '8080') {
      return window.location.origin;
    }
    
    // Desenvolvimento local - inferir porta 8080
    return 'http://localhost:8080';
  };

  const checkApiHealth = async () => {
    setApiStatus('checking');
    try {
      const apiUrl = getApiUrl();
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 5000); // 5s timeout
      
      const response = await fetch(`${apiUrl}/api/versao`, {
        signal: controller.signal,
        method: 'GET',
        cache: 'no-cache'
      });
      
      clearTimeout(timeoutId);
      
      if (response.ok) {
        const versionText = await response.text();
        setApiVersion(versionText);
        setApiStatus('online');
      } else {
        setApiStatus('offline');
      }
    } catch (error) {
      console.warn('API Health Check falhou:', error.message);
      setApiStatus('offline');
    }
  };

  useEffect(() => {
    checkApiHealth();
    // Recheck a cada 30 segundos
    const interval = setInterval(checkApiHealth, 30000);
    return () => clearInterval(interval);
  }, []);

  const handleVersionClick = () => {
    setShowVersion(!showVersion);
    if (!showVersion) {
      // Recheca quando abre o tooltip
      checkApiHealth();
    }
  };

  const openVersionEndpoint = () => {
    const apiUrl = getApiUrl();
    window.open(`${apiUrl}/api/versao`, '_blank');
  };

  const getStatusIcon = () => {
    switch (apiStatus) {
      case 'online': return '🟢';
      case 'offline': return '🔴';
      case 'checking': return '🟡';
      default: return '⚪';
    }
  };

  const getStatusText = () => {
    switch (apiStatus) {
      case 'online': return 'Online';
      case 'offline': return 'Offline';
      case 'checking': return 'Verificando...';
      default: return 'Desconhecido';
    }
  };

  const getEnvironmentInfo = () => {
    const { protocol, hostname, port } = window.location;
    
    // Detectar tipo de ambiente
    if (hostname === 'localhost' || hostname === '127.0.0.1') {
      return {
        type: 'local',
        icon: '🏠',
        label: 'Local',
        description: `${hostname}:${port}`,
        color: '#3b82f6' // azul
      };
    }
    
    // IP direto sem HTTPS
    if (/^\d+\.\d+\.\d+\.\d+$/.test(hostname) && protocol === 'http:') {
      return {
        type: 'ip-http',
        icon: '🌐',
        label: 'IP Direto',
        description: `${hostname}${port ? ':' + port : ''}`,
        color: '#f59e0b' // amarelo/laranja
      };
    }
    
    // ALB/Load Balancer sem HTTPS
    if (protocol === 'http:' && hostname.includes('.elb.')) {
      return {
        type: 'alb-http',
        icon: '⚖️',
        label: 'ALB HTTP',
        description: hostname,
        color: '#ef4444' // vermelho
      };
    }
    
    // Domínio com HTTPS (produção)
    if (protocol === 'https:') {
      return {
        type: 'domain-https',
        icon: '🔒',
        label: 'Produção',
        description: hostname,
        color: '#22c55e' // verde
      };
    }
    
    // Outros casos
    return {
      type: 'other',
      icon: '❓',
      label: 'Outro',
      description: `${hostname}${port ? ':' + port : ''}`,
      color: '#6b7280' // cinza
    };
  };

  return (
    <div className="version-info">
      <button 
        className={`version-trigger ${apiStatus} ${getEnvironmentInfo().type}`}
        onClick={handleVersionClick}
        title={`${getEnvironmentInfo().icon} ${getEnvironmentInfo().label} | API: ${getStatusText()}`}
        style={{
          borderColor: apiStatus === 'online' ? getEnvironmentInfo().color : 
                      apiStatus === 'offline' ? '#ef4444' : 
                      '#f59e0b'
        }}
      >
        {getStatusIcon()}
      </button>
             {showVersion && (
         <div className="version-tooltip">
           <div className="version-content">
             <strong>{apiVersion}</strong>
             <div className="version-details">
               <small>
                 <span className="status-indicator">{getStatusIcon()}</span>
                 Status: {getStatusText()}
               </small>
               <small>
                 <span 
                   className="env-indicator" 
                   style={{ color: getEnvironmentInfo().color }}
                 >
                   {getEnvironmentInfo().icon}
                 </span>
                 Ambiente: {getEnvironmentInfo().label}
               </small>
               <small>Local: {getEnvironmentInfo().description}</small>
               <small>API: {getApiUrl()}</small>
               <small>
                 <button 
                   className="version-link" 
                   onClick={openVersionEndpoint}
                   title="Abrir endpoint de versão"
                 >
                   🔗 /api/versao
                 </button>
               </small>
               <small>
                 <button 
                   className="version-link refresh-btn" 
                   onClick={checkApiHealth}
                   title="Verificar status da API"
                   disabled={apiStatus === 'checking'}
                 >
                   🔄 {apiStatus === 'checking' ? 'Verificando...' : 'Atualizar'}
                 </button>
               </small>
             </div>
           </div>
         </div>
       )}
    </div>
  );
};

export default VersionInfo; 