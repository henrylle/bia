const express = require("express");
const cors = require("cors");
const path = require("path");
const config = require("config");
const bodyParser = require("body-parser");

const initializeExpress = async () => {
  try {
    const app = express();

    // SETANDO VARIÁVEIS DA APLICAÇÃO
    app.set("port", process.env.PORT || config.get("server.port"));

    // Setando react
    app.use(express.static(path.join(__dirname, "../", "client", "build")));

    // parse request bodies (req.body)
    app.use(express.urlencoded({ extended: true }));
    app.use(bodyParser.json());

    app.use(cors());

    require("../api/routes/versao")(app);
    require("../api/routes/tarefas")(app);    

    return app;
  } catch (error) {
    console.error("Erro ao inicializar o Express:", error);
    throw error;
  }
};

module.exports = initializeExpress;
