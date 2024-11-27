module.exports = (app) => {
  app.route("/api/ping").get((req, res) => {
    res.json("Rota funcionando. Pong!");
  });
};
