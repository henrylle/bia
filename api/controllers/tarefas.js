const initializeModels = require("../models");
const cache = require("../../lib/cache");

const CACHE_KEY = "tarefas:all";

async function refreshCache() {
  const { Tarefas } = await initializeModels();
  const data = await Tarefas.findAll();
  await cache.set(CACHE_KEY, data);
}

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
      await refreshCache();
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
        await refreshCache();
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

      await refreshCache();
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

  controller.deleteAll = async (req, res) => {
    try {
      const { Tarefas } = await initializeModels();
      const result = await Tarefas.destroy({ where: {}, truncate: true });
      await cache.del(CACHE_KEY);
      res.send({ message: "Todas as tarefas foram deletadas." });
    } catch (err) {
      res.status(500).send({
        message: err.message || "Deu ruim.",
      });
    }
  };

  controller.findAll = async (req, res) => {
    try {
      const cacheEnabled = !!process.env.CACHE_ENDPOINT;
      const start = Date.now();

      if (cacheEnabled) {
        const { data: cached, error: cacheError } = await cache.get(CACHE_KEY);
        if (cached) {
          const elapsed = Date.now() - start;
          const remaining = await cache.ttl(CACHE_KEY);
          console.log(`[CACHE HIT] tarefas - ${elapsed}ms - TTL restante: ${remaining}s`);
          return res.send({ fromCache: true, cacheTTL: remaining, data: cached });
        }
        if (cacheError) {
          console.log(`[CACHE ERROR] tarefas - Redis indisponível, buscando do banco`);
        }
      }

      const { Tarefas } = await initializeModels();
      const data = await Tarefas.findAll();
      const elapsed = Date.now() - start;

      if (cacheEnabled) {
        const cacheError = (await cache.get(CACHE_KEY)).error;
        if (!cacheError) {
          await cache.set(CACHE_KEY, data);
        }
        const ttl = Number(process.env.CACHE_TTL) || 60;
        console.log(`[CACHE MISS] tarefas - ${elapsed}ms - buscou do banco${cacheError ? ' (cache indisponível)' : ', cache setado com TTL: ' + ttl + 's'}`);
        return res.send({ fromCache: false, cacheTTL: ttl, cacheError, data });
      }

      res.send(data);
    } catch (err) {
      res.status(500).send({
        message: err.message || "Deu ruim.",
      });
    }
  };

  return controller;
};
