USE Empresa3;
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_ProcesarOperacionesPorFecha]
    @path NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @xml XML, @sql NVARCHAR(MAX);
    DECLARE @Resultado INT = 0;

    BEGIN TRY
        -- Cargar XML desde archivo
        SET @sql = N'SELECT @x = CONVERT(XML, BulkColumn)
                      FROM OPENROWSET(BULK ''' + @path + ''', SINGLE_BLOB) AS X;';
        EXEC sp_executesql @sql, N'@x XML OUTPUT', @x = @xml OUTPUT;

        -- Usar tabla variable en lugar de temporal (PERMITIDO)
        DECLARE @Fechas TABLE (Fecha DATE PRIMARY KEY, Orden INT IDENTITY(1,1));

        -- Insertar fechas ordenadas (CORREGIDO: sin ORDER BY en INSERT)
        INSERT INTO @Fechas (Fecha)
        SELECT DISTINCT fecha.value('@fecha', 'DATE')
        FROM @xml.nodes('/Operaciones/FechaOperacion') AS T(fecha);

        -- Validar que hay fechas
        IF NOT EXISTS (SELECT 1 FROM @Fechas)
        BEGIN
            RETURN 50001; -- No se encontraron fechas
        END;

        -- Procesar usando WHILE en lugar de cursor
        DECLARE @FechaOperacion DATE;
        DECLARE @MinOrden INT, @MaxOrden INT, @CurrentOrden INT = 0;

        SELECT @MinOrden = MIN(Orden), @MaxOrden = MAX(Orden) FROM @Fechas;

        WHILE @CurrentOrden < @MaxOrden
        BEGIN
            SET @CurrentOrden = @CurrentOrden + 1;
            
            SELECT @FechaOperacion = Fecha 
            FROM @Fechas 
            WHERE Orden = @CurrentOrden;

            BEGIN TRY
                BEGIN TRANSACTION;

                -- 1. Procesar Personas
                INSERT INTO dbo.Persona (valorDocId, Nombre, email, telefono, fechaRegistro)
                SELECT
                    p.value('@valorDocumento','NVARCHAR(20)'),
                    p.value('@nombre','NVARCHAR(128)'),
                    p.value('@email','NVARCHAR(128)'),
                    p.value('@telefono','NVARCHAR(128)'),
                    @FechaOperacion
                FROM @xml.nodes('/Operaciones/FechaOperacion') AS F(f)
                CROSS APPLY f.nodes('Personas/Persona') AS X(p)
                WHERE f.value('@fecha', 'DATE') = @FechaOperacion
                AND NOT EXISTS (
                    SELECT 1 FROM dbo.Persona WHERE valorDocId = p.value('@valorDocumento','NVARCHAR(20)')
                );

                -- 2. Procesar Propiedades
                INSERT INTO dbo.Propiedad (numeroFinca, numeroMedidor, areaM2, tipoUso, tipoZona, valorFiscal, FechaRegistro)
                SELECT
                    P.value('@numeroFinca','NVARCHAR(128)'),
                    P.value('@numeroMedidor','NVARCHAR(128)'),
                    P.value('@metrosCuadrados','INT'),
                    P.value('@tipoUsoId','INT'),
                    P.value('@tipoZonaId','INT'),
                    P.value('@valorFiscal','MONEY'),
                    ISNULL(P.value('@fechaRegistro','DATE'), @FechaOperacion)
                FROM @xml.nodes('/Operaciones/FechaOperacion') AS F(f)
                CROSS APPLY f.nodes('Propiedades/Propiedad') AS X(P)
                WHERE f.value('@fecha', 'DATE') = @FechaOperacion
                AND NOT EXISTS (SELECT 1 FROM dbo.Propiedad WHERE numeroFinca = P.value('@numeroFinca','NVARCHAR(128)'));

                -- 3. Procesar PropiedadPersona
                INSERT INTO dbo.PropiedadPersona (valorDocId, numeroFinca, tipoAsoId, fechaRegistro)
                SELECT
                    pp.value('@valorDocumento','NVARCHAR(20)'),
                    pp.value('@numeroFinca','NVARCHAR(128)'),
                    pp.value('@tipoAsociacionId','INT'),
                    @FechaOperacion
                FROM @xml.nodes('/Operaciones/FechaOperacion') AS F(f)
                CROSS APPLY f.nodes('PropiedadPersona/Movimiento') AS X(pp)
                WHERE f.value('@fecha', 'DATE') = @FechaOperacion;

                -- 4. Procesar CCPropiedad
                INSERT INTO dbo.CCPropiedad (numeroFinca, idCC, tipoAso, fechaRegistro)
                SELECT
                    c.value('@numeroFinca','NVARCHAR(128)'),
                    c.value('@idCC','INT'),
                    c.value('@tipoAsociacionId','INT'),
                    @FechaOperacion
                FROM @xml.nodes('/Operaciones/FechaOperacion') AS F(f)
                CROSS APPLY f.nodes('CCPropiedad/Movimiento') AS X(c)
                WHERE f.value('@fecha', 'DATE') = @FechaOperacion;

                -- 5. Procesar LecturasMedidor
                INSERT INTO dbo.LecturaMedidor (numeroMedidor, tipoMov, valor, fechaLectura)
                SELECT
                    l.value('@numeroMedidor','NVARCHAR(128)'),
                    l.value('@tipoMovimientoId','INT'),
                    l.value('@valor','DECIMAL(10,2)'),
                    @FechaOperacion
                FROM @xml.nodes('/Operaciones/FechaOperacion') AS F(f)
                CROSS APPLY f.nodes('LecturasMedidor/Lectura') AS X(l)
                WHERE f.value('@fecha', 'DATE') = @FechaOperacion;

                -- 6. Actualizar saldos de medidores después de lecturas
                UPDATE p
                SET p.saldoM3 = lm.valor
                FROM dbo.Propiedad p
                INNER JOIN dbo.LecturaMedidor lm ON p.numeroMedidor = lm.numeroMedidor
                WHERE lm.fechaLectura = @FechaOperacion 
                AND lm.tipoMov = 1;

                -- 7. Procesar Pagos (sin cursor)
                INSERT INTO dbo.Pagos (numeroFinca, tipoMedioPago, numeroRef, fechaPago)
                SELECT
                    p.value('@numeroFinca','NVARCHAR(128)'),
                    p.value('@tipoMedioPagoId','INT'),
                    p.value('@numeroReferencia','NVARCHAR(128)'),
                    @FechaOperacion
                FROM @xml.nodes('/Operaciones/FechaOperacion') AS F(f)
                CROSS APPLY f.nodes('Pagos/Pago') AS X(p)
                WHERE f.value('@fecha', 'DATE') = @FechaOperacion;

                -- 8. Procesos Masivos (en orden)
                EXEC @Resultado = dbo.sp_ProcesoMasivo_Facturacion @FechaOperacion;
                IF @Resultado <> 0 
                BEGIN
                    ROLLBACK;
                    RETURN @Resultado;
                END

                EXEC @Resultado = dbo.sp_ProcesoMasivo_Cortes @FechaOperacion;
                IF @Resultado <> 0 
                BEGIN
                    ROLLBACK;
                    RETURN @Resultado;
                END

                EXEC @Resultado = dbo.sp_ProcesoMasivo_Reconexion @FechaOperacion;
                IF @Resultado <> 0 
                BEGIN
                    ROLLBACK;
                    RETURN @Resultado;
                END

                COMMIT TRANSACTION;
            END TRY
            BEGIN CATCH
                IF @@TRANCOUNT > 0
                    ROLLBACK TRANSACTION;
                RETURN ERROR_NUMBER();
            END CATCH
        END

        RETURN 0;
    END TRY
    BEGIN CATCH
        RETURN ERROR_NUMBER();
    END CATCH
END;
GO