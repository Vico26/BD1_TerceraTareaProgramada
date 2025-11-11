USE Empresa3;
GO 

CREATE OR ALTER PROCEDURE sp_ObtenerPagosPorFinca
    @numeroFinca NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar que la finca exista
    IF NOT EXISTS (SELECT 1 FROM dbo.Propiedad WHERE numeroDeFinca = @numeroFinca)
    BEGIN
        PRINT 'No existe una propiedad con ese número de finca.';
        RETURN 50008;
    END;

    -- Si no hay pagos registrados, avisar
    IF NOT EXISTS (SELECT 1 FROM dbo.Pagos WHERE numeroFinca = @numeroFinca)
    BEGIN
        PRINT 'No hay pagos registrados para esta finca.';
        RETURN 50009;
    END;

    -- Mostrar pagos
    SELECT numeroFinca, tipoMedioPago, numeroRef, fechaPago
    FROM dbo.Pagos
    WHERE numeroFinca = @numeroFinca
    ORDER BY fechaPago;
END;
GO
