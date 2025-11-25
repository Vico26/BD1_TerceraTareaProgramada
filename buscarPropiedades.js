const sql = require('mssql');
const { config } = require('./db');

async function buscarPropiedades(valorBusqueda) {
    try {
        const pool = await sql.connect(config);

        console.log("BUSCANDO:", valorBusqueda);

        const result = await pool.request()
            .input('valorBusqueda', sql.NVarChar(128), valorBusqueda)
            .execute('sp_BuscarPropiedades');

        console.log("RESULTADO:");
        console.log(result.recordset);

    } catch (err) {
        console.error("ERROR:", err);
    }
}

module.exports = { buscarPropiedades };

// Buscar por finca:
//buscarPropiedades("F-0012");

// O buscar por propietario:
//buscarPropiedades("10000053");