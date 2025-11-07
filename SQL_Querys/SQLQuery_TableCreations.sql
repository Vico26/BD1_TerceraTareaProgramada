------------------------------------------------------------------
USE Empresa3;
GO
--TABLES CREATION BEGIN
CREATE TABLE dbo.Persona(
	valorDocId NVARCHAR(20) NOT NULL PRIMARY KEY,
	Nombre NVARCHAR(128) NOT NULL,
	email NVARCHAR(128),
	telefono VARCHAR(128)
);
GO

CREATE TABLE dbo.PropiedadPersona(
	idPropiedadP INT IDENTITY(1,1) PRIMARY KEY,
	valorDocId NVARCHAR(20) NOT NULL,
	tipoAsoId INT NOT NULL,
	numeroFinca NVARCHAR(128),
	FechaInicio DATE, 
	FOREIGN KEY(numeroFinca) REFERENCES dbo.Propiedad(numeroDeFinca),
	FOREIGN KEY (valorDocId) REFERENCES dbo.Persona(valorDocId),
	FOREIGN KEY (tipoAsoId) REFERENCES dbo.TipoAsociacion(idTipoAso)
);
GO
CREATE TABLE dbo.Usuario(
	idUsuario INT IDENTITY(1,1) PRIMARY KEY,
	valorDocId NVARCHAR(20) NOT NULL,
	tipoUser INT,
	userName NVARCHAR(128) NOT NULL,
	pass NVARCHAR(128) NOT NULL,
	estado BIT NOT NULL DEFAULT 1,
	FOREIGN KEY(tipoUser) REFERENCES dbo.TipoUsuario(idUser),
	FOREIGN KEY(valorDocId) REFERENCES dbo.Persona(valorDocId)
);
GO

CREATE TABLE dbo.Propiedad(
	idPropiedad INT IDENTITY(1,1) PRIMARY KEY,
	numeroDeFinca NVARCHAR(128) UNIQUE NOT NULL,
	numeroMedidor NVARCHAR(128),
	areaM2 INT,
	tipoUso INT,
	tipoZona INT,
	valorFiscal MONEY,
	FechaRegistro DATE,
	saldoM3 DECIMAL(10,2) DEFAULT 0,
	saldoM3ultimaFactura DECIMAL(10,2) DEFAULT 0,
	FOREIGN KEY (tipoUso) REFERENCES dbo.TipoUsoPropiedad(idTipoUso),
	FOREIGN KEY (tipoZona) REFERENCES dbo.TipoZonaPropiedad(idTipoZona)
);
GO
CREATE TABLE dbo.CCPropiedad(
	idCCPropiedad INT IDENTITY(1,1) PRIMARY KEY,
	numeroDeFinca NVARCHAR(128),
	idCC INT,
	tipoAso INT,
	fechaRegistro DATE NOT NULL,
	FOREIGN KEY (idCC) REFERENCES dbo.CCs(id),
	FOREIGN KEY (tipoAso) REFERENCES dbo.TipoAsociacion(idTipoAso)
);
GO
CREATE TABLE dbo.LecturaMedidor(
	idLecturaMedidor INT IDENTITY(1,1) PRIMARY KEY,
	numeroMedidor NVARCHAR(128),
	tipoMov INT,
	valor DECIMAL(10,2),
	fechaLectura DATE NOT NULL,
	FOREIGN KEY (tipoMov) REFERENCES dbo.TipoMovimientoLecturaMedidor(idTipoMov)
);
GO
CREATE TABLE dbo.Pagos(
	idPago INT IDENTITY(1,1) PRIMARY KEY,
	numeroFinca NVARCHAR(128),
	tipoMedioPago INT,
	numeroRef NVARCHAR(128),
	fechaPago DATE NOT NULL,
	FOREIGN KEY (tipoMedioPago) REFERENCES dbo.TipoMedioPago(idTipoPago)
);