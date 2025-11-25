const sql = require('mssql');
const { config } = require('./db');

async function obtenerLecturasPorMedidor(numeroMedidor) {
    try {
        const pool = await sql.connect(config);
        console.log("ENVIANDO:", numeroMedidor);

        const result = await pool.request()
            .input('numeroMedidor', sql.NVarChar(128), numeroMedidor)
            .execute('sp_ObtenerLecturasPorMedidor');

        console.log("RESULTADO:", result);
        return { success: result.returnValue === 0, returnValue: result.returnValue, recordset: result.recordset };
    } catch (err) {
        console.error(err);
        return { success: false, error: err.message };
    }
}

module.exports = { obtenerLecturasPorMedidor };
//obtenerLecturasPorMedidor('M-1019');
