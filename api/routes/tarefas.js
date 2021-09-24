module.exports = (app) => {
  const controller = require("../controllers/tarefas")();

  app.route("/api/tarefas").get(controller.findAll).post(controller.create);
  app.route("/api/tarefas/:uuid").get(controller.find);
  app
    .route("/api/tarefas/update_priority/:uuid")
    .put(controller.update_priority);
  app.route("/api/tarefas/:uuid").delete(controller.delete);
};
