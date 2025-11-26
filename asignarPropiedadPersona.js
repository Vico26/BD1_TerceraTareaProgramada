const sql = require('mssql');
const { config } = require('./db');
async function asignarPropiedadPersona(payload = {}) {
  const valorDocId = String(payload.valorDocId ?? '').trim();
  const numeroFinca = String(payload.numeroFinca ?? '').trim();
  const tipoAsoId = Number.parseInt(payload.tipoAsoId, 10);

  let fecha = null;
  if (payload.fechaRegistro) {
    const d = new Date(payload.fechaRegistro);
    if (!Number.isNaN(d.getTime())) fecha = d;
  }

  if (!valorDocId) return { success: false, error: 'valorDocId requerido' };
  if (!numeroFinca) return { success: false, error: 'numeroFinca requerido' };
  if (!Number.isInteger(tipoAsoId) || tipoAsoId <= 0) return { success: false, error: 'tipoAsoId inválido' };

  try {
    const pool = await sql.connect(config);

    const result = await pool.request()
      .input('valorDocId', sql.NVarChar(20), valorDocId)
      .input('numeroFinca', sql.NVarChar(128), numeroFinca)
      .input('tipoAsoId', sql.Int, tipoAsoId)
      .input('fechaRegistro', sql.Date, fecha) // acepta null
      .execute('sp_AsignarPropiedadPersona');

    const returnValue = typeof result.returnValue === 'number' ? result.returnValue : null;
    const anyRows = Array.isArray(result.rowsAffected) && result.rowsAffected.some(n => (n || 0) > 0);
    const success = (returnValue === 0) || anyRows;

    return {
      success,
      data: { recordset: result.recordset || [], rowsAffected: result.rowsAffected || [] },
      meta: { returnValue, sent: { valorDocId, numeroFinca, tipoAsoId, fecha: fecha ?? null } },
      error: success ? null : 'El SP no indicó éxito (returnValue/rowsAffected).'
    };
  } catch (err) {
    console.error('[asignarPropiedadPersona] Error:', err);
    return { success: false, error: err.message || String(err) };
  }
}

module.exports = { asignarPropiedadPersona };
//asignarPropiedadPersona("10000053","F-0012",1,"2025-11-24");
