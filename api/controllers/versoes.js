const initializeModels = require("../models");

module.exports = () => {
  const controller = {};

  controller.findAll = async (req, res) => {
    try {
      const { TarefaVersoes } = await initializeModels();
      const data = await TarefaVersoes.findAll({
        order: [["createdAt", "DESC"]],
      });
      res.send(data);
    } catch (err) {
      res.status(500).send({
        message: err.message || "Deu ruim.",
      });
    }
  };

  return controller;
};
