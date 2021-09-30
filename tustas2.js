const { Tarefas } = require("./api/models");

//CRIAR TAREFA
Tarefas.create({
  titulo: "Evento Teste",
  data_atividade: Date.now(),
  importante: true,
}).then((tarefa) => {
  console.log("Tarefa criada com sucesso. ID:", tarefa.uuid);
});

//LISTAR TODOS
// Tarefas.findAll().then((tarefas) => {
//   console.log("Todas as tarefas:", JSON.stringify(tarefas, null, 4));
// });

//REMOVER TAREFA

// Tarefas.destroy({
//   where: {
//     uuid: "21fa0770-1d61-11ec-bfe3-51fc93ec9b8b",
//   },
// }).then(() => {
//   console.log("Done");
// });
