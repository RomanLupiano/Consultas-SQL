--Para el esquema de Proveedores
--a)Cada proveedor no puede proveer más de 20 productos a una misma sucursal.
--DECLARATIVAMENTE:
ALTER TABLE PROVEE ADD CONSTRAINT chk_max_20_provee
CHECK(NOT EXISTS(Select  1
                FROM provee
                GROUP BY nro_prov, cod_suc
                HAVING count(cod_producto) > 20;));
--Postgres no permite las RI de tabla declarativamente, se implementan proceduralmente

--PROCEDURALMENTE:
--Forma 1:
CREATE OR REPLACE FUNCTION fn_max_20_provee()
RETURNS TRIGGER AS $$
BEGIN
    IF(EXISTS(Select  1
                FROM provee
                GROUP BY provee.nro_prov, provee.cod_suc
                HAVING count(*) > 20)) THEN
        RAISE EXCEPTION 'El proveedor supera los 20 productos para una misma sucursal';
    END IF;
    RETURN NEW;
END; $$ LANGUAGE 'plpgsql';

--Forma 2(Más eficiente):
CREATE OR REPLACE FUNCTION fn_max_20_provee()
RETURNS TRIGGER AS $$
BEGIN
    IF((Select count(provee.cod_producto) FROM provee
        WHERE provee.nro_prov = NEW.nro_prov AND provee.cod_suc = NEW.cod_suc) > 20) THEN
        RAISE EXCEPTION 'El proveedor supera los 20 productos para una misma sucursal';
    END IF;
    RETURN NEW;
END; $$ LANGUAGE 'plpgsql';

--Trigger
CREATE TRIGGER tgr_max_20_provee
AFTER INSERT OR UPDATE OF nro_prov, cod_suc
ON provee
FOR EACH ROW EXECUTE FUNCTION fn_max_20_provee();






--d)Cada proveedor sólo puede proveer productos a sucursales de su localidad.
--DECLARATIVAMENTE:
CREATE ASSERTION proveedor_a_su_localidad
CHECK(NOT EXISTS(SELECT 1 
                FROM proveedor p
                    JOIN provee ON (p.nro_prov = provee.nro_prov)
                    JOIN sucursal s ON (s.cod_suc = provee.cod_suc)
                WHERE p.localidad != s.localidad));
--Postgres no permite las RI generales declarativamente, se implementan proceduralmente

--PROCEDURALMENTE:
--FORMA 1:
CREATE FUNCTION fn_proveedor_a_su_localidad
RETURNS TRIGGER AS $$
BEGIN
    IF (EXISTS(SELECT 1 
                FROM proveedor p
                    JOIN provee ON (p.nro_prov = provee.nro_prov)
                    JOIN sucursal s ON (s.cod_suc = provee.cod_suc)
                WHERE p.localidad != s.localidad)) THEN
        RAISE EXCEPTION 'Cada proveedor sólo puede proveer productos a sucursales de su localidad';
    END IF;
END; $$ LANGUAGE 'plpgsql';

CREATE TRIGGER  tgr_proveedor_a_su_localidad_provee
AFTER INSERT OR UPDATE OF nro_prov, cod_suc
ON provee
FOR EACH ROW EXECUTE FUNCTION fn_proveedor_a_su_localidad();

CREATE TRIGGER  tgr_proveedor_a_su_localidad_proveedor
AFTER UPDATE of localidad
ON proveedor
FOR EACH ROW EXECUTE FUNCTION fn_proveedor_a_su_localidad();

CREATE TRIGGER  tgr_proveedor_a_su_localidad_sucursal
AFTER UPDATE of localidad
ON sucursal
FOR EACH ROW EXECUTE FUNCTION fn_proveedor_a_su_localidad();






--Para el esquema de Voluntarios
--a)Ningún voluntario puede aportar más horas que las de su coordinador.
--DECLARATIVAMENTE:
ALTER TABLE voluntario ADD CONSTRAINT hrs_voluntario_menores_cordinador
CHECK(NOT EXISTS(SELECT 1
                FROM voluntario v
                    JOIN voluntario c ON (v.id_coordinador = c.nro_voluntario)
                WHERE v.horas_aportadas > c.horas_aportadas));

--PROCEDURALMENTE:
--Forma 1:
CREATE FUNCTION fn_horas_voluntario_no_supera_coordinador
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.id_coordinador IS null) THEN --INSERT sin coordinador o UPDATE quitando coordinador
        RETURN NEW;
    END IF;
    IF (NEW.horas_aportadas
            >
        (SELECT horas_aportadas FROM voluntario WHERE nro_voluntario = NEW.id_coordinador) ) THEN
        RAISE EXCEPTION 'Ningún voluntario puede aportar más horas que las de su coordinador';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

--Forma 2:
CREATE FUNCTION fn_horas_voluntario_no_supera_coordinador
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.id_coordinador IS null) THEN
    RETURN NEW;
    END IF;
    IF (EXISTS (SELECT 1
                FROM voluntario v
                    JOIN voluntario c ON (v.id_coordinador = c.nro_voluntario)
                WHERE v.horas_aportadas > c.horas_aportadas)) THEN
    RAISE EXCEPTION 'Ningún voluntario puede aportar más horas que las de su coordinador';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER tgr_horas_voluntario_no_supera_coordinador
AFTER INSERT OR UPDATE OF horas_aportadas, id_coordinador
ON voluntario
FOR EACH ROW EXECUTE FUNCTION fn_horas_voluntario_no_supera_coordinador();






--b)Las horas aportadas por un voluntario deben estar dentro de los valores máximos y mínimos consignados en la tarea que realiza.
--DECLARATIVAMENTE
CREATE ASSERTION horas_aportadas_dentro_horas_min_max
CHECK(NOT EXISTS(SELECT 1
                FROM voluntario v
                    JOIN tarea t ON (v.id_tarea = t.id_tarea)
                WHERE v.horas_aportadas NOT BETWEEN t.min_horas AND t.max_horas));

--ṔROCEDURALMENTE
--FORMA 1:
CREATE FUNCTION fn_horas_aportadas_dentro_min_max
RETURNS TRIGGER AS $$
DECLARE
    _min_horas INT;
    _max_horas INT;
BEGIN
    IF (TG_TABLE_NAME = 'voluntario') THEN
        SELECT min_horas, max_horas INTO _min_horas, _max_horas FROM tarea WHERE id_tarea = NEW.id_tarea;
        IF (NEW.horas_aportadas NOT BETWEEN _min_horas AND _max_horas) THEN
            RAISE EXCEPTION 'Las horas aportadas por un voluntario deben estar dentro de los valores máximos y mínimos consignados en la tarea que realiza';
        END IF;
    END IF;
    IF (TG_TABLE_NAME = 'tarea') THEN
        IF (EXISTS(SELECT 1 FROM voluntario WHERE id_tarea = new.id_tarea 
            AND (horas_aportadas NOT BETWEEN NEW.min_horas AND NEW.max_horas))) THEN
            RAISE EXCEPTION 'Hay voluntarios cuyas horas aportadas no entran dentro de los valores máximos y mínimos consignados en la tarea que realiza';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';


CREATE TRIGGER tgr_horas_aportadas_dentro_min_max_voluntario
AFTER INSERT OR UPDATE OF horas_aportadas, id_tarea
ON voluntario
FOR EACH ROW EXECUTE fn_horas_aportadas_dentro_min_max();

CREATE TRIGGER tgr_horas_aportadas_dentro_min_max_tarea
AFTER UPDATE OF min_horas, max_horas
ON tarea
FOR EACH ROW EXECUTE fn_horas_aportadas_dentro_min_max();



--FORMA 2:
CREATE FUNCTION fn_horas_aportadas_dentro_min_max_voluntario()
RETURNS TRIGGER AS $$
DECLARE
    _min_horas INT;
    _max_horas INT;
BEGIN
    SELECT min_horas, max_horas INTO _min_horas, _max_horas FROM tarea WHERE id_tarea = NEW.id_tarea;
    IF (NEW.horas_aportadas NOT BETWEEN _min_horas AND _max_horas) THEN
        RAISE EXCEPTION 'Las horas aportadas por un voluntario deben estar dentro de los valores máximos y mínimos consignados en la tarea que realiza';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE FUNCTION fn_horas_aportadas_dentro_min_max_tarea()
RETURNS TRIGGER AS $$
BEGIN
    IF (EXISTS(SELECT 1 FROM voluntario 
               WHERE id_tarea = NEW.id_tarea 
               AND (horas_aportadas NOT BETWEEN NEW.min_horas AND NEW.max_horas))) THEN
        RAISE EXCEPTION 'Hay voluntarios cuyas horas aportadas no entran dentro de los valores máximos y mínimos consignados en la tarea que realiza';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';


CREATE TRIGGER tgr_horas_aportadas_dentro_min_max_voluntario
BEFORE INSERT OR UPDATE OF horas_aportadas, id_tarea
ON voluntario
FOR EACH ROW EXECUTE FUNCTION fn_horas_aportadas_dentro_min_max_voluntario();

CREATE TRIGGER tgr_horas_aportadas_dentro_min_max_tarea
BEFORE UPDATE OF min_horas, max_horas
ON tarea
FOR EACH ROW EXECUTE FUNCTION fn_horas_aportadas_dentro_min_max_tarea();






--c)Todos los voluntarios deben realizar la misma tarea que su coordinador.
--DECLARATIVAMENTE
ALTER TABLE voluntario ADD CONSTRAINT voluntario_misma_tarea_cordinador
CHECK(NOT EXISTS(SELECT 1
                FROM voluntario v
                    JOIN voluntario c ON (v.id_coordinador = c.nro_voluntario)
                WHERE v.id_tarea != c.id_tarea));

--ṔROCEDURALMENTE
CREATE FUNCTION fn_voluntario_misma_tarea_cordinador
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.id_coordinador IS NOT NULL) THEN
        IF (NEW.id_tarea != (SELECT id_tarea FROM voluntario WHERE nro_voluntario = NEW.id_coordinador)) THEN
            RAISE EXCEPTION 'Todos los voluntarios deben realizar la misma tarea que su coordinador';
        END IF;
    END IF;
    RETURN NEW;    
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER tgr_voluntario_misma_tarea_cordinador
BEFORE INSERT OR UPDATE OF id_tarea, id_coordinador
ON voluntario
FOR EACH ROW EXECUTE FUNCTION fn_voluntario_misma_tarea_cordinador();


CREATE FUNCTION fn_verificar_voluntarios_misma_tarea()
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar que todos los voluntarios asociados al coordinador tengan la misma tarea
    IF EXISTS (SELECT 1 FROM voluntario v
               WHERE v.id_coordinador = NEW.nro_voluntario
               AND v.id_tarea != NEW.id_tarea) THEN
        RAISE EXCEPTION 'Los voluntarios asociados al coordinador deben realizar la misma tarea';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';


CREATE TRIGGER tgr_actualizar_coordinador_misma_tarea
BEFORE UPDATE OF id_tarea
ON voluntario
FOR EACH ROW
EXECUTE FUNCTION fn_verificar_voluntarios_misma_tarea();






--d)Los voluntarios no pueden cambiar de institución más de tres veces en un año.
--DECLARATIVAMENTE
CREATE ASSERTION voluntario_max_3_cambios_tarea_al_año
CHECK(NOT EXISTS(SELECT v.nro_voluntario, count(*)
                FROM voluntario v
                    JOIN historico h ON (v.nro_voluntario = h.nro_voluntario)
                WHERE AGE(h.fecha_inicio) <= '1 years'
                GROUP BY v.nro_voluntario
                HAVING count(*) > 3));

--ṔROCEDURALMENTE
CREATE FUNCTION fn_voluntario_max_3_cambios_tarea_al_año
RETURNS TRIGGER AS $$ 
BEGIN
    if ((SELECT count(*) FROM historico 
        WHERE nro_voluntario = NEW.nro_voluntario 
        AND fecha_fin )) >= 3 THEN
        RAISE EXCEPTION 'Los voluntarios no pueden cambiar de institución más de tres veces en un año';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER tgr_voluntario_max_3_cambios_tarea_al_año
BEFORE INSERT
ON historico
FOR EACH ROW EXECUTE FUNCTION fn_voluntario_max_3_cambios_tarea_al_año();
