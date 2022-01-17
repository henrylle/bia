var metadata = require("node-ec2-metadata");

module.exports = () => {
  const controller = {};

  controller.get_instance = (req, res) => {
    metadata.isEC2().then(
      metadata
        .getMetadataForInstance("instance-id")
        .then(function (instanceId) {
          console.log("Instance ID: " + instanceId);
          res.send(instanceId);
        })
        .fail(function (error) {
          res.status(500).send({
            message: error.message || "Deu ruim.",
          });
        })
    );
  };

  controller.get_instance = (req, res) => {
    metadata.isEC2().then(
      metadata
        .getMetadataForInstance("instance-id")
        .then(function (instanceId) {
          console.log("Instance ID: " + instanceId);
          res.send(instanceId);
        })
        .fail(function (error) {
          res.status(500).send({
            message: error.message || "Deu ruim.",
          });
        })
    );
  };
  return controller;
};
