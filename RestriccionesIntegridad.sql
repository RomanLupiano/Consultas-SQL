--Restricciones de integridad Declarativas

--Para el esquema de Articulos
--a)Controlar que las nacionalidades sean 'Argentina', 'Española', 'Inglesa' o 'Chilena'.
ALTER TABLE articulo ADD CONSTRAINT chk_nacionalidad
    CHECK(nacionalidad in ('Argentina', 'Española', 'Inglesa', 'Chilena'));

--b)Para las fechas de publicaciones se debe considerar que sean fechas posteriores o iguales al 2010.
ALTER TABLE articulo ADD CONSTRAINT chk_posterior_2010
    CHECK(EXTRACT(YEAR FROM fecha_pub) >= 2010)

--c)Los artículos publicados luego del año 2020 no deben ser de nacionalidad Inglesa.
ALTER TABLE articulo ADD CONSTRAINT chk_posterior_2020_no_inglesa
    CHECK((nacionalidad != 'Inglesa' 
        AND EXTRACT(YEAR FROM fecha_pub) >= 2020) 
        OR EXTRACT(YEAR FROM fecha_pub) <= 2020)
    
--d)Sólo se pueden publicar artículos argentinos que contengan hasta 10 palabras claves.
CREATE ASSERTION max_10_palabras_argentinos
CHECK (NOT EXISTS (SELECT 1 FROM articulo a
                    JOIN contiene c ON (a.id_articulo = c.id_articulo)
                    WHERE nacionalidad = 'Argentina'
                    GROUP BY id_articulo
                    HAVING count(*) > 10));

--Para el esquema de Proveedores
--a)Cada proveedor no puede proveer más de 20 productos a una misma sucursal.
ALTER TABLE PROVEE ADD CONSTRAINT chk_max_20_provee
CHECK(NOT EXISTS(Select  1
                FROM proveedor
                GROUP BY nro_prov, cod_suc
                HAVING count(cod_producto) > 20;));

--b)Los nombres de sucursales de Tandil deben comenzar con T.
ALTER TABLE sucursal ADD CONSTRAINT chk_tandil_con_t
CHECK((localidad = 'Tandil' AND nombre LIKE 'T%') 
        OR localidad != 'Tandil')

--c)La descripción y la presentación de un producto no pueden ser ambas nulas.
ALTER TABLE producto ADD CONSTRAINT chk_ambas_no_nulas
CHECK(NOT(presentación = null AND descripcion = null)

--d)Cada proveedor sólo puede proveer productos a sucursales de su localidad.
CREATE ASSERTION proveedor_a_su_localidad
CHECK(NOT EXISTS(SELECT 1 
                FROM proveedor p
                    JOIN provee ON (p.nro_prov = provee.nro_prov)
                    JOIN sucursal s ON (s.cod_suc = provee.cod_suc)
                WHERE p.localidad != s.localidad));

--Para el esquema de Voluntarios
--a)Ningún voluntario puede aportar más horas que las de su coordinador.
ALTER TABLE voluntario ADD CONSTRAINT hrs_voluntario_menores_cordinador
CHECK(NOT EXISTS(SELECT 1
                FROM voluntario v
                    JOIN voluntario c ON (v.id_coordinador = c.nro_voluntario)
                WHERE v.horas_aportadas > c.horas_aportadas));

--b)Las horas aportadas por un voluntario deben estar dentro de los valores máximos y mínimos consignados en la tarea que realiza.
CREATE ASSERTION horas_aportadas_dentro_horas_min_max
CHECK(NOT EXISTS(SELECT 1
                FROM voluntario v
                    JOIN tarea t ON (v.id_tarea = t.id_tarea)
                WHERE v.horas_aportadas NOT BETWEEN t.min_horas AND t.max_horas));

--c)Todos los voluntarios deben realizar la misma tarea que su coordinador.
ALTER TABLE voluntario ADD CONSTRAINT voluntario_misma_tarea_cordinador
CHECK(NOT EXISTS(SELECT 1
                FROM voluntario v
                    JOIN voluntario c ON (v.id_coordinador = c.nro_voluntario)
                WHERE v.id_tarea != c.id_tarea));

--d)Los voluntarios no pueden cambiar de institución más de tres veces en un año.
CREATE ASSERTION voluntario_max_3_cambios_tarea_al_año
CHECK(NOT EXISTS(SELECT v.nro_voluntario, count(*)
                FROM voluntario v
                    JOIN historico h ON (v.nro_voluntario = h.nro_voluntario)
                WHERE AGE(h.fecha_inicio) <= '1 years'
                GROUP BY v.nro_voluntario
                HAVING count(*) > 3));