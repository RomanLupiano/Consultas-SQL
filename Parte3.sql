--Consultas sobre una tabla (esq. Voluntarios)

--Consultas con condiciones y ordenamiento
--1)Muestre el apellido, nombre, las horas aportadas y la fecha de nacimiento de todos los voluntarios cuya tarea
--  sea IT_PROG o ST_CLERK y cuyas horas aportadas no sean iguales a 2.500, 3.500 ni 7.000. Ordene por apellido y nombre.
SELECT apellido, nombre, horas_aportadas, fecha_nacimiento
FROM voluntario
WHERE id_tarea IN ('IT_PROG', 'ST_CLERK')
    AND horas_aportadas NOT IN (2500, 3500, 7000)
ORDER BY apellido, nombre;

--2)Genere un listado ordenado por número de voluntario, incluyendo también el nombre y apellido y el e-mail de los 
--  voluntarios con menos de 1000 horas aportadas. Coloque como encabezado de las columnas los títulos ‘Numero’, 'Nombre y apellido' y 'Contacto'.
SELECT nro_voluntario "Numero", nombre || ' ' || apellido "Nombre y apellido", e_mail "Contacto"
FROM voluntario
WHERE horas_aportadas < 1000
ORDER BY nro_voluntario;



--Consultas con DISTINCT y con IS [NOT] NULL
--3)Genere un listado de los distintos id de coordinadores en la base de Voluntariado. Tenga en cuenta de no incluir el valor nulo en el resultado. 
SELECT id_coordinador
FROM voluntario
WHERE id_coordinador IS NOT NULL;

--4)Muestre los códigos de las diferentes tareas que están desarrollando los voluntarios que no registran porcentaje de donación. 
SELECT DISTINCT id_tarea
FROM voluntario
WHERE porcentaje IS NULL;



--Consultas con funciones de fecha y LIMIT 
--5)Muestre los 5 voluntarios que poseen más horas aportadas y que hayan nacido después del año 1995.
SELECT nro_voluntario, apellido, nombre, horas_aportadas, fecha_nacimiento
FROM voluntario
WHERE EXTRACT('year' from fecha_nacimiento) > '1995'
ORDER BY horas_aportadas DESC
LIMIT 5;

--6)Liste el id, apellido, nombre y edad (expresada en años) de los voluntarios con fecha de cumpleaños en el mes actual. 
--  Limite el resultado a los 3 voluntarios de mayor edad.
SELECT nro_voluntario, apellido, nombre, EXTRACT(YEAR FROM AGE(fecha_nacimiento)) Edad
FROM voluntario
WHERE EXTRACT(MONTH FROM fecha_nacimiento) = EXTRACT(MONTH FROM NOW())
ORDER BY fecha_nacimiento
LIMIT 3;



--Consultas con funciones de grupo, GROUP BY y HAVING 
--7)Encuentre la cantidad mínima, máxima y promedio de horas aportadas por los voluntarios de más de 30 años.

--8)Por cada institución con identificador conocido, indicar la cantidad de voluntarios que trabajan en ella y el total de horas que aportan.

--9)Muestre el identificador de las instituciones y la cantidad de voluntarios que trabajan en ellas, sólo de aquellas instituciones que tengan más de 10 voluntarios.

--10)Liste los coordinadores que tienen a su cargo más de 3 voluntarios dentro de una misma institución.

-------------------------------------------------------------------------------------------------------
--Consultas sobre más de una tabla (esq. Peliculas): 
--Consultas para resolver mediante ensamble/s (NATURAL/INNER/OUTER JOIN).
--11)Muestre los ids, nombres y apellidos de los empleados que no poseen jefe. Incluya también el nombre de la tarea que cada uno realiza,
--   verificando que el sueldo máximo de la misma sea superior a 14800. 

--12)Determine si hay empleados que reciben un sueldo superior al de sus respectivos jefes.

--13)Liste el identificador, nombre y tipo de los distribuidores que hayan entregado películas en idioma Español luego del año 2010. 
--   Incluya en cada caso la cantidad de películas distintas entregadas.

--14)Para cada uno de los empleados registrados en la base, liste su apellido junto con el apellido de su jefe, en caso de tenerlo, 
--   sino incluya la expresión ‘(no posee)’. Ordene el resultado por el apellido del empleado.

--15)Liste el id y nombre de todos los distribuidores existentes junto con la cantidad de videos a los que han realizado entregas.




--Consultas para resolver con subconsultas (IN, NOT IN, EXISTS, NOT EXISTS).
--16)Liste los datos de las películas que nunca han sido entregadas por un distribuidor nacional.

--17)Indicar los departamentos (nombre e identificador completo) que tienen más de 3 empleados realizando tareas de sueldo mínimo inferior a 6000. 
---  Mostrar el resultado ordenado por el id de departamento.

--18)Liste los datos de los Departamentos en los que trabajan menos del 10 % de los empleados registrados.

--19)Encuentre el/los departamento/s con la mayor cantidad de empleados.

--20)Resuelva los servicios del grupo anterior mediante consultas anidadas, en caso que sea posible.




--Consultas para resolver con operadores de conjuntos (o simulando la operación)
--21)Encuentre los id de distribuidor correspondientes a distribuidores que no han realizado entregas.

--22)Verifique si hay empleados que son jefes de otro/s empleado/s y que además son jefes de algún departamento.

--23)Liste los datos personales de todos los distribuidores (nacionales e internacionales) junto con el encargado, para el caso de distribuidores nacionales. 

--24)Determine si hay distribuidores que han realizado entregas de películas a todos los videos.


--Interpretación de resultados donde intervienen valores nulos
--Analice los resultados de los siguientes grupos de consultas: 

      A.1   SELECT avg(porcentaje), count(porcentaje), count(*)
  	      FROM voluntario;

      A.2      SELECT avg(porcentaje), count(porcentaje), count(*)
        FROM voluntario WHERE porcentaje IS NOT NULL;
 
      A.3      SELECT avg(porcentaje), count(porcentaje), count(*)
        FROM voluntario WHERE porcentaje IS NULL;

      B.1      SELECT * FROM voluntario 
        WHERE nro_voluntario NOT IN (SELECT id_director FROM institucion);

      B.2      SELECT * FROM voluntario 
        WHERE nro_voluntario NOT IN (SELECT id_director FROM institucion
                                       WHERE id_director IS NOT NULL);

      C.1      SELECT i.id_institucion, count(*)
        FROM institucion i LEFT JOIN voluntario v
        ON (i.id_institucion = v.id_institucion)
        GROUP BY  i.id_institucion;

      C.2      SELECT v.id_institucion, count(*)
        FROM institucion i LEFT JOIN voluntario v
        ON (i.id_institucion = v.id_institucion)
        GROUP BY  v.id_institucion;
