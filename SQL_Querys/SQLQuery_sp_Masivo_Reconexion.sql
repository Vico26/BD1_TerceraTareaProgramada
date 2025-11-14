USE Empresa3;
GO
CREATE OR ALTER PROCEDURE dbo.sp_ProcesoMasivo_Reconexion
    @FechaOperacion DATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        -- Insertar reconexiones donde la factura ya fue pagada
        INSERT INTO dbo.OrdenReconexion (idOrdenCorte, numeroFinca, fechaReconexion)
        SELECT oc.idOrdenCorte, oc.numeroFinca, @FechaOperacion
        FROM dbo.OrdenCorte oc
        JOIN dbo.Factura f ON f.idFactura = oc.idFactura
        WHERE oc.estado = 1
          AND f.pagado = 1
          AND NOT EXISTS (
              SELECT 1 FROM dbo.OrdenReconexion r WHERE r.idOrdenCorte = oc.idOrdenCorte
          );

        -- Actualizar estado
        UPDATE oc
        SET oc.estado = 2,
            oc.fechaEstado = @FechaOperacion
        FROM dbo.OrdenCorte oc
        JOIN dbo.Factura f ON f.idFactura = oc.idFactura
        WHERE oc.estado = 1 AND f.pagado = 1;

        COMMIT;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;

        THROW;  -- Re-lanza el error original sin usar RAISERROR
    END CATCH
END
GO
