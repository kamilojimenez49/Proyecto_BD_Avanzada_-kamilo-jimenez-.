-- Base de datos: Comercio Electrónico
-- Archivo 02: Consultas Avanzadas

USE comercio_electronico;

-- 1. Análisis de Ventas Mensuales: total vendido agrupado por mes y año
SELECT
    YEAR(fecha_venta) AS anio,
    MONTH(fecha_venta) AS mes,
    SUM(total) AS total_vendido
FROM ventas
GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
ORDER BY anio, mes;

-- 2. Crecimiento de Clientes: nuevos clientes registrados por trimestre
SELECT
    YEAR(fecha_registro) AS anio,
    QUARTER(fecha_registro) AS trimestre,
    COUNT(*) AS clientes_nuevos
FROM clientes
GROUP BY YEAR(fecha_registro), QUARTER(fecha_registro)
ORDER BY anio, trimestre;

-- 3. Productos que Necesitan Reabastecimiento: stock por debajo del minimo
SELECT
    id_producto,
    nombre,
    stock,
    stock_minimo
FROM productos
WHERE stock < stock_minimo;

-- 4. Análisis Geográfico de Ventas: ventas agrupadas por ciudad del cliente
SELECT
    c.ciudad,
    COUNT(v.id_venta) AS cantidad_ventas,
    SUM(v.total) AS total_vendido
FROM ventas v
INNER JOIN clientes c ON v.id_cliente = c.id_cliente
GROUP BY c.ciudad
ORDER BY total_vendido DESC;

-- 5. Ventas por Hora del Día: identifica las horas pico de compra
SELECT
    HOUR(fecha_venta) AS hora,
    COUNT(*) AS cantidad_ventas
FROM ventas
GROUP BY HOUR(fecha_venta)
ORDER BY cantidad_ventas DESC;

-- 6. Margen de beneficio por producto: precio menos costo
SELECT
    id_producto,
    nombre,
    precio,
    costo,
    (precio - costo) AS margen,
    ROUND(((precio - costo) / precio) * 100, 2) AS margen_porcentaje
FROM productos
ORDER BY margen DESC;

-- 7. Top 10 Productos Más Vendidos: por ingresos generados
SELECT
    p.id_producto,
    p.nombre,
    SUM(dv.cantidad) AS unidades_vendidas,
    SUM(dv.cantidad * dv.precio_unitario_congelado) AS ingresos_generados
FROM detalle_ventas dv
INNER JOIN productos p ON dv.id_producto = p.id_producto
GROUP BY p.id_producto, p.nombre
ORDER BY ingresos_generados DESC
LIMIT 10;

-- 8. Clientes VIP: top 5 clientes por gasto total historico (LTV)
SELECT
    c.id_cliente,
    c.nombre,
    c.apellido,
    SUM(v.total) AS gasto_total
FROM clientes c
INNER JOIN ventas v ON c.id_cliente = v.id_cliente
GROUP BY c.id_cliente, c.nombre, c.apellido
ORDER BY gasto_total DESC
LIMIT 5;

-- 9. Tasa de Compra Repetida: porcentaje de clientes con mas de una compra
SELECT
    ROUND(
        (SELECT COUNT(*) FROM (
            SELECT id_cliente FROM ventas GROUP BY id_cliente HAVING COUNT(*) > 1
        ) AS clientes_recurrentes)
        / (SELECT COUNT(DISTINCT id_cliente) FROM ventas) * 100
    , 2) AS porcentaje_compra_repetida;

-- 10. Rendimiento de Proveedores: ranking segun el volumen de ventas de sus productos
SELECT
    pr.id_proveedor,
    pr.nombre,
    SUM(dv.cantidad * dv.precio_unitario_congelado) AS total_vendido
FROM proveedores pr
INNER JOIN productos p ON pr.id_proveedor = p.id_proveedor
INNER JOIN detalle_ventas dv ON p.id_producto = dv.id_producto
GROUP BY pr.id_proveedor, pr.nombre
ORDER BY total_vendido DESC;
