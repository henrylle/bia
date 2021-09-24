const express = require("express");
var path = require("path");
var logger = require("morgan");
const config = require("config");

module.exports = () => {
  const app = express();

  // SETANDO VARIÁVEIS DA APLICAÇÃO
  app.set("port", process.env.PORT || config.get("server.port"));

  //Setando react
  app.use(express.static(path.join(__dirname, "../", "client", "build")));

  // parse request bodies (req.body)
  app.use(express.urlencoded({ extended: true }));

  require("../api/routes/tarefas")(app);

  return app;
};
