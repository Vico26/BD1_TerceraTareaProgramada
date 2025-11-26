const sql = require('mssql');
const { config } = require('./db');

async function obtenerTodasLasLecturas() {
    try {
        const pool = await sql.connect(config);

        console.log("OBTENIENDO TODAS LAS LECTURAS...");

        const result = await pool.request()
            .execute('sp_ObtenerLecturas');

        console.log("RETURN VALUE:", result.returnValue);
        console.log("RECORDSET:", result.recordset);

        return {
            success: result.returnValue === 0 || result.returnValue === undefined,
            returnValue: result.returnValue ?? 0,
            recordset: result.recordset
        };

    } catch (err) {
        console.error('Error en obtenerTodasLasLecturas:', err);
        return { success: false, error: err.message };
    }
}

module.exports = { obtenerTodasLasLecturas };
