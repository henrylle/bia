import React, { useState } from 'react';

const VersionInfo = () => {
  const [showVersion, setShowVersion] = useState(false);

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

  const handleVersionClick = () => {
    setShowVersion(!showVersion);
  };

  const openVersionEndpoint = () => {
    const apiUrl = getApiUrl();
    window.open(`${apiUrl}/api/versao`, '_blank');
  };

  return (
    <div className="version-info">
      <button 
        className="version-trigger" 
        onClick={handleVersionClick}
        title="Informações da versão"
      >
        v
      </button>
             {showVersion && (
         <div className="version-tooltip">
           <div className="version-content">
             <strong>BIA 4.0.0</strong>
             <div className="version-details">
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
             </div>
           </div>
         </div>
       )}
    </div>
  );
};

export default VersionInfo; 