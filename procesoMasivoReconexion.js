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
/*(async () => {
    try {
        const resultado = await procesoMasivoReconexion('2025-10-15'); // fecha de operación de prueba
        console.log("RESULTADO DEL PROCESO DE RECONEXIÓN:", resultado);
    } catch (err) {
        console.error("ERROR AL PROBAR RECONEXIÓN:", err);
    }
})();*/
module.exports = { procesoMasivoReconexion };