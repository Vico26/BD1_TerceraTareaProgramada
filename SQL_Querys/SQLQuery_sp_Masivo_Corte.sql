USE Empresa3;
GO
CREATE OR ALTER PROCEDURE dbo.sp_ProcesoMasivo_Cortes
    @FechaOperacion DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;

        DECLARE @DiasGracia INT;
        SELECT TOP 1 @DiasGracia = DiasGraciasCorta FROM dbo.Parametros;

        -- Facturas vencidas además del periodo de gracia
        ;WITH FacturasVencidas AS (
            SELECT F.*
            FROM dbo.Factura F
            WHERE F.pagado = 0
              AND DATEADD(DAY, ISNULL(@DiasGracia,0), ISNULL(F.fechaVencimiento,F.fechaFactura)) < @FechaOperacion
        )

        -- Insertar ordenes de corte para facturas vencidas y que pertenezcan a fincas con CC Agua
        INSERT INTO dbo.OrdenCorte (idFactura, numeroFinca, fechaOrden, estado)
        SELECT fv.idFactura, fv.numeroFinca, @FechaOperacion, 1
        FROM FacturasVencidas fv
        WHERE EXISTS (
            SELECT 1 FROM dbo.CCPropiedad ccp WHERE ccp.numeroFinca = fv.numeroFinca AND ccp.idCC = 3
        )
        AND NOT EXISTS (
            SELECT 1 FROM dbo.OrdenCorte oc WHERE oc.idFactura = fv.idFactura
        );

        -- Añadir detalle de reconexión (CC id=6) y aumentar totalFinal de factura
        -- Obtenemos monto de reconexión desde CC id = 6 si existe
        DECLARE @montoReconexion MONEY = (
            SELECT TOP 1 CAST(ISNULL(valorFijo,0) AS MONEY) FROM dbo.CCs WHERE id = 6
        );

        IF @montoReconexion IS NULL SET @montoReconexion = 0;

        -- Insertar detalle para cada factura que acabamos de crear orden de corte (evita duplicados)
        INSERT INTO dbo.DetalleFactura (idFactura, idCC, descripcion, monto)
        SELECT oc.idFactura, 6, 'Reconexión de agua (orden de corte)', @montoReconexion
        FROM dbo.OrdenCorte oc
        WHERE oc.fechaOrden = @FechaOperacion
          AND oc.estado = 1
          AND NOT EXISTS (
              SELECT 1 FROM dbo.DetalleFactura df
              WHERE df.idFactura = oc.idFactura AND df.idCC = 6
          );

        -- Actualizar totalFinal sumando monto reconexión
        UPDATE F
        SET F.totalFinal = F.totalFinal + @montoReconexion
        FROM dbo.Factura F
        WHERE EXISTS (
            SELECT 1 FROM dbo.OrdenCorte oc WHERE oc.idFactura = F.idFactura AND oc.fechaOrden = @FechaOperacion
        );

        COMMIT;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        DECLARE @err NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Error en sp_ProcesoMasivo_Cortes: %s',16,1,@err);
        RETURN ERROR_NUMBER();
    END CATCH
END
GO
