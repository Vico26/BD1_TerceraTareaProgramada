
const config = require('./dbConfig'); // ajusta según tu proyecto

async function procesarOperacionesPorFecha(pathXML) {
    try {
        const pool = await sql.connect(config);

        const result = await pool.request()
            .input('path', sql.NVarChar(500), pathXML)
            .execute('sp_ProcesarOperacionesPorFecha');

        return {
            success: result.returnValue === 0,
            returnValue: result.returnValue
        };

    } catch (err) {
        console.error('Error al procesar operaciones:', err);
        return {
            success: false,
            error: err.message
        };
    }
}

module.exports = { procesarOperacionesPorFecha };