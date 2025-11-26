const sql = require('mssql');
const { config } = require('./db');

/**
 * Obtiene CCs (idCC + nombre) desde sp_ObtenerCCs.
 * Por qué: centraliza el acceso a datos y mantiene el contrato del SP.
 */
async function obtenerCCs() {
  try {
    const pool = await sql.connect(config);
    const result = await pool.request().execute('sp_ObtenerCCs');
    console.log('Resultado de obtenerCCs:', result.recordset);
    return result.recordset;
  } catch (error) {
    console.log('Error en obtenerCCs:', error);
    throw error;
  }
}

module.exports = { obtenerCCs };