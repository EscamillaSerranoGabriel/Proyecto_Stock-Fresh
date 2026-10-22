-- ============================================================
-- BASE DE DATOS Stock&FreshWeb
-- ============================================================
CREATE DATABASE IF NOT EXISTS stock_fresh_web;
USE stock_fresh_web;

-- ------------------------------------------------------------
-- 1. CATÁLOGOS Y ENTIDADES BASE
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS LOCATARIO (
   idLocatario             VARCHAR(50)     NOT NULL,
   nombre                  VARCHAR(100)    NOT NULL,
   correoElectronico       VARCHAR(100)    NOT NULL UNIQUE,
   contrasena              VARCHAR(255)    NOT NULL,
   numeroCelular           VARCHAR(15)     NULL,
   rol                     ENUM('Locatario', 'Administrador') NOT NULL DEFAULT 'Locatario',
   CONSTRAINT pk_id_locatario PRIMARY KEY (idLocatario)
);

CREATE TABLE IF NOT EXISTS LOCAL (
   idLocal                 INT             AUTO_INCREMENT NOT NULL,
   idLocatario             VARCHAR(50)     NOT NULL UNIQUE,
   nombre                  VARCHAR(100)    NOT NULL,
   correoElectronico       VARCHAR(100)    NULL,
   numeroTelefono          VARCHAR(15)     NULL,
   CONSTRAINT pk_id_local PRIMARY KEY (idLocal),
   CONSTRAINT fk_local_locatario FOREIGN KEY (idLocatario) REFERENCES LOCATARIO(idLocatario) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS CATEGORIA (
   idCategoria             INT             AUTO_INCREMENT NOT NULL,
   nombre                  VARCHAR(100)    NOT NULL,
   descripcion             VARCHAR(255)    NULL,
   CONSTRAINT pk_id_categoria PRIMARY KEY (idCategoria)
);

CREATE TABLE IF NOT EXISTS TIPO_PAGO (
   idTipoPago              INT             AUTO_INCREMENT NOT NULL,
   nombre                  VARCHAR(50)     NOT NULL UNIQUE,
   descripcion             VARCHAR(100)    NULL,
   CONSTRAINT pk_id_tipo_pago PRIMARY KEY (idTipoPago)
);

CREATE TABLE IF NOT EXISTS TURNO (
   idTurno                 INT             AUTO_INCREMENT NOT NULL,
   nombre                  VARCHAR(100)    NOT NULL,
   descripcion             VARCHAR(100)    NULL,
   CONSTRAINT pk_id_turno PRIMARY KEY (idTurno)
);

CREATE TABLE IF NOT EXISTS CLIENTE (
   idCliente               INT             AUTO_INCREMENT NOT NULL,
   idLocatario             VARCHAR(50)     NOT NULL,
   nombre                  VARCHAR(100)    NOT NULL,
   correoElectronico       VARCHAR(100)    NOT NULL UNIQUE,
   contrasena              VARCHAR(255)    NOT NULL,
   numeroCelular           VARCHAR(15)     NULL,
   CONSTRAINT pk_idcliente PRIMARY KEY (idCliente),
   CONSTRAINT fk_cliente_locatario FOREIGN KEY (idLocatario) REFERENCES LOCATARIO(idLocatario) ON UPDATE CASCADE ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 2. RELACIONES Y PROVEEDORES
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS LOCAL_CLIENTE (
   idLocalCliente          INT             AUTO_INCREMENT NOT NULL,
   idLocal                 INT             NOT NULL,
   idCliente               INT             NOT NULL,
   fechaVinculacion        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
   statusMembresia         VARCHAR(50)     NOT NULL DEFAULT 'Activa',
   CONSTRAINT pk_id_local_cliente PRIMARY KEY (idLocalCliente),
   CONSTRAINT fk_lc_local FOREIGN KEY (idLocal) REFERENCES LOCAL(idLocal) ON UPDATE CASCADE ON DELETE RESTRICT,
   CONSTRAINT fk_lc_cliente FOREIGN KEY (idCliente) REFERENCES CLIENTE(idCliente) ON UPDATE CASCADE ON DELETE CASCADE,
   CONSTRAINT uc_local_cliente UNIQUE (idLocal, idCliente)
);

CREATE TABLE IF NOT EXISTS PROVEEDOR (
   idProveedor             INT             AUTO_INCREMENT NOT NULL,
   nombre                  VARCHAR(100)    NOT NULL,
   CONSTRAINT pk_id_proveedor PRIMARY KEY (idProveedor)
);

CREATE TABLE IF NOT EXISTS PROVEEDOR_PARTICULAR (
   idDNS                   INT             AUTO_INCREMENT NOT NULL,
   idLocal                 INT             NOT NULL,
   idProveedor             INT             NOT NULL,
   CONSTRAINT pk_id_dns PRIMARY KEY (idDNS),
   CONSTRAINT fk_pp_local FOREIGN KEY (idLocal) REFERENCES LOCAL(idLocal) ON UPDATE CASCADE ON DELETE RESTRICT,
   CONSTRAINT fk_pp_proveedor FOREIGN KEY (idProveedor) REFERENCES PROVEEDOR(idProveedor) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ------------------------------------------------------------
-- 3. INVENTARIO Y OPERACIÓN DE CAJA
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS PRODUCTO (
   idProducto              INT             AUTO_INCREMENT NOT NULL,
   idLocal                 INT             NOT NULL,
   idCategoria             INT             NOT NULL,
   nombre                  VARCHAR(100)    NOT NULL,
   precio                  DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
   stock                   DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
   CONSTRAINT pk_id_producto PRIMARY KEY (idProducto),
   CONSTRAINT fk_producto_local FOREIGN KEY (idLocal) REFERENCES LOCAL(idLocal) ON UPDATE CASCADE ON DELETE RESTRICT,
   CONSTRAINT fk_producto_categoria FOREIGN KEY (idCategoria) REFERENCES CATEGORIA(idCategoria) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS MOVIMIENTO (
   idMovimiento            INT             AUTO_INCREMENT NOT NULL,
   idLocal                 INT             NOT NULL,
   idProducto              INT             NOT NULL,
   fecha                   DATE            NOT NULL DEFAULT (CURRENT_DATE),
   cantidad                DECIMAL(10,2)   NOT NULL,
   tipo                    ENUM('Reabastecimiento', 'Limpieza', 'Cambio') NOT NULL,
   CONSTRAINT pk_id_movimiento PRIMARY KEY (idMovimiento),
   CONSTRAINT fk_movimiento_local FOREIGN KEY (idLocal) REFERENCES LOCAL(idLocal) ON UPDATE CASCADE ON DELETE RESTRICT,
   CONSTRAINT fk_movimiento_producto FOREIGN KEY (idProducto) REFERENCES PRODUCTO(idProducto) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS CAJA_COBRO (
   idCajaCobro             INT             AUTO_INCREMENT NOT NULL,
   idLocal                 INT             NOT NULL,
   status                  VARCHAR(50)     NOT NULL DEFAULT 'Inactiva',
   CONSTRAINT pk_id_cajacobro PRIMARY KEY (idCajaCobro),
   CONSTRAINT fk_cajacobro_local FOREIGN KEY (idLocal) REFERENCES LOCAL(idLocal) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS OPERACION (
   idFichaje               INT             AUTO_INCREMENT NOT NULL,
   idTurno                 INT             NOT NULL,
   idCaja                  INT             NOT NULL,
   idLocal                 INT             NOT NULL,
   fecha                   DATE            NOT NULL DEFAULT (CURRENT_DATE),
   horaApertura            TIME            NOT NULL DEFAULT (CURRENT_TIME),
   horaCierre              TIME            NULL,
   fondoInicial            DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
   fondoFinal              DECIMAL(10,2)   NULL,
   numTransaccion          INT             NOT NULL DEFAULT 0,
   efectivo                DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
   transferencia           DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
   CONSTRAINT pk_id_fichaje PRIMARY KEY (idFichaje),
   CONSTRAINT fk_fichaje_turno FOREIGN KEY (idTurno) REFERENCES TURNO(idTurno) ON UPDATE CASCADE ON DELETE RESTRICT,
   CONSTRAINT fk_fichaje_caja FOREIGN KEY (idCaja) REFERENCES CAJA_COBRO(idCajaCobro) ON UPDATE CASCADE ON DELETE RESTRICT,
   CONSTRAINT fk_fichaje_local FOREIGN KEY (idLocal) REFERENCES LOCAL(idLocal) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ------------------------------------------------------------
-- 4. VENTAS, DETALLES Y NOTIFICACIONES
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS VENTA (
   idVenta                 INT             AUTO_INCREMENT NOT NULL,
   idFichaje               INT             NOT NULL,
   idCajaCobro             INT             NOT NULL,
   idLocalCliente          INT             NULL,
   idTipoPago              INT             NOT NULL,
   fecha                   DATE            NOT NULL DEFAULT (CURRENT_DATE),
   hora                    TIME            NOT NULL DEFAULT (CURRENT_TIME),
   montoTotal              DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
   CONSTRAINT pk_id_venta PRIMARY KEY (idVenta),
   CONSTRAINT fk_venta_cajacobro FOREIGN KEY (idCajaCobro) REFERENCES CAJA_COBRO(idCajaCobro) ON UPDATE CASCADE ON DELETE RESTRICT,
   CONSTRAINT fk_venta_fichaje FOREIGN KEY (idFichaje) REFERENCES OPERACION(idFichaje) ON UPDATE CASCADE ON DELETE RESTRICT,
   CONSTRAINT fk_venta_local_cliente FOREIGN KEY (idLocalCliente) REFERENCES LOCAL_CLIENTE(idLocalCliente) ON UPDATE CASCADE ON DELETE SET NULL,
   CONSTRAINT fk_venta_tipo_pago FOREIGN KEY (idTipoPago) REFERENCES TIPO_PAGO(idTipoPago) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS DETALLE_VENTA (
   idDetalleVenta          INT             AUTO_INCREMENT NOT NULL,
   idVenta                 INT             NOT NULL,
   idProducto              INT             NOT NULL,
   cantidad                DECIMAL(10,2)   NOT NULL,
   precioUnitario          DECIMAL(10,2)   NOT NULL,
   subtotal                DECIMAL(10,2)   NOT NULL,
   CONSTRAINT pk_id_detalle_venta PRIMARY KEY (idDetalleVenta),
   CONSTRAINT fk_detalle_venta FOREIGN KEY (idVenta) REFERENCES VENTA(idVenta) ON UPDATE CASCADE ON DELETE CASCADE,
   CONSTRAINT fk_detalle_producto FOREIGN KEY (idProducto) REFERENCES PRODUCTO(idProducto) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS NOTIFICACION (
   idNotificacion          INT             AUTO_INCREMENT NOT NULL,
   idLocal                 INT             NOT NULL,
   mensaje                 TEXT            NOT NULL,
   fechaHora               DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
   leida                   BOOLEAN         NOT NULL DEFAULT FALSE,
   CONSTRAINT pk_id_notificacion PRIMARY KEY (idNotificacion),
   CONSTRAINT fk_notificacion_local FOREIGN KEY (idLocal) REFERENCES LOCAL(idLocal) ON UPDATE CASCADE ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 5. MÓDULO CLIENTE: BODEGA, PRODUCTOS Y ALMACÉN
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS BODEGA (
   idBodega                INT             AUTO_INCREMENT NOT NULL,
   idCliente               INT             NOT NULL,
   nombre                  VARCHAR(100)    NOT NULL,
   CONSTRAINT pk_idbodega PRIMARY KEY (idBodega),
   CONSTRAINT fk_bodega_cliente FOREIGN KEY (idCliente) REFERENCES CLIENTE(idCliente) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS CATEGORIA_CLIENTE (
   idCategoria             INT             AUTO_INCREMENT NOT NULL,
   nombre                  VARCHAR(100)    NOT NULL,
   descripcion             VARCHAR(255)    NULL,
   CONSTRAINT pk_idctag_cliente PRIMARY KEY (idCategoria)
);

CREATE TABLE IF NOT EXISTS UNIDAD_MEDIDA (
   idUnidad                INT             AUTO_INCREMENT NOT NULL,
   codigo                  VARCHAR(10)     NOT NULL UNIQUE,
   descripcion             VARCHAR(50)     NOT NULL,
   CONSTRAINT pk_idunidad PRIMARY KEY (idUnidad)
);

CREATE TABLE IF NOT EXISTS PRODUCTO_CLIENTE (
   idProducto              INT             AUTO_INCREMENT NOT NULL,
   idCategoria             INT             NOT NULL,
   idUnidad                INT             NOT NULL,
   nombre                  VARCHAR(100)    NOT NULL,
   CONSTRAINT pk_idproducto_cliente PRIMARY KEY (idProducto),
   CONSTRAINT fk_prodcliente_categoria FOREIGN KEY (idCategoria) REFERENCES CATEGORIA_CLIENTE(idCategoria),
   CONSTRAINT fk_prodcliente_unidad FOREIGN KEY (idUnidad) REFERENCES UNIDAD_MEDIDA(idUnidad)
);

CREATE TABLE IF NOT EXISTS ALMACEN (
   idAlmacen               INT             AUTO_INCREMENT NOT NULL,
   idBodega                INT             NOT NULL,
   idProducto              INT             NOT NULL,
   cantidad                DECIMAL(10,2)   NOT NULL,
   fechaAgregada           DATE            NULL,
   fechaCaducidad          DATE            NULL,
   status                  VARCHAR(50)     NULL,
   CONSTRAINT pk_idalmacen PRIMARY KEY (idAlmacen),
   CONSTRAINT fk_almacen_bodega FOREIGN KEY (idBodega) REFERENCES BODEGA(idBodega) ON UPDATE CASCADE ON DELETE CASCADE,
   CONSTRAINT fk_almacen_producto FOREIGN KEY (idProducto) REFERENCES PRODUCTO_CLIENTE(idProducto)
);

-- ------------------------------------------------------------
-- 6. MÓDULO CLIENTE: LISTAS
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS LISTA (
   idLista                 INT             AUTO_INCREMENT NOT NULL,
   tipo                    VARCHAR(50)     NOT NULL,
   CONSTRAINT pk_idlista PRIMARY KEY (idLista)
);

CREATE TABLE IF NOT EXISTS CLIENTE_LISTA (
   idRegistro              INT             AUTO_INCREMENT NOT NULL,
   idCliente               INT             NOT NULL,
   idLista                 INT             NOT NULL,
   CONSTRAINT pk_clientelista PRIMARY KEY (idRegistro),
   CONSTRAINT fk_clientelista_cliente FOREIGN KEY (idCliente) REFERENCES CLIENTE(idCliente) ON UPDATE CASCADE ON DELETE CASCADE,
   CONSTRAINT fk_clientelista_lista FOREIGN KEY (idLista) REFERENCES LISTA(idLista) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS LISTA_PRODUCTO (
   idRegistro              INT             AUTO_INCREMENT NOT NULL,
   idLista                 INT             NOT NULL,
   idProducto              INT             NOT NULL,
   cantidad                DECIMAL(10,2)   NOT NULL,
   CONSTRAINT pk_listaproducto PRIMARY KEY (idRegistro),
   CONSTRAINT fk_listaprod_lista FOREIGN KEY (idLista) REFERENCES LISTA(idLista) ON UPDATE CASCADE ON DELETE CASCADE,
   CONSTRAINT fk_listaprod_producto FOREIGN KEY (idProducto) REFERENCES PRODUCTO_CLIENTE(idProducto)
);

-- ------------------------------------------------------------
-- 7. MÓDULO CLIENTE: RECETAS, INGREDIENTES Y UTENSILIOS
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS RECETA (
   idReceta                INT             AUTO_INCREMENT NOT NULL,
   nombre                  VARCHAR(100)    NOT NULL,
   descripcion             VARCHAR(255)    NULL,
   CONSTRAINT pk_idreceta PRIMARY KEY (idReceta)
);

CREATE TABLE IF NOT EXISTS CLIENTE_RECETA (
   idRegistro              INT             AUTO_INCREMENT NOT NULL,
   idCliente               INT             NOT NULL,
   idReceta                INT             NOT NULL,
   CONSTRAINT pk_clientereceta PRIMARY KEY (idRegistro),
   CONSTRAINT fk_clientereceta_cliente FOREIGN KEY (idCliente) REFERENCES CLIENTE(idCliente) ON UPDATE CASCADE ON DELETE CASCADE,
   CONSTRAINT fk_clientereceta_receta FOREIGN KEY (idReceta) REFERENCES RECETA(idReceta) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS INGREDIENTE (
   idIngrediente           INT             AUTO_INCREMENT NOT NULL,
   nombre                  VARCHAR(100)    NOT NULL,
   CONSTRAINT pk_idingrediente PRIMARY KEY (idIngrediente)
);

CREATE TABLE IF NOT EXISTS RECETA_INGREDIENTE (
   idRegistro              INT             AUTO_INCREMENT NOT NULL,
   idReceta                INT             NOT NULL,
   idIngrediente           INT             NOT NULL,
   cantidad                DECIMAL(10,2)   NOT NULL,
   CONSTRAINT pk_recetaingrediente PRIMARY KEY (idRegistro),
   CONSTRAINT fk_recetaing_receta FOREIGN KEY (idReceta) REFERENCES RECETA(idReceta) ON UPDATE CASCADE ON DELETE CASCADE,
   CONSTRAINT fk_recetaing_ingrediente FOREIGN KEY (idIngrediente) REFERENCES INGREDIENTE(idIngrediente)
);

CREATE TABLE IF NOT EXISTS INGREDIENTE_UNIDAD (
   idRegistro              INT             AUTO_INCREMENT NOT NULL,
   idIngrediente           INT             NOT NULL,
   idUnidad                INT             NOT NULL,
   CONSTRAINT pk_ingredienteunidad PRIMARY KEY (idRegistro),
   CONSTRAINT fk_ingunidad_ingrediente FOREIGN KEY (idIngrediente) REFERENCES INGREDIENTE(idIngrediente) ON UPDATE CASCADE ON DELETE CASCADE,
   CONSTRAINT fk_ingunidad_unidad FOREIGN KEY (idUnidad) REFERENCES UNIDAD_MEDIDA(idUnidad)
);

CREATE TABLE IF NOT EXISTS INGREDIENTE_PRODUCTO (
   idRegistro              INT             AUTO_INCREMENT NOT NULL,
   idIngrediente           INT             NOT NULL,
   idProducto              INT             NOT NULL,
   CONSTRAINT pk_ingredienteproducto PRIMARY KEY (idRegistro),
   CONSTRAINT fk_ingprod_ingrediente FOREIGN KEY (idIngrediente) REFERENCES INGREDIENTE(idIngrediente),
   CONSTRAINT fk_ingprod_producto FOREIGN KEY (idProducto) REFERENCES PRODUCTO_CLIENTE(idProducto)
);

CREATE TABLE IF NOT EXISTS UTENSILIO (
   idUtensilio             INT             AUTO_INCREMENT NOT NULL,
   nombre                  VARCHAR(100)    NULL,
   CONSTRAINT pk_idutensilio PRIMARY KEY (idUtensilio)
);

CREATE TABLE IF NOT EXISTS RECETA_UTENSILIO (
   idRegistroUtensilio     INT             AUTO_INCREMENT NOT NULL,
   idReceta                INT             NOT NULL,
   idUtensilio             INT             NOT NULL,
   CONSTRAINT pk_recetautensilio PRIMARY KEY (idRegistroUtensilio),
   CONSTRAINT fk_recut_receta FOREIGN KEY (idReceta) REFERENCES RECETA(idReceta),
   CONSTRAINT fk_recut_utensilio FOREIGN KEY (idUtensilio) REFERENCES UTENSILIO(idUtensilio)
);

DROP ROLE IF EXISTS 'rol_admin', 'rol_locatario', 'rol_cliente';
 
CREATE ROLE 'rol_admin';
CREATE ROLE 'rol_locatario';
CREATE ROLE 'rol_cliente';
 
-- ------------------------------------------------------------
-- 1. PERMISOS PARA ADMIN
-- ------------------------------------------------------------
GRANT ALL PRIVILEGES ON stock_fresh_web.* TO 'rol_admin';
 
-- ------------------------------------------------------------
-- 2. PERMISOS PARA LOCATARIO
-- ------------------------------------------------------------
GRANT SELECT, INSERT, UPDATE         ON stock_fresh_web.PRODUCTO              TO 'rol_locatario';
GRANT SELECT, INSERT, UPDATE         ON stock_fresh_web.MOVIMIENTO            TO 'rol_locatario';
GRANT SELECT, INSERT, UPDATE         ON stock_fresh_web.CAJA_COBRO            TO 'rol_locatario';
GRANT SELECT, INSERT, UPDATE         ON stock_fresh_web.LOCAL_CLIENTE         TO 'rol_locatario';
GRANT SELECT, INSERT, UPDATE         ON stock_fresh_web.PROVEEDOR_PARTICULAR  TO 'rol_locatario';
GRANT SELECT, INSERT, UPDATE, DELETE ON stock_fresh_web.NOTIFICACION          TO 'rol_locatario';
GRANT SELECT                         ON stock_fresh_web.VENTA                 TO 'rol_locatario';
GRANT SELECT                         ON stock_fresh_web.DETALLE_VENTA         TO 'rol_locatario';
GRANT SELECT                         ON stock_fresh_web.OPERACION             TO 'rol_locatario';
GRANT SELECT                         ON stock_fresh_web.CATEGORIA             TO 'rol_locatario';
GRANT SELECT                         ON stock_fresh_web.PROVEEDOR             TO 'rol_locatario';
GRANT SELECT                         ON stock_fresh_web.TIPO_PAGO             TO 'rol_locatario';
GRANT SELECT                         ON stock_fresh_web.TURNO                 TO 'rol_locatario';
GRANT SELECT                         ON stock_fresh_web.LOCAL                 TO 'rol_locatario';
GRANT UPDATE (nombre, correoElectronico, numeroTelefono) ON stock_fresh_web.LOCAL TO 'rol_locatario';
GRANT SELECT (idCliente, idLocatario, nombre, correoElectronico, numeroCelular) ON stock_fresh_web.CLIENTE   TO 'rol_locatario';
GRANT INSERT, UPDATE ON stock_fresh_web.CLIENTE   TO 'rol_locatario';
GRANT SELECT (idLocatario, nombre, correoElectronico, numeroCelular) ON stock_fresh_web.LOCATARIO TO 'rol_locatario';
GRANT UPDATE (nombre, correoElectronico, numeroCelular, contrasena) ON stock_fresh_web.LOCATARIO TO 'rol_locatario';
 
-- ------------------------------------------------------------
-- 3. PERMISOS PARA CLIENTE
-- ------------------------------------------------------------
GRANT SELECT (idCliente, idLocatario, nombre, correoElectronico, numeroCelular) ON stock_fresh_web.CLIENTE TO 'rol_cliente';
GRANT UPDATE (nombre, numeroCelular) ON stock_fresh_web.CLIENTE TO 'rol_cliente';
GRANT SELECT ON stock_fresh_web.LOCAL_CLIENTE TO 'rol_cliente';
GRANT SELECT ON stock_fresh_web.LOCAL         TO 'rol_cliente';
 
GRANT SELECT, INSERT, UPDATE, DELETE ON stock_fresh_web.BODEGA               TO 'rol_cliente';
GRANT SELECT, INSERT, UPDATE, DELETE ON stock_fresh_web.ALMACEN              TO 'rol_cliente';
GRANT SELECT, INSERT, UPDATE         ON stock_fresh_web.PRODUCTO_CLIENTE     TO 'rol_cliente';
GRANT SELECT                         ON stock_fresh_web.CATEGORIA_CLIENTE    TO 'rol_cliente';
GRANT SELECT                         ON stock_fresh_web.UNIDAD_MEDIDA        TO 'rol_cliente';
 
GRANT SELECT, INSERT, UPDATE, DELETE ON stock_fresh_web.LISTA                TO 'rol_cliente';
GRANT SELECT, INSERT, DELETE         ON stock_fresh_web.CLIENTE_LISTA        TO 'rol_cliente';
GRANT SELECT, INSERT, UPDATE, DELETE ON stock_fresh_web.LISTA_PRODUCTO       TO 'rol_cliente';
 
GRANT SELECT, INSERT, UPDATE         ON stock_fresh_web.RECETA               TO 'rol_cliente';
GRANT SELECT, INSERT, DELETE         ON stock_fresh_web.CLIENTE_RECETA       TO 'rol_cliente';
GRANT SELECT, INSERT                 ON stock_fresh_web.INGREDIENTE          TO 'rol_cliente';
GRANT SELECT, INSERT, UPDATE, DELETE ON stock_fresh_web.RECETA_INGREDIENTE   TO 'rol_cliente';
GRANT SELECT                         ON stock_fresh_web.INGREDIENTE_UNIDAD   TO 'rol_cliente';
GRANT SELECT, INSERT, DELETE         ON stock_fresh_web.INGREDIENTE_PRODUCTO TO 'rol_cliente';
GRANT SELECT, INSERT                 ON stock_fresh_web.UTENSILIO            TO 'rol_cliente';
GRANT SELECT, INSERT, DELETE         ON stock_fresh_web.RECETA_UTENSILIO     TO 'rol_cliente';
 
-- ------------------------------------------------------------
-- 4. USUARIOS
-- ------------------------------------------------------------
CREATE USER IF NOT EXISTS 'admin1'@'localhost'      IDENTIFIED BY '123';
CREATE USER IF NOT EXISTS 'locatario1'@'localhost'  IDENTIFIED BY '321';
CREATE USER IF NOT EXISTS 'cliente1'@'localhost'    IDENTIFIED BY '213';
CREATE USER IF NOT EXISTS 'login'@'localhost'       IDENTIFIED BY '999';
 
-- Cuenta exclusiva para el login
GRANT SELECT (idLocatario, nombre, correoElectronico, contrasena, rol)
   ON stock_fresh_web.LOCATARIO TO 'login'@'localhost';
GRANT SELECT (idCliente, nombre, correoElectronico, contrasena)
   ON stock_fresh_web.CLIENTE   TO 'login'@'localhost';
GRANT SELECT (idLocal, idLocatario)
   ON stock_fresh_web.LOCAL     TO 'login'@'localhost';
 
-- ------------------------------------------------------------
-- 5. ASIGNACIÓN DE ROLES
-- ------------------------------------------------------------
GRANT 'rol_admin'     TO 'admin1'@'localhost';
GRANT 'rol_locatario' TO 'locatario1'@'localhost';
GRANT 'rol_cliente'   TO 'cliente1'@'localhost';
 
SET DEFAULT ROLE 'rol_admin'     TO 'admin1'@'localhost';
SET DEFAULT ROLE 'rol_locatario' TO 'locatario1'@'localhost';
SET DEFAULT ROLE 'rol_cliente'   TO 'cliente1'@'localhost';

SELECT CURRENT_ROLE();  
SELECT CURRENT_ROLE();  
SELECT * FROM LOCATARIO;