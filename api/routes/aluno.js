module.exports = (app) => {
  const controller = require("../controllers/aluno")();

  app.route("/api/aluno").get(controller.get_email);
};
