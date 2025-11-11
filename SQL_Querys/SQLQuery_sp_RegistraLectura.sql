USE Empresa3;
GO

CREATE OR ALTER PROCEDURE sp_RegistrarLectura
    @numeroMedidor NVARCHAR(128),
    @tipoMov INT,
    @valor DECIMAL(10,2),
    @fechaLectura DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ultimaLectura DECIMAL(10,2),
            @consumo DECIMAL(10,2);

    BEGIN TRY
        -- Validar existencia del medidor
        IF NOT EXISTS (SELECT 1 FROM dbo.Propiedad WHERE numeroMedidor = @numeroMedidor)
        BEGIN
            RETURN 50008; -- No existe el medidor indicado
        END;

        -- Obtener la última lectura registrada desde la propiedad
        SELECT @ultimaLectura = saldoM3ultimaFactura
        FROM dbo.Propiedad 
        WHERE numeroMedidor = @numeroMedidor;

        -- Calcular consumo según tipoMov
        IF @tipoMov = 1  -- Lectura normal
            SET @consumo = ISNULL(@valor - @ultimaLectura, 0);
        ELSE              -- Lectura 2 o 3
            SET @consumo = ISNULL(@ultimaLectura - @valor, 0);

        -- Insertar nueva lectura
        INSERT INTO dbo.LecturaMedidor (numeroMedidor, tipoMov, valor, fechaLectura)
        VALUES (@numeroMedidor, @tipoMov, @valor, @fechaLectura);

        -- Actualizar saldoM3 y saldoM3ultimaFactura
        UPDATE dbo.Propiedad
        SET saldoM3 = CASE 
                         WHEN saldoM3 + @consumo < 0 THEN 0 
                         ELSE saldoM3 + @consumo 
                      END,
            saldoM3ultimaFactura = @valor
        WHERE numeroMedidor = @numeroMedidor;

        --PRINT CONCAT('Lectura registrada correctamente. Consumo: ', @consumo);
		RETURN 0;
    END TRY
    BEGIN CATCH
        SELECT ERROR_NUMBER() AS ErrorNumber,
               ERROR_MESSAGE() AS ErrorMessage,
               ERROR_LINE() AS ErrorLine;
    END CATCH;
END;
GO
