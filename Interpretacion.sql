--Considere la siguiente tabla:
CREATE TABLE Equipo (
  Id 		int NOT NULL,
  puntos		int,
  descripcion 	varchar(20),
	CONSTRAINT pk_equipo PRIMARY KEY (Id)
);
--con los siguientes datos:
INSERT INTO Equipo(id, puntos) VALUES (1, null), (2, null), (3, null), (4, null);



--a) Qué retornan las siguientes consultas?
--1)
SELECT avg(puntos), count(puntos), count(*)
FROM Equipo;
--RTA: Retorna una tabla con NULL, 0, 4.

--2)
SELECT id, ‘Su descripción es ’|| descripcion
FROM equipo
WHERE puntos NOT IN (select distinct puntos from equipo);
--RTA: No retorna nada porque la subqueary retorna NULL y el NOT IN nunca lo toma en cuenta.

--3)
SELECT *
FROM equipo
WHERE puntos NOT IN (select distinct puntos from equipo);
--RTA: No retorna nada porque la subqueary retorna NULL y el NOT IN nunca lo toma en cuenta.

--4)
SELECT *
FROM equipo e1 JOIN equipo e2
ON (e1.puntos = e2.puntos);
--RTA: los nulos nunca matchean con nulos, por lo tanto no va a devolver nada.


--b) Modifique la consulta 1 para que devuelva los valores nulos como ceros o blancos.
--RTA:
SELECT COALESCE(avg(puntos), 0), COALESCE(count(puntos), 0), COALESCE(count(*), 0)
FROM Equipo;



--¿Cuáles son los voluntarios que no selecciona la siguiente consulta?
SELECT nro_voluntario, apellido, nombre
FROM VOLUNTARIO
WHERE NOT (porcentaje BETWEEN 0.15 AND 0.30) ; 
--RTA: No se seleccionan aquellos que tengan el porcentaje entre 0.15 y 0.30, y tampoco aquellos con 
--     porcentaje NULL



--Estas dos consultas arrojan los mismos resultados? O sino, cuáles son las diferencias?
SELECT I.id_institucion, count(*)
FROM institucion I LEFT JOIN voluntario V
ON (I. id_institucion = V. id_institucion)
GROUP BY   I.id_institucion;

SELECT V.id_institucion, count(*)
FROM institucion I LEFT JOIN voluntario V
ON (I. id_institucion = V. id_institucion)
GROUP BY   V.id_institucion;
--RTA: No arroja los mismos resultados, en el primer caso se agrupan por todas las instituciones.
--     En el segundo caso se agrupan por las instituciones que tienen voluntarios realizando trabajos.