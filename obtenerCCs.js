const sql = require('mssql');
const { config } = require('./db');

async function obtenerCCs() {
  try {
    const pool = await sql.connect(config);
    const result = await pool.request().execute('sp_ObtenerCCs');
    const recordset = Array.isArray(result.recordset) ? result.recordset : [];
    console.log('sp_ObtenerCCs rows:', recordset.length);
    return { recordset, returnValue: typeof result.returnValue === 'number' ? result.returnValue : 0 };
  } catch (error) {
    console.error('Error en obtenerCCs:', error);
    return { success: false, error };
  }
}

module.exports = { obtenerCCs };