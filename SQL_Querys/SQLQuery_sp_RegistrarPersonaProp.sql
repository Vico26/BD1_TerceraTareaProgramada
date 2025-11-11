USE Empresa3;
GO

CREATE OR ALTER PROCEDURE sp_RegistrarPropiedadPersona
    @valorDocId NVARCHAR(20),
    @numeroFinca NVARCHAR(128),
    @tipoAsoId INT,
    @fechaRegistro DATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validar existencia de la persona
        IF NOT EXISTS (SELECT 1 FROM dbo.Persona WHERE valorDocId = @valorDocId)
        BEGIN
            RETURN 50008;
        END;

        -- Validar existencia de la propiedad
        IF NOT EXISTS (SELECT 1 FROM dbo.Propiedad WHERE numeroDeFinca = @numeroFinca)
        BEGIN
            RETURN 50008;
        END;

        -- Validar si la asociación ya existe
        IF EXISTS (
            SELECT 1
            FROM dbo.PropiedadPersona
            WHERE valorDocId = @valorDocId AND numeroFinca = @numeroFinca
        )
        BEGIN
            RETURN 50008;
        END;

        -- Insertar nueva relación
        INSERT INTO dbo.PropiedadPersona (valorDocId, numeroFinca, tipoAsoId, fechaRegistro)
        VALUES (@valorDocId, @numeroFinca, @tipoAsoId, @fechaRegistro);

        RETURN 0;
    END TRY
    BEGIN CATCH
        SELECT ERROR_NUMBER() AS ErrorNumber,
               ERROR_MESSAGE() AS ErrorMessage,
               ERROR_LINE() AS ErrorLine;
    END CATCH;
END;
GO
