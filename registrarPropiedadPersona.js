const sql = require('mssql');
const config = require('./dbConfig'); // tu configuración de SQL Server

async function registrarPropiedadPersona(valorDocId, numeroFinca, tipoAsoId, fechaRegistro) {
    try {
        const pool = await sql.connect(config);
        const result = await pool.request()
            .input('valorDocId', sql.NVarChar(20), valorDocId)
            .input('numeroFinca', sql.NVarChar(128), numeroFinca)
            .input('tipoAsoId', sql.Int, tipoAsoId)
            .input('fechaRegistro', sql.Date, fechaRegistro)
            .execute('sp_RegistrarPropiedadPersona');

        return { success: result.returnValue === 0, returnValue: result.returnValue };
    } catch (err) {
        console.error('Error en registrarPropiedadPersona:', err);
        return { success: false, error: err.message };
    }
}
module.exports = { registrarPropiedadPersona };