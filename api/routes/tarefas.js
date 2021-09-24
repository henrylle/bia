module.exports = (app) => {
  const controller = require("../controllers/tarefas")();

  app.route("/api/tarefas").get(controller.listTarefas);
};
