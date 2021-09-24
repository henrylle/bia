module.exports = () => {
  const tarefasDB = require("../data/tarefas.json");
  const controller = {};

  controller.listTarefas = (req, res) => res.status(200).json(tarefasDB.tasks);

  return controller;
};
