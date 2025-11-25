const { sql, config } = require('./db');

async function logIn(Username, Pass) {
    try {
        let pool = await sql.connect(config);

        let result = await pool.request()
            .input('Username', sql.NVarChar(128), Username)
            .input('Pass', sql.NVarChar(128), Pass)
            .execute('sp_LogIn');

        const codigoError = result.returnValue;

        if (codigoError === 0) {
            console.log('LogIn exitoso');
            return { success: true };
        } else {
            console.log('LogIn fallido', codigoError);
            return { success: false, codigoError };
        }

    } catch (err) {
        console.log('Error con el LogIn', err);
        return { success: false, error: err };
    }
}

module.exports = { logIn };
logIn("Administrador", "SoyAdmin");
