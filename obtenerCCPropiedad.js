const sql = require('mssql');
const { config } = require('./db');

async function obtenerCCPropiedad() {
    try {
        let pool = await sql.connect(config);
        let result = await pool.request().execute('sp_ObtenerCCPropiedad');
        return result.recordset;
    } catch (error) {
        console.log('Error en obtenerCCPropiedad:', error);
        throw error;
    }
}

module.exports = { obtenerCCPropiedad };