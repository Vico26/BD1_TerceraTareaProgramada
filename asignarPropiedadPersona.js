const sql = require('mssql');
const { sql, config } = require('./db'); // tu archivo de configuración

async function asignarPropiedadPersona({ valorDocId, numeroFinca, tipoAsoId, fechaRegistro }) {
    try {
        const pool = await sql.connect(config);
        const result = await pool.request()
            .input('valorDocId', sql.NVarChar(20), valorDocId)
            .input('numeroFinca', sql.NVarChar(128), numeroFinca)
            .input('tipoAsoId', sql.Int, tipoAsoId)
            .input('fechaRegistro', sql.Date, fechaRegistro)
            .execute('sp_AsignarPropiedadPersona');

        return { success: result.returnValue === 0, returnValue: result.returnValue };
    } catch (err) {
        console.error('Error en asignarPropiedadPersona:', err);
        return { success: false, error: err.message };
    }
}

module.exports = { asignarPropiedadPersona };
