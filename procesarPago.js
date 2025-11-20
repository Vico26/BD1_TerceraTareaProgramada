const sql = require('mssql');
const config = require('./dbConfig'); // tu configuración de SQL Server

async function procesarPago(numeroFinca, tipoMedioPago, numeroRef, fechaPago) {
    try {
        const pool = await sql.connect(config);
        const result = await pool.request()
            .input('numeroFinca', sql.NVarChar(128), numeroFinca)
            .input('tipoMedioPago', sql.Int, tipoMedioPago)
            .input('numeroRef', sql.NVarChar(128), numeroRef)
            .input('fechaPago', sql.Date, fechaPago)
            .execute('sp_ProcesarPago');

        // El returnValue viene del SP (0 = éxito, otros = error)
        return { success: result.returnValue === 0, returnValue: result.returnValue };
    } catch (err) {
        console.error('Error en procesarPago:', err);
        return { success: false, error: err.message };
    }
}

module.exports = { procesarPago };