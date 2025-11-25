
const sql = require('mssql');
const { config } = require('./db');

async function asignarPropiedadPersona(valorDocId, numeroFinca, tipoAsoId, fechaRegistro) {
    try {
        const pool = await sql.connect(config);

        console.log("ENVIANDO:", valorDocId, numeroFinca);

        const result = await pool.request()
            .input('valorDocId', sql.NVarChar(20), valorDocId)
            .input('numeroFinca', sql.NVarChar(128), numeroFinca)
            .input('tipoAsoId', sql.Int, tipoAsoId)
            .input('fechaRegistro', sql.Date, fechaRegistro)
            .execute('sp_AsignarPropiedadPersona');

        console.log("RESULTADO:", result.returnValue);

    } catch (err) {
        console.error("ERROR:", err);
    }
}

module.exports = { asignarPropiedadPersona };

asignarPropiedadPersona("10000053","F-0012",1,"2025-11-24");
