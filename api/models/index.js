"use strict";

const fs = require("fs/promises");
const path = require("path");
const Sequelize = require("sequelize");
const basename = path.basename(__filename);

const db = {};
const initializeModels = async () => {
  const config = require("../../config/database.js");
  const sequelize = new Sequelize(config);
  try {
    const files = await fs.readdir(__dirname);

    for (const file of files) {
      if (file !== basename && file.slice(-3) === ".js") {
        const model = require(path.join(__dirname, file))(sequelize, Sequelize.DataTypes);
        db[model.name] = model;
      }
    }

    Object.keys(db).forEach(modelName => {
      if (db[modelName].associate) {
        db[modelName].associate(db);
      }
    });

    db.sequelize = sequelize;
    db.Sequelize = Sequelize;

    return db;
  } catch (error) {
    console.error("Erro ao inicializar os modelos:", error);
    throw error;
  }
};

module.exports = initializeModels;
