import React, { useState, useEffect } from "react";
import { BrowserRouter as Router, Route } from "react-router-dom";
import Header from "./components/Header";
import Footer from "./components/Footer";
import Tasks from "./components/Tasks";
import AddTask from "./components/AddTask";
import About from "./components/About";
const apiUrl = process.env.REACT_APP_API_URL || "http://localhost:8080";

function App() {
  const [showAddTask, setShowAddTask] = useState(false);
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

  return (
    <Router>
      <div className="container">
        <Header
          onAdd={() => setShowAddTask(!showAddTask)}
          showAdd={showAddTask}
        />

        <Route
          path="/"
          exact
          render={(props) => (
            <>
              {showAddTask && <AddTask onAdd={addTask} />}
              {tasks.length > 0 ? (
                <Tasks
                  tasks={tasks}
                  onDelete={deleteTask}
                  onToggle={toggleReminder}
                />
              ) : (
                "Nenhuma tarefa nesse momento"
              )}
            </>
          )}
        />
        <Route path="/about" component={About} />
        <Footer />
      </div>
    </Router>
  );
}

export default App;
