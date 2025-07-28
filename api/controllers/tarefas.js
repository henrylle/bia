const initializeModels = require("../models");

module.exports = () => {
  const controller = {};

  controller.create = async (req, res) => {
    try {
      const { Tarefas } = await initializeModels();
      let tarefa = {
        titulo: req.body.titulo,
        dia_atividade: req.body.dia_atividade,
        importante: req.body.importante,
      };

      const data = await Tarefas.create(tarefa);
      res.send(data);
    } catch (err) {
      res.status(500).send({
        message: err.message || "Deu ruim.",
      });
    }
  };

  controller.find = async (req, res) => {
    try {
      const { Tarefas } = await initializeModels();
      let uuid = req.params.uuid;
      const data = await Tarefas.findByPk(uuid);
      if (data) {
        res.send(data);
      } else {
        res.status(404).send({
          message: "Tarefa não encontrada.",
        });
      }
    } catch (err) {
      res.status(500).send({
        message: err.message || "Deu ruim.",
      });
    }
  };

  controller.delete = async (req, res) => {
    try {
      const { Tarefas } = await initializeModels();
      let { uuid } = req.params;
      const result = await Tarefas.destroy({
        where: {
          uuid: uuid,
        },
      });

      if (result) {
        res.send({ message: "Tarefa deletada com sucesso." });
      } else {
        res.status(404).send({
          message: "Tarefa não encontrada.",
        });
      }
    } catch (err) {
      res.status(500).send({
        message: err.message || "Deu ruim.",
      });
    }
  };

  controller.update_priority = async (req, res) => {
    try {
      const { Tarefas } = await initializeModels();
      let { uuid } = req.params;
      await Tarefas.update(req.body, {
        where: {
          uuid: uuid,
        },
      });

      const data = await Tarefas.findByPk(uuid);
      if (data) {
        res.send(data);
      } else {
        res.status(404).send({
          message: "Tarefa não encontrada.",
        });
      }
    } catch (err) {
      res.status(500).send({
        message: err.message || "Deu ruim.",
      });
    }
  };

  controller.findAll = async (req, res) => {
    try {
      const { Tarefas } = await initializeModels();
      const data = await Tarefas.findAll();
      res.send(data);
    } catch (err) {
      res.status(500).send({
        message: err.message || "Deu ruim.",
      });
    }
  };

  return controller;
};
