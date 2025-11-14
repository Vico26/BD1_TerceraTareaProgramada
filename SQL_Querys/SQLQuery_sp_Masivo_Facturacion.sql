USE Empresa3;
GO
CREATE OR ALTER PROCEDURE dbo.sp_ProcesoMasivo_Facturacion
    @FechaOperacion DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;

        DECLARE @dia INT = DAY(@FechaOperacion);
        DECLARE @DiaVenc INT, @DiasGracia INT;

        -- Obtener parámetros del sistema (tu tabla dbo.Parametros)
        SELECT TOP 1 @DiaVenc = DiaVencimientoFactura, @DiasGracia = DiasGraciasCorta
        FROM dbo.Parametros;

        -- 1) Propiedades a facturar hoy (día de registro coincide ó caso 31->mes corto)
        DECLARE @Props TABLE (numeroFinca NVARCHAR(128) PRIMARY KEY, consumo DECIMAL(18,4), valorFiscal MONEY);

        INSERT INTO @Props (numeroFinca, consumo, valorFiscal)
        SELECT
            p.numeroFinca,
            (ISNULL(p.saldoM3,0) - ISNULL(p.saldoM3ultimaFactura,0)) AS consumo,
            p.valorFiscal
        FROM dbo.Propiedad p
        WHERE
            (DAY(p.FechaRegistro) = @dia)
            OR (
                DAY(p.FechaRegistro) > DAY(EOMONTH(@FechaOperacion))
                AND @dia = DAY(EOMONTH(@FechaOperacion))
            );

        IF NOT EXISTS (SELECT 1 FROM @Props)
        BEGIN
            ROLLBACK;
            RETURN 0; -- no hay propiedades para facturar
        END

        -- 2) Insertar facturas (cabeceras) y capturar ids insertados (uno por finca)
        DECLARE @InsertedFacturas TABLE (idFactura INT, numeroFinca NVARCHAR(128), consumo DECIMAL(18,4), fechaFactura DATE, fechaVencimiento DATE, totalInicial MONEY);

        INSERT INTO dbo.Factura (numeroFactura, numeroFinca, fechaFactura, fechaVencimiento, consumoM3, monto, totalFinal, pagado)
        OUTPUT inserted.idFactura, inserted.numeroFinca, inserted.consumoM3, inserted.fechaFactura, inserted.fechaVencimiento, inserted.monto
        INTO @InsertedFacturas (idFactura, numeroFinca, consumo, fechaFactura, fechaVencimiento, totalInicial)
        SELECT
            -- numeroFactura: FAC-YYYY-ROW#
            CONCAT('FAC-', YEAR(@FechaOperacion), '-', RIGHT('0000' + CAST(ROW_NUMBER() OVER (ORDER BY p.numeroFinca) AS NVARCHAR(10)),4)) AS numeroFactura,
            p.numeroFinca,
            @FechaOperacion AS fechaFactura,
            DATEADD(DAY, ISNULL(@DiaVenc,30), @FechaOperacion) AS fechaVencimiento,
            (ISNULL(p.saldoM3,0) - ISNULL(p.saldoM3ultimaFactura,0)) AS consumoM3,

            -- monto inicial: sum only water CC for now; we'll add other CCs in detalle
            ISNULL( (CASE 
                WHEN (ISNULL(p.saldoM3,0) - ISNULL(p.saldoM3ultimaFactura,0)) * ISNULL(c.valorMinM3,0) > ISNULL(c.valorMin,0)
                    THEN (ISNULL(p.saldoM3,0) - ISNULL(p.saldoM3ultimaFactura,0)) * ISNULL(c.valorFijoM3Adicional,0)
                ELSE ISNULL(c.valorMin,0)
            END), 0) AS monto,

            -- totalFinal same as monto initially
            ISNULL( (CASE 
                WHEN (ISNULL(p.saldoM3,0) - ISNULL(p.saldoM3ultimaFactura,0)) * ISNULL(c.valorMinM3,0) > ISNULL(c.valorMin,0)
                    THEN (ISNULL(p.saldoM3,0) - ISNULL(p.saldoM3ultimaFactura,0)) * ISNULL(c.valorFijoM3Adicional,0)
                ELSE ISNULL(c.valorMin,0)
            END), 0) AS totalFinal,

            0 -- pagado = 0 (pendiente default)
        FROM dbo.Propiedad p
        LEFT JOIN dbo.CCPropiedad ccp ON ccp.numeroFinca = p.numeroFinca
        LEFT JOIN dbo.CCs c ON c.id = ccp.idCC AND c.id = 3 -- agua CC only for initial monto
        WHERE p.numeroFinca IN (SELECT numeroFinca FROM @Props);

        -- 3) Insertar detalle por cada CC asociado: calculamos monto por CC y lo insertamos en DetalleFactura
        -- Usamos @InsertedFacturas para relacionar facturas con propiedades
        INSERT INTO dbo.DetalleFactura (idFactura, idCC, descripcion, monto)
        SELECT
            f.idFactura,
            cc.id,
            cc.nombre,
            -- monto según tipo de CC
            CASE 
                WHEN cc.tipoMonto = 1 -- monto fijo (valorFijo), se prorratea por periodo si aplica
                    THEN CASE WHEN ISNULL(pm.cantidadMeses,1) > 1 THEN CAST(cc.valorFijo AS MONEY) / ISNULL(pm.cantidadMeses,1) ELSE CAST(cc.valorFijo AS MONEY) END

                WHEN cc.tipoMonto = 2 -- consumo (Agua u otros por M3)
                    -- Usamos fórmula del PDF: if consumo * M3TarifaMinima > TarifaMinima then consumo * CostoM3 else TarifaMinima
                    THEN CASE 
                            WHEN (ISNULL(prop.consumo,0) * ISNULL(cc.valorMinM3,0)) > ISNULL(cc.valorMin,0)
                                THEN CAST(ISNULL(prop.consumo,0) * ISNULL(cc.valorFijoM3Adicional,0) AS MONEY)
                            ELSE CAST(ISNULL(cc.valorMin,0) AS MONEY)
                         END

                WHEN cc.tipoMonto = 3 -- porcentaje sobre valor fiscal (se divide por periodo en meses)
                    THEN CAST( (ISNULL(cc.valorPorcentual,0) * ISNULL(prop.valorFiscal,0)) / NULLIF(ISNULL(pm.cantidadMeses,1),0) AS MONEY)

                ELSE 0
            END AS montoCC
        FROM @InsertedFacturas f
        JOIN dbo.Propiedad p ON p.numeroFinca = f.numeroFinca
        JOIN dbo.CCPropiedad ccp ON ccp.numeroFinca = p.numeroFinca
        JOIN dbo.CCs cc ON cc.id = ccp.idCC
        LEFT JOIN dbo.PeriodoMontoCC pm ON pm.idPeriodoMonto = cc.periodoMonto
        LEFT JOIN (SELECT numeroFinca, consumo, valorFiscal FROM @Props) prop ON prop.numeroFinca = f.numeroFinca
        WHERE 1=1;

        -- 4) Ajustar totalFinal de factura sumando los detalles (ya insertados)
        UPDATE F
        SET F.totalFinal = DF.sumDetalle
        FROM dbo.Factura F
        JOIN (
            SELECT idFactura, SUM(monto) AS sumDetalle
            FROM dbo.DetalleFactura
            WHERE idFactura IN (SELECT idFactura FROM @InsertedFacturas)
            GROUP BY idFactura
        ) DF ON DF.idFactura = F.idFactura;

        -- 5) Actualizar SaldoM3UltimaFactura para las propiedades facturadas
        UPDATE P
        SET P.saldoM3ultimaFactura = P.saldoM3
        FROM dbo.Propiedad P
        WHERE P.numeroFinca IN (SELECT numeroFinca FROM @InsertedFacturas);

        COMMIT;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        DECLARE @errMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Error en sp_ProcesoMasivo_Facturacion: %s',16,1,@errMsg);
        RETURN ERROR_NUMBER();
    END CATCH
END
GO
