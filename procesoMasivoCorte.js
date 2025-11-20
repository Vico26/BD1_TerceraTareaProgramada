const sql = require('mssql');
const { sql, config } = require('./db'); // tu archivo de configuración

async function procesoMasivoCortes(fechaOperacion) {
    try {
        const pool = await sql.connect(config);
        const result = await pool.request()
            .input('FechaOperacion', sql.Date, fechaOperacion)
            .execute('sp_ProcesoMasivo_Cortes');

        return { success: result.returnValue === 0, returnValue: result.returnValue };
    } catch (err) {
        console.error('Error en procesoMasivoCortes:', err);
        return { success: false, error: err.message };
    }
}

module.exports = { procesoMasivoCortes };