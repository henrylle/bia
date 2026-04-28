const getConfig = require('../config/database.js');
const { Sequelize, QueryTypes } = require('sequelize');

(async () => {
  const cfg = await getConfig();
  const seq = new Sequelize(cfg);

  const tables = await seq.query(
    "SELECT table_name FROM information_schema.tables WHERE table_schema='public' ORDER BY table_name",
    { type: QueryTypes.SELECT }
  );

  console.log('\n=== TABELAS ===');
  for (const t of tables) {
    const name = t.table_name;
    console.log(' -', name);

    const cols = await seq.query(
      `SELECT column_name, data_type, is_nullable FROM information_schema.columns WHERE table_name='${name}' ORDER BY ordinal_position`,
      { type: QueryTypes.SELECT }
    );
    console.log(`\n=== ESTRUTURA: ${name} ===`);
    cols.forEach(c => console.log(` ${c.column_name} | ${c.data_type} | nullable: ${c.is_nullable}`));

    const rows = await seq.query(`SELECT * FROM "${name}"`, { type: QueryTypes.SELECT });
    console.log(`\n=== CONTEÚDO: ${name} (${rows.length} registros) ===`);
    if (rows.length) console.log(JSON.stringify(rows, null, 2));
  }

  await seq.close();
})();
