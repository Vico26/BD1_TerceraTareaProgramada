USE Empresa3;
GO
--CATALOG CREATION BEGIN
CREATE TABLE dbo.Parametros(
	idParametro INT PRIMARY KEY CHECK(idParametro = 1),
	DiaVencimientoFactura INT,
	DiasGraciasCorta INT
);
GO
CREATE TABLE dbo.TipoMovimientoLecturaMedidor(
	idTipoMov INT PRIMARY KEY,
	Nombre VARCHAR(128)
);
GO
CREATE TABLE dbo.TipoUsoPropiedad(
	idTipoUso INT PRIMARY KEY,
	Nombre VARCHAR(128)
);
GO
CREATE TABLE dbo.TipoZonaPropiedad(
	idTipoZona INT PRIMARY KEY,
	Nombre VARCHAR(128)
);
GO
CREATE TABLE dbo.TipoUsuario(
	idUser INT PRIMARY KEY,
	Nombre VARCHAR(128)
);
GO
CREATE TABLE dbo.TipoAsociacion(
	idTipoAso INT PRIMARY KEY,
	Nombre VARCHAR(128)
);
GO
CREATE TABLE dbo.PeriodoMontoCC(
	idPeriodoMonto INT PRIMARY KEY,
	Nombre VARCHAR(128),
	cantidadMeses INT
);
GO
CREATE TABLE dbo.TipoMontoC(
	idTipoMonto INT PRIMARY KEY,
	Nombre VARCHAR(128)
);
GO
CREATE TABLE dbo.CCs(
	id INT PRIMARY KEY,
	Nombre VARCHAR(128),
	tipoMonto INT,
	periodoMonto INT,
	valorMin INT,
	valorMinM3 INT,
	valorFijoM3Adicional INT,
	valorPorcentual DECIMAL(10,2),
	valorFijo INT,
	valorMinM2 INT,
	valorTramoM2 INT
);
GO
--CATALOGS CREATION END
