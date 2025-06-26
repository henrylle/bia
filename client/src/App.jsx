import React, { useState, useEffect } from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import { ThemeProvider } from "./contexts/ThemeContext.jsx";
import Header from "./components/Header.jsx";
import Footer from "./components/Footer.jsx";
import Tasks from "./components/Tasks.jsx";
import AddTask from "./components/AddTask.jsx";
import About from "./components/About.jsx";
const apiUrl = import.meta.env.VITE_API_URL || "http://localhost:8080";

function App() {
  const [tasks, setTasks] = useState([]);

  useEffect(() => {
    const getTasks = async () => {
      const tasksFromServer = await fetchTasks();
      setTasks(tasksFromServer);
    };

    //Listar Tarefas
    const fetchTasks = async () => {
      const res = await fetch(`${apiUrl}/api/tarefas`);
      console.log(res);
      const data = await res.json();
      return data;
    };

    getTasks();
  }, []);

  //Listar Tarefa
  const fetchTask = async (uuid) => {
    const res = await fetch(`${apiUrl}/api/tarefas/${uuid}`);
    const data = await res.json();
    return data;
  };

  //Alternar Importante
  const toggleReminder = async (uuid) => {
    const taskToToggle = await fetchTask(uuid);
    const updatedTask = {
      ...taskToToggle,
      importante: !taskToToggle.importante,
    };

    const res = await fetch(`${apiUrl}/api/tarefas/update_priority/${uuid}`, {
      method: "PUT",
      headers: {
        "Content-type": "application/json",
      },
      body: JSON.stringify(updatedTask),
    });
    const data = await res.json();
    setTasks(
      tasks.map((task) =>
        task.uuid === uuid ? { ...task, importante: data.importante } : task
      )
    );
  };

  //Adicionar Tarefa
  const addTask = async (task) => {
    const res = await fetch(`${apiUrl}/api/tarefas`, {
      method: "POST",
      headers: {
        "Content-type": "application/json",
      },
      body: JSON.stringify(task),
    });
    const data = await res.json();
    setTasks([...tasks, data]);
  };

  //Remover tarefa
  const deleteTask = async (uuid) => {
    await fetch(`${apiUrl}/api/tarefas/${uuid}`, {
      method: "DELETE",
    });
    setTasks(tasks.filter((task) => task.uuid !== uuid));
  };

  // Componente para página principal
  const HomePage = () => (
    <>
      <AddTask onAdd={addTask} />
      {tasks.length > 0 ? (
        <Tasks
          tasks={tasks}
          onDelete={deleteTask}
          onToggle={toggleReminder}
        />
      ) : (
        <div className="empty-state">
          <h3>Nenhuma tarefa por aqui 📝</h3>
          <p>Adicione sua primeira tarefa usando o formulário acima!</p>
        </div>
      )}
    </>
  );

  return (
    <ThemeProvider>
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
        </Router>
      </div>
    </ThemeProvider>
  );
}

export default App;
