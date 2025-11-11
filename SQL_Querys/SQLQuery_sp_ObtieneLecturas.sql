USE Empresa3;
GO

CREATE OR ALTER PROCEDURE sp_ObtenerLecturasPorMedidor
    @numeroMedidor NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar que el medidor exista
    IF NOT EXISTS (SELECT 1 FROM dbo.Propiedad WHERE numeroMedidor = @numeroMedidor)
    BEGIN
        PRINT 'El medidor no está asociado a ninguna propiedad.';
        RETURN 50008;
    END;

    -- Verificar si existen lecturas para ese medidor
    IF NOT EXISTS (SELECT 1 FROM dbo.LecturaMedidor WHERE numeroMedidor = @numeroMedidor)
    BEGIN
        PRINT 'No hay lecturas registradas para este medidor.';
        RETURN 50009;
    END;

    -- Mostrar lecturas
    SELECT numeroMedidor, tipoMov, valor, fechaLectura
    FROM dbo.LecturaMedidor
    WHERE numeroMedidor = @numeroMedidor
    ORDER BY fechaLectura;
END;
GO
