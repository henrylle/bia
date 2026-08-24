module.exports = (app) => {
  const controller = require("../controllers/versoes")();

  app.route("/api/tarefas/versoes").get(async (req, res, next) => {
    try {
      await controller.findAll(req, res);
    } catch (err) {
      next(err);
    }
  });
};
