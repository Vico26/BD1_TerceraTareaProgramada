USE Empresa3;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FacturarTodas
    @fechaFactura DATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Insertar todas las facturas en una sola operación
        INSERT INTO dbo.Factura (numeroFinca, fechaFactura, consumoM3, monto)
        SELECT 
            P.numeroDeFinca,
            @fechaFactura,
            P.saldoM3 AS consumoM3,
            CASE 
                WHEN P.saldoM3 <= ISNULL(C.valorMinM3, 0)
                    THEN ISNULL(C.valorMin, 0)
                ELSE ISNULL(C.valorMin, 0) + ((P.saldoM3 - ISNULL(C.valorMinM3, 0)) * ISNULL(C.valorFijoM3Adicional, 0))
            END AS monto
        FROM dbo.Propiedad P
        INNER JOIN dbo.CCPropiedad CCP ON CCP.numeroDeFinca = P.numeroDeFinca
        INNER JOIN dbo.CCs C ON C.id = CCP.idCC
        WHERE P.saldoM3 > 0;  -- solo se factura si hay consumo

        -- Actualizar saldos en Propiedad después de facturar
        UPDATE P
        SET 
            P.saldoM3ultimaFactura = P.saldoM3,
            P.saldoM3 = 0
        FROM dbo.Propiedad P
        WHERE P.saldoM3 > 0;

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

