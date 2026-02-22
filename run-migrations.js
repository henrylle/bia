const { Sequelize } = require('sequelize');

const sequelize = new Sequelize('bia', 'postgres', 'Ajkluj65z3s3GLCI5CIY', {
  host: 'bia.c4zy4cykm0n7.us-east-1.rds.amazonaws.com',
  port: 5432,
  dialect: 'postgres',
  dialectOptions: {
    ssl: {
      require: true,
      rejectUnauthorized: false
    }
  }
});

async function runMigrations() {
  try {
    await sequelize.authenticate();
    console.log('✅ Conexão estabelecida com sucesso!');
    
    // Criar tabela de tarefas
    await sequelize.query(`
      CREATE TABLE IF NOT EXISTS tarefas (
        id SERIAL PRIMARY KEY,
        titulo VARCHAR(255) NOT NULL,
        dia_atividade VARCHAR(255),
        importante BOOLEAN DEFAULT false,
        "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
        "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
      );
    `);
    console.log('✅ Tabela tarefas criada!');
    
    await sequelize.close();
  } catch (error) {
    console.error('❌ Erro:', error.message);
    process.exit(1);
  }
}

runMigrations();
