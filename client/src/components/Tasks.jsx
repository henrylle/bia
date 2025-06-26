import React, { useState, useEffect } from "react";
import Task from "./Task.jsx";

const Tasks = ({ tasks, onDelete, onToggle }) => {
  const [currentPage, setCurrentPage] = useState(1);
  const tasksPerPage = 5; // Mostrar 5 tarefas por página

  // Calcular tarefas da página atual
  const indexOfLastTask = currentPage * tasksPerPage;
  const indexOfFirstTask = indexOfLastTask - tasksPerPage;
  const currentTasks = tasks.slice(indexOfFirstTask, indexOfLastTask);
  
  // Calcular total de páginas
  const totalPages = Math.ceil(tasks.length / tasksPerPage);

  // Resetar para primeira página quando tasks mudam
  useEffect(() => {
    if (currentPage > totalPages && totalPages > 0) {
      setCurrentPage(1);
    }
  }, [tasks.length, totalPages, currentPage]);

  // Funções de navegação
  const goToPage = (pageNumber) => {
    setCurrentPage(pageNumber);
  };

  const goToPrevious = () => {
    if (currentPage > 1) {
      setCurrentPage(currentPage - 1);
    }
  };

  const goToNext = () => {
    if (currentPage < totalPages) {
      setCurrentPage(currentPage + 1);
    }
  };

  // Se não há tarefas, não mostrar nada
  if (tasks.length === 0) {
    return null;
  }

  return (
    <div className="tasks-container">
      {/* Lista de tarefas da página atual */}
      <div className="tasks-list">
        {currentTasks.map((task) => (
          <Task
            key={task.uuid}
            task={task}
            onDelete={onDelete}
            onToggle={onToggle}
          />
        ))}
      </div>

      {/* Controles de paginação */}
      {totalPages > 1 && (
        <div className="pagination">
          <div className="pagination-info">
            <span>
              Mostrando {indexOfFirstTask + 1}-{Math.min(indexOfLastTask, tasks.length)} de {tasks.length} tarefas
            </span>
          </div>
          
          <div className="pagination-controls">
            <button 
              className="pagination-btn"
              onClick={goToPrevious}
              disabled={currentPage === 1}
              title="Página anterior"
            >
              ‹
            </button>
            
            {/* Números das páginas */}
            {Array.from({ length: totalPages }, (_, index) => {
              const pageNumber = index + 1;
              
              // Mostrar sempre primeira, última e páginas próximas da atual
              if (
                pageNumber === 1 ||
                pageNumber === totalPages ||
                (pageNumber >= currentPage - 1 && pageNumber <= currentPage + 1)
              ) {
                return (
                  <button
                    key={pageNumber}
                    className={`pagination-btn ${currentPage === pageNumber ? 'active' : ''}`}
                    onClick={() => goToPage(pageNumber)}
                  >
                    {pageNumber}
                  </button>
                );
              }
              
              // Mostrar reticências
              if (
                pageNumber === currentPage - 2 ||
                pageNumber === currentPage + 2
              ) {
                return <span key={pageNumber} className="pagination-dots">...</span>;
              }
              
              return null;
            })}
            
            <button 
              className="pagination-btn"
              onClick={goToNext}
              disabled={currentPage === totalPages}
              title="Próxima página"
            >
              ›
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default Tasks;
