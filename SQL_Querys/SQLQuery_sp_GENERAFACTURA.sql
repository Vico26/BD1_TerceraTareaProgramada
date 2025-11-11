USE Empresa3;
GO

CREATE OR ALTER PROCEDURE dbo.sp_CalcularFacturaMensual
    @numeroFinca NVARCHAR(128),
    @fechaFactura DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @idCC INT,
        @valorMin MONEY,
        @valorMinM3 MONEY,
        @valorFijoM3Adicional MONEY,
        @consumo DECIMAL(10,2),
        @montoFactura MONEY,
        @idFactura INT,
        @numeroFactura NVARCHAR(128),
        @diasVenc INT,
        @fechaVencimiento DATE;

    BEGIN TRY
        -- Validar que la propiedad exista
        IF NOT EXISTS (SELECT 1 FROM dbo.Propiedad WHERE numeroDeFinca = @numeroFinca)
        BEGIN
            RETURN 50008; -- Propiedad no existe
        END;

        -- Obtener el código de cobro (CC) asociado
        SELECT TOP 1 @idCC = idCC
        FROM dbo.CCPropiedad
        WHERE numeroDeFinca = @numeroFinca
        ORDER BY fechaRegistro DESC;

        IF @idCC IS NULL
        BEGIN
            RETURN 50008; -- No hay CC asociado
        END;

        -- Obtener parámetros del CC
        SELECT 
            @valorMin = ISNULL(valorMin, 0),
            @valorMinM3 = ISNULL(valorMinM3, 0),
            @valorFijoM3Adicional = ISNULL(valorFijoM3Adicional, 0)
        FROM dbo.CCs
        WHERE id = @idCC;

        -- Obtener consumo actual
        SELECT @consumo = saldoM3
        FROM dbo.Propiedad
        WHERE numeroDeFinca = @numeroFinca;

        -- Calcular monto de factura
        IF @consumo <= @valorMinM3
            SET @montoFactura = @valorMin;
        ELSE
            SET @montoFactura = @valorMin + ((@consumo - @valorMinM3) * @valorFijoM3Adicional);

        -- Obtener días de vencimiento desde la tabla Parametros (si existe)
        SELECT TOP 1 @diasVenc = DiaVencimientoFactura FROM dbo.Parametros;
        SET @fechaVencimiento = DATEADD(DAY, ISNULL(@diasVenc, 30), @fechaFactura);

        -- Generar número de factura (ejemplo: FAC-2025-0001)
        SET @numeroFactura = CONCAT(
            'FAC-', YEAR(@fechaFactura), '-',
            RIGHT('0000' + CAST(
                (SELECT COUNT(*) + 1 FROM dbo.Factura WHERE YEAR(fechaFactura) = YEAR(@fechaFactura))
            AS NVARCHAR(10)), 4)
        );

        -- Insertar la factura
        INSERT INTO dbo.Factura (numeroFactura, numeroFinca, fechaFactura, consumoM3, monto, fechaVencimiento)
        VALUES (@numeroFactura, @numeroFinca, @fechaFactura, @consumo, @montoFactura, @fechaVencimiento);

        -- Obtener el ID recién insertado
        SET @idFactura = SCOPE_IDENTITY();

        -- Actualizar saldos
        UPDATE dbo.Propiedad
        SET 
            saldoM3ultimaFactura = saldoM3,
            saldoM3 = 0
        WHERE numeroDeFinca = @numeroFinca;

        -- Mostrar la información generada
        SELECT 
            @idFactura AS IdFactura,
            @numeroFactura AS NumeroFactura,
            @numeroFinca AS NumeroFinca,
            @consumo AS ConsumoM3,
            @montoFactura AS Monto,
            @fechaFactura AS FechaFactura,
            @fechaVencimiento AS FechaVencimiento;
		RETURN 0;
    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_LINE() AS ErrorLine;
    END CATCH;
END;
GO


