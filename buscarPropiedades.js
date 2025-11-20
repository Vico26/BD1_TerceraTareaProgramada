const sql = require('mssql');
const { sql, config } = require('./db'); // tu archivo de configuración

async function buscarPropiedades({ tipoBusqueda, valorBusqueda }) {
    try {
        const pool = await sql.connect(config);
        const result = await pool.request()
            .input('tipoBusqueda', sql.Int, tipoBusqueda)
            .input('valorBusqueda', sql.NVarChar(128), valorBusqueda)
            .execute('sp_BuscarPropiedades');

        return { success: true, recordset: result.recordset };
    } catch (err) {
        console.error('Error en buscarPropiedades:', err);
        return { success: false, error: err.message };
    }
}

module.exports = { buscarPropiedades };