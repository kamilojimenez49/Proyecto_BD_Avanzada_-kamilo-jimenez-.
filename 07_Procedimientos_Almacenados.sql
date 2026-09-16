-- Base de datos: Comercio Electrónico
-- Archivo 07: Procedimientos Almacenados

USE comercio_electronico;

DELIMITER //

-- 1. sp_AgregarNuevoProducto
CREATE PROCEDURE sp_AgregarNuevoProducto(
    IN p_nombre VARCHAR(150),
    IN p_descripcion TEXT,
    IN p_precio DECIMAL(10,2),
    IN p_costo DECIMAL(10,2),
    IN p_stock INT,
    IN p_sku VARCHAR(50),
    IN p_id_categoria INT,
    IN p_id_proveedor INT
)
BEGIN
    INSERT INTO productos (nombre, descripcion, precio, costo, stock, sku, id_categoria, id_proveedor)
    VALUES (p_nombre, p_descripcion, p_precio, p_costo, p_stock, p_sku, p_id_categoria, p_id_proveedor);
END //

-- 2. sp_ActualizarDireccionCliente
CREATE PROCEDURE sp_ActualizarDireccionCliente(
    IN p_id_cliente INT,
    IN p_direccion_nueva VARCHAR(255)
)
BEGIN
    UPDATE clientes
    SET direccion_envio = p_direccion_nueva
    WHERE id_cliente = p_id_cliente;
END //

-- 3. sp_ObtenerHistorialComprasCliente
CREATE PROCEDURE sp_ObtenerHistorialComprasCliente(
    IN p_id_cliente INT
)
BEGIN
    SELECT
        v.id_venta,
        v.fecha_venta,
        v.estado,
        v.total
    FROM ventas v
    WHERE v.id_cliente = p_id_cliente
    ORDER BY v.fecha_venta DESC;
END //

-- 4. sp_AjustarNivelStock
CREATE PROCEDURE sp_AjustarNivelStock(
    IN p_id_producto INT,
    IN p_nuevo_stock INT,
    IN p_motivo VARCHAR(255)
)
BEGIN
    DECLARE v_stock_anterior INT;

    IF p_nuevo_stock < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El stock ajustado no puede ser negativo';
    ELSE
        SELECT stock INTO v_stock_anterior
        FROM productos
        WHERE id_producto = p_id_producto;

        UPDATE productos
        SET stock = p_nuevo_stock
        WHERE id_producto = p_id_producto;

        INSERT INTO log_ajustes_stock (id_producto, stock_anterior, stock_nuevo, motivo)
        VALUES (p_id_producto, v_stock_anterior, p_nuevo_stock, p_motivo);
    END IF;
END //

-- 5. sp_CambiarEstadoPedido
CREATE PROCEDURE sp_CambiarEstadoPedido(
    IN p_id_venta INT,
    IN p_nuevo_estado VARCHAR(30)
)
BEGIN
    UPDATE ventas
    SET estado = p_nuevo_estado
    WHERE id_venta = p_id_venta;
END //

-- 6. sp_RegistrarNuevoCliente
CREATE PROCEDURE sp_RegistrarNuevoCliente(
    IN p_nombre VARCHAR(100),
    IN p_apellido VARCHAR(100),
    IN p_email VARCHAR(150),
    IN p_contrasena VARCHAR(255),
    IN p_direccion_envio VARCHAR(255),
    IN p_ciudad VARCHAR(100)
)
BEGIN
    DECLARE v_existe INT;
    SELECT COUNT(*) INTO v_existe FROM clientes WHERE email = p_email;
    IF v_existe > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe un cliente registrado con ese correo electronico';
    ELSE
        INSERT INTO clientes (nombre, apellido, email, contrasena, direccion_envio, ciudad)
        VALUES (p_nombre, p_apellido, p_email, p_contrasena, p_direccion_envio, p_ciudad);
    END IF;
END //

-- 7. sp_ObtenerDetallesProductoCompleto
CREATE PROCEDURE sp_ObtenerDetallesProductoCompleto(
    IN p_id_producto INT
)
BEGIN
    SELECT
        p.id_producto,
        p.nombre,
        p.descripcion,
        p.precio,
        p.stock,
        c.nombre AS categoria,
        pr.nombre AS proveedor,
        pr.email_contacto AS proveedor_email
    FROM productos p
    LEFT JOIN categorias c ON p.id_categoria = c.id_categoria
    LEFT JOIN proveedores pr ON p.id_proveedor = pr.id_proveedor
    WHERE p.id_producto = p_id_producto;
END //

-- 8. sp_AsignarProductoAProveedor
CREATE PROCEDURE sp_AsignarProductoAProveedor(
    IN p_id_producto INT,
    IN p_id_proveedor INT
)
BEGIN
    UPDATE productos
    SET id_proveedor = p_id_proveedor
    WHERE id_producto = p_id_producto;
END //

-- 9. sp_ProcesarPago
CREATE PROCEDURE sp_ProcesarPago(
    IN p_id_venta INT
)
BEGIN
    UPDATE ventas
    SET estado = 'Pagado'
    WHERE id_venta = p_id_venta
    AND estado = 'Pendiente de Pago';
END //

-- 10. sp_MoverProductosEntreCategorias
CREATE PROCEDURE sp_MoverProductosEntreCategorias(
    IN p_id_categoria_origen INT,
    IN p_id_categoria_destino INT
)
BEGIN
    UPDATE productos
    SET id_categoria = p_id_categoria_destino
    WHERE id_categoria = p_id_categoria_origen;
END //

DELIMITER ;
