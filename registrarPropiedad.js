const { sql, config } = require('./db'); // tu configuración de SQL Server

async function registrarPropiedad(numeroFinca, numeroMedidor, areaM2, tipoUso, tipoZona, valorFiscal, fechaRegistro) {
    try {
        console.log("ENVIANDO:", { numeroFinca, numeroMedidor, areaM2, tipoUso, tipoZona, valorFiscal, fechaRegistro });

        const pool = await sql.connect(config);
        const result = await pool.request()
            .input('numeroFinca', sql.NVarChar(128), numeroFinca)
            .input('numeroMedidor', sql.NVarChar(128), numeroMedidor)
            .input('areaM2', sql.Int, areaM2)
            .input('tipoUso', sql.Int, tipoUso)
            .input('tipoZona', sql.Int, tipoZona)
            .input('valorFiscal', sql.Money, valorFiscal)
            .input('fechaRegistro', sql.Date, fechaRegistro)
            .execute('sp_RegistrarPropiedad');

        console.log("RESULTADO:", result);
        return { success: result.returnValue === 0, returnValue: result.returnValue };
    } catch (err) {
        console.error('Error en registrarPropiedad:', err);
        return { success: false, error: err.message };
    }
}

//registrarPropiedad('F-0051', 'M-1051', 255, 4, 3, 2630000, '2025-11-24');

module.exports = { registrarPropiedad };