--Se ingresan los valores en las tablas
USE Empresa3;
GO
DECLARE @xml AS XML;
BEGIN TRY
	SELECT @xml = CONVERT(XML, BulkColumn)
	FROM OPENROWSET(
		BULK 'C:\Users\USUARIO\Documents\GitHub\BD1_TerceraTareaProgramada\XMLS\operaciones_limpio.xml',
		SINGLE_BLOB
	) AS X;

	--Persona
	INSERT INTO dbo.Persona(valorDocId, Nombre, email, telefono, fechaRegistro)
	SELECT
		p.value('@valorDocumento','NVARCHAR(20)'),
		p.value('@nombre','NVARCHAR(128)'),
		p.value('@email','NVARCHAR(128)'),
		p.value('@telefono','NVARCHAR(128)'),
		f.value('@fecha','DATE')
	FROM @xml.nodes('/Operaciones/FechaOperacion') AS F(f)
	CROSS APPLY f.nodes('Personas/Persona') AS X(p)
	WHERE NOT EXISTS (
		SELECT 1
		FROM dbo.Persona per
		WHERE per.valorDocId = p.value('@valorDocumento','NVARCHAR(20)'));

	--Propiedad
	INSERT INTO dbo.Propiedad(numeroDeFinca,numeroMedidor,areaM2,tipoUso,tipoZona,valorFiscal,FechaRegistro)
	SELECT
		P.value('@numeroFinca','NVARCHAR(128)'),
		P.value('@numeroMedidor','NVARCHAR(128)'),
		P.value('@metrosCuadrados','INT'),
		P.value('@tipoUsoId','INT'),
		P.value('@tipoZonaId','INT'),
		P.value('@valorFiscal','MONEY'),
		P.value('@fechaRegistro','DATE')
	FROM @xml.nodes('/Operaciones/FechaOperacion/Propiedades/Propiedad') AS X(P)
	WHERE NOT EXISTS(
	SELECT 1
	FROM dbo.Propiedad p
	WHERE p.numeroDeFinca=P.value('@numeroFinca','NVARCHAR(128)'));

	--PropiedadPersona
	INSERT INTO dbo.PropiedadPersona(valorDocId,numeroFinca,tipoAsoId,fechaRegistro)
	SELECT
		pp.value('@valorDocumento','NVARCHAR(128)'),
		pp.value('@numeroFinca','NVARCHAR(128)'),
		pp.value('@tipoAsociacionId','INT'),
		f.value('@fecha','DATE')
	FROM @xml.nodes('/Operaciones/FechaOperacion') AS F(f)
	CROSS APPLY f.nodes('PropiedadPersona/PropiedadPersona') AS X(pp)
	WHERE NOT EXISTS(
	SELECT 1
	FROM dbo.PropiedadPersona pper
	WHERE pper.valorDocId=pp.value('@valorDocumento','NVARCHAR(20)'));

	--CCPropiedad
	INSERT INTO dbo.CCPropiedad(numeroDeFinca,idCC,tipoAso,fechaRegistro)
	SELECT
		c.value('@numeroFinca','NVARCHAR(128)'),
		c.value('@idCC','INT'),
		c.value('@tipoAsociacionId','INT'),
		f.value('@fecha','DATE')
	FROM @xml.nodes('/Operaciones/FechaOperacion') AS F(f)
	CROSS APPLY f.nodes('CCPropiedad/Movimiento') AS X(c)
	WHERE NOT EXISTS (
		SELECT 1
		FROM dbo.CCPropiedad C
		WHERE C.numeroDeFinca = c.value('@numeroFinca','NVARCHAR(128)'));

	--LecturaMedidor
	INSERT INTO dbo.LecturaMedidor(numeroMedidor,tipoMov,valor,fechaLectura)
	SELECT
		l.value('@numeroMedidor','NVARCHAR(128)'),
		l.value('@tipoMovimientoId','INT'),
		l.value('@valor','DECIMAL(10,2)'),
		f.value('@fecha','DATE')
	FROM @xml.nodes('/Operaciones/FechaOperacion') AS F(f)
	CROSS APPLY f.nodes('LecturasMedidor/Lectura') AS X(l)
	WHERE NOT EXISTS(
		SELECT 1
		FROM dbo.LecturaMedidor L
		WHERE L.numeroMedidor=l.value('@numeroMedidor','NVARCHAR(128)'));

	--Pagos
	INSERT INTO dbo.Pagos(numeroFinca,tipoMedioPago,numeroRef,fechaPago)
	SELECT
		p.value('@numeroFinca','NVARCHAR(128)'),
		p.value('@tipoMedioPagoId','INT'),
		p.value('@numeroReferencia','NVARCHAR(128)'),
		f.value('@fecha','DATE')
	FROM @xml.nodes('/Operaciones/FechaOperacion') AS F(f)
	CROSS APPLY f.nodes('Pagos/Pago') AS X(p)
	WHERE NOT EXISTS(
		SELECT 1
		FROM dbo.Pagos P
		WHERE P.numeroFinca=p.value('@numeroFinca','NVARCHAR(128)'));

	--Usuario(Falta en el XML)

END TRY
BEGIN CATCH
	SELECT
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_MESSAGE() AS ErrorMessage,
		ERROR_LINE() AS ErrorLine;
END CATCH
