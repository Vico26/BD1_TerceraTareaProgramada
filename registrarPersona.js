const { sql, config } = require('./db'); // tu configuración de SQL Server


async function registrarPersona(valorDocId, nombre, email, telefono, fechaRegistro) {
    try {
        console.log("ENVIANDO:", { valorDocId, nombre, email, telefono, fechaRegistro });

        const pool = await sql.connect(config);
        const result = await pool.request()
            .input('valorDocId', sql.NVarChar(20), valorDocId)
            .input('Nombre', sql.NVarChar(128), nombre)
            .input('email', sql.NVarChar(128), email)
            .input('telefono', sql.VarChar(128), telefono)
            .input('fechaRegistro', sql.Date, fechaRegistro)
            .execute('sp_RegistrarPersona');

        console.log("RESULTADO:", result);
        return { success: result.returnValue === 0, returnValue: result.returnValue };
    } catch (err) {
        console.error('Error en registrarPersona:', err);
        return { success: false, error: err.message };
    }
}

// Ejemplo de prueba
//registrarPersona('10000072', 'Rocio Gomez', 'gomilona@hotmail.com', '22156395', '2025-11-24');

module.exports = { registrarPersona };