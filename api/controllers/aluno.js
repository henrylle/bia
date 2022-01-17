module.exports = () => {
  const controller = {};

  controller.get_email = (req, res) => {
    res.send(process.env.EMAIL_ALUNO);
  };

  return controller;
};
