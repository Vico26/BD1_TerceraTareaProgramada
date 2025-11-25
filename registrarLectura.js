
const config = require('./dbConfig'); // tu configuración de SQL Server

// Registrar lectura de medidor
async function registrarLectura(numeroMedidor, tipoMov, valor, fechaLectura) {
    try {
        const pool = await sql.connect(config);
        const result = await pool.request()
            .input('numeroMedidor', sql.NVarChar(128), numeroMedidor)
            .input('tipoMov', sql.Int, tipoMov)
            .input('valor', sql.Decimal(10,2), valor)
            .input('fechaLectura', sql.Date, fechaLectura)
            .execute('sp_RegistrarLectura');

        return { success: result.returnValue === 0, returnValue: result.returnValue };
    } catch (err) {
        console.error('Error en registrarLectura:', err);
        return { success: false, error: err.message };
    }
}
module.exports = { registrarLectura };