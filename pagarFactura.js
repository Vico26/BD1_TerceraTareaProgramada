const sql = require('mssql');
const { config } = require('./db');

async function pagarFactura(idFactura, tipoMedioPago, numeroRef, fechaPago) {
    try {
        const pool = await sql.connect(config);
        console.log("ENVIANDO:", { idFactura, tipoMedioPago, numeroRef, fechaPago });

        const result = await pool.request()
            .input('idFactura', sql.Int, idFactura)
            .input('tipoMedioPago', sql.Int, tipoMedioPago)
            .input('numeroRef', sql.NVarChar(128), numeroRef)
            .input('fechaPago', sql.Date, fechaPago)
            .execute('sp_PagarFactura');

        console.log("RESULTADO:", result);
        return { 
            success: result.returnValue === 0,
            returnValue: result.returnValue,
            recordset: result.recordset
        };
    } catch (err) {
        console.error(err);
        return { success: false, error: err.message };
    }
}

module.exports = { pagarFactura };