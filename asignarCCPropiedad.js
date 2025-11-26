// /asignarCCPropiedad.js
const sql = require('mssql');
const { config } = require('./db');

/**
 * Asigna un CC a una propiedad.
 * Por qué: la ruta envía un objeto; aquí se valida/castea antes de llamar el SP.
 */
async function asignarCCPropiedad({ numeroFinca, idCC, tipoAso, fechaRegistro }) {
  // Normalización/casteo
  const numeroFincaStr = String(numeroFinca ?? '').trim();
  const idCCInt = Number.parseInt(idCC, 10);
  const tipoAsoInt = Number.parseInt(tipoAso, 10);

  let fecha = null;
  if (fechaRegistro) {
    const d = new Date(fechaRegistro);
    if (!Number.isNaN(d.getTime())) fecha = d;
  }

  // Validaciones mínimas (evita EPARAM/Invalid string)
  if (!numeroFincaStr) return { success: false, error: 'numeroFinca requerido' };
  if (!Number.isInteger(idCCInt) || idCCInt <= 0) return { success: false, error: 'idCC inválido' };
  if (!Number.isInteger(tipoAsoInt) || tipoAsoInt <= 0) return { success: false, error: 'tipoAso inválido' };

  try {
    const pool = await sql.connect(config);

    const result = await pool.request()
      .input('numeroFinca', sql.NVarChar(128), numeroFincaStr) // Ajusta a VARCHAR si tu SP lo usa
      .input('idCC', sql.Int, idCCInt)
      .input('tipoAso', sql.Int, tipoAsoInt)
      .input('fechaRegistro', sql.Date, fecha) // null si no viene
      .execute('sp_AsignarCCPropiedad');

    return {
      success: (result.returnValue ?? 0) === 0,
      returnValue: result.returnValue ?? 0,
      recordset: result.recordset || []
    };
  } catch (err) {
    console.error('Error en asignarCCPropiedad:', err);
    return { success: false, error: err.message || String(err) };
  }
}

module.exports = { asignarCCPropiedad };

//asignarCCPropiedad("F-0012",5,1,"2025-11-24");

