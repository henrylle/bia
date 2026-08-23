import React, { useState, useEffect, useCallback } from "react";
import { FaHistory, FaCalendarAlt, FaExclamationCircle } from "react-icons/fa";

const apiUrl = import.meta.env.VITE_API_URL || "http://localhost:8080";

const HistoricoVersoes = ({ refreshTrigger }) => {
  const [versoes, setVersoes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const fetchVersoes = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      const res = await fetch(`${apiUrl}/api/tarefas/versoes`);
      if (!res.ok) {
        throw new Error(`HTTP ${res.status}: ${res.statusText}`);
      }
      const data = await res.json();
      setVersoes(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, []);

  // Busca ao montar e sempre que refreshTrigger mudar (nova tarefa adicionada)
  useEffect(() => {
    fetchVersoes();
  }, [fetchVersoes, refreshTrigger]);

  const formatDate = (dateString) => {
    if (!dateString) return "—";
    try {
      return new Date(dateString).toLocaleString("pt-BR", {
        day: "2-digit",
        month: "2-digit",
        year: "numeric",
        hour: "2-digit",
        minute: "2-digit",
      });
    } catch {
      return dateString;
    }
  };

  return (
    <div className="historico-versoes">
      <div className="historico-header">
        <FaHistory className="historico-icon" />
        <h3>Histórico de Versões</h3>
        <span className="historico-count">{versoes.length}</span>
      </div>

      {loading && (
        <div className="historico-estado">
          <p className="historico-loading">Carregando histórico...</p>
        </div>
      )}

      {!loading && error && (
        <div className="historico-estado historico-erro">
          <FaExclamationCircle />
          <p>Erro ao carregar: {error}</p>
        </div>
      )}

      {!loading && !error && versoes.length === 0 && (
        <div className="historico-estado">
          <p className="historico-vazio">Nenhuma versão registrada ainda</p>
        </div>
      )}

      {!loading && !error && versoes.length > 0 && (
        <ul className="historico-lista">
          {versoes.map((versao) => (
            <li key={versao.id} className="historico-item">
              <div className="historico-item-numero">
                <span className="versao-badge">v{versao.versao}</span>
              </div>
              <div className="historico-item-info">
                <p className="historico-item-titulo">{versao.titulo}</p>
                {versao.dia_atividade && (
                  <p className="historico-item-prazo">
                    <FaCalendarAlt className="historico-item-icon" />
                    {versao.dia_atividade}
                  </p>
                )}
                <p className="historico-item-data">
                  Registrado em: {formatDate(versao.createdAt)}
                </p>
              </div>
              {versao.importante && (
                <span className="historico-item-importante" title="Importante">
                  ⚡
                </span>
              )}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
};

export default HistoricoVersoes;
