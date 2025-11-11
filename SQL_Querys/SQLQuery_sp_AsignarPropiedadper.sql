USE Empresa3;
GO

CREATE OR ALTER PROCEDURE dbo.sp_AsignarPropiedadPersona
    @valorDocId NVARCHAR(20),
    @numeroFinca NVARCHAR(128),
    @tipoAsoId INT,
    @fechaRegistro DATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validar que la persona exista
        IF NOT EXISTS (SELECT 1 FROM dbo.Persona WHERE valorDocId = @valorDocId)
        BEGIN
            RETURN 50001; -- Persona no existe
        END;

        -- Validar que la propiedad exista
        IF NOT EXISTS (SELECT 1 FROM dbo.Propiedad WHERE numeroDeFinca = @numeroFinca)
        BEGIN
            RETURN 50008; -- Propiedad no existe
        END;

        -- Validar que la asociación no exista ya
        IF EXISTS (
            SELECT 1 FROM dbo.PropiedadPersona
            WHERE valorDocId = @valorDocId AND numeroFinca = @numeroFinca
        )
        BEGIN
            RETURN 50008; -- Asociación ya existe
        END;

        -- Insertar nueva relación
        INSERT INTO dbo.PropiedadPersona (valorDocId, numeroFinca, tipoAsoId, fechaRegistro)
        VALUES (@valorDocId, @numeroFinca, @tipoAsoId, @fechaRegistro);

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
