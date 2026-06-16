module.exports = () => {
  const controller = {};

  controller.get = async (req, res) => {
    const endpoint = process.env.CACHE_ENDPOINT || null;
    const port = process.env.CACHE_PORT || "6379";
    const ttl = process.env.CACHE_TTL || "60";

    res.send({
      enabled: !!endpoint,
      endpoint,
      port,
      ttl
    });
  };

  return controller;
};
