module.exports = (app) => {
  const controllerFactory = require("../controllers/tarefas");
  const controller = controllerFactory();

  app.route("/api/tarefas")
    .get(async (req, res, next) => {
      try {
        await controller.findAll(req, res);
      } catch (err) {
        next(err);
      }
    })
    .post(async (req, res, next) => {
      try {
        await controller.create(req, res);
      } catch (err) {
        next(err);
      }
    });

  app.route("/api/tarefas/:uuid")
    .get(async (req, res, next) => {
      try {
        await controller.find(req, res);
      } catch (err) {
        next(err);
      }
    });

  app.route("/api/tarefas/update_priority/:uuid")
    .put(async (req, res, next) => {
      try {
        await controller.update_priority(req, res);
      } catch (err) {
        next(err);
      }
    });

  app.route("/api/tarefas/:uuid")
    .delete(async (req, res, next) => {
      try {
        await controller.delete(req, res);
      } catch (err) {
        next(err);
      }
    });
};
