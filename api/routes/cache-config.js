module.exports = (app) => {
  const controller = require("../controllers/cache-config")();

  app.route("/api/cache-config").get(controller.get);
};
