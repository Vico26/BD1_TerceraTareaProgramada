USE Empresa3;
GO
CREATE OR ALTER PROCEDURE dbo.sp_MarcarFacturaPagada
    @numeroFactura NVARCHAR(128)
AS
BEGIN
    UPDATE dbo.Factura
    SET pagado = 1
    WHERE numeroFactura = @numeroFactura;
END;
GO
