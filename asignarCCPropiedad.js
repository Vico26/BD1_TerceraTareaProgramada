const sql = require('mssql');
const { config } = require('./db');

async function asignarCCPropiedad({ numeroFinca, idCC, tipoAso, fechaRegistro }) {
  // Normalización
  const numeroFincaStr = String(numeroFinca ?? '').trim();
  const idCCInt = Number.parseInt(idCC, 10);
  const tipoAsoInt = Number.parseInt(tipoAso, 10);

  let fecha = null;
  if (fechaRegistro) {
    const d = new Date(fechaRegistro);
    if (!Number.isNaN(d.getTime())) fecha = d;
  }

  // Validaciones mínimas
  if (!numeroFincaStr) {
    return { success: false, error: 'numeroFinca requerido' };
  }
  if (!Number.isInteger(idCCInt) || idCCInt <= 0) {
    return { success: false, error: 'idCC inválido' };
  }
  if (!Number.isInteger(tipoAsoInt) || tipoAsoInt <= 0) {
    return { success: false, error: 'tipoAso inválido' };
  }

  // Por qué NVARCHAR(64): evitamos "Invalid string length" y desbordes si el SP usa VARCHAR(n)
  const NVARCHAR_LEN = 64;

  try {
    const pool = await sql.connect(config);

    const req = pool.request()
      .input('numeroFinca', sql.NVarChar(NVARCHAR_LEN), numeroFincaStr)
      .input('idCC', sql.Int, idCCInt)
      .input('tipoAso', sql.Int, tipoAsoInt)
      .input('fechaRegistro', sql.Date, fecha); // null si no viene

    // Si tu SP tiene parámetros OUTPUT, decláralos aquí:
    // .output('CodigoResultado', sql.Int)

    const result = await req.execute('sp_AsignarCCPropiedad');

    // Heurística de éxito robusta
    const returnValue = typeof result.returnValue === 'number' ? result.returnValue : null;
    const anyRows =
      Array.isArray(result.rowsAffected) && result.rowsAffected.some(n => (n || 0) > 0);

    const success = (returnValue === 0) || anyRows;

    return {
      success,
      data: {
        recordset: result.recordset || [],
        rowsAffected: result.rowsAffected || [],
      },
      meta: {
        returnValue,
        // outputParams: result.output, // descomenta si usas OUTPUT
        sent: { numeroFinca: numeroFincaStr, idCC: idCCInt, tipoAso: tipoAsoInt, fecha: fecha ?? null }
      },
      error: success ? null : 'El procedimiento no indicó éxito (returnValue/rowsAffected).'
    };
  } catch (err) {
    // Por qué: facilita depurar diferencias de tipos/valores esperados por el SP
    console.error('[asignarCCPropiedad] Error:', err);
    return { success: false, error: err.message || String(err) };
  }
}
module.exports={asignarCCPropiedad};
//asignarCCPropiedad("F-0012",5,1,"2025-11-24");

