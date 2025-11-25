const sql = require('mssql');
const { config } = require('./db');

async function asignarCCPropiedad(numeroFinca, idCC, tipoAso, fechaRegistro) {
    try {
        const pool = await sql.connect(config);
        console.log("ENVIANDO:", numeroFinca);
        const result = await pool.request()
            .input('numeroFinca', sql.NVarChar(128), numeroFinca)
            .input('idCC', sql.Int, idCC)
            .input('tipoAso', sql.Int, tipoAso)
            .input('fechaRegistro', sql.Date, fechaRegistro)
            .execute('sp_AsignarCCPropiedad');

        console.log("RESULTADO:", result.returnValue);

    } catch (err) {
        console.error(err);
    }
}

module.exports = { asignarCCPropiedad };
//asignarCCPropiedad("F-0012",5,1,"2025-11-24");
