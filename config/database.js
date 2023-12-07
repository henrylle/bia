module.exports = {
  username: process.env.DB_USER || "postgres",
  password: process.env.DB_PWD || "postgres",
  database: "bia",
  host: process.env.DB_HOST || "127.0.0.1",
  port: process.env.DB_PORT || 5433,
  dialect: "postgres",
  dialectOptions: isLocalConnection() ? {} : getRemoteDialectOptions(),
};

function isLocalConnection() {
  // Lógica para determinar se a conexão é local
  return (
    process.env.DB_HOST === undefined ||
    process.env.DB_HOST === "database" ||
    process.env.DB_HOST === "127.0.0.1" ||
    process.env.DB_HOST === "localhost"
  );
}

function getRemoteDialectOptions() {
  // Configurações específicas para conexões remotas (útil a partir do pg 15)
  return {
    ssl: {
      require: true,
      rejectUnauthorized: false,
    },
  };
}
