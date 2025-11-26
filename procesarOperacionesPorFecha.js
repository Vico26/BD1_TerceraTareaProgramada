const sql = require('mssql');
const { config } = require('./db');

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
if (require.main === module) {
    (async () => {
        const pathDePrueba = 'C:\\Users\\USUARIO\\Documents\\GitHub\\BD1_TerceraTareaProgramada\\XMLS\\xmlUltimo.xml';

        const resultado = await procesarOperacionesPorFecha(pathDePrueba);
        console.log('Resultado prueba:', resultado);
        process.exit(0);
    })();
}

module.exports = { procesarOperacionesPorFecha };