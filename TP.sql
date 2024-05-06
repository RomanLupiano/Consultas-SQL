--Consultas con DISTINCT
--1) Liste los códigos de las distintas tareas que están realizando actualmente los voluntarios.
SELECT DISTINCT id_tarea from voluntario;

--2) Genere un listado con los distintos identificadores de los coordinadores.
SELECT DISTINCT id_coordinador from voluntario;


-------------------------------------------------------------------------------------------------------
--Consultas con condiciones y ordenamiento (esq. Voluntarios)
--1)Muestre los apellidos, nombres y e_mail de los voluntarios que llevan aportadas más de 1.000 horas,
--  ordenados por apellido.
SELECT apellido, nombre, e_mail 
FROM voluntario
WHERE horas_aportadas > 1000
ORDER BY apellido;

--2)Muestre el apellido y teléfono de todos los voluntarios de las instituciones 20 y 50 en orden 
-- alfabético por apellido y nombre.
SELECT apellido, telefono
FROM voluntario
WHERE (id_institucion = 20 OR id_institucion = 50)
ORDER BY apellido, nombre;

--3)Muestre el apellido, nombre y el e-mail de todos los voluntarios cuyo teléfono comienza con '+11'. 
--  Coloque como encabezado de las columnas los títulos 'Apellido y Nombre' y 'Dirección de mail'.
SELECT apellido || ' , ' || nombre AS "Apellido y Nombre", e_mail AS "Direccion de mail"
FROM voluntario
WHERE telefono like '+11%'


-------------------------------------------------------------------------------------------------------
--Consultas con IS [NOT] NULL (esq. Películas)
--1)Muestre apellido, nombre e identificador de todos los empleados que no cobran 
--  porcentaje de comisión . Ordene por apellido.
SELECT apellido, nombre, id_empleado 
FROM empleado
WHERE porc_comision is NULL
ORDER BY apellido;

--2)Muestre los datos de los distribuidores internacionales que no tienen registrado teléfono. 
SELECT * 
FROM distribuidor
WHERE tipo = 'I' AND telefono is null;

--3)Seleccione la clave y el nombre de los departamentos sin jefe.
SELECT id_departamento, nombre
FROM departamento
WHERE jefe_departamento is null;


-------------------------------------------------------------------------------------------------------
--Uso de funciones de fecha (esq. Voluntarios)
--1)Haga un listado de los voluntarios donde se muestre el apellido y nombre (concatenados y separados 
--  por una coma) y la fecha de nacimiento (como año, mes y día), ordenados por año de nacimiento.
SELECT apellido || ', ' || nombre "Apellido y nombre", fecha_nacimiento 
FROM voluntario
ORDER BY EXTRACT(YEAR FROM fecha_nacimiento);

--2)Muestre todos los voluntarios nacidos a partir de 1998 con más de 5000 horas aportadas, 
--  ordenados por su identificador.
SELECT nro_voluntario, nombre, apellido 
FROM voluntario
WHERE EXTRACT(YEAR FROM fecha_nacimiento) >= 1998 AND horas_aportadas > 5000
ORDER BY nro_voluntario;

--3)Haga un listado de los voluntarios que cumplen años hoy (día y mes actual), indicando el nombre, 
--  apellido y su edad (en años).
SELECT nombre, apellido, EXTRACT('YEAR' FROM AGE(CURRENT_DATE, fecha_nacimiento)) AS edad
FROM voluntario
WHERE 
    EXTRACT(MONTH FROM fecha_nacimiento) = EXTRACT(MONTH FROM CURRENT_DATE)
AND EXTRACT(DAY FROM fecha_nacimiento) = EXTRACT(DAY FROM CURRENT_DATE)


-------------------------------------------------------------------------------------------------------
--Consultas con LIMIT (esq. Voluntarios)
--1)Seleccione los datos de las 10 primeras direcciones ordenadas de acuerdo a su identificador.
SELECT id_direccion, calle, provincia, ciudad
FROM direccion
ORDER BY id_direccion
LIMIT 10;

--2)Si se desea paginar la consulta que selecciona los datos de las tareas cuyo nombre comience 
--  con O, A o C, y hay 5 registros por página, muestre la consulta que llenaría los datos para 
--  la 3er. página.
--PRIMER PAGINA
SELECT nombre_tarea, min_horas, max_horas
FROM tarea
WHERE nombre_tarea like 'O%' OR nombre_tarea like 'A%' OR nombre_tarea like 'C%'
ORDER BY nombre_tarea
LIMIT 5;
--SEGUNDA PAGINA
SELECT nombre_tarea, min_horas, max_horas
FROM tarea
WHERE nombre_tarea like 'O%' OR nombre_tarea like 'A%' OR nombre_tarea like 'C%'
ORDER BY nombre_tarea
LIMIT 5
OFFSET 5;
--TERCERA PAGINA
SELECT nombre_tarea, min_horas, max_horas
FROM tarea
WHERE nombre_tarea like 'O%' OR nombre_tarea like 'A%' OR nombre_tarea like 'C%'
ORDER BY nombre_tarea
LIMIT 5
OFFSET 10;


-------------------------------------------------------------------------------------------------------
--Funciones de grupo y uso de GROUP BY y HAVING (esq. Voluntarios)
--1)Recupere la cantidad mínima, máxima y promedio de horas aportadas por los voluntarios de más de 25 años. 
SELECT MIN(horas_aportadas), MAX(horas_aportadas), AVG(horas_aportadas)
FROM voluntario
WHERE EXTRACT(YEAR FROM AGE(CURRENT_DATE, fecha_nacimiento)) >= 25;

--2)Obtenga la cantidad de voluntarios que tiene cada institución.
SELECT id_institucion, count(nro_voluntario)
FROM voluntario
GROUP BY id_institucion;

--3)Muestre la fecha de nacimiento del voluntario más joven y del más viejo.
SELECT MIN(fecha_nacimiento), MAX(Fecha_nacimiento)
FROM voluntario;

--4)Considerando los datos históricos de cada voluntario, indique la cantidad de tareas 
--  distintas que cada uno ha realizado.
SELECT nro_voluntario, COUNT(DISTINCT id_tarea)
FROM historico
GROUP BY nro_voluntario;

--5)Se quiere conocer los coordinadores que tienen a su cargo menos de 3 voluntarios dentro 
--  de cada institución.
SELECT id_coordinador, COUNT(nro_voluntario)
FROM voluntario
GROUP BY id_coordinador;


-------------------------------------------------------------------------------------------------------
--Consultas sobre la Base de Datos de Voluntariado: 
--1)Realice un listado donde, por cada voluntario, se indique las distintas instituciones y tareas 
--  que ha desarrollado (considere los datos históricos). 

--2)Muestre el apellido, la tarea y las horas aportadas de todos los voluntarios cuyas tareas sean 
--  de “SA_REP” o “ST_CLERK” y cuyas horas aportadas no sean iguales a 2.500, 3.500 ni 7.000.

--3)Muestre los datos completos de las instituciones que posean director. 

--4)Muestre el apellido e identificador de la tarea de todos los voluntarios que no tienen coordinador.

--5)Muestre el apellido, las horas aportadas y el porcentaje de donación para todos los voluntarios que 
--  aportan horas (aporte > 0 o distinto de nulo). Ordene los datos de forma descendente según las 
--  horas aportadas y porcentajes de donaciones.

--6)Liste los identificadores de aquellos coordinadores que coordinan a más de 8 voluntarios.


--7)Muestre el identificador de las instituciones y la cantidad de voluntarios que trabajan en 
--  ellas, sólo de aquellas instituciones que tengan más de 10 voluntarios.



-------------------------------------------------------------------------------------------------------
--Consultas sobre la Base de Distribución de Películas:
--8)Liste los apellidos, nombres y e-mails de los empleados con cuentas de gmail y cuyo sueldo sea 
--  superior a 1000. 

--9)Muestre los códigos de películas que han recibido entre 3 y 5 entregas. (cantidad de entregas, 
--  NO cantidad de películas entregadas) 

--10)Liste la cantidad de películas que hay por cada idioma. 

--11)Calcule la cantidad de empleados por departamento. 
