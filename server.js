const initializeApp = async () => {
  try {
    const app = await require("./config/express")();
    const port = app.get("port");

    app.listen(port, () => {
      console.log(`Servidor rodando na porta ${port}`);
    });
  } catch (error) {
    console.error("Erro ao inicializar o servidor:", error);
  }
};

initializeApp();