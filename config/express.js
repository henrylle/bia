const express = require("express");
var cors = require("cors");
var path = require("path");
const config = require("config");
var bodyParser = require("body-parser");
var AWSXray = require("aws-xray-sdk");

module.exports = () => {
  const app = express();

  app.use(AWSXray.express.openSegment("bia"));
  // SETANDO VARIÁVEIS DA APLICAÇÃO
  app.set("port", process.env.PORT || config.get("server.port"));

  //Setando react
  app.use(express.static(path.join(__dirname, "../", "client", "build")));

  // parse request bodies (req.body)
  app.use(express.urlencoded({ extended: true }));
  app.use(bodyParser.json());

  app.use(cors());

  require("../api/routes/tarefas")(app);
  require("../api/routes/versao")(app);
  app.use(AWSXray.express.closeSegment());

  return app;
};
