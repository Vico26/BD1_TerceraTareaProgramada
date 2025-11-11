USE Empresa3;
GO

CREATE OR ALTER PROCEDURE sp_RegistrarPersona
    @valorDocId NVARCHAR(20),
    @nombre NVARCHAR(128),
    @email NVARCHAR(128),
    @telefono NVARCHAR(128),
    @fechaRegistro DATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validar que el documento no sea nulo o vacío
        IF @valorDocId IS NULL OR @valorDocId = ''
        BEGIN
            PRINT 'El valor del documento no puede estar vacío.';
            RETURN 50008;
        END;

        -- Verificar si la persona ya existe
        IF EXISTS (SELECT 1 FROM dbo.Persona WHERE valorDocId = @valorDocId)
        BEGIN
            PRINT 'La persona ya existe.';
            RETURN 50008;
        END;

        -- Insertar nueva persona
        INSERT INTO dbo.Persona (valorDocId, Nombre, email, telefono, fechaRegistro)
        VALUES (@valorDocId, @nombre, @email, @telefono, @fechaRegistro);

        RETURN 0;
    END TRY
    BEGIN CATCH
        SELECT ERROR_NUMBER() AS ErrorNumber,
               ERROR_MESSAGE() AS ErrorMessage,
               ERROR_LINE() AS ErrorLine;
    END CATCH;
END;
GO
