module.exports = (app) => {
  const controller = require("../controllers/versao")();

  app.route("/api/versao").get(controller.get);
  app.route("/api/versao/info").get(controller.info);
};
