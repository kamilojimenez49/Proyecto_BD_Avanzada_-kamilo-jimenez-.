USE comercio_electronico;

CREATE TABLE IF NOT EXISTS devoluciones (
    id_devolucion INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    fecha_devolucion DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_devolucion_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_dev_venta FOREIGN KEY (id_venta) REFERENCES ventas(id_venta),
    CONSTRAINT fk_dev_producto FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

DELIMITER //

DROP PROCEDURE IF EXISTS sp_ProcesarDevolucion //

CREATE PROCEDURE sp_ProcesarDevolucion(
    IN p_id_venta INT,
    IN p_id_producto INT,
    IN p_cantidad_devuelta INT
)
BEGIN
    DECLARE v_cantidad_comprada INT DEFAULT 0;
    DECLARE v_total_devuelto_previo INT DEFAULT 0;
    DECLARE v_nueva_cantidad_devuelta INT DEFAULT 0;
    DECLARE v_total_articulos_venta INT DEFAULT 0;
    DECLARE v_total_articulos_devueltos INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF p_cantidad_devuelta <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La cantidad a devolver debe ser mayor a cero';
    END IF;

    -- Validar existencia del producto en la venta
    SELECT cantidad INTO v_cantidad_comprada
    FROM detalle_ventas
    WHERE id_venta = p_id_venta AND id_producto = p_id_producto
    FOR UPDATE;

    IF v_cantidad_comprada IS NULL OR v_cantidad_comprada = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El producto no pertenece a la venta especificada';
    END IF;

    -- Verificar que no se devuelva mas de lo comprado
    SELECT IFNULL(SUM(cantidad), 0) INTO v_total_devuelto_previo
    FROM devoluciones
    WHERE id_venta = p_id_venta AND id_producto = p_id_producto;

    SET v_nueva_cantidad_devuelta = v_total_devuelto_previo + p_cantidad_devuelta;

    IF v_nueva_cantidad_devuelta > v_cantidad_comprada THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La cantidad a devolver supera la cantidad comprada en esta venta';
    END IF;

    -- Reingreso de stock al inventario
    UPDATE productos
    SET stock = stock + p_cantidad_devuelta
    WHERE id_producto = p_id_producto;

    -- Registro en auditoria de devoluciones
    INSERT INTO devoluciones (id_venta, id_producto, cantidad, fecha_devolucion)
    VALUES (p_id_venta, p_id_producto, p_cantidad_devuelta, NOW());

    -- Actualizar estado de la venta segun cantidades devueltas
    SELECT SUM(cantidad) INTO v_total_articulos_venta
    FROM detalle_ventas
    WHERE id_venta = p_id_venta;

    SELECT IFNULL(SUM(cantidad), 0) INTO v_total_articulos_devueltos
    FROM devoluciones
    WHERE id_venta = p_id_venta;

    IF v_total_articulos_devueltos >= v_total_articulos_venta THEN
        UPDATE ventas
        SET estado = 'Devuelto Totalmente'
        WHERE id_venta = p_id_venta;
    ELSE
        UPDATE ventas
        SET estado = 'Devolución Parcial'
        WHERE id_venta = p_id_venta;
    END IF;

    COMMIT;
END //

DELIMITER ;