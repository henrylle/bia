import React, { useState, useEffect } from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import { ThemeProvider } from "./contexts/ThemeContext.jsx";
import { LogProvider, useLog } from "./contexts/LogContext.jsx";
import Header from "./components/Header.jsx";
import Footer from "./components/Footer.jsx";
import Tasks from "./components/Tasks.jsx";
import AddTask from "./components/AddTask.jsx";
import TaskCounter from "./components/TaskCounter.jsx";
import About from "./components/About.jsx";
import Version from "./components/Version.jsx";
import DebugLogs from "./components/DebugLogs.jsx";
import Analytics from "./components/Analytics.jsx";

const apiUrl = import.meta.env.VITE_API_URL || "http://localhost:8080";

function AppContent() {
  const [tasks, setTasks] = useState([]);
  const [fromCache, setFromCache] = useState(false);
  const [cacheTTL, setCacheTTL] = useState(null);
  const [cacheError, setCacheError] = useState(false);
  const { logApiRequest, logApiResponse, logApiError, addLog } = useLog();

  // Definir getTasks ANTES do useEffect
  const getTasks = async () => {
    try {
      const response = await fetchTasks();

      // Garantir que tasks é SEMPRE um array
      let tarefas = [];
      if (Array.isArray(response)) {
        tarefas = response;
        setFromCache(false);
        setCacheTTL(null);
        setCacheError(false);
      } else if (response && Array.isArray(response.data)) {
        tarefas = response.data;
        setFromCache(response.fromCache || false);
        setCacheTTL(response.cacheTTL || null);
        setCacheError(response.cacheError || false);
      }

      // Campo "concluida" é client-only (não existe na API) — inicializa
      // como false para toda tarefa carregada.
      tarefas = tarefas.map((tarefa) => ({
        ...tarefa,
        concluida: tarefa.concluida ?? false,
      }));

      setTasks(tarefas);
    } catch (error) {
      addLog('ERROR', 'Falha ao carregar tarefas', error.message);
    }
  };

  useEffect(() => {
    addLog('INFO', 'Aplicação iniciada', `API URL configurada: ${apiUrl}`);
    getTasks();
  }, []);

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

  //Alternar Concluída (estado client-only, sem persistência na API)
  const toggleConcluida = (uuid) => {
    setTasks((prevTasks) =>
      prevTasks.map((task) =>
        task.uuid === uuid ? { ...task, concluida: !task.concluida } : task
      )
    );

    const task = tasks.find((task) => task.uuid === uuid);
    if (task) {
      addLog(
        'INFO',
        'Conclusão alternada',
        `Tarefa ${uuid} - Concluída: ${!task.concluida}`
      );
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

      setTasks([...tasks, { ...data, concluida: false }]);
      addLog('SUCCESS', 'Tarefa criada', `"${task.titulo}" adicionada com sucesso`);
    } catch (error) {
      logApiError('POST', url, error);
      addLog('ERROR', 'Falha ao criar tarefa', error.message);
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
  const HomePage = () => {
    const pendentesCount = tasks.filter((task) => !task.concluida).length;
    const concluidasCount = tasks.filter((task) => task.concluida).length;

    return (
      <>
        <AddTask onAdd={addTask} />

        {/* Card de acesso rápido ao Analytics */}
        <div className="analytics-link-wrapper">
          <a href="/analytics" className="analytics-link-card">
            <span className="analytics-link-icon">📊</span>
            <div className="analytics-link-text">
              <strong>Ver Analytics</strong>
              <span>Visualize suas tarefas por prioridade</span>
            </div>
            <span className="analytics-link-arrow">→</span>
          </a>
        </div>

        {tasks.length > 0 ? (
          <>
            <TaskCounter pendentes={pendentesCount} concluidas={concluidasCount} />
            <Tasks
              tasks={tasks}
              onDelete={deleteTask}
              onToggle={toggleReminder}
              onToggleConcluida={toggleConcluida}
              fromCache={fromCache}
              cacheTTL={cacheTTL}
              cacheError={cacheError}
            />
          </>
        ) : (
          <div className="empty-state">
            <h3>Nenhuma tarefa por aqui 📝</h3>
            <p>Adicione sua primeira tarefa usando o formulário acima!</p>
          </div>
        )}
      </>
    );
  };

  return (
    <div className="app">
      <Router>
        <div className="container">
          <Header />

          <Routes>
            <Route path="/" element={<HomePage />} />
            <Route path="/about" element={<About />} />
            <Route path="/versao" element={<Version />} />
            <Route path="/analytics" element={<Analytics tasks={tasks} />} />
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
