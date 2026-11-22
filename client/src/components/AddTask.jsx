import React, { useState } from "react";
import { t } from "../i18n";
import Modal from "./Modal";

const AddTask = ({ onAdd }) => {
  const [titulo, setTitulo] = useState("");
  const [dia, setDia] = useState("");
  const [importante, setImportante] = useState(false);
  const [showModal, setShowModal] = useState(false);

  const onSubmit = (e) => {
    e.preventDefault();

    if (!titulo.trim()) {
      setShowModal(true);
      return;
    }

    onAdd({ 
      titulo: titulo.trim(), 
      dia_atividade: dia || new Date().toLocaleDateString('pt-BR'), 
      importante 
    });

    setTitulo("");
    setDia("");
    setImportante(false);
  };

  return (
    <form className="add-form" onSubmit={onSubmit}>
      <div className="form-control">
        <label>{t("tarefa")}</label>
        <input
          type="text"
          placeholder={t("tarefaPlaceholder")}
          value={titulo}
          onChange={(e) => setTitulo(e.target.value)}
        />
      </div>
      
      <div className="form-control">
        <label>{t("prazo")}</label>
        <input
          type="text"
          placeholder={t("prazoPlaceholder")}
          value={dia}
          onChange={(e) => setDia(e.target.value)}
        />
      </div>
      
      <div className="form-control-check">
        <input
          type="checkbox"
          id="importante"
          checked={importante}
          onChange={(e) => setImportante(e.target.checked)}
        />
        <label htmlFor="importante">{t("importante")}</label>
      </div>
      
      <button type="submit" className="btn btn-block success">
        {t("adicionar")}
      </button>
      
      <Modal
        isOpen={showModal}
        onClose={() => setShowModal(false)}
        title={t("campoObrigatorio")}
        message={t("descricaoObrigatoria")}
        type="warning"
      />
    </form>
  );
};

export default AddTask;
