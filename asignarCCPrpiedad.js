const sql = require('mssql');
const { sql, config } = require('./db'); // tu archivo de configuración

async function asignarCCPropiedad({ numeroFinca, idCC, tipoAso, fechaRegistro }) {
    try {
        const pool = await sql.connect(config);
        const result = await pool.request()
            .input('numeroFinca', sql.NVarChar(128), numeroFinca)
            .input('idCC', sql.Int, idCC)
            .input('tipoAso', sql.Int, tipoAso)
            .input('fechaRegistro', sql.Date, fechaRegistro)
            .execute('sp_AsignarCCPropiedad');

        return { success: result.returnValue === 0, returnValue: result.returnValue };
    } catch (err) {
        console.error('Error en asignarCCPropiedad:', err);
        return { success: false, error: err.message };
    }
}

module.exports = { asignarCCPropiedad };