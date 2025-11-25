
const { sql, config } = require('./db'); // tu archivo de configuración

async function procesoMasivoReconexion(fechaOperacion) {
    try {
        const pool = await sql.connect(config);
        const result = await pool.request()
            .input('FechaOperacion', sql.Date, fechaOperacion)
            .execute('sp_ProcesoMasivo_Reconexion');

        return { success: result.returnValue === 0, returnValue: result.returnValue };
    } catch (err) {
        console.error('Error en procesoMasivoReconexion:', err);
        return { success: false, error: err.message };
    }
}

module.exports = { procesoMasivoReconexion };