USE Empresa3;
GO

CREATE TRIGGER trg_AgregarCCPorDefault
ON dbo.Propiedad
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idAso INT = 1;  -- 1 = Asociar

    -- 1) Impuesto sobre la propiedad (siempre)
    INSERT INTO dbo.CCPropiedad (numeroFinca, idCC, tipoAso, fechaRegistro)
    SELECT i.numeroFinca, 3, @idAso, GETDATE()
    FROM inserted i
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.CCPropiedad c WHERE c.numeroFinca = i.numeroFinca AND c.idCC = 3
    );

    -- 2) Recolección de basura: si NO es agrícola (tipoZona != 2)
    INSERT INTO dbo.CCPropiedad (numeroFinca, idCC, tipoAso, fechaRegistro)
    SELECT i.numeroFinca, 4, @idAso, GETDATE()
    FROM inserted i
    WHERE ISNULL(i.tipoZona,0) <> 2
      AND NOT EXISTS (
          SELECT 1 FROM dbo.CCPropiedad c WHERE c.numeroFinca = i.numeroFinca AND c.idCC = 4
      );

    -- 3) Mantenimiento de parques: si residencial(1) o comercial(5)
    INSERT INTO dbo.CCPropiedad (numeroFinca, idCC, tipoAso, fechaRegistro)
    SELECT i.numeroFinca, 5, @idAso, GETDATE()
    FROM inserted i
    WHERE i.tipoZona IN (1,5)
      AND NOT EXISTS (
          SELECT 1 FROM dbo.CCPropiedad c WHERE c.numeroFinca = i.numeroFinca AND c.idCC = 5
      );

END;
GO
