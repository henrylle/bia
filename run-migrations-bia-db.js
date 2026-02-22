const { Client } = require('pg');

const client = new Client({
  host: 'bia-db.c4zy4cykm0n7.us-east-1.rds.amazonaws.com',
  port: 5432,
  user: 'postgres',
  password: 'Ajkluj65z3s3GLCI5CIY',
  database: 'bia-db',
  ssl: {
    rejectUnauthorized: false
  }
});

async function runMigrations() {
  try {
    await client.connect();
    console.log('Conectado ao database bia-db');
    
    // Criar tabela Tarefas
    await client.query(`
      CREATE TABLE IF NOT EXISTS "Tarefas" (
        uuid UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        titulo VARCHAR(255) NOT NULL,
        dia_atividade VARCHAR(255),
        importante BOOLEAN DEFAULT false,
        "createdAt" TIMESTAMP NOT NULL DEFAULT NOW(),
        "updatedAt" TIMESTAMP NOT NULL DEFAULT NOW()
      )
    `);
    console.log('Tabela "Tarefas" criada com sucesso!');
    
    await client.end();
  } catch (err) {
    console.error('Erro:', err.message);
    process.exit(1);
  }
}

runMigrations();
