-- ============================================================
-- BASE DE DATOS: Stock&FreshWeb (V1)
-- ============================================================
CREATE DATABASE IF NOT EXISTS stock_fresh_web;
USE stock_fresh_web;

-- ------------------------------------------------------------
-- 1. CATÁLOGOS Y ENTIDADES BASE
-- ------------------------------------------------------------

CREATE TABLE LOCATARIO (
   idLocatario             VARCHAR(50)     NOT NULL,
   nombre                  VARCHAR(100)    NOT NULL,
   correoElectronico       VARCHAR(100)    NOT NULL UNIQUE,
   contrasena              VARCHAR(255)    NOT NULL,
   numeroCelular           VARCHAR(15)     NULL,
   CONSTRAINT pk_id_locatario PRIMARY KEY (idLocatario)
);

CREATE TABLE LOCAL (
   idLocal                 INT             AUTO_INCREMENT NOT NULL,
   idLocatario             VARCHAR(50)     NOT NULL UNIQUE,
   nombre                  VARCHAR(100)    NOT NULL,
   correoElectronico       VARCHAR(100)    NULL,
   numeroTelefono          VARCHAR(15)     NULL,
   CONSTRAINT pk_id_local PRIMARY KEY (idLocal),
   CONSTRAINT fk_local_locatario 
      FOREIGN KEY (idLocatario) REFERENCES LOCATARIO(idLocatario)
      ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE CATEGORIA (
   idCategoria             INT             AUTO_INCREMENT NOT NULL,
   nombre                  VARCHAR(100)    NOT NULL,
   descripcion             VARCHAR(255)    NULL,
   CONSTRAINT pk_id_categoria PRIMARY KEY (idCategoria)
);

CREATE TABLE TIPO_PAGO (
   idTipoPago              INT             AUTO_INCREMENT NOT NULL,
   nombre                  VARCHAR(50)     NOT NULL UNIQUE,
   descripcion             VARCHAR(100)    NULL,
   CONSTRAINT pk_id_tipo_pago PRIMARY KEY (idTipoPago)
);

CREATE TABLE TURNO (
   idTurno                 INT             AUTO_INCREMENT NOT NULL,
   nombre                  VARCHAR(100)    NOT NULL,
   descripcion             VARCHAR(100)    NULL,
   CONSTRAINT pk_id_turno PRIMARY KEY (idTurno)
);

CREATE TABLE CLIENTE (
   idCliente               VARCHAR(36)     NOT NULL, -- UUID para sincronización móvil-web
   nombre                  VARCHAR(100)    NOT NULL,
   correoElectronico       VARCHAR(100)    NOT NULL UNIQUE,
   telefono                VARCHAR(15)     NULL,
   fechaRegistro           DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
   CONSTRAINT pk_id_cliente PRIMARY KEY (idCliente)
);

-- ------------------------------------------------------------
-- 2. RELACIONES Y PROVEEDORES
-- ------------------------------------------------------------

CREATE TABLE LOCAL_CLIENTE (
   idLocalCliente          INT             AUTO_INCREMENT NOT NULL,
   idLocal                 INT             NOT NULL,
   idCliente               VARCHAR(36)     NOT NULL,
   fechaVinculacion        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
   statusMembresia         VARCHAR(50)     NOT NULL DEFAULT 'Activa',
   CONSTRAINT pk_id_local_cliente PRIMARY KEY (idLocalCliente),
   CONSTRAINT fk_lc_local FOREIGN KEY (idLocal) REFERENCES LOCAL(idLocal) ON UPDATE CASCADE ON DELETE RESTRICT,
   CONSTRAINT fk_lc_cliente FOREIGN KEY (idCliente) REFERENCES CLIENTE(idCliente) ON UPDATE CASCADE ON DELETE CASCADE,
   CONSTRAINT uc_local_cliente UNIQUE (idLocal, idCliente)
);

CREATE TABLE PROVEEDOR (
   idProveedor             INT             AUTO_INCREMENT NOT NULL,
   nombre                  VARCHAR(100)    NOT NULL,
   CONSTRAINT pk_id_proveedor PRIMARY KEY (idProveedor)
);

CREATE TABLE PROVEEDOR_PARTICULAR (
   idDNS                   INT             AUTO_INCREMENT NOT NULL,
   idLocal                 INT             NOT NULL,
   idProveedor             INT             NOT NULL,
   CONSTRAINT pk_id_dns PRIMARY KEY (idDNS),
   CONSTRAINT fk_id_local FOREIGN KEY (idLocal) REFERENCES LOCAL(idLocal) ON UPDATE CASCADE ON DELETE RESTRICT,
   CONSTRAINT fk_id_proveedor FOREIGN KEY (idProveedor) REFERENCES PROVEEDOR(idProveedor) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ------------------------------------------------------------
-- 3. INVENTARIO Y OPERACIÓN DE CAJA
-- ------------------------------------------------------------

CREATE TABLE PRODUCTO (
   idProducto              INT             AUTO_INCREMENT NOT NULL,
   idLocal                 INT             NOT NULL,
   idCategoria             INT             NOT NULL,
   nombre                  VARCHAR(100)    NOT NULL,
   precio                  DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
   stock                   DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
   CONSTRAINT pk_id_producto PRIMARY KEY (idProducto),
   CONSTRAINT fk_producto_local FOREIGN KEY (idLocal) REFERENCES LOCAL(idLocal) ON UPDATE CASCADE ON DELETE RESTRICT,
   CONSTRAINT fk_producto_categoria FOREIGN KEY (idCategoria) REFERENCES CATEGORIA (idCategoria) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE MOVIMIENTO (
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

CREATE TABLE CAJA_COBRO (
   idCajaCobro             INT             AUTO_INCREMENT NOT NULL,
   idLocal                 INT             NOT NULL,
   status                  VARCHAR(50)     NOT NULL DEFAULT 'Inactiva',
   CONSTRAINT pk_id_cajacobro PRIMARY KEY (idCajaCobro),
   CONSTRAINT fk_cajacobro_local FOREIGN KEY (idLocal) REFERENCES LOCAL(idLocal) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE OPERACION (
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
   CONSTRAINT fk_fichaje_turno FOREIGN KEY (idTurno) REFERENCES TURNO (idTurno) ON UPDATE CASCADE ON DELETE RESTRICT,
   CONSTRAINT fk_fichaje_caja FOREIGN KEY (idCaja) REFERENCES CAJA_COBRO (idCajaCobro) ON UPDATE CASCADE ON DELETE RESTRICT,
   CONSTRAINT fk_fichaje_local FOREIGN KEY (idLocal) REFERENCES LOCAL (idLocal) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ------------------------------------------------------------
-- 4. VENTAS, DETALLES Y NOTIFICACIONES
-- ------------------------------------------------------------

CREATE TABLE VENTA (
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

-- ------------------------------------------------------------
-- 5. DETALLE DE VENTA Y NOTIFICACIONES
-- ------------------------------------------------------------

CREATE TABLE DETALLE_VENTA (
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

CREATE TABLE NOTIFICACION (
   idNotificacion          INT             AUTO_INCREMENT NOT NULL,
   idLocal                 INT             NOT NULL,
   mensaje                 TEXT            NOT NULL,
   fechaHora               DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
   leida                   BOOLEAN         NOT NULL DEFAULT FALSE,
   CONSTRAINT pk_id_notificacion PRIMARY KEY (idNotificacion),
   CONSTRAINT fk_notificacion_local FOREIGN KEY (idLocal) REFERENCES LOCAL(idLocal) ON UPDATE CASCADE ON DELETE CASCADE
);
INSERT INTO LOCATARIO (idLocatario, nombre, correoElectronico, contrasena) 
VALUES ('pepe','Juan Pérez', 'admin@stockfresh.com', '123456');
SELECT * FROM LOCATARIO;

DESCRIBE LOCATARIO;
