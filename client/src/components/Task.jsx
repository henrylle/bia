import React from "react";
import { FaTimes, FaStar, FaRegStar } from "react-icons/fa";

const Task = ({ task, onDelete, onToggle, onToggleConcluida }) => {
  return (
    <div
      className={`task ${task.importante ? "reminder" : ""} ${
        task.concluida ? "task-done" : ""
      }`}
      onDoubleClick={() => onToggle(task.uuid)}
    >
      <label
        className="task-checkbox-wrapper"
        onClick={(e) => e.stopPropagation()}
        onDoubleClick={(e) => e.stopPropagation()}
      >
        <input
          type="checkbox"
          className="task-checkbox"
          checked={!!task.concluida}
          onChange={() => onToggleConcluida(task.uuid)}
          title={
            task.concluida ? "Marcar como pendente" : "Marcar como concluída"
          }
        />
      </label>
      <div className="task-content">
        <h3>{task.titulo}</h3>
        <p className="task-date">
          📅 {task.dia_atividade || "Sem data definida"}
        </p>
      </div>
      <div className="task-actions">
        <button
          className="task-priority"
          onClick={() => onToggle(task.uuid)}
          title={task.importante ? "Remover importante" : "Marcar importante"}
        >
          {task.importante ? <FaStar /> : <FaRegStar />}
        </button>
        <button
          className="task-delete"
          onClick={() => onDelete(task.uuid)}
          title="Excluir"
        >
          <FaTimes />
        </button>
      </div>
    </div>
  );
};

export default Task;
