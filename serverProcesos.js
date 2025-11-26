const express = require('express');
const router = express.Router();

const { registrarLectura } = require('./registrarLectura');//PROBADA Y SI SIRVE
const { registrarPersona } = require('./registrarPersona');//PROBADA Y SI SIRVE
const { registrarPropiedad } = require('./registrarPropiedad');//PROBADA Y SI SIRVE
const { registrarPropiedadPersona } = require('./registrarPropiedadPersona');//PROBADA Y SI SIRVE  
const { logIn } = require('./logInAdmin');//PROBADA Y SI SIRVE

const { asignarCCPropiedad } = require("./asignarCCPropiedad"); //PROBADA Y SI SIRVE
const { buscarPropiedades } = require("./buscarPropiedades");//PROBADA Y SI SIRVE
const { asignarPropiedadPersona } = require("./asignarPropiedadPersona");//PROBADA Y SI SIRVE

const { obtenerFacturasPorFinca } = require('./obtenerFacturasPorFinca');//PROBADA Y SI SIRVE
const { obtenerLecturasPorMedidor } = require('./obtenerLecturasPorMedidor');//PROBADA Y SI SIRVE
const { obtenerPagosPorFinca } = require('./obtenerPagosPorFinca');//PROBADA Y SI SIRVE
const { obtenerTodosLosPagos } = require('./obtenerPagos');//FALTA PROBAR
const { obtenerTodasLasFacturas } = require('./obtenerFacturas');//FALTA PROBAR
const { obtenerTodasLasLecturas } = require('./obtenerLecturas');//FALTA PROBAR
const { obtenerTipoUsoPropiedad} = require('./obtenerTipoUso');//FALTA PROBAR
const { obtenerTipoZonaPropiedad } = require('./obtenerTipoDeZona');//FALTA PROBAR
const { obtenerTipoAsociacion } = require('./obtenerTipoAso');//FALTA PROBAR
const { obtenerCCPropiedad } = require('./obtenerCCPropiedad');//FALTA PROBAR

const { pagarFactura } = require('./pagarFactura');//POBRADA Y SI SIRVE

const { procesoMasivoFacturacion } = require('./procesoMasivoFacturacion');//PROBADA Y SI SIRVE
const { procesoMasivoCortes } = require('./procesoMasivoCorte');//PROBADA Y SI SIRVE 
const { procesoMasivoReconexion } = require('./procesoMasivoReconexion');//PROBADA Y SI SIRVE
const { procesarOperacionesPorFecha } = require('./procesarOperacionesPorFecha');


router.post('/loginAdmin', async (req, res) => { //YA SIRVE EN INDEX.HTML
    try {
        const { Username, Pass } = req.body;

        if (!Username || !Pass) {
            return res.status(400).json({ error: 'Faltan datos' });
        }

        const resultado = await logIn(Username, Pass);

        if (resultado.success) {
            return res.json({ success: true, message: 'Login exitoso' });
        } else {
            return res.status(400).json({ success: false, CodigoError: resultado.codigoError });
        }

    } catch (err) {
        console.error("Error en /login:", err);
        res.status(500).json({ error: "Error interno del servidor" });
    }
});

// Función para manejar respuestas comunes de SP
function manejarRespuestaSP(res, resultado, recordsetOK = true) {
    if (resultado.success === false) {
        console.error('Error en SP:', resultado.error);
        return res.status(500).json({ error: 'Error interno del servidor' });
    }

    if (resultado.returnValue !== 0) {
        return res.status(400).json({ CodigoError: resultado.returnValue });
    }

    if (recordsetOK) {
        return res.json(resultado.recordset || []);
    }

    return null;
}


router.get('/facturas/:numeroFinca', async (req, res) => {//PROBAR EN INTERFAZ
    try {
        const numeroFinca = req.params.numeroFinca?.trim();
        if (!numeroFinca) return res.status(400).json({ error: 'Falta numeroFinca' });

        const resultado = await obtenerFacturasPorFinca(numeroFinca);
        return manejarRespuestaSP(res, resultado);

    } catch (err) {
        console.error('Error en /facturas/:numeroFinca', err);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

router.get('/lecturas/:numeroMedidor', async (req, res) => {
    try {
        const numeroMedidor = req.params.numeroMedidor?.trim();
        if (!numeroMedidor) return res.status(400).json({ error: 'Falta numeroMedidor' });

        const resultado = await obtenerLecturasPorMedidor(numeroMedidor);
        return manejarRespuestaSP(res, resultado);

    } catch (err) {
        console.error('Error en /lecturas/:numeroMedidor', err);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

router.get('/pagos/:numeroFinca', async (req, res) => {
    try {
        const numeroFinca = req.params.numeroFinca?.trim();
        if (!numeroFinca) return res.status(400).json({ error: 'Falta numeroFinca' });

        const resultado = await obtenerPagosPorFinca(numeroFinca);
        return manejarRespuestaSP(res, resultado);

    } catch (err) {
        console.error('Error en /pagos/:numeroFinca', err);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});


router.get('/buscarPropiedades', async (req, res) => {
    try {
        const resultado = await buscarPropiedades(req.query.valorBusqueda);
        res.json(resultado);
    } catch (err) {
        res.status(500).json({ error: "Error interno del servidor" });
    }
});


router.post('/pagarFactura/masvieja', async (req, res) => {
  try {
    let { numeroFinca, idFactura, tipoMedioPago, numeroRef, fechaPago } = req.body;

    const tipoMedioPagoInt = Number(tipoMedioPago);
    if (!numeroFinca && (!idFactura || !Number.isInteger(Number(idFactura)))) {
      return res.status(400).json({ success: false, error: 'Proporcione numeroFinca o idFactura válido' });
    }
    if (!Number.isInteger(tipoMedioPagoInt) || !numeroRef || !fechaPago) {
      return res.status(400).json({ success: false, error: 'Faltan datos para el pago' });
    }

    const pool = await sql.connect(config);

    // Si vino idFactura, obtener numeroFinca de esa factura (y validar existencia)
    if (!numeroFinca) {
      const r1 = await pool.request()
        .input('id', sql.Int, Number(idFactura))
        .query(`SELECT TOP 1 numeroFinca FROM dbo.Factura WHERE idFactura = @id`);
      if (!r1.recordset?.length) {
        return res.status(404).json({ success: false, error: 'Factura no encontrada' });
      }
      numeroFinca = r1.recordset[0].numeroFinca;
    }

    // Buscar la más vieja pendiente de esa finca
    const r2 = await pool.request()
      .input('finca', sql.NVarChar(128), numeroFinca)
      .query(`
        SELECT TOP 1 idFactura
        FROM dbo.Factura
        WHERE numeroFinca = @finca AND estado = 1     -- 1 = pendiente
        ORDER BY fechaFactura ASC, idFactura ASC
      `);

    if (!r2.recordset?.length) {
      return res.status(400).json({ success: false, error: 'No hay facturas pendientes para esa finca' });
    }

    const idMasVieja = r2.recordset[0].idFactura;

    // Ejecutar el SP sobre la más vieja
    const resultado = await pagarFactura(idMasVieja, tipoMedioPagoInt, numeroRef, fechaPago);
    if (typeof resultado?.returnValue === 'number' && resultado.returnValue !== 0) {
      return res.status(400).json({ success: false, CodigoError: resultado.returnValue });
    }

    const info = resultado?.recordset?.[0] || {};
    return res.json({
      success: true,
      message: info.mensaje || 'Pago registrado',
      pagada: idMasVieja,
      finca: numeroFinca
    });
  } catch (err) {
    console.error('POST /pagarFactura/masvieja error:', err);
    return res.status(500).json({ success: false, error: 'Error interno del servidor' });
  }
});


router.post('/masivos/facturacion', async (req, res) => {
    try {
        const { fechaOperacion } = req.body;
        if (!fechaOperacion) return res.status(400).json({ error: 'Falta fechaOperacion' });

        const resultado = await procesoMasivoFacturacion(fechaOperacion);

        if (resultado.returnValue !== 0) {
            return res.status(400).json({ CodigoError: resultado.returnValue });
        }

        res.json({ success: true, message: 'Proceso masivo de facturación ejecutado' });

    } catch (err) {
        console.error('Error en /masivos/facturacion', err);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

router.post('/masivos/cortes', async (req, res) => {
    try {
        const { fechaOperacion } = req.body;
        if (!fechaOperacion) return res.status(400).json({ error: 'Falta fechaOperacion' });

        const resultado = await procesoMasivoCortes(fechaOperacion);

        if (resultado.returnValue !== 0) {
            return res.status(400).json({ CodigoError: resultado.returnValue });
        }

        res.json({ success: true, message: 'Proceso masivo de cortes ejecutado' });

    } catch (err) {
        console.error('Error en /masivos/cortes', err);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

router.post('/masivos/reconexion', async (req, res) => {
    try {
        const { fechaOperacion } = req.body;
        if (!fechaOperacion) return res.status(400).json({ error: 'Falta fechaOperacion' });

        const resultado = await procesoMasivoReconexion(fechaOperacion);

        if (resultado.returnValue !== 0) {
            return res.status(400).json({ CodigoError: resultado.returnValue });
        }

        res.json({ success: true, message: 'Proceso masivo de reconexión ejecutado' });

    } catch (err) {
        console.error('Error en /masivos/reconexion', err);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

router.post('/registrarLectura', async (req, res) => {
    try {
        const { numeroMedidor, tipoMov, valor, fechaLectura } = req.body;

        if (!numeroMedidor || tipoMov == null || valor == null || !fechaLectura)
            return res.status(400).json({ error: "Faltan datos" });

        const resultado = await registrarLectura(numeroMedidor, tipoMov, valor, fechaLectura);

        if (resultado.returnValue !== 0) {
            return res.status(400).json({ CodigoError: resultado.returnValue });
        }

        res.json({ success: true, message: "Lectura registrada exitosamente" });

    } catch (err) {
        console.error("Error en /registrarLectura:", err);
        res.status(500).json({ error: "Error interno del servidor" });
    }
});

router.post('/registrarPersona', async (req, res) => {
    try {
        const { valorDocId, Nombre, email, telefono, fechaRegistro } = req.body;

        if (!valorDocId || !Nombre || !fechaRegistro)
            return res.status(400).json({ error: "Faltan datos obligatorios" });

        const resultado = await registrarPersona(valorDocId, Nombre, email, telefono, fechaRegistro);

        if (resultado.returnValue !== 0) {
            return res.status(400).json({ CodigoError: resultado.returnValue });
        }

        res.json({ success: true, message: "Persona registrada exitosamente" });

    } catch (err) {
        console.error("Error en /registrarPersona:", err);
        res.status(500).json({ error: "Error interno del servidor" });
    }
});

router.post('/registrarPropiedad', async (req, res) => {
    try {
        const { numeroFinca, numeroMedidor, areaM2, tipoUso, tipoZona, valorFiscal, fechaRegistro } = req.body;

        if (!numeroFinca || !numeroMedidor || areaM2 == null || !tipoUso || !tipoZona || valorFiscal == null)
            return res.status(400).json({ error: "Faltan datos obligatorios" });

        const resultado = await registrarPropiedad(
            numeroFinca, numeroMedidor, areaM2, tipoUso, tipoZona, valorFiscal, fechaRegistro
        );

        if (resultado.returnValue !== 0) {
            return res.status(400).json({ CodigoError: resultado.returnValue });
        }

        res.json({ success: true, message: "Propiedad registrada exitosamente" });

    } catch (err) {
        console.error("Error en /registrarPropiedad:", err);
        res.status(500).json({ error: "Error interno del servidor" });
    }
});

router.post('/registrarPropiedadPersona', async (req, res) => {
    try {
        const { valorDocId, numeroFinca, tipoAsoId, fechaRegistro } = req.body;

        if (!valorDocId || !numeroFinca || !tipoAsoId)
            return res.status(400).json({ error: "Faltan datos" });

        const resultado = await registrarPropiedadPersona(
            valorDocId, numeroFinca, tipoAsoId, fechaRegistro
        );

        if (resultado.returnValue !== 0) {
            return res.status(400).json({ CodigoError: resultado.returnValue });
        }

        res.json({ success: true, message: "Asociación registrada exitosamente" });

    } catch (err) {
        console.error("Error en /registrarPropiedadPersona:", err);
        res.status(500).json({ error: "Error interno del servidor" });
    }
});


router.post("/asignarCCPropiedad", async (req, res) => {
    try {
        const resultado = await asignarCCPropiedad(req.body);
        res.status(200).json(resultado);
    } catch (err) {
        console.error("Error en /asignarCCPropiedad", err);
        res.status(500).json({ error: "Error interno del servidor" });
    }
});

router.post("/asignar/propiedad-persona", async (req, res) => {
    try {
        const resultado = await asignarPropiedadPersona(req.body);
        res.status(200).json(resultado);
    } catch (err) {
        console.error("Error en /asignar/propiedad-persona:", err);
        res.status(500).json({ error: "Error interno del servidor" });
    }
});

router.get('/pagos', async (req, res) => {
    try {
        const resultado = await obtenerTodosLosPagos();
        return manejarRespuestaSP(res, resultado);

    } catch (err) {
        console.error('Error en /pagos', err);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

router.get('/facturas', async (req, res) => {
    try {
        const resultado = await obtenerTodasLasFacturas();
        return manejarRespuestaSP(res, resultado);

    } catch (err) {
        console.error('Error en /facturas', err);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

router.get('/lecturas', async (req, res) => {
    try {
        const resultado = await obtenerTodasLasLecturas();
        return manejarRespuestaSP(res, resultado);

    } catch (err) {
        console.error('Error en /lecturas', err);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

router.get('/tipoUsoPropiedad', async (req, res) => {
    try {
        const resultado = await obtenerTipoUsoPropiedad();
        return manejarRespuestaSP(res, resultado);

    } catch (err) {
        console.error('Error en /tipoUsoPropiedad', err);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

router.get('/tipoZonaPropiedad', async (req, res) => {
    try {
        const resultado = await obtenerTipoZonaPropiedad();
        return manejarRespuestaSP(res, resultado);

    } catch (err) {
        console.error('Error en /tipoZonaPropiedad', err);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

router.get('/tipoAsociacion', async (req, res) => {
    try {
        const resultado = await obtenerTipoAsociacion();
        return manejarRespuestaSP(res, resultado);

    } catch (err) {
        console.error('Error en /tipoAsociacion', err);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

router.get('/ccpropiedad', async (req, res) => {
    try {
        const resultado = await obtenerCCPropiedad(); // ← tu función del módulo
        return manejarRespuestaSP(res, resultado);
    } catch (err) {
        console.error('Error en /ccpropiedad', err);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

router.post('/procesos/operaciones-por-fecha', async (req, res) => {
    try {
        const { pathXML } = req.body;   // ejemplo: "C:\\Users\\USUARIO\\...\\xmlUltimo.xml"

        if (!pathXML) {
            return res.status(400).json({ error: 'Falta pathXML' });
        }

        const resultado = await procesarOperacionesPorFecha(pathXML);

        // Error a nivel de conexión/JS
        if (resultado.success === false && resultado.error) {
            console.error('Error en sp_ProcesarOperacionesPorFecha:', resultado.error);
            return res.status(500).json({ error: 'Error interno al procesar operaciones' });
        }

        // SP devolvió código distinto de 0
        if (resultado.returnValue !== 0) {
            return res.status(400).json({ CodigoError: resultado.returnValue });
        }

        // Todo bien
        return res.json({
            success: true,
            message: 'Operaciones procesadas correctamente para el XML indicado'
        });

    } catch (err) {
        console.error('Error en /procesos/operaciones-por-fecha:', err);
        return res.status(500).json({ error: 'Error interno del servidor' });
    }
});

module.exports = router;
