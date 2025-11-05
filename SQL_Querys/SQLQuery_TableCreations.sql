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
	idPropiedad INT NOT NULL,
	valorDocId NVARCHAR(20) NOT NULL,
	tipoAsoId INT NOT NULL,
	FechaInicio DATE,
	PRIMARY KEY (idPropiedad,valorDocId,FechaInicio),
	FOREIGN KEY(idPropiedad) REFERENCES dbo.Propiedad(idPropiedad),
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
	numeroDeFinca NVARCHAR(128),
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
