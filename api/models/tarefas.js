module.exports = (sequelize, DataTypes) => {
  const Tarefas = sequelize.define("Tarefas", {
    uuid: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV1,
      primaryKey: true,
    },
    titulo: DataTypes.STRING,
    dia_atividade: DataTypes.STRING,
    importante: DataTypes.BOOLEAN,
  });

  return Tarefas;
};
