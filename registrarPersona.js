const sql = require('mssql');
const config = require('./dbConfig'); // tu configuración de SQL Server

async function registrarPersona(valorDocId, nombre, email, telefono, fechaRegistro) {
    try {
        const pool = await sql.connect(config);
        const result = await pool.request()
            .input('valorDocId', sql.NVarChar(20), valorDocId)
            .input('Nombre', sql.NVarChar(128), nombre)
            .input('email', sql.NVarChar(128), email)
            .input('telefono', sql.VarChar(128), telefono)
            .input('fechaRegistro', sql.Date, fechaRegistro)
            .execute('sp_RegistrarPersona');

        return { success: result.returnValue === 0, returnValue: result.returnValue };
    } catch (err) {
        console.error('Error en registrarPersona:', err);
        return { success: false, error: err.message };
    }
}
module.exports = { registrarPersona };