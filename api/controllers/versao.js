module.exports = () => {
  const controller = {};

  controller.get = async (req, res) => {
    const responseString = `Bia ${process.env.VERSAO_API || "2.0.2"}`;
    res.send(responseString);
  };

  return controller;
};
