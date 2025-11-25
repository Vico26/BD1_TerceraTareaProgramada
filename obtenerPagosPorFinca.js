
const { sql, config } = require('./db'); // tu archivo de configuración

async function obtenerPagosPorFinca(numeroFinca) {
    try {
        const pool = await sql.connect(config);
        const result = await pool.request()
            .input('numeroFinca', sql.NVarChar(128), numeroFinca)
            .execute('sp_ObtenerPagosPorFinca');

        return { success: result.returnValue === 0, returnValue: result.returnValue, recordset: result.recordset };
    } catch (err) {
        console.error('Error en obtenerPagosPorFinca:', err);
        return { success: false, error: err.message };
    }
}

module.exports = { obtenerPagosPorFinca };