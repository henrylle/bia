module.exports = (sequelize, DataTypes) => {
  const TarefaVersoes = sequelize.define(
    "TarefaVersoes",
    {
      id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      tarefa_uuid: {
        type: DataTypes.UUID,
        allowNull: false,
      },
      titulo: DataTypes.STRING,
      dia_atividade: DataTypes.STRING,
      importante: DataTypes.BOOLEAN,
      versao: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 1,
      },
    },
    {
      tableName: "tarefa_versoes",
    }
  );

  TarefaVersoes.associate = (models) => {
    TarefaVersoes.belongsTo(models.Tarefas, {
      foreignKey: "tarefa_uuid",
      targetKey: "uuid",
    });
  };

  return TarefaVersoes;
};
