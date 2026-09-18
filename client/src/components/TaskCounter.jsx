import React from "react";

const TaskCounter = ({ pendentes, concluidas }) => {
  return (
    <div className="task-counter-wrapper">
      <div className="task-counter" role="status" aria-live="polite">
        <span className="task-counter-item task-counter-pending">
          <strong>{pendentes}</strong> pendente{pendentes === 1 ? "" : "s"}
        </span>
        <span className="task-counter-separator">·</span>
        <span className="task-counter-item task-counter-done">
          <strong>{concluidas}</strong> concluída{concluidas === 1 ? "" : "s"}
        </span>
      </div>
    </div>
  );
};

export default TaskCounter;
