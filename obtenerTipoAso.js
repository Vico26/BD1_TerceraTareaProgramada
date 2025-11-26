const sql = require('mssql');
const { config } = require('./db');

async function obtenerTipoAsociacion() {
    try {
        const pool = await sql.connect(config);

        console.log("OBTENIENDO TipoAsociacion");

        const result = await pool.request()
            .execute('sp_ObtenerTipoAsociacion');

        console.log("RETURN VALUE:", result.returnValue);
        console.log("RECORDSET:", result.recordset);

        return {
            success: result.returnValue === 0,
            returnValue: result.returnValue,
            recordset: result.recordset
        };

    } catch (err) {
        console.error('Error en obtenerTipoAsociacion:', err);
        return { success: false, error: err.message };
    }
}

module.exports = { obtenerTipoAsociacion };