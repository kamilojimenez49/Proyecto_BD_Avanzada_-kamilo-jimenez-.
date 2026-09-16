-- Base de datos: Comercio Electrónico
-- Archivo 03: Funciones

USE comercio_electronico;

DELIMITER //

CREATE FUNCTION fn_ObtenerPrecioProducto(p_id_producto INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_precio DECIMAL(10,2);
    SELECT precio INTO v_precio
    FROM productos
    WHERE id_producto = p_id_producto;
    RETURN v_precio;
END //

CREATE FUNCTION fn_FormatearNombreCompleto(p_id_cliente INT)
RETURNS VARCHAR(200)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_nombre_completo VARCHAR(200);
    SELECT CONCAT(nombre, ' ', apellido) INTO v_nombre_completo
    FROM clientes
    WHERE id_cliente = p_id_cliente;
    RETURN v_nombre_completo;
END //

CREATE FUNCTION fn_AplicarDescuento(p_monto DECIMAL(10,2), p_porcentaje DECIMAL(5,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN p_monto - (p_monto * p_porcentaje / 100);
END //

CREATE FUNCTION fn_ObtenerNombreCategoria(p_id_producto INT)
RETURNS VARCHAR(100)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_nombre_categoria VARCHAR(100);
    SELECT c.nombre INTO v_nombre_categoria
    FROM productos p
    INNER JOIN categorias c ON p.id_categoria = c.id_categoria
    WHERE p.id_producto = p_id_producto;
    RETURN v_nombre_categoria;
END //

CREATE FUNCTION fn_ContarVentasCliente(p_id_cliente INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total_ventas INT;
    SELECT COUNT(*) INTO v_total_ventas
    FROM ventas
    WHERE id_cliente = p_id_cliente;
    RETURN v_total_ventas;
END //

CREATE FUNCTION fn_CalcularIVA(p_monto DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN p_monto * 0.19;
END //

CREATE FUNCTION fn_ConvertirMoneda(p_monto DECIMAL(10,2), p_tasa_cambio DECIMAL(10,4))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN p_monto * p_tasa_cambio;
END //

CREATE FUNCTION fn_CalcularTotalVenta(p_id_venta INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(10,2);
    SELECT SUM(cantidad * precio_unitario_congelado) INTO v_total
    FROM detalle_ventas
    WHERE id_venta = p_id_venta;
    RETURN IFNULL(v_total, 0);
END //

CREATE FUNCTION fn_VerificarDisponibilidadStock(p_id_producto INT, p_cantidad INT)
RETURNS TINYINT(1)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_stock INT;
    SELECT stock INTO v_stock
    FROM productos
    WHERE id_producto = p_id_producto;
    IF v_stock >= p_cantidad THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END //

CREATE FUNCTION fn_ObtenerUltimaFechaCompra(p_id_cliente INT)
RETURNS DATETIME
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_ultima_fecha DATETIME;
    SELECT MAX(fecha_venta) INTO v_ultima_fecha
    FROM ventas
    WHERE id_cliente = p_id_cliente;
    RETURN v_ultima_fecha;
END //

DELIMITER ;
