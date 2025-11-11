USE Empresa3;
GO

CREATE PROCEDURE sp_realizarPago
    @numeroFinca NVARCHAR(128),
    @tipoMedioPago INT,
    @numeroRef NVARCHAR(128),
    @fechaPago DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Verifica que la propiedad exista
        IF NOT EXISTS (SELECT 1 FROM dbo.Propiedad WHERE numeroDeFinca = @numeroFinca)
        BEGIN
            RETURN 50008;
        END;

        -- Verifica que no exista ya ese número de referencia
        IF EXISTS (SELECT 1 FROM dbo.Pagos WHERE numeroRef = @numeroRef)
        BEGIN
           RETURN 50008;
        END;

        -- Inserta el pago
        INSERT INTO dbo.Pagos (numeroFinca, tipoMedioPago, numeroRef, fechaPago)
        VALUES (@numeroFinca, @tipoMedioPago, @numeroRef, @fechaPago);

        RETURN 0;
	END TRY
	BEGIN CATCH
	SELECT
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_MESSAGE() AS ErrorMessage,
		ERROR_LINE() AS ErrorLine;
	END CATCH
END;
GO
