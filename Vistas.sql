--Para el esquema de Proveedores Simple
--Defina las siguientes vistas mediante sentencias SQL:
--a.1) ENVIOS500 con los envíos de 500 o más unidades (a partir de ENVIO)
CREATE VIEW ENVIOS500 AS
SELECT * FROM envio
WHERE cantidad >= 500;

--a.2) ENVIOS500-M con los envíos de entre 500 y 999 unidades (a partir de ENVIOS500) 
CREATE VIEW ENVIOS500-M AS
SELECT * FROM ENVIOS500
WHERE cantidad <= 999;

--a.3) RUBROS_PROV con los diferentes rubros que poseen los proveedores ubicados en Tandil
CREATE VIEW RUBROS_PROV AS
SELECT rubro FROM proveedores
WHERE ciudad = 'Tandil';

--a.4) ENVIOS_PROV con los diferentes id y nombre de proveedor y la cantidad total de unidades enviadas 
CREATE VIEW ENVIOS_PROV AS
SELECT p.id_proveedor, p.nombre, SUM(e.cantidad)  
FROM proveedores p JOIN envio e ON (e.id_proveedor = p.id_proveedor)
GROUP BY p.id_proveedor; 

--b) Determine si las vistas anteriores son automáticamente actualizables según el estándar SQL o no (en este caso indicar la/s causa/s).
--RTA
--a.1) Es automáticamente actualizable.
--a.2) Es automáticamente actualizable.
--a.3) NO es automáticamente actualizable. NO conserva todas las columnas de su PK.
--a.4) NO es automáticamente actualizable. Tiene función de agregación y un ensamble

--c) Compruebe si resultan automáticamente actualizables para PostgreSQL, proporcionando sentencias de actualización sobre las vistas en cada caso. 






--Considere el esquema de Peliculas
--Escriba las sentencias de creación de las vistas solicitadas en cada caso.
--Indique si para el estándar SQL dicha vista es actualizable o no. Justifique cada respuesta.
--idem en PostgreSQL, teniendo en cuenta de construir vistas que resulten automáticamente actualizables, siempre que sea posible.
--1)Cree una vista EMPLEADO_DIST_20 que liste el id_empleado, nombre, apellido, sueldo y fecha_nacimiento 
--  de los empleados que corresponden al distribuidor con identificador 20.
CREATE VIEW EMPLEADO_DIST_20 AS
SELECT id_empleado, nombre, apellido, sueldo, fecha_nacimiento FROM empleado
WHERE id_distribuidor = 20;

--2)Sobre la vista anterior defina otra vista EMPLEADO_DIST_2000 con el id, nombre, apellido y sueldo de 
--  los empleados con sueldo mayor a 2000.
CREATE VIEW EMPLEADO_DIST_2000 AS
SELECT id_empleado, nombre, apellido, sueldo FROM EMPLEADO_DIST_20
WHERE sueldo > 2000;

--3)Sobre la vista EMPLEADO_DIST_20 cree la vista EMPLEADO_DIST_20_70 con aquellos empleados que han nacido 
--  en la década del 70 (entre los años 1970 y 1979).
CREATE VIEW EMPLEADO_DIST_20_70 AS
SELECT id_empleado FROM EMPLEADO_DIST_20
WHERE EXTRACT(year from fecha_nacimiento) BETWEEN 1970 AND 1979;


--4) Cree una vista PELICULAS_ENTREGADAS que contenga el código de cada película y la cantidad de unidades entregadas.
CREATE VIEW PELICULAS_ENTREGADAS AS
SELECT codigo_pelicula, SUM(cantidad) FROM renglon_entrega
GROUP BY codigo_pelicula;

--5)Cree una vista DISTRIB_NAC con los el id de las distribuidoras nacionales, nro_incripcion y encargado, 
--  con distribuidor mayorista del país AR
CREATE VIEW DISTRIB_NAC AS
SELECT d.id_distribuidor, n.nro_incripcion, n.encargado 
FROM nacional n
    JOIN distribuidor d ON (n.id_distribuidor = d.id_distribuidor)
    JOIN internacional i ON (d.id_distribuidor = i.id_distribuidor)
WHERE d.tipo = "N" AND codigo_pais = "AR";



--6)Usando la vista anterior, cree la vista DISTRIB_NAC_MAS2EMP con los datos completos de las distribuidoras 
--  nacionales cuyos departamentos tengan más de 2 empleados.
