const { sql, config } = require('./db'); // tu configuración de SQL Server

async function registrarPropiedadPersona(valorDocId, numeroFinca, tipoAsoId, fechaRegistro) {
    try {
        console.log("ENVIANDO:", { valorDocId, numeroFinca, tipoAsoId, fechaRegistro });

        const pool = await sql.connect(config);
        const result = await pool.request()
            .input('valorDocId', sql.NVarChar(20), valorDocId)
            .input('numeroFinca', sql.NVarChar(128), numeroFinca)
            .input('tipoAsoId', sql.Int, tipoAsoId)
            .input('fechaRegistro', sql.Date, fechaRegistro)
            .execute('sp_RegistrarPropiedadPersona');

        console.log("RESULTADO:", result);
        return { success: result.returnValue === 0, returnValue: result.returnValue };
    } catch (err) {
        console.error('Error en registrarPropiedadPersona:', err);
        return { success: false, error: err.message };
    }
}

//registrarPropiedadPersona('10000072', 'F-0051', 1, '2025-11-24');

module.exports = { registrarPropiedadPersona };