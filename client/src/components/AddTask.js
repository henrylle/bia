import { useState } from "react";

const AddTask = ({ onAdd }) => {
  const [titulo, setTitulo] = useState("");
  const [dia, setDia] = useState("");
  const [importante, setImportante] = useState(false);

  const onSubmit = (e) => {
    e.preventDefault();

    if (!titulo) {
      alert("Por favor, adicione uma tarefa");
      return;
    }

    onAdd({ titulo, dia, importante });

    setTitulo("");
    setDia("");
    setImportante(false);
  };

  return (
    <form className="add-form" onSubmit={onSubmit}>
      <div className="form-control">
        <label>Tarefa</label>
        <input
          type="text"
          placeholder="Adicionar Tarefa"
          value={titulo}
          onChange={(e) => setTitulo(e.target.value)}
        />
      </div>
      <div className="form-control">
        <label>Dia</label>
        <input
          type="text"
          placeholder="Adicione o Dia"
          value={dia}
          onChange={(e) => setDia(e.target.value)}
        />
      </div>
      <div className="form-control form-control-check">
        <label>Importante?</label>
        <input
          type="checkbox"
          checked={importante}
          value={importante}
          onChange={(e) => setImportante(e.currentTarget.checked)}
        />
      </div>
      <input type="submit" value="Salvar Tarefa" className="btn btn-block" />
    </form>
  );
};

export default AddTask;
