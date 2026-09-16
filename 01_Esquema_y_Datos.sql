-- Base de datos: Comercio Electrónico
-- Archivo 01: Esquema y Datos

DROP DATABASE IF EXISTS comercio_electronico;
CREATE DATABASE comercio_electronico CHARACTER SET utf8mb4;
USE comercio_electronico;

-- ============================================================
-- TABLAS PRINCIPALES
-- ============================================================

CREATE TABLE categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(255)
);

CREATE TABLE proveedores (
    id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    email_contacto VARCHAR(150) UNIQUE,
    telefono_contacto VARCHAR(30)
);

CREATE TABLE productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL UNIQUE,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    costo DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    stock_minimo INT NOT NULL DEFAULT 5,
    sku VARCHAR(50) NOT NULL UNIQUE,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    activo TINYINT(1) NOT NULL DEFAULT 1,
    ubicacion VARCHAR(100) DEFAULT 'Bodega Principal',
    id_categoria INT,
    id_proveedor INT,
    CONSTRAINT chk_precio CHECK (precio > 0),
    CONSTRAINT chk_costo CHECK (costo >= 0),
    CONSTRAINT chk_stock CHECK (stock >= 0),
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria),
    FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor)
);

CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL,
    direccion_envio VARCHAR(255),
    ciudad VARCHAR(100),
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_ultima_compra DATETIME,
    nivel_lealtad VARCHAR(20) DEFAULT 'Bronce'
);

CREATE TABLE ventas (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    fecha_venta DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) NOT NULL DEFAULT 'Pendiente de Pago',
    total DECIMAL(10,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

CREATE TABLE detalle_ventas (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario_congelado DECIMAL(10,2) NOT NULL,
    CONSTRAINT chk_cantidad CHECK (cantidad > 0),
    FOREIGN KEY (id_venta) REFERENCES ventas(id_venta),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

-- ============================================================
-- TABLAS DE APOYO (necesarias para triggers, eventos y reportes)
-- ============================================================

CREATE TABLE log_cambios_precio (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    precio_anterior DECIMAL(10,2),
    precio_nuevo DECIMAL(10,2),
    fecha_cambio DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE log_cambios_precio_archivo (
    id_log INT PRIMARY KEY,
    id_producto INT NOT NULL,
    precio_anterior DECIMAL(10,2),
    precio_nuevo DECIMAL(10,2),
    fecha_cambio DATETIME
);

CREATE TABLE log_clientes_nuevos (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE lista_reabastecimiento (
    id_lista INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    stock_actual INT NOT NULL,
    stock_minimo INT NOT NULL,
    fecha_generacion DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE log_tamano_bd (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    tamano_mb DECIMAL(10,2)
);

CREATE TABLE resumen_ventas_diarias (
    id_resumen INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    total_ventas DECIMAL(12,2) NOT NULL,
    cantidad_ventas INT NOT NULL
);

CREATE TABLE ranking_productos (
    id_ranking INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    unidades_vendidas INT NOT NULL,
    fecha_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE reporte_proveedores (
    id_reporte INT AUTO_INCREMENT PRIMARY KEY,
    id_proveedor INT NOT NULL,
    total_vendido DECIMAL(12,2) NOT NULL,
    fecha_reporte DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE log_ajustes_stock (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    stock_anterior INT NOT NULL,
    stock_nuevo INT NOT NULL,
    motivo VARCHAR(255),
    fecha_ajuste DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE reporte_ventas_semanales (
    id_reporte INT AUTO_INCREMENT PRIMARY KEY,
    semana VARCHAR(20) NOT NULL,
    total_ventas DECIMAL(12,2) NOT NULL,
    fecha_generacion DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- DATOS DE EJEMPLO
-- ============================================================

INSERT INTO categorias (nombre, descripcion) VALUES
('General', 'Categoria por defecto para productos sin clasificar'),
('Electronica', 'Dispositivos y accesorios electronicos'),
('Ropa', 'Prendas de vestir'),
('Hogar', 'Articulos para el hogar'),
('Deportes', 'Articulos deportivos');

INSERT INTO proveedores (nombre, email_contacto, telefono_contacto) VALUES
('Tecno Import SAS', 'contacto@tecnoimport.com', '3001234567'),
('Moda Total SAS', 'ventas@modatotal.com', '3009876543'),
('Hogar Facil SAS', 'contacto@hogarfacil.com', '3007894561'),
('Deportes Pro SAS', 'info@deportespro.com', '3002223344');

INSERT INTO productos (nombre, descripcion, precio, costo, stock, stock_minimo, sku, id_categoria, id_proveedor) VALUES
('Audifonos Bluetooth', 'Audifonos inalambricos con estuche de carga', 89900, 45000, 40, 10, 'SKU-0001', 2, 1),
('Teclado Mecanico', 'Teclado mecanico retroiluminado', 159900, 90000, 25, 5, 'SKU-0002', 2, 1),
('Camiseta Basica', 'Camiseta de algodon 100%', 39900, 15000, 100, 20, 'SKU-0003', 3, 2),
('Pantalon Jean', 'Pantalon jean corte recto', 99900, 45000, 60, 15, 'SKU-0004', 3, 2),
('Juego de Sabanas', 'Juego de sabanas 2 plazas', 129900, 60000, 30, 8, 'SKU-0005', 4, 3),
('Lampara de Mesa', 'Lampara led para escritorio', 69900, 30000, 4, 10, 'SKU-0006', 4, 3),
('Balon de Futbol', 'Balon de futbol talla 5', 79900, 35000, 3, 10, 'SKU-0007', 5, 4),
('Mancuernas 5kg', 'Par de mancuernas de 5kg', 119900, 55000, 50, 10, 'SKU-0008', 5, 4);

INSERT INTO clientes (nombre, apellido, email, contrasena, direccion_envio, ciudad) VALUES
('Juan', 'Perez', 'juan.perez@correo.com', 'hash123', 'Calle 10 # 5-20', 'Bogota'),
('Maria', 'Gomez', 'maria.gomez@correo.com', 'hash123', 'Carrera 20 # 15-30', 'Medellin'),
('Carlos', 'Rodriguez', 'carlos.rodriguez@correo.com', 'hash123', 'Avenida 5 # 8-40', 'Bogota'),
('Ana', 'Martinez', 'ana.martinez@correo.com', 'hash123', 'Calle 50 # 12-10', 'Cali'),
('Luis', 'Fernandez', 'luis.fernandez@correo.com', 'hash123', 'Carrera 8 # 20-15', 'Bogota');

INSERT INTO ventas (id_cliente, fecha_venta, estado, total) VALUES
(1, '2026-06-01 10:00:00', 'Entregado', 129800),
(1, '2026-07-15 14:30:00', 'Entregado', 159900),
(2, '2026-06-10 09:15:00', 'Entregado', 99900),
(3, '2026-08-01 16:45:00', 'Procesando', 229700),
(4, '2026-07-20 11:00:00', 'Entregado', 79900),
(5, '2026-08-10 13:20:00', 'Enviado', 249800);

INSERT INTO detalle_ventas (id_venta, id_producto, cantidad, precio_unitario_congelado) VALUES
(1, 1, 1, 89900),
(1, 3, 1, 39900),
(2, 2, 1, 159900),
(3, 4, 1, 99900),
(4, 1, 1, 89900),
(4, 3, 1, 39900),
(4, 4, 1, 99900),
(5, 7, 1, 79900),
(6, 5, 1, 129900),
(6, 8, 1, 119900);
