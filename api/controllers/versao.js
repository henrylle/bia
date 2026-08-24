module.exports = () => {
  const controller = {};

  controller.get = async (req, res) => {
    const responseString = `Bia ${process.env.VERSAO_API || "4.2.3"}`;
    res.send(responseString);
  };

  controller.info = async (req, res) => {
    res.json({
      versao: process.env.VERSAO_API || "4.2.3",
      nome: "BIA",
      timestamp: new Date().toISOString(),
    });
  };

  return controller;
};
