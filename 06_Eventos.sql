-- Base de datos: Comercio Electrónico
-- Archivo 06: Eventos Programados

USE comercio_electronico;

SET GLOBAL event_scheduler = ON;

DELIMITER //

-- 1. evt_cleanup_temp_tables_daily
CREATE EVENT evt_cleanup_temp_tables_daily
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    DROP TEMPORARY TABLE IF EXISTS tmp_calculo_diario;
END //

-- 2. evt_generate_reorder_list_daily
CREATE EVENT evt_generate_reorder_list_daily
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    INSERT INTO lista_reabastecimiento (id_producto, stock_actual, stock_minimo)
    SELECT id_producto, stock, stock_minimo
    FROM productos
    WHERE stock < stock_minimo;
END //

-- 3. evt_rebuild_indexes_weekly
CREATE EVENT evt_rebuild_indexes_weekly
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    OPTIMIZE TABLE productos, clientes, ventas, detalle_ventas;
END //

-- 4. evt_log_database_size_weekly
CREATE EVENT evt_log_database_size_weekly
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    INSERT INTO log_tamano_bd (fecha, tamano_mb)
    SELECT NOW(), ROUND(SUM(data_length + index_length) / 1024 / 1024, 2)
    FROM information_schema.tables
    WHERE table_schema = 'comercio_electronico';
END //

-- 5. evt_archive_old_logs_monthly
CREATE EVENT evt_archive_old_logs_monthly
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    INSERT INTO log_cambios_precio_archivo (id_log, id_producto, precio_anterior, precio_nuevo, fecha_cambio)
    SELECT id_log, id_producto, precio_anterior, precio_nuevo, fecha_cambio
    FROM log_cambios_precio
    WHERE fecha_cambio < DATE_SUB(NOW(), INTERVAL 6 MONTH);

    DELETE FROM log_cambios_precio
    WHERE fecha_cambio < DATE_SUB(NOW(), INTERVAL 6 MONTH);
END //

-- 6. evt_aggregate_daily_sales_data
CREATE EVENT evt_aggregate_daily_sales_data
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    INSERT INTO resumen_ventas_diarias (fecha, total_ventas, cantidad_ventas)
    SELECT CURDATE(), IFNULL(SUM(total), 0), COUNT(*)
    FROM ventas
    WHERE DATE(fecha_venta) = CURDATE();
END //

-- 7. evt_update_product_rankings_hourly
CREATE EVENT evt_update_product_rankings_hourly
ON SCHEDULE EVERY 1 HOUR
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    INSERT INTO ranking_productos (id_producto, unidades_vendidas)
    SELECT id_producto, SUM(cantidad)
    FROM detalle_ventas
    GROUP BY id_producto;
END //

-- 8. evt_generate_supplier_performance_report_monthly
CREATE EVENT evt_generate_supplier_performance_report_monthly
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    INSERT INTO reporte_proveedores (id_proveedor, total_vendido)
    SELECT p.id_proveedor, SUM(dv.cantidad * dv.precio_unitario_congelado)
    FROM proveedores p
    INNER JOIN productos pr ON p.id_proveedor = pr.id_proveedor
    INNER JOIN detalle_ventas dv ON pr.id_producto = dv.id_producto
    GROUP BY p.id_proveedor;
END //

-- 9. evt_generate_weekly_sales_report
CREATE EVENT evt_generate_weekly_sales_report
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    INSERT INTO reporte_ventas_semanales (semana, total_ventas)
    SELECT CONCAT(YEAR(CURDATE()), '-S', WEEK(CURDATE())), IFNULL(SUM(total), 0)
    FROM ventas
    WHERE YEARWEEK(fecha_venta) = YEARWEEK(CURDATE());
END //

-- 10. evt_recalculate_customer_loyalty_tiers_nightly
CREATE EVENT evt_recalculate_customer_loyalty_tiers_nightly
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    UPDATE clientes c
    SET nivel_lealtad = (
        SELECT CASE
            WHEN IFNULL(SUM(v.total), 0) >= 500000 THEN 'Oro'
            WHEN IFNULL(SUM(v.total), 0) >= 200000 THEN 'Plata'
            ELSE 'Bronce'
        END
        FROM ventas v
        WHERE v.id_cliente = c.id_cliente
    );
END //

DELIMITER ;
