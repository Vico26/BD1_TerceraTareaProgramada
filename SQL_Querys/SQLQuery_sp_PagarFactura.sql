USE Empresa3;
GO
CREATE OR ALTER PROCEDURE dbo.sp_PagarFactura
    @idFactura INT,
    @tipoMedioPago INT,
    @numeroRef NVARCHAR(128),
    @fechaPago DATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        -- 1) Validar que exista la factura
        IF NOT EXISTS (SELECT 1 FROM dbo.Factura WHERE idFactura = @idFactura)
        BEGIN
            ROLLBACK; RETURN 50001; -- factura no existe
        END;

        DECLARE @numFinca NVARCHAR(128);
        SELECT @numFinca = numeroFinca FROM dbo.Factura WHERE idFactura = @idFactura;

        -- 2) Validar que la factura sea la más vieja pendiente de esa finca
        DECLARE @idMasVieja INT;

        SELECT TOP 1 @idMasVieja = idFactura
        FROM dbo.Factura
        WHERE numeroFinca = @numFinca AND pagado = 0
        ORDER BY fechaFactura ASC, idFactura ASC;

        IF @idMasVieja IS NULL
        BEGIN
            ROLLBACK; RETURN 50009; -- no hay pendientes
        END;

        IF @idMasVieja <> @idFactura
        BEGIN
            ROLLBACK; RETURN 50010; -- no puede pagar otra factura que no sea la más vieja
        END;

        -- 3) Calcular intereses moratorios si aplica
        DECLARE 
            @fechaVenc DATE,
            @moraTotal MONEY = 0,
            @diasVencidos INT = 0,
            @tasaDiaria DECIMAL(10,6) = 0,
            @totalActual MONEY;

        SELECT @fechaVenc = fechaVencimiento, @totalActual = totalFinal
        FROM dbo.Factura
        WHERE idFactura = @idFactura;

        SELECT TOP 1 @tasaDiaria = ISNULL(valorPorcentual,0)
        FROM dbo.CCs
        WHERE id = 7;   -- CC Intereses Moratorios

        IF @tasaDiaria IS NULL SET @tasaDiaria = 0;

        IF @fechaPago > ISNULL(@fechaVenc, @fechaPago)
        BEGIN
            SET @diasVencidos = DATEDIFF(DAY, @fechaVenc, @fechaPago);

            SET @moraTotal = CAST((@totalActual * @tasaDiaria * @diasVencidos) AS MONEY);

            IF @moraTotal > 0
            BEGIN
                INSERT INTO dbo.DetalleFactura (idFactura, idCC, descripcion, monto)
                VALUES (@idFactura, 7, CONCAT('Intereses moratorios ', @diasVencidos, ' días'), @moraTotal);

                UPDATE dbo.Factura
                SET totalFinal = totalFinal + @moraTotal
                WHERE idFactura = @idFactura;
            END
        END

        -- 4) Insertar pago
        INSERT INTO dbo.Pagos (numeroFinca, tipoMedioPago, idFactura, numeroRef, fechaPago)
        VALUES (@numFinca, @tipoMedioPago, @idFactura, @numeroRef, @fechaPago);

        DECLARE @idPago INT = SCOPE_IDENTITY();

        -- 5) Marcar factura como pagada
        UPDATE dbo.Factura
        SET pagado = 1
        WHERE idFactura = @idFactura;

        -- 6) Marcar orden de corte como pagada (si existe)
        UPDATE oc
        SET oc.estado = 2, oc.fechaEstado = @fechaPago
        FROM dbo.OrdenCorte oc
        WHERE oc.idFactura = @idFactura;

        COMMIT;

        -- Respuesta para UI
        SELECT 
            idPago = @idPago,
            mensaje = 'Pago registrado correctamente',
            intereses = @moraTotal;

        RETURN 0;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;

        PRINT 'Error en sp_PagarFactura: ' + ERROR_MESSAGE();
        RETURN ERROR_NUMBER();
    END CATCH
END;
GO

