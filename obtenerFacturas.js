const sql = require('mssql');
const { config } = require('./db');

async function obtenerTodasLasFacturas() {
    try {
        const pool = await sql.connect(config);

        console.log("OBTENIENDO TODAS LAS FACTURAS...");

        const result = await pool.request()
            .execute('sp_ObtenerFacturas');

        console.log("RETURN VALUE:", result.returnValue);
        console.log("RECORDSET:", result.recordset);

        return {
            success: result.returnValue === 0 || result.returnValue === undefined,
            returnValue: result.returnValue ?? 0,
            recordset: result.recordset
        };

    } catch (err) {
        console.error('Error en obtenerTodasLasFacturas:', err);
        return { success: false, error: err.message };
    }
}

module.exports = { obtenerTodasLasFacturas };
//obtenerTodasLasFacturas();  
