--Para el esquema de Proveedores
--a)Cada proveedor no puede proveer más de 20 productos a una misma sucursal.
--DECLARATIVAMENTE:
ALTER TABLE PROVEE ADD CONSTRAINT chk_max_20_provee
CHECK(NOT EXISTS(Select  1
                FROM proveedor
                GROUP BY nro_prov, cod_suc
                HAVING count(cod_producto) > 20;));
--Postgres no permite las RI de tabla declarativamente, se implementan proceduralmente

--PROCEDURALMENTE:

CREATE FUNCTION fn_max_20_provee()
RETURNS TRIGGER AS $$
BEGIN
    IF(NOT EXISTS(Select  1
                FROM proveedor
                GROUP BY nro_prov, cod_suc
                HAVING count(cod_producto) > 20) THEN
        RAISE EXCEPTION 'El proveedor supera los 20 productos para una misma sucursañ'
    END IF;
    RETURN NEW;

    
END;
$$ LANGUAGE 'plpgsql';


CREATE TRIGGER tgr_max_20_provee
AFTER INSERT OR UPDATE OF nro_prov OR UPDATE OF cod_suc
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



