USE Empresa3;
GO
DECLARE @xml XML;

BEGIN TRY
	SELECT @xml = CONVERT(XML, BulkColumn)
	FROM OPENROWSET(
		BULK 'C:\Users\USUARIO\Documents\GitHub\BD1_TerceraTareaProgramada\XMLS\CatalogosP3.xml',
		SINGLE_BLOB
	) AS X;

	-- Parametros
	INSERT INTO dbo.Parametros(idParametro, DiaVencimientoFactura, DiasGraciasCorta)
	SELECT
		1,
		p.value('(DiasVencimientoFactura/text())[1]', 'INT'),
		p.value('(DiasGraciaCorta/text())[1]', 'INT')
	FROM @xml.nodes('/Catalogos/ParametrosSistema') AS X(p)
	WHERE NOT EXISTS (SELECT 1 FROM dbo.Parametros WHERE idParametro = 1);

	-- TipoMovimientoLecturaMedidor
	INSERT INTO dbo.TipoMovimientoLecturaMedidor(idTipoMov, Nombre)
	SELECT
		t.value('@id[1]', 'INT'),
		t.value('@nombre[1]', 'VARCHAR(128)')
	FROM @xml.nodes('/Catalogos/TipoMovimientoLecturaMedidor/TipoMov') AS X(t)
	WHERE NOT EXISTS (
		SELECT 1
		FROM dbo.TipoMovimientoLecturaMedidor tm
		WHERE tm.idTipoMov = t.value('@id[1]', 'INT')
	);

	-- TipoUsoPropiedad
	INSERT INTO dbo.TipoUsoPropiedad(idTipoUso, Nombre)
	SELECT
		u.value('@id[1]', 'INT'),
		u.value('@nombre[1]', 'VARCHAR(128)')
	FROM @xml.nodes('/Catalogos/TipoUsoPropiedad/TipoUso') AS X(u)
	WHERE NOT EXISTS (
		SELECT 1
		FROM dbo.TipoUsoPropiedad tu
		WHERE tu.idTipoUso = u.value('@id[1]', 'INT')
	);

	-- TipoZonaPropiedad
	INSERT INTO dbo.TipoZonaPropiedad(idTipoZona, Nombre)
	SELECT
		z.value('@id[1]', 'INT'),
		z.value('@nombre[1]', 'VARCHAR(128)')
	FROM @xml.nodes('/Catalogos/TipoZonaPropiedad/TipoZona') AS X(z)
	WHERE NOT EXISTS (
		SELECT 1
		FROM dbo.TipoZonaPropiedad tz
		WHERE tz.idTipoZona = z.value('@id[1]', 'INT')
	);

	-- TipoUsuario
	INSERT INTO dbo.TipoUsuario(idUser, Nombre)
	SELECT
		us.value('@id[1]', 'INT'),
		us.value('@nombre[1]', 'VARCHAR(128)')
	FROM @xml.nodes('/Catalogos/TipoUsuario/TipoUser') AS X(us)
	WHERE NOT EXISTS (
		SELECT 1
		FROM dbo.TipoUsuario tu
		WHERE tu.idUser = us.value('@id[1]', 'INT')
	);

	-- TipoAsociacion
	INSERT INTO dbo.TipoAsociacion(idTipoAso, Nombre)
	SELECT
		a.value('@id[1]', 'INT'),
		a.value('@nombre[1]', 'VARCHAR(128)')
	FROM @xml.nodes('/Catalogos/TipoAsociacion/TipoAso') AS X(a)
	WHERE NOT EXISTS (
		SELECT 1
		FROM dbo.TipoAsociacion ta
		WHERE ta.idTipoAso = a.value('@id[1]', 'INT')
	);

	-- TipoMedioPago
	INSERT INTO dbo.TipoMedioPago(idTipoPago, Nombre)
	SELECT
		mp.value('@id[1]', 'INT'),
		mp.value('@nombre[1]', 'VARCHAR(128)')
	FROM @xml.nodes('/Catalogos/TipoMedioPago/MedioPago') AS X(mp)
	WHERE NOT EXISTS (
		SELECT 1
		FROM dbo.TipoMedioPago tp
		WHERE tp.idTipoPago = mp.value('@id[1]', 'INT')
	);

	-- PeriodoMontoCC
	INSERT INTO dbo.PeriodoMontoCC(idPeriodoMonto, Nombre, cantidadMeses)
	SELECT
		m.value('@id[1]', 'INT'),
		m.value('@nombre[1]', 'VARCHAR(128)'),
		m.value('@qMeses[1]', 'INT')
	FROM @xml.nodes('/Catalogos/PeriodoMontoCC/PeriodoMonto') AS X(m)
	WHERE NOT EXISTS (
		SELECT 1
		FROM dbo.PeriodoMontoCC pm
		WHERE pm.idPeriodoMonto = m.value('@id[1]', 'INT')
	);

	-- TipoMontoC
	INSERT INTO dbo.TipoMontoC(idTipoMonto, Nombre)
	SELECT
		mc.value('@id[1]', 'INT'),
		mc.value('@nombre[1]', 'VARCHAR(128)')
	FROM @xml.nodes('/Catalogos/TipoMontoCC/TipoMonto') AS X(mc)
	WHERE NOT EXISTS (
		SELECT 1
		FROM dbo.TipoMontoC tm
		WHERE tm.idTipoMonto = mc.value('@id[1]', 'INT')
	);

	-- CCs
	INSERT INTO dbo.CCs(id, Nombre, tipoMonto, periodoMonto, valorMin, valorMinM3, valorFijoM3Adicional,
	valorPorcentual, valorFijo, valorMinM2, valorTramoM2)
	SELECT
		ISNULL(TRY_CAST(NULLIF(c.value('@id', 'VARCHAR(50)'), '') AS INT), 0),
		NULLIF(c.value('@nombre', 'VARCHAR(128)'), ''),
		ISNULL(TRY_CAST(NULLIF(c.value('@TipoMontoCC', 'VARCHAR(50)'), '') AS INT), 0),
		ISNULL(TRY_CAST(NULLIF(c.value('@PeriodoMontoCC', 'VARCHAR(50)'), '') AS INT), 0),
		ISNULL(TRY_CAST(NULLIF(c.value('@ValorMinimo', 'VARCHAR(50)'), '') AS INT), 0),
		ISNULL(TRY_CAST(NULLIF(c.value('@ValorMinimoM3', 'VARCHAR(50)'), '') AS INT), 0),
		ISNULL(TRY_CAST(NULLIF(c.value('@ValorFijoM3Adicional', 'VARCHAR(50)'), '') AS INT), 0),
		ISNULL(TRY_CAST(NULLIF(c.value('@ValorPorcentual', 'VARCHAR(50)'), '') AS DECIMAL(10,2)), 0),
		ISNULL(TRY_CAST(NULLIF(c.value('@ValorFijo', 'VARCHAR(50)'), '') AS INT), 0),
		ISNULL(TRY_CAST(NULLIF(c.value('@ValorM2Minimo', 'VARCHAR(50)'), '') AS INT), 0),
		ISNULL(TRY_CAST(NULLIF(c.value('@ValorTramosM2', 'VARCHAR(50)'), '') AS INT), 0)
	FROM @xml.nodes('/Catalogos/CCs/CC') AS X(c)
	WHERE NOT EXISTS (
		SELECT 1
		FROM dbo.CCs cc
		WHERE cc.id = ISNULL(TRY_CAST(NULLIF(c.value('@id', 'VARCHAR(50)'), '') AS INT), 0)
	);

END TRY
BEGIN CATCH
	SELECT  
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_MESSAGE() AS ErrorMessage,
		ERROR_LINE() AS ErrorLine;
END CATCH;
GO

