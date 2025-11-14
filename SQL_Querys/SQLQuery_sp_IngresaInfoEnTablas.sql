USE Empresa3;
GO
CREATE PROCEDURE sp_cargarTablas
	@path NVARCHAR(500)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @xml XML, @sql NVARCHAR(MAX);

	BEGIN TRY
		-- Cargar XML 
		SET @sql = N'SELECT @x = CONVERT(XML, BulkColumn)
                      FROM OPENROWSET(BULK ''' + @path + ''', SINGLE_BLOB) AS X;';
		EXEC sp_executesql @sql, N'@x XML OUTPUT', @x = @xml OUTPUT;

		-- Persona
		INSERT INTO dbo.Persona(valorDocId, Nombre, email, telefono, fechaRegistro)
		SELECT
			p.value('@valorDocumento','NVARCHAR(20)'),
			p.value('@nombre','NVARCHAR(128)'),
			p.value('@email','NVARCHAR(128)'),
			p.value('@telefono','NVARCHAR(128)'),
			TRY_CAST(f.value('@fecha','VARCHAR(20)') AS DATE)
		FROM @xml.nodes('/Operaciones/FechaOperacion') AS F(f)
		CROSS APPLY f.nodes('Personas/Persona') AS X(p)
		WHERE NOT EXISTS (
			SELECT 1
			FROM dbo.Persona per
			WHERE per.valorDocId = p.value('@valorDocumento','NVARCHAR(20)')
		);

		-- Propiedad
		INSERT INTO dbo.Propiedad(numeroFinca, numeroMedidor, areaM2, tipoUso, tipoZona, valorFiscal, FechaRegistro)
		SELECT
			P.value('@numeroFinca','NVARCHAR(128)'),
			P.value('@numeroMedidor','NVARCHAR(128)'),
			TRY_CAST(P.value('@metrosCuadrados','VARCHAR(20)') AS INT),
			TRY_CAST(P.value('@tipoUsoId','VARCHAR(20)') AS INT),
			TRY_CAST(P.value('@tipoZonaId','VARCHAR(20)') AS INT),
			TRY_CAST(P.value('@valorFiscal','VARCHAR(20)') AS MONEY),
			TRY_CAST(P.value('@fechaRegistro','VARCHAR(20)') AS DATE)
		FROM @xml.nodes('/Operaciones/FechaOperacion/Propiedades/Propiedad') AS X(P)
		WHERE NOT EXISTS (
			SELECT 1
			FROM dbo.Propiedad p
			WHERE p.numeroFinca = P.value('@numeroFinca','NVARCHAR(128)')
		);

		-- PropiedadPersona
		INSERT INTO dbo.PropiedadPersona(valorDocId, numeroFinca, tipoAsoId, fechaRegistro)
		SELECT
			pp.value('@valorDocumento','NVARCHAR(128)'),
			pp.value('@numeroFinca','NVARCHAR(128)'),
			TRY_CAST(pp.value('@tipoAsociacionId','VARCHAR(20)') AS INT),
			TRY_CAST(f.value('@fecha','VARCHAR(20)') AS DATE)
		FROM @xml.nodes('/Operaciones/FechaOperacion') AS F(f)
		CROSS APPLY f.nodes('PropiedadPersona/PropiedadPersona') AS X(pp)
		WHERE NOT EXISTS (
			SELECT 1
			FROM dbo.PropiedadPersona pper
			WHERE pper.valorDocId = pp.value('@valorDocumento','NVARCHAR(20)')
		);

		-- CCPropiedad
		INSERT INTO dbo.CCPropiedad(numeroFinca, idCC, tipoAso, fechaRegistro)
		SELECT
			c.value('@numeroFinca','NVARCHAR(128)'),
			TRY_CAST(c.value('@idCC','VARCHAR(20)') AS INT),
			TRY_CAST(c.value('@tipoAsociacionId','VARCHAR(20)') AS INT),
			TRY_CAST(f.value('@fecha','VARCHAR(20)') AS DATE)
		FROM @xml.nodes('/Operaciones/FechaOperacion') AS F(f)
		CROSS APPLY f.nodes('CCPropiedad/Movimiento') AS X(c)
		WHERE NOT EXISTS (
			SELECT 1
			FROM dbo.CCPropiedad C
			WHERE C.numeroFinca = c.value('@numeroFinca','NVARCHAR(128)')
		);

		-- LecturaMedidor
		INSERT INTO dbo.LecturaMedidor(numeroMedidor, tipoMov, valor, fechaLectura)
		SELECT
			l.value('@numeroMedidor','NVARCHAR(128)'),
			TRY_CAST(l.value('@tipoMovimientoId','VARCHAR(20)') AS INT),
			TRY_CAST(l.value('@valor','VARCHAR(20)') AS DECIMAL(10,2)),
			TRY_CAST(f.value('@fecha','VARCHAR(20)') AS DATE)
		FROM @xml.nodes('/Operaciones/FechaOperacion') AS F(f)
		CROSS APPLY f.nodes('LecturasMedidor/Lectura') AS X(l)
		WHERE NOT EXISTS (
			SELECT 1
			FROM dbo.LecturaMedidor L
			WHERE L.numeroMedidor = l.value('@numeroMedidor','NVARCHAR(128)')
		);

		-- Pagos
		INSERT INTO dbo.Pagos(numeroFinca, tipoMedioPago, numeroRef, fechaPago)
		SELECT
			p.value('@numeroFinca','NVARCHAR(128)'),
			TRY_CAST(p.value('@tipoMedioPagoId','VARCHAR(20)') AS INT),
			p.value('@numeroReferencia','NVARCHAR(128)'),
			TRY_CAST(f.value('@fecha','VARCHAR(20)') AS DATE)
		FROM @xml.nodes('/Operaciones/FechaOperacion') AS F(f)
		CROSS APPLY f.nodes('Pagos/Pago') AS X(p)
		WHERE NOT EXISTS (
			SELECT 1
			FROM dbo.Pagos P
			WHERE P.numeroFinca = p.value('@numeroFinca','NVARCHAR(128)')
		);

		PRINT 'Datos cargados correctamente desde: ' + @path;

	END TRY
	BEGIN CATCH
		SELECT
			ERROR_NUMBER() AS ErrorNumber,
			ERROR_MESSAGE() AS ErrorMessage,
			ERROR_LINE() AS ErrorLine;
	END CATCH
END;
GO
