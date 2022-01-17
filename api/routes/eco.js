module.exports = (app) => {
  const controller = require("../controllers/eco")();

  app.route("/api/eco").get(controller.get_instance);
};
