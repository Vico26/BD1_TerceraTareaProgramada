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
CREATE TABLE dbo.UsuarioAdmin(
	idUser INT PRIMARY KEY,
	Nombre VARCHAR(128),
	pass VARCHAR(128)
);
GO
CREATE TABLE dbo.TipoAsociacion(
	idTipoAso INT PRIMARY KEY,
	Nombre VARCHAR(128)
);
GO
CREATE TABLE dbo.TipoMedioPago(
	idTipoPago INT PRIMARY KEY,
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
	nombre NVARCHAR(128),
	tipoMonto INT NOT NULL,         --Relación con TipoMontoCC
	periodoMonto INT NOT NULL,      --Relación con PeriodoMontoCC
	valorMin INT NULL,
	valorMinM3 INT NULL,
	valorFijoM3Adicional INT NULL,
	valorPorcentual DECIMAL(10,4) NULL,
	valorFijo INT NULL,
	valorMinM2 INT NULL,
	valorTramoM2 INT NULL,
	FOREIGN KEY (tipoMonto) REFERENCES dbo.TipoMontoC(idTipoMonto),
	FOREIGN KEY (periodoMonto) REFERENCES dbo.PeriodoMontoCC(idPeriodoMonto)
);
--CATALOGS CREATION END
