USE Empresa3;
GO

CREATE OR ALTER PROCEDURE dbo.sp_AsignarCCPropiedad
    @numeroFinca NVARCHAR(128),
    @idCC INT,
    @tipoAso INT,
    @fechaRegistro DATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validar que la propiedad exista
        IF NOT EXISTS (SELECT 1 FROM dbo.Propiedad WHERE numeroDeFinca = @numeroFinca)
        BEGIN
            RETURN 50001; -- Propiedad no existe
        END;

        -- Validar que el código de cobro (CC) exista
        IF NOT EXISTS (SELECT 1 FROM dbo.CCs WHERE id = @idCC)
        BEGIN
            RETURN 50008; -- CC no existe
        END;

        -- Validar que la asociación no exista ya
        IF EXISTS (
            SELECT 1 
            FROM dbo.CCPropiedad
            WHERE numeroDeFinca = @numeroFinca AND idCC = @idCC
        )
        BEGIN
            RETURN 50008; -- Asociación ya existe
        END;

        -- Insertar nueva asociación
        INSERT INTO dbo.CCPropiedad (numeroDeFinca, idCC, tipoAso, fechaRegistro)
        VALUES (@numeroFinca, @idCC, @tipoAso, @fechaRegistro);

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
