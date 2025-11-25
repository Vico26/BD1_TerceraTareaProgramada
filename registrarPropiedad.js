
const config = require('./dbConfig'); // tu configuración de SQL Server

async function registrarPropiedad(numeroFinca, numeroMedidor, areaM2, tipoUso, tipoZona, valorFiscal, fechaRegistro) {
    try {
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

        return { success: result.returnValue === 0, returnValue: result.returnValue };
    } catch (err) {
        console.error('Error en registrarPropiedad:', err);
        return { success: false, error: err.message };
    }
}