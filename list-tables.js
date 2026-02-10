const { Client } = require('pg');
const getConfig = require('./config/database');

async function listTables() {
  try {
    const config = await getConfig();
    
    const client = new Client({
      host: config.host,
      port: config.port,
      database: config.database,
      user: config.username,
      password: config.password,
      ssl: config.dialectOptions.ssl || false
    });

    await client.connect();
    console.log('Conectado ao banco:', config.database);
    
    const result = await client.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      ORDER BY table_name;
    `);
    
    console.log('\n=== TABELAS NO BANCO ===');
    result.rows.forEach(row => {
      console.log(`- ${row.table_name}`);
    });
    
    // Verificar se existe tabela de tarefas
    const tarefasResult = await client.query(`
      SELECT COUNT(*) as count 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_name = 'tarefas';
    `);
    
    console.log(`\nTabela 'tarefas' existe: ${tarefasResult.rows[0].count > 0 ? 'SIM' : 'NÃO'}`);
    
    await client.end();
  } catch (error) {
    console.error('Erro:', error.message);
  }
}

listTables();
