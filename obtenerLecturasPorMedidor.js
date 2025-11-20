const sql = require('mssql');
const { sql, config } = require('./db'); // tu archivo de configuración

async function obtenerLecturasPorMedidor(numeroMedidor) {
    try {
        const pool = await sql.connect(config);
        const result = await pool.request()
            .input('numeroMedidor', sql.NVarChar(128), numeroMedidor)
            .execute('sp_ObtenerLecturasPorMedidor');

        return { success: result.returnValue === 0, returnValue: result.returnValue, recordset: result.recordset };
    } catch (err) {
        console.error('Error en obtenerLecturasPorMedidor:', err);
        return { success: false, error: err.message };
    }
}

module.exports = { obtenerLecturasPorMedidor };
