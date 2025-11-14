------------------------------------------------------------------
USE Empresa3;
GO
--TABLES CREATION BEGIN
CREATE TABLE dbo.Persona(
	valorDocId NVARCHAR(20) NOT NULL PRIMARY KEY,
	Nombre NVARCHAR(128) NOT NULL,
	email NVARCHAR(128),
	telefono VARCHAR(128),
	fechaRegistro DATE
);
GO

CREATE TABLE dbo.PropiedadPersona(
	idPropiedadP INT IDENTITY(1,1) PRIMARY KEY,
	valorDocId NVARCHAR(20) NOT NULL,
	numeroFinca NVARCHAR(128),
	tipoAsoId INT NOT NULL,
	fechaRegistro DATE,
	fechaFin DATE NULL,
	FOREIGN KEY(numeroFinca) REFERENCES dbo.Propiedad(numeroFinca),
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
	numeroFinca NVARCHAR(128) UNIQUE NOT NULL,
	numeroMedidor NVARCHAR(128),
	areaM2 INT,
	tipoUso INT NOT NULL,
	tipoZona INT NOT NULL,
	valorFiscal MONEY NOT NULL,
	FechaRegistro DATE NOT NULL,
	saldoM3 DECIMAL(10,2) DEFAULT 0,
	saldoM3ultimaFactura DECIMAL(10,2) DEFAULT 0,
	FOREIGN KEY (tipoUso) REFERENCES dbo.TipoUsoPropiedad(idTipoUso),
	FOREIGN KEY (tipoZona) REFERENCES dbo.TipoZonaPropiedad(idTipoZona)
);
GO
CREATE TABLE dbo.CCPropiedad(
	idCCPropiedad INT IDENTITY(1,1) PRIMARY KEY,
	numeroFinca NVARCHAR(128),
	idCC INT NOT NULL,
	tipoAso INT NOT NULL,
	fechaRegistro DATE NOT NULL,
	FOREIGN KEY (idCC) REFERENCES dbo.CCs(id),
	FOREIGN KEY (tipoAso) REFERENCES dbo.TipoAsociacion(idTipoAso)
);
GO
CREATE TABLE dbo.LecturaMedidor(
	idLecturaMedidor INT IDENTITY(1,1) PRIMARY KEY,
	numeroMedidor NVARCHAR(128),
	tipoMov INT NOT NULL,
	valor DECIMAL(10,2),
	fechaLectura DATE NOT NULL,
	FOREIGN KEY (tipoMov) REFERENCES dbo.TipoMovimientoLecturaMedidor(idTipoMov)
);
GO

CREATE TABLE dbo.Factura (
    idFactura INT IDENTITY(1,1) PRIMARY KEY,   -- Clave interna automática
	numeroFactura NVARCHAR(128) NOT NULL,       -- Número visible (FAC-YYYY-XXXX)
    numeroFinca NVARCHAR(128) NOT NULL,         
    fechaFactura DATE NOT NULL,
	fechaVencimiento DATE NULL, -- Fecha límite de pago
    consumoM3 DECIMAL(10,2) NOT NULL,           
    monto MONEY NOT NULL,
	totalFinal MONEY NULL,
    pagado BIT DEFAULT 0,
	FOREIGN KEY(numeroFinca) REFERENCES dbo.Propiedad(numeroFinca)
);
GO

CREATE TABLE dbo.Pagos(
	idPago INT IDENTITY(1,1) PRIMARY KEY,
	numeroFinca NVARCHAR(128),
	tipoMedioPago INT,
	idFactura INT NULL,
	numeroRef NVARCHAR(128),
	fechaPago DATE NOT NULL,
	FOREIGN KEY (idFactura) REFERENCES dbo.Factura(idFactura),
	FOREIGN KEY (tipoMedioPago) REFERENCES dbo.TipoMedioPago(idTipoPago)
);
GO
CREATE TABLE dbo.DetalleFactura(
    idDetalle INT IDENTITY(1,1) PRIMARY KEY,
    idFactura INT NOT NULL,
    idCC INT NULL,                -- referencia al CC aplicado (si aplica)
    descripcion NVARCHAR(200) NULL,
    monto MONEY NOT NULL,
    fechaRegistro DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    FOREIGN KEY (idFactura) REFERENCES dbo.Factura(idFactura),
    FOREIGN KEY (idCC) REFERENCES dbo.CCs(id)
);
GO
CREATE TABLE dbo.OrdenCorte(
    idOrdenCorte INT IDENTITY(1,1) PRIMARY KEY,
    idFactura INT NOT NULL,
    numeroFinca NVARCHAR(128) NOT NULL,
    fechaOrden DATE NOT NULL,
    estado INT NOT NULL DEFAULT 1, -- 1: pendiente reconexión, 2: reconexión pagado
    fechaEstado DATE NULL,
    FOREIGN KEY (idFactura) REFERENCES dbo.Factura(idFactura)
);
GO
CREATE TABLE dbo.OrdenReconexion(
    idReconexion INT IDENTITY(1,1) PRIMARY KEY,
    idOrdenCorte INT NOT NULL,
    numeroFinca NVARCHAR(128) NOT NULL,
    fechaReconexion DATE NOT NULL,
    FOREIGN KEY (idOrdenCorte) REFERENCES dbo.OrdenCorte(idOrdenCorte)
);


