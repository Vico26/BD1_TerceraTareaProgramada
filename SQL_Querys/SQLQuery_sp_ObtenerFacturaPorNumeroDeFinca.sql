USE Empresa3;
GO
CREATE OR ALTER PROCEDURE dbo.sp_ObtenerFacturasPorFinca
    @numeroFinca NVARCHAR(128)
AS
BEGIN
    SELECT numeroFactura, fechaFactura, consumoM3, monto, fechaVencimiento, pagado
    FROM dbo.Factura
    WHERE numeroFinca = @numeroFinca
    ORDER BY fechaFactura DESC;
END;
GO
