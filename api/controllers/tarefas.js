const { Tarefas } = require("../models");

module.exports = () => {
  const controller = {};

  controller.create = (req, res) => {
    let tarefa = {
      titulo: req.body.titulo,
      dia_atividade: req.body.dia,
      importante: req.body.importante,
    };

    Tarefas.create(tarefa)
      .then((data) => {
        res.send(data);
      })
      .catch((err) => {
        res.status(500).send({
          message: err.message || "Deu ruim.",
        });
      });
  };

  controller.find = (req, res) => {
    let uuid = req.params.uuid;
    Tarefas.findByPk(uuid)
      .then((data) => {
        res.send(data);
      })
      .catch((err) => {
        res.status(500).send({
          message: err.message || "Deu ruim.",
        });
      });
  };

  controller.delete = (req, res) => {
    let { uuid } = req.params;

    Tarefas.destroy({
      where: {
        uuid: uuid,
      },
    })
      .then(() => {
        res.send();
      })
      .catch((err) => {
        res.status(500).send({
          message: err.message || "Deu ruim.",
        });
      });
  };

  controller.update_priority = (req, res) => {
    let { uuid } = req.params;

    Tarefas.update(req.body, {
      where: {
        uuid: uuid,
      },
    })
      .then(() => {
        Tarefas.findByPk(uuid).then((data) => {
          res.send(data);
        });
      })
      .catch((err) => {
        res.status(500).send({
          message: err.message || "Deu ruim.",
        });
      });
  };

  controller.findAll = (req, res) => {
    Tarefas.findAll()
      .then((data) => {
        res.send(data);
      })
      .catch((err) => {
        res.status(500).send({
          message: err.message || "Deu ruim.",
        });
      });
  };
  return controller;
};
