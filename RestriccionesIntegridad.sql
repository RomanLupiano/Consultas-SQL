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


--Para el esquema de Proveedores
--a)Cada proveedor no puede proveer más de 20 productos a una misma sucursal.
--b)Los nombres de sucursales de Tandil deben comenzar con T.
--c)La descripción y la presentación de un producto no pueden ser ambas nulas.
--d)Cada proveedor sólo puede proveer productos a sucursales de su localidad.

--Para el esquema de Voluntarios
--a)Ningún voluntario puede aportar más horas que las de su coordinador.
--b)Las horas aportadas por un voluntario deben estar dentro de los valores máximos y mínimos consignados en la tarea que realiza.
--c)Todos los voluntarios deben realizar la misma tarea que su coordinador.
--d)Los voluntarios no pueden cambiar de institución más de tres veces en un año.
