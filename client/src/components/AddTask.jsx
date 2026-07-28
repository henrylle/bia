import React, { useState } from "react";
import DatePicker from "react-datepicker";
import { registerLocale } from "react-datepicker";
import { ptBR } from "date-fns/locale/pt-BR";
import "react-datepicker/dist/react-datepicker.css";
import "../styles/datepicker.css";
import Modal from "./Modal";

registerLocale("pt-BR", ptBR);

const AddTask = ({ onAdd }) => {
  const [titulo, setTitulo] = useState("");
  const [dia, setDia] = useState(null);
  const [importante, setImportante] = useState(false);
  const [showModal, setShowModal] = useState(false);

  const onSubmit = (e) => {
    e.preventDefault();

    if (!titulo.trim()) {
      setShowModal(true);
      return;
    }

    const formatDateToString = (date) => {
      if (!date) return new Date().toLocaleDateString('pt-BR');
      return date.toLocaleDateString('pt-BR');
    };

    onAdd({ 
      titulo: titulo.trim(), 
      dia_atividade: formatDateToString(dia), 
      importante 
    });

    setTitulo("");
    setDia(null);
    setImportante(false);
  };

  return (
    <form className="add-form" onSubmit={onSubmit}>
      <div className="form-control">
        <label>Tarefa</label>
        <input
          type="text"
          placeholder="O que você precisa fazer?"
          value={titulo}
          onChange={(e) => setTitulo(e.target.value)}
        />
      </div>
      
      <div className="form-control">
        <label>Data/Prazo</label>
        <DatePicker
          selected={dia}
          onChange={(date) => setDia(date)}
          locale="pt-BR"
          dateFormat="dd/MM/yyyy"
          placeholderText="Quando?"
          isClearable
          showYearDropdown
          scrollableYearDropdown
          yearDropdownItemNumber={15}
          className="datepicker-input"
          calendarClassName="datepicker-calendar"
        />
      </div>
      
      <div className="form-control-check">
        <input
          type="checkbox"
          id="importante"
          checked={importante}
          onChange={(e) => setImportante(e.target.checked)}
        />
        <label htmlFor="importante">Importante</label>
      </div>
      
      <button type="submit" className="btn btn-block success">
        Add New Task
      </button>
      
      <Modal
        isOpen={showModal}
        onClose={() => setShowModal(false)}
        title="Campo obrigatório"
        message="Por favor, adicione uma descrição para a tarefa"
        type="warning"
      />
    </form>
  );
};

export default AddTask;
