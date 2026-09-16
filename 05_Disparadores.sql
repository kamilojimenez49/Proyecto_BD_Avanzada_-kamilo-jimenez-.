-- Base de datos: Comercio Electrónico
-- Archivo 05: Disparadores (Triggers)

USE comercio_electronico;

DELIMITER //

-- 1. trg_prevent_delete_categoria_with_products
CREATE TRIGGER trg_prevent_delete_categoria_with_products
BEFORE DELETE ON categorias
FOR EACH ROW
BEGIN
    DECLARE v_cantidad INT;
    SELECT COUNT(*) INTO v_cantidad FROM productos WHERE id_categoria = OLD.id_categoria;
    IF v_cantidad > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar la categoria: tiene productos asociados';
    END IF;
END //

-- 2. trg_log_new_customer_after_insert
CREATE TRIGGER trg_log_new_customer_after_insert
AFTER INSERT ON clientes
FOR EACH ROW
BEGIN
    INSERT INTO log_clientes_nuevos (id_cliente, fecha_registro)
    VALUES (NEW.id_cliente, NOW());
END //

-- 3. trg_set_fecha_modificacion_producto
CREATE TRIGGER trg_set_fecha_modificacion_producto
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN
    SET NEW.fecha_modificacion = NOW();
END //

-- 4. trg_prevent_negative_stock
CREATE TRIGGER trg_prevent_negative_stock
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN
    IF NEW.stock < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El stock de un producto no puede ser negativo';
    END IF;
END //

-- 5. trg_capitalize_nombre_cliente
CREATE TRIGGER trg_capitalize_nombre_cliente
BEFORE INSERT ON clientes
FOR EACH ROW
BEGIN
    SET NEW.nombre = CONCAT(UPPER(LEFT(NEW.nombre, 1)), LOWER(SUBSTRING(NEW.nombre, 2)));
    SET NEW.apellido = CONCAT(UPPER(LEFT(NEW.apellido, 1)), LOWER(SUBSTRING(NEW.apellido, 2)));
END //

-- 6. trg_prevent_price_zero_or_less
CREATE TRIGGER trg_prevent_price_zero_or_less
BEFORE INSERT ON productos
FOR EACH ROW
BEGIN
    IF NEW.precio <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El precio de un producto debe ser mayor que cero';
    END IF;
END //

-- 6b. Version del mismo trigger para actualizaciones (el enunciado pide bloquear
-- el precio en cero o negativo cuando "se establezca", es decir insercion o actualizacion)
CREATE TRIGGER trg_prevent_price_zero_or_less_update
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN
    IF NEW.precio <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El precio de un producto debe ser mayor que cero';
    END IF;
END //

-- 7. trg_update_last_order_date_customer
CREATE TRIGGER trg_update_last_order_date_customer
AFTER INSERT ON ventas
FOR EACH ROW
BEGIN
    UPDATE clientes
    SET fecha_ultima_compra = NEW.fecha_venta
    WHERE id_cliente = NEW.id_cliente;
END //

-- 8. trg_assign_default_category_on_null
CREATE TRIGGER trg_assign_default_category_on_null
BEFORE INSERT ON productos
FOR EACH ROW
BEGIN
    IF NEW.id_categoria IS NULL THEN
        SET NEW.id_categoria = (SELECT id_categoria FROM categorias WHERE nombre = 'General' LIMIT 1);
    END IF;
END //

-- 9. trg_audit_precio_producto_after_update
CREATE TRIGGER trg_audit_precio_producto_after_update
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    IF OLD.precio <> NEW.precio THEN
        INSERT INTO log_cambios_precio (id_producto, precio_anterior, precio_nuevo, fecha_cambio)
        VALUES (NEW.id_producto, OLD.precio, NEW.precio, NOW());
    END IF;
END //

-- 10. trg_update_stock_after_insert_venta
CREATE TRIGGER trg_update_stock_after_insert_venta
AFTER INSERT ON detalle_ventas
FOR EACH ROW
BEGIN
    UPDATE productos
    SET stock = stock - NEW.cantidad
    WHERE id_producto = NEW.id_producto;
END //

DELIMITER ;
