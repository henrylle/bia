const { Client } = require('pg');

const client = new Client({
  host: 'bia-db.c4zy4cykm0n7.us-east-1.rds.amazonaws.com',
  port: 5432,
  user: 'postgres',
  password: 'Ajkluj65z3s3GLCI5CIY',
  database: 'postgres',
  ssl: {
    rejectUnauthorized: false
  }
});

async function createDatabase() {
  try {
    await client.connect();
    console.log('Conectado ao PostgreSQL');
    
    // Criar database bia
    const checkBia = await client.query("SELECT 1 FROM pg_database WHERE datname = 'bia'");
    if (checkBia.rows.length === 0) {
      await client.query('CREATE DATABASE bia');
      console.log('Database "bia" criado com sucesso!');
    } else {
      console.log('Database "bia" já existe');
    }
    
    // Criar database bia-db também (fallback)
    const checkBiaDb = await client.query("SELECT 1 FROM pg_database WHERE datname = 'bia-db'");
    if (checkBiaDb.rows.length === 0) {
      await client.query('CREATE DATABASE "bia-db"');
      console.log('Database "bia-db" criado com sucesso!');
    } else {
      console.log('Database "bia-db" já existe');
    }
    
    await client.end();
  } catch (err) {
    console.error('Erro:', err.message);
    process.exit(1);
  }
}

createDatabase();
