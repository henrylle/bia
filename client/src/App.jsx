import React, { useState, useEffect } from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import { ThemeProvider } from "./contexts/ThemeContext.jsx";
import { LogProvider, useLog } from "./contexts/LogContext.jsx";
import Header from "./components/Header.jsx";
import Footer from "./components/Footer.jsx";
import Tasks from "./components/Tasks.jsx";
import AddTask from "./components/AddTask.jsx";
import Modal from "./components/Modal.jsx";
import About from "./components/About.jsx";
import DebugLogs from "./components/DebugLogs.jsx";

const apiUrl = import.meta.env.VITE_API_URL || "http://localhost:8080";

function AppContent() {
  const [tasks, setTasks] = useState([]);
  const [fromCache, setFromCache] = useState(false);
  const [cacheTTL, setCacheTTL] = useState(null);
  const [showConfirmModal, setShowConfirmModal] = useState(false);
  const { logApiRequest, logApiResponse, logApiError, addLog } = useLog();

  useEffect(() => {
    addLog('INFO', 'Aplicação iniciada', `API URL configurada: ${apiUrl}`);
    getTasks();
  }, []);

  const getTasks = async () => {
    try {
      const response = await fetchTasks();
      if (response.data) {
        setTasks(response.data);
        setFromCache(response.fromCache);
        setCacheTTL(response.cacheTTL);
      } else {
        setTasks(response);
        setFromCache(false);
        setCacheTTL(null);
      }
    } catch (error) {
      addLog('ERROR', 'Falha ao carregar tarefas', error.message);
    }
  };

  //Listar Tarefas
  const fetchTasks = async () => {
    const url = `${apiUrl}/api/tarefas`;
    logApiRequest('GET', url);
    
    try {
      const res = await fetch(url);
      const data = await res.json();
      
      logApiResponse('GET', url, res.status, data);
      
      if (!res.ok) {
        throw new Error(`HTTP ${res.status}: ${res.statusText}`);
      }
      
      return data;
    } catch (error) {
      logApiError('GET', url, error);
      throw error;
    }
  };

  //Listar Tarefa
  const fetchTask = async (uuid) => {
    const url = `${apiUrl}/api/tarefas/${uuid}`;
    logApiRequest('GET', url);
    
    try {
      const res = await fetch(url);
      const data = await res.json();
      
      logApiResponse('GET', url, res.status, data);
      
      if (!res.ok) {
        throw new Error(`HTTP ${res.status}: ${res.statusText}`);
      }
      
      return data;
    } catch (error) {
      logApiError('GET', url, error);
      throw error;
    }
  };

  //Alternar Importante
  const toggleReminder = async (uuid) => {
    try {
      const taskToToggle = await fetchTask(uuid);
      const updatedTask = {
        ...taskToToggle,
        importante: !taskToToggle.importante,
      };

      const url = `${apiUrl}/api/tarefas/update_priority/${uuid}`;
      logApiRequest('PUT', url, updatedTask);

      const res = await fetch(url, {
        method: "PUT",
        headers: {
          "Content-type": "application/json",
        },
        body: JSON.stringify(updatedTask),
      });
      
      const data = await res.json();
      
      logApiResponse('PUT', url, res.status, data);
      
      if (!res.ok) {
        throw new Error(`HTTP ${res.status}: ${res.statusText}`);
      }
      
      setTasks(
        tasks.map((task) =>
          task.uuid === uuid ? { ...task, importante: data.importante } : task
        )
      );
      
      addLog('SUCCESS', 'Prioridade alterada', `Tarefa ${uuid} - Importante: ${data.importante}`);
    } catch (error) {
      addLog('ERROR', 'Falha ao alterar prioridade', error.message);
    }
  };

  //Adicionar Tarefa
  const addTask = async (task) => {
    const url = `${apiUrl}/api/tarefas`;
    logApiRequest('POST', url, task);
    
    try {
      const res = await fetch(url, {
        method: "POST",
        headers: {
          "Content-type": "application/json",
        },
        body: JSON.stringify(task),
      });
      
      const data = await res.json();
      
      logApiResponse('POST', url, res.status, data);
      
      if (!res.ok) {
        throw new Error(`HTTP ${res.status}: ${res.statusText}`);
      }
      
      setTasks([...tasks, data]);
      addLog('SUCCESS', 'Tarefa criada', `"${task.titulo}" adicionada com sucesso`);
    } catch (error) {
      logApiError('POST', url, error);
      addLog('ERROR', 'Falha ao criar tarefa', error.message);
    }
  };

  //Remover todas as tarefas
  const confirmDeleteAll = () => setShowConfirmModal(true);

  const deleteAllTasks = async () => {
    setShowConfirmModal(false);
    const url = `${apiUrl}/api/tarefas`;
    logApiRequest('DELETE', url);

    try {
      const res = await fetch(url, { method: "DELETE" });
      logApiResponse('DELETE', url, res.status);

      if (!res.ok) throw new Error(`HTTP ${res.status}: ${res.statusText}`);

      setTasks([]);
      addLog('SUCCESS', 'Todas as tarefas removidas');
      getTasks();
    } catch (error) {
      logApiError('DELETE', url, error);
      addLog('ERROR', 'Falha ao excluir todas as tarefas', error.message);
    }
  };

  //Remover tarefa
  const deleteTask = async (uuid) => {
    const url = `${apiUrl}/api/tarefas/${uuid}`;
    logApiRequest('DELETE', url);
    
    try {
      const res = await fetch(url, {
        method: "DELETE",
      });
      
      logApiResponse('DELETE', url, res.status);
      
      if (!res.ok) {
        throw new Error(`HTTP ${res.status}: ${res.statusText}`);
      }
      
      setTasks(tasks.filter((task) => task.uuid !== uuid));
      addLog('SUCCESS', 'Tarefa removida', `Tarefa ${uuid} excluída com sucesso`);
    } catch (error) {
      logApiError('DELETE', url, error);
      addLog('ERROR', 'Falha ao excluir tarefa', error.message);
    }
  };

  // Componente para página principal
  const HomePage = () => (
    <>
      <AddTask onAdd={addTask} />
      {tasks.length > 0 ? (
        <Tasks
          tasks={tasks}
          onDelete={deleteTask}
          onDeleteAll={confirmDeleteAll}
          onToggle={toggleReminder}
          fromCache={fromCache}
          cacheTTL={cacheTTL}
        />
      ) : (
        <div className="empty-state">
          <h3>Nenhuma tarefa por aqui 📝</h3>
          <p>Adicione sua primeira tarefa usando o formulário acima!</p>
        </div>
      )}
      <Modal
        isOpen={showConfirmModal}
        onClose={() => setShowConfirmModal(false)}
        onConfirm={deleteAllTasks}
        title="Limpar tudo"
        message="Tem certeza que deseja excluir todas as tarefas?"
        type="warning"
      />
    </>
  );

  return (
    <div className="app">
      <Router>
        <div className="container">
          <Header />

          <Routes>
            <Route path="/" element={<HomePage />} />
            <Route path="/about" element={<About />} />
          </Routes>
          <Footer />
        </div>
        <DebugLogs />
      </Router>
    </div>
  );
}

function App() {
  return (
    <ThemeProvider>
      <LogProvider>
        <AppContent />
      </LogProvider>
    </ThemeProvider>
  );
}

export default App;
