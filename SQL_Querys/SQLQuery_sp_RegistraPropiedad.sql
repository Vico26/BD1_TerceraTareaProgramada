USE Empresa3;
GO

CREATE OR ALTER PROCEDURE dbo.sp_RegistrarPropiedad
    @numeroDeFinca NVARCHAR(128),
    @numeroMedidor NVARCHAR(128),
    @areaM2 INT,
    @tipoUso INT,
    @tipoZona INT,
    @valorFiscal MONEY,
    @fechaRegistro DATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validar existencia de la finca
        IF EXISTS (SELECT 1 FROM dbo.Propiedad WHERE numeroDeFinca = @numeroDeFinca)
        BEGIN
            RETURN 50008;
        END;

        -- Insertar nueva propiedad
        INSERT INTO dbo.Propiedad (
            numeroDeFinca,
            numeroMedidor,
            areaM2,
            tipoUso,
            tipoZona,
            valorFiscal,
            fechaRegistro,
            saldoM3,
            saldoM3ultimaFactura
        )
        VALUES (
            @numeroDeFinca,
            @numeroMedidor,
            @areaM2,
            @tipoUso,
            @tipoZona,
            @valorFiscal,
            @fechaRegistro,
            0,  -- saldo inicial
            0   -- última lectura inicial
        );

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
