"use strict";

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable("tarefa_versoes", {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER,
      },
      tarefa_uuid: {
        allowNull: false,
        type: Sequelize.UUID,
        references: {
          model: "Tarefas",
          key: "uuid",
        },
        onUpdate: "CASCADE",
        onDelete: "CASCADE",
      },
      titulo: {
        allowNull: false,
        type: Sequelize.STRING,
      },
      dia_atividade: {
        allowNull: true,
        type: Sequelize.STRING,
      },
      importante: {
        allowNull: true,
        defaultValue: false,
        type: Sequelize.BOOLEAN,
      },
      versao: {
        allowNull: false,
        defaultValue: 1,
        type: Sequelize.INTEGER,
      },
      createdAt: {
        allowNull: false,
        type: Sequelize.DATE,
      },
      updatedAt: {
        allowNull: false,
        type: Sequelize.DATE,
      },
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable("tarefa_versoes");
  },
};
