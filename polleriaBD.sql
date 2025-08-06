CREATE DATABASE LosPostes2;

CREATE EXTENSION IF NOT EXISTS pgcrypto;
-- tablas

-- Tabla: Categorias
CREATE TABLE Categorias (
    CategoriaID int GENERATED ALWAYS AS IDENTITY,
    Nombre varchar(50)  NOT NULL,
    Descripcion text  NULL,
    Estado boolean  NOT NULL,
    CONSTRAINT Categorias_pk PRIMARY KEY (CategoriaID)
);

-- Tabla: DetallePagos
CREATE TABLE DetallePagos (
    DetallePagoID int GENERATED ALWAYS AS IDENTITY,
    Cliente_TipoDocumento varchar(3) NULL,
	Cliente_NumeroDocumento varchar(11) NULL,
	Izipay_Comprobante varchar(20) NULL,
	Subtotal decimal(10,2)  NOT NULL,
    IGV decimal(10,2)  NOT NULL,
    Total decimal(10,2)  NOT NULL,
    Pagos_PagoID int  NOT NULL,
    CONSTRAINT DetallePagos_pk PRIMARY KEY (DetallePagoID)
);

-- Tabla: DetalleOrdenes
CREATE TABLE DetalleOrdenes (
    DetalleOrdenID int GENERATED ALWAYS AS IDENTITY,
    Cantidad int  NOT NULL,
    SubTotal decimal(10,2)  NOT NULL,
	Comentario text NULL,
	Condicion varchar(20)  NOT NULL,
    Productos_ProductoID int  NOT NULL,
    Ordenes_OrdenID int  NOT NULL,
    CONSTRAINT DetalleOrdenes_pk PRIMARY KEY (DetalleOrdenID)
);

-- Tabla: Empleados
CREATE TABLE Empleados (
    EmpleadoID int GENERATED ALWAYS AS IDENTITY,
    DNI varchar(8)  NOT NULL,
    Nombre varchar(50)  NOT NULL,
    Apellido varchar(50)  NOT NULL,
	Cargo varchar(20) NOT NULL,
    Estado boolean  NOT NULL,
    CONSTRAINT Empleados_pk PRIMARY KEY (EmpleadoID)
);

-- Tabla: Mesas
CREATE TABLE Mesas (
    MesaID int GENERATED ALWAYS AS IDENTITY,
    Numero int  NOT NULL,
    Capacidad int  NOT NULL,
    Condicion varchar(20) NOT NULL,
	Estado boolean NOT NULL,
    CONSTRAINT Mesas_pk PRIMARY KEY (MesaID)
);

-- Tabla: Ordenes
CREATE TABLE Ordenes (
    OrdenID int GENERATED ALWAYS AS IDENTITY,
    FechaOrden timestamp  NOT NULL,
    Condicion varchar(20)  NOT NULL,
	MontoTotal decimal(10,2)  NOT NULL,
    Empleados_EmpleadoID int  NOT NULL,
    Mesas_MesaID int  NOT NULL,
    CONSTRAINT Ordenes_pk PRIMARY KEY (OrdenID)
);

-- Tabla: Pagos
CREATE TABLE Pagos (
    PagoID int GENERATED ALWAYS AS IDENTITY,
    FechaPago timestamp  NOT NULL,
	MetodoPago varchar(20) NOT NULL,
    EstadoPago varchar(20)  NULL,
    Ordenes_OrdenID int  NOT NULL,	
	TipoComprobantes_TipoComprobanteID int NOT NULL,
    CONSTRAINT Pagos_pk PRIMARY KEY (PagoID)
);

-- Tabla: Productos
CREATE TABLE Productos (
    ProductoID int GENERATED ALWAYS AS IDENTITY,
    Nombre varchar(100)  NOT NULL,
    Descripcion text  NULL,
    Precio decimal(10,2)  NOT NULL,
    Estado boolean  NOT NULL,
    SubCategorias_SubCategoriaID int  NOT NULL,
    CONSTRAINT Productos_pk PRIMARY KEY (ProductoID)
);

-- Tabla: SubCategorias
CREATE TABLE SubCategorias (
    SubCategoriaID int GENERATED ALWAYS AS IDENTITY,
    Nombre varchar(50)  NOT NULL,
    Descripcion text  NULL,
    Estado boolean  NOT NULL,
    Categorias_CategoriaID int  NOT NULL,
    CONSTRAINT SubCategorias_pk PRIMARY KEY (SubCategoriaID)
);

-- Tabla: TipoComprobantes
CREATE TABLE TipoComprobantes (
    TipoComprobanteID int GENERATED ALWAYS AS IDENTITY,
    Nombre varchar(20)  NOT NULL,
    RequiereIdentificacion boolean  NOT NULL,
	Estado boolean NOT NULL,
    CONSTRAINT TipoComprobantes_pk PRIMARY KEY (TipoComprobanteID)
);

-- Tabla: Usuarios
CREATE TABLE Usuarios (
    UsuarioID int GENERATED ALWAYS AS IDENTITY,
    Username varchar(20)  NOT NULL,
    Password varchar(255)  NOT NULL,
    Estado boolean  NOT NULL,
    Rol varchar(15)  NOT NULL,
	Empleados_EmpleadoID int NOT NULL,
    CONSTRAINT Usuarios_pk PRIMARY KEY (UsuarioID)
);

--triggers
-- Crear una función para convertir a hash automáticamente las contraseñas antes de insertar/actualizar
CREATE OR REPLACE FUNCTION hash_password()
RETURNS TRIGGER AS $$
BEGIN
    -- Usar bcrypt para el hash de contraseñas
    NEW.Password = crypt(NEW.Password, gen_salt('bf'));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear un trigger para invocar la función hash de contraseña
CREATE TRIGGER hash_password_trigger
BEFORE INSERT OR UPDATE ON Usuarios
FOR EACH ROW
EXECUTE FUNCTION hash_password();

-- foreign keys
-- Reference: DetallePagos_Pagos (table: DetallePagos)
ALTER TABLE DetallePagos ADD CONSTRAINT DetallePagos_Pagos
    FOREIGN KEY (Pagos_PagoID)
    REFERENCES Pagos (PagoID)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: DetallesOrden_Ordenes (table: DetallesOrden)
ALTER TABLE DetalleOrdenes ADD CONSTRAINT DetalleOrdenes_Ordenes
    FOREIGN KEY (Ordenes_OrdenID)
    REFERENCES Ordenes (OrdenID)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: DetallesOrden_Productos (table: DetallesOrden)
ALTER TABLE DetalleOrdenes ADD CONSTRAINT DetalleOrdenes_Productos
    FOREIGN KEY (Productos_ProductoID)
    REFERENCES Productos (ProductoID)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: Usuarios_Empleados (table: Usuarios)
ALTER TABLE Usuarios ADD CONSTRAINT Usuarios_Empleados
    FOREIGN KEY (Empleados_EmpleadoID)
    REFERENCES Empleados (EmpleadoID)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: Ordenes_Empleados (table: Ordenes)
ALTER TABLE Ordenes ADD CONSTRAINT Ordenes_Empleados
    FOREIGN KEY (Empleados_EmpleadoID)
    REFERENCES Empleados (EmpleadoID)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: Ordenes_Mesas (table: Ordenes)
ALTER TABLE Ordenes ADD CONSTRAINT Ordenes_Mesas
    FOREIGN KEY (Mesas_MesaID)
    REFERENCES Mesas (MesaID)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: Pagos_Ordenes (table: Pagos)
ALTER TABLE Pagos ADD CONSTRAINT Pagos_Ordenes
    FOREIGN KEY (Ordenes_OrdenID)
    REFERENCES Ordenes (OrdenID)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: Productos_SubCategorias (table: Productos)
ALTER TABLE Productos ADD CONSTRAINT Productos_SubCategorias
    FOREIGN KEY (SubCategorias_SubCategoriaID)
    REFERENCES SubCategorias (SubCategoriaID)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: SubCategorias_Categorias (table: SubCategorias)
ALTER TABLE SubCategorias ADD CONSTRAINT SubCategorias_Categorias
    FOREIGN KEY (Categorias_CategoriaID)
    REFERENCES Categorias (CategoriaID)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: Pagos_TipoComprobantes (table: Pagos)
ALTER TABLE Pagos ADD CONSTRAINT Pagos_TipoComprobantes
    FOREIGN KEY (TipoComprobantes_TipoComprobanteID)
    REFERENCES TipoComprobantes (TipoComprobanteID)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

Insert into Empleados (DNI, Nombre, Apellido, Cargo, Estado) 
values ('73429482', 'John Albert', 'Roncal Castillo', 'Administrador', True);

Insert into Usuarios (username, Password, Estado, rol, empleados_empleadoid) 
values ('admin', '1234', True, 'ROLE_ADMIN', 1);

-- End of file.