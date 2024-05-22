--Contenidos--
--Consultas avanzadas a la base de datos mediante SQL
--Consultas que involucran más de una tabla.
--Distintos tipos de ensambles (JOIN NATURAL, INNER, OUTER).
--Consultas para resolver mediante subconsultas (IN, NOT IN, EXISTS, NOT EXISTS).
-------------------------------------------------------------------------------------------------------


--Consultas a la base de datos utilizando ensambles y consultas anidadas
--Considere el esquema de Voluntarios
--1)Haga un resumen de cuantas veces ha cambiado de tareas cada voluntario. Indique el número,  
--  nombre y apellido del voluntario.
SELECT voluntario.nro_voluntario, apellido, nombre, COUNT(historico.id_tarea) AS veces_que_cambio
FROM voluntario
    JOIN historico ON historico.nro_voluntario = voluntario.nro_voluntario
GROUP BY voluntario.nro_voluntario;

--2)Liste los datos de contacto (nombre, apellido, e-mail y teléfono) de los voluntarios que hayan 
-- desarrollado tareas con diferencia max_horas-min_horas de hasta 5000 horas y que las hayan 
-- finalizado antes del  01/01/2000. 
SELECT DISTINCT nombre, apellido, e_mail, telefono
FROM historico his
    JOIN tarea tar ON his.id_tarea = tar.id_tarea
    JOIN voluntario vol ON vol.nro_voluntario = his.nro_voluntario
WHERE (his.fecha_fin <= make_date(2000, 1, 1))
    AND ((tar.max_horas - tar.min_horas) <= 5000)

--3)Indique nombre, id y dirección completa de las instituciones que no poseen voluntarios con 
--  aporte de horas mayor o igual que el máximo de horas de la tarea que realiza. 
SELECT nombre_institucion, id_institucion, dir.calle, dir.provincia, dir.ciudad, pais.nombre_pais
FROM institucion
   JOIN direccion dir USING (id_direccion)
   JOIN pais USING (id_pais)
WHERE id_institucion not in (
SELECT DISTINCT id_institucion
FROM voluntario vol
WHERE horas_aportadas >= (SELECT max_horas FROM tarea tar
                          where tar.id_tarea = vol.id_tarea))

--4)Liste en orden alfabético los nombres de los países que nunca han tenido acción de voluntarios 
--  (considerando sólo información histórica, no tener en cuenta los voluntarios actuales).
SELECT DISTINCT nombre_pais 
FROM institucion 
    JOIN direccion dir USING (id_direccion)
    JOIN pais USING (id_pais)
WHERE id_institucion NOT IN 
    (SELECT id_institucion
     FROM voluntario
     WHERE nro_voluntario in (select nro_voluntario from historico))
ORDER BY nombre_pais;

--5)Indique los datos de las tareas que se han desarrollado históricamente y que no se están 
--  desarrollando actualmente.
SELECT id_tarea, fecha_inicio, fecha_fin 
FROM historico
WHERE id_tarea NOT IN (SELECT DISTINCT id_tarea FROM voluntario);

--6)Liste el id, nombre y máxima cantidad de horas de las tareas que se están ejecutando solo 
--  una vez y que actualmente la están realizando voluntarios de la ciudad ‘Munich’. Ordene 
--  por id de tarea.

SELECT id_tarea, nombre_tarea, max_horas 
FROM tarea
WHERE id_tarea NOT IN (SELECT id_tarea FROM historico)
AND id_tarea in 
    (SELECT id_tarea
    FROM voluntario
    WHERE id_institucion in 
            (SELECT id_institucion 
            FROM institucion
            WHERE id_direccion in 
                    (SELECT id_direccion 
                    FROM direccion 
                    WHERE ciudad = 'Munich')))
ORDER BY id_tarea;

--7)Indique los datos de las instituciones que poseen director, donde históricamente se hayan 
--  desarrollado tareas que actualmente las estén ejecutando voluntarios de otras instituciones.



--8)Liste los datos completos de todas las instituciones junto con el apellido y nombre de su 
--  director, si poseen.
SELECT ins.id_institucion, ins.nombre_institucion, ins.id_director, ins.id_direccion, vol.apellido, vol.nombre FROM institucion ins
    JOIN voluntario vol ON (ins.id_director = vol.nro_voluntario);



-------------------------------------------------------------------------------------------------------
--Considere el esquema de Películas (Figura 2 del TP2-P1) y resuelva las siguientes consultas en SQL:
--9)Para cada uno de los empleados indique su id, nombre y apellido junto con el id, nombre y 
--  apellido de su jefe, en caso de tenerlo.
SELECT emp.id_empleado, emp.nombre, emp.apellido, jefe.id_empleado as "Jefe id", jefe.nombre as "Jefe nombre", jefe.apellido as "Jefe apellido" 
FROM empleado emp 
   JOIN empleado jefe ON (emp.id_jefe = jefe.id_empleado)
WHERE emp.id_jefe IS NOT NULL;


--10)Determine los ids, nombres y apellidos de los empleados que son jefes y cuyos departamentos 
--   donde se desempeñan se encuentren en la ciudad ‘Rawalpindi’. Ordene los datos por los ids. 
SELECT id_empleado, nombre, apellido 
FROM empleado 
WHERE id_empleado IN (SELECT id_jefe FROM empleado WHERE id_jefe IS NOT NULL)
AND id_empleado 
  IN (SELECT jefe_departamento FROM departamento 
      WHERE id_ciudad = (SELECT id_ciudad FROM ciudad 
                         WHERE nombre_ciudad = 'Rawalpindi')) 
ORDER BY id_empleado;

--11)Liste los ids y números de inscripción de los distribuidores nacionales que hayan entregado 
--   películas en idioma Español luego del año 2010.


--12)Liste las películas que nunca han sido entregadas por un distribuidor nacional.


--13)Liste el apellido y nombre de los empleados que trabajan en departamentos residentes en el
--   país Argentina y donde el jefe de departamento posee más del 40% de comisión.

--14)Indique los departamentos (nombre e identificador completo) que tienen más de 3 empleados con
--   tareas con sueldo mínimo menor a 6000. Muestre el resultado ordenado por distribuidor.


--15)Liste los datos de los departamentos en los que trabajan menos del 10 % de los empleados que 
--   hay registrados.

