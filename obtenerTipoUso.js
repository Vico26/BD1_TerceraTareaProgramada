const sql = require('mssql');
const { config } = require('./db');

async function obtenerTipoUsoPropiedad() {
    try {
        const pool = await sql.connect(config);

        console.log("OBTENIENDO TipoUsoPropiedad");

        const result = await pool.request()
            .execute('sp_ObtenerTipoUsoPropiedad');

        console.log("RETURN VALUE:", result.returnValue);
        console.log("RECORDSET:", result.recordset);

        return {
            success: result.returnValue === 0,
            returnValue: result.returnValue,
            recordset: result.recordset
        };

    } catch (err) {
        console.error('Error en obtenerTipoUsoPropiedad:', err);
        return { success: false, error: err.message };
    }
}

module.exports = { obtenerTipoUsoPropiedad };