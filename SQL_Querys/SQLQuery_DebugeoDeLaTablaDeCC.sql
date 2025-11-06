USE Empresa3;
GO

DECLARE @xml XML;

SELECT @xml = CONVERT(XML, BulkColumn)
FROM OPENROWSET(
	BULK 'C:\Users\USUARIO\Documents\GitHub\BD1_TerceraTareaProgramada\XMLS\CatalogosP3.xml',
	SINGLE_BLOB
) AS X;

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
FROM @xml.nodes('/Catalogos/CCs/CC') AS X(c);
