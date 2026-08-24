module.exports = () => {
  const controller = {};

  controller.get = async (req, res) => {
    const responseString = `Bia ${process.env.VERSAO_API || "4.2.3"}`;
    res.send(responseString);
  };

  return controller;
};
