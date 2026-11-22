import React from "react";
import { t } from "../i18n";
import { FaTimes, FaStar, FaRegStar } from "react-icons/fa";

const Task = ({ task, onDelete, onToggle }) => {
  return (
    <div
      className={`task ${task.importante ? "reminder" : ""}`}
      onDoubleClick={() => onToggle(task.uuid)}
    >
      <div className="task-content">
        <h3>{task.titulo}</h3>
        <p className="task-date">
          📅 {task.dia_atividade || t("semData")}
        </p>
      </div>
      <div className="task-actions">
        <button
          className="task-priority"
          onClick={() => onToggle(task.uuid)}
          title={task.importante ? t("removerImportante") : t("marcarImportante")}
        >
          {task.importante ? <FaStar /> : <FaRegStar />}
        </button>
        <button
          className="task-delete"
          onClick={() => onDelete(task.uuid)}
          title={t("excluir")}
        >
          <FaTimes />
        </button>
      </div>
    </div>
  );
};

export default Task;
