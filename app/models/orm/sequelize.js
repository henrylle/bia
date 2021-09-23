const { Sequelize } = require("sequelize");

// Option 1: Passing a connection URI
//const sequelize = new Sequelize('postgres://user:postgres@127.0.0.1:5433/dbname') // Example for postgres

// Option 2: Passing parameters separately (other dialects)
const sequelize = new Sequelize("bia", "postgres", "postgres", {
  host: "localhost",
  port: 5433,
  dialect: "postgres",
});

async function test_conn() {
  try {
    await sequelize.authenticate();
    console.log("Connection has been established successfully.");
  } catch (error) {
    console.error("Unable to connect to the database:", error);
  }
}

test_conn();
