-- Base de datos: Comercio Electrónico
-- Archivo 04: Seguridad (Roles y Usuarios)

USE comercio_electronico;

-- 1. Rol Administrador_Sistema: todos los privilegios sobre la base de datos
CREATE ROLE 'Administrador_Sistema';
GRANT ALL PRIVILEGES ON comercio_electronico.* TO 'Administrador_Sistema';

-- 2. Rol Gerente_Marketing: solo lectura sobre ventas y clientes
CREATE ROLE 'Gerente_Marketing';
GRANT SELECT ON comercio_electronico.ventas TO 'Gerente_Marketing';
GRANT SELECT ON comercio_electronico.clientes TO 'Gerente_Marketing';

-- 3. Rol Analista_Datos: solo lectura sobre todas las tablas de negocio
CREATE ROLE 'Analista_Datos';
GRANT SELECT ON comercio_electronico.productos TO 'Analista_Datos';
GRANT SELECT ON comercio_electronico.categorias TO 'Analista_Datos';
GRANT SELECT ON comercio_electronico.proveedores TO 'Analista_Datos';
GRANT SELECT ON comercio_electronico.clientes TO 'Analista_Datos';
GRANT SELECT ON comercio_electronico.ventas TO 'Analista_Datos';
GRANT SELECT ON comercio_electronico.detalle_ventas TO 'Analista_Datos';

-- 4. Rol Empleado_Inventario: solo puede modificar stock y ubicacion de productos
CREATE ROLE 'Empleado_Inventario';
GRANT SELECT ON comercio_electronico.productos TO 'Empleado_Inventario';
GRANT UPDATE (stock, ubicacion) ON comercio_electronico.productos TO 'Empleado_Inventario';

-- 5. Rol Atencion_Cliente: puede ver clientes y ventas, sin modificar precios
CREATE ROLE 'Atencion_Cliente';
GRANT SELECT ON comercio_electronico.clientes TO 'Atencion_Cliente';
GRANT SELECT ON comercio_electronico.ventas TO 'Atencion_Cliente';

-- 6. Rol Auditor_Financiero: solo lectura sobre ventas, productos y precios
CREATE ROLE 'Auditor_Financiero';
GRANT SELECT ON comercio_electronico.ventas TO 'Auditor_Financiero';
GRANT SELECT ON comercio_electronico.productos TO 'Auditor_Financiero';
GRANT SELECT ON comercio_electronico.log_cambios_precio TO 'Auditor_Financiero';

-- 7. Usuario admin_user con el rol de administrador
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'Admin#2026Seguro';
GRANT 'Administrador_Sistema' TO 'admin_user'@'localhost';

-- 8. Usuario marketing_user con el rol de marketing
CREATE USER 'marketing_user'@'localhost' IDENTIFIED BY 'Marketing#2026Seguro';
GRANT 'Gerente_Marketing' TO 'marketing_user'@'localhost';

-- 9. Usuario inventario_user con el rol de inventario
CREATE USER 'inventario_user'@'localhost' IDENTIFIED BY 'Inventario#2026Seguro';
GRANT 'Empleado_Inventario' TO 'inventario_user'@'localhost';

-- 10. Usuario support_user con el rol de atencion al cliente
CREATE USER 'support_user'@'localhost' IDENTIFIED BY 'Support#2026Seguro';
GRANT 'Atencion_Cliente' TO 'support_user'@'localhost';

FLUSH PRIVILEGES;
