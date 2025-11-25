
const sql = require('mssql');
const { config } = require('./db');

async function obtenerFacturasPorFinca(numeroFinca) {
    try {
        const pool = await sql.connect(config);
        
        console.log("BUSCANDO FACTURAS PARA:", numeroFinca);

        const result = await pool.request()
            .input('numeroFinca', sql.NVarChar(128), numeroFinca)
            .execute('sp_ObtenerFacturasPorFinca');

        console.log("RETURN VALUE:", result.returnValue);
        console.log("RECORDSET:", result.recordset);

        return { 
            success: result.returnValue === 0,
            returnValue: result.returnValue,
            recordset: result.recordset 
        };

    } catch (err) {
        console.error('Error en obtenerFacturasPorFinca:', err);
        return { success: false, error: err.message };
    }
}

module.exports = { obtenerFacturasPorFinca };

//obtenerFacturasPorFinca('F-0029');