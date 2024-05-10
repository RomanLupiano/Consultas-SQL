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

--4)Liste en orden alfabético los nombres de los países que nunca han tenido acción de voluntarios 
--  (considerando sólo información histórica, no tener en cuenta los voluntarios actuales).

--5)Indique los datos de las tareas que se han desarrollado históricamente y que no se están 
--  desarrollando actualmente.

--6)Liste el id, nombre y máxima cantidad de horas de las tareas que se están ejecutando solo 
--  una vez y que actualmente la están realizando voluntarios de la ciudad ‘Munich’. Ordene 
--  por id de tarea.

--7)Indique los datos de las instituciones que poseen director, donde históricamente se hayan 
--  desarrollado tareas que actualmente las estén ejecutando voluntarios de otras instituciones.

--8)Liste los datos completos de todas las instituciones junto con el apellido y nombre de su 
--  director, si poseen.

