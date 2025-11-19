USE Empresa3;
GO
CREATE TRIGGER trg_AgregarCCPorDefault
ON dbo.Propiedad
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idAso INT = 1;  -- 1 = Asociar

    -- 1) Impuesto sobre la propiedad (siempre) - CC id=3
    INSERT INTO dbo.CCPropiedad (numeroFinca, idCC, tipoAso, fechaRegistro)
    SELECT i.numeroFinca, 3, @idAso, GETDATE()
    FROM inserted i;

    -- 2) Recolección de basura: si NO es agrícola (tipoZona != 2) - CC id=4
    INSERT INTO dbo.CCPropiedad (numeroFinca, idCC, tipoAso, fechaRegistro)
    SELECT i.numeroFinca, 4, @idAso, GETDATE()
    FROM inserted i
    WHERE i.tipoZona <> 2;  -- 2 = agrícola

    -- 3) Mantenimiento de parques: si residencial(1) o comercial(5) - CC id=5
    INSERT INTO dbo.CCPropiedad (numeroFinca, idCC, tipoAso, fechaRegistro)
    SELECT i.numeroFinca, 5, @idAso, GETDATE()
    FROM inserted i
    WHERE i.tipoZona IN (1, 5);  -- 1=residencial, 5=comercial

    -- 4) Consumo de agua (siempre) - CC id=1
    INSERT INTO dbo.CCPropiedad (numeroFinca, idCC, tipoAso, fechaRegistro)
    SELECT i.numeroFinca, 1, @idAso, GETDATE()
    FROM inserted i;

END;
GO