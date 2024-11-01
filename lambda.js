const serverlessExpress = require("@codegenie/serverless-express");
const app = require("./config/express")();
exports.handler = serverlessExpress({ app });