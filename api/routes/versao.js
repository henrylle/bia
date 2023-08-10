module.exports = (app) => {
  const controller = require("../controllers/versao")();

  app.route("/api/versao").get(controller.get);
};
