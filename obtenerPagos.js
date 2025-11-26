const sql = require('mssql');
const { config } = require('./db');

async function obtenerTodosLosPagos() {
    try {
        const pool = await sql.connect(config);

        console.log("OBTENIENDO TODOS LOS PAGOS...");

        const result = await pool.request()
            .execute('sp_ObtenerPagos');

        console.log("RETURN VALUE:", result.returnValue);
        console.log("RECORDSET:", result.recordset);

        return {
            success: result.returnValue === 0 || result.returnValue === undefined,
            returnValue: result.returnValue ?? 0,
            recordset: result.recordset
        };

    } catch (err) {
        console.error('Error en obtenerTodosLosPagos:', err);
        return { success: false, error: err.message };
    }
}

module.exports = { obtenerTodosLosPagos };
