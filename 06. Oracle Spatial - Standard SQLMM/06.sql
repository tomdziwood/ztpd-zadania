--01 A
SELECT
    lpad('-', 2 *(level - 1), '|-')
    || t.owner
    || '.'
    || t.type_name
    || ' (FINAL:'
    || t.final
    || ', INSTANTIABLE:'
    || t.instantiable
    || ', ATTRIBUTES:'
    || t.attributes
    || ', METHODS:'
    || t.methods
    || ')'
FROM
    all_types t
START WITH
    t.type_name = 'ST_GEOMETRY'
CONNECT BY PRIOR t.type_name = t.supertype_name
           AND PRIOR t.owner = t.owner;



--01 B
select distinct m.method_name
from all_type_methods m
where m.type_name like 'ST_POLYGON'
and m.owner = 'MDSYS'
order by 1;



--01 C
CREATE TABLE myst_major_cities (
    fips_cntry VARCHAR2(2),
    city_name VARCHAR2(40),
    stgeom ST_POINT
);



--01 D
INSERT INTO myst_major_cities (fips_cntry, city_name, stgeom)
SELECT fips_cntry, city_name, TREAT(ST_POINT.FROM_SDO_GEOM(geom) as ST_POINT) stgeom
FROM major_cities;



--02 A
INSERT INTO myst_major_cities (fips_cntry, city_name, stgeom)
VALUES ('PL', 'Szczyrk', TREAT(ST_POINT.FROM_WKT('POINT (19.036107 49.718655)') as ST_POINT));


--02 B
SELECT r.name, r.geom.GET_WKT() as WKT
FROM rivers r
ORDER BY name;


--02 C
SELECT SDO_UTIL.TO_GMLGEOMETRY(c.stgeom.GET_SDO_GEOM()) AS gml
FROM myst_major_cities c
WHERE city_name = 'Szczyrk';
-- <gml:Point srsName="SDO:" xmlns:gml="http://www.opengis.net/gml"><gml:coordinates decimal="." cs="," ts=" ">19.036107,49.718655 </gml:coordinates></gml:Point>



--03 A
CREATE TABLE myst_country_boundaries (
    fips_cntry VARCHAR2(2),
    cntry_name VARCHAR2(40),
    stgeom ST_MULTIPOLYGON
);


--03 B
INSERT INTO myst_country_boundaries (fips_cntry, cntry_name, stgeom)
SELECT fips_cntry, cntry_name, ST_MULTIPOLYGON(geom) stgeom
FROM country_boundaries;


--03 C
SELECT b.stgeom.ST_GEOMETRYTYPE() as "TYP OBIEKTU", COUNT(*) as "ILE"
FROM myst_country_boundaries b
GROUP BY b.stgeom.ST_GEOMETRYTYPE()
ORDER BY "TYP OBIEKTU";


--03 D
SELECT b.fips_cntry, b.cntry_name, b.stgeom.ST_ISSIMPLE()
FROM myst_country_boundaries b;



--04 A
-- Brak podanego ukladu odniesienia dla wczesniej wstawianego rekordu miasta Szczyrk
-- Usuniecie i ponowne wpisanie rekordu miasta do tabeli myst_major_cities
DELETE FROM myst_major_cities
WHERE city_name = 'Szczyrk';

INSERT INTO myst_major_cities (fips_cntry, city_name, stgeom)
VALUES ('PL', 'Szczyrk', TREAT(ST_POINT.FROM_WKT('POINT (19.036107 49.718655)', 8307) as ST_POINT));

SELECT cb.cntry_name, COUNT(*) as "ILE"
FROM myst_country_boundaries cb, myst_major_cities mc
WHERE mc.stgeom.ST_WITHIN(cb.stgeom) = 1
GROUP BY cb.cntry_name
ORDER BY cb.cntry_name;
-- CNTRY_NAME                                      ILE
-- ---------------------------------------- ----------
-- Austria                                           6
-- Byelarus                                          2
-- Czech Republic                                    7
-- Denmark                                           1
-- Germany                                           3
-- Hungary                                          19
-- Latvia                                            1
-- Lithuania                                         1
-- Poland                                           51
-- Romania                                          13
-- Russia                                            1
-- Slovakia                                          3
-- Slovenia                                          1
-- Sweden                                            7
-- Ukraine                                           7


--04 B
SELECT a.cntry_name as "A NAME", b.cntry_name as "B NAME"
FROM myst_country_boundaries a, myst_country_boundaries b
WHERE b.cntry_name = 'Czech Republic'
    AND a.cntry_name != 'Czech Republic'
    AND ST_INTERSECTS(a.stgeom, b.stgeom) = 'TRUE';
-- A NAME                                   B NAME                                  
-- ---------------------------------------- ----------------------------------------
-- Austria                                  Czech Republic                          
-- Germany                                  Czech Republic                          
-- Slovakia                                 Czech Republic                          
-- Poland                                   Czech Republic


--04 C
SELECT DISTINCT cb.cntry_name, r.name
FROM myst_country_boundaries cb, rivers r
WHERE cb.cntry_name = 'Czech Republic'
    AND ST_LINESTRING(R.GEOM).ST_INTERSECTS(cb.STGEOM) = 1
ORDER BY r.name;


--04 D
SELECT ROUND(TREAT(a.stgeom.ST_UNION(b.stgeom) as ST_POLYGON).ST_AREA(), -2) as POWIERZCHNIA
FROM myst_country_boundaries a, myst_country_boundaries b
WHERE a.cntry_name = 'Czech Republic'
    AND b.cntry_name = 'Slovakia';


--04 E
SELECT cb.STGEOM.ST_DIFFERENCE(ST_GEOMETRY(wb.geom)) as OBIEKT, cb.STGEOM.ST_DIFFERENCE(ST_GEOMETRY(wb.geom)).ST_GEOMETRYTYPE() as "WEGRY BEZ"
FROM myst_country_boundaries cb, water_bodies wb
WHERE cb.cntry_name = 'Hungary'
    AND wb.name = 'Balaton';



--05 A
SELECT COUNT(*) as ILE
FROM myst_country_boundaries cb, myst_major_cities mc
WHERE cb.cntry_name = 'Poland'
    AND SDO_WITHIN_DISTANCE(cb.stgeom, mc.stgeom, 'distance=100 unit=km') = 'TRUE';
--        ILE
-- ----------
--         67


EXPLAIN PLAN FOR
SELECT COUNT(*) as ILE
FROM myst_country_boundaries cb, myst_major_cities mc
WHERE cb.cntry_name = 'Poland'
    AND SDO_WITHIN_DISTANCE(cb.stgeom, mc.stgeom, 'distance=100 unit=km') = 'TRUE';
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
-- Plan hash value: 1954295368
--  
-- -----------------------------------------------------------------------------------------------
-- | Id  | Operation           | Name                    | Rows  | Bytes | Cost (%CPU)| Time     |
-- -----------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT    |                         |     1 |  7680 |     8   (0)| 00:00:01 |
-- |   1 |  SORT AGGREGATE     |                         |     1 |  7680 |            |          |
-- |   2 |   NESTED LOOPS      |                         |     1 |  7680 |     8   (0)| 00:00:01 |
-- |*  3 |    TABLE ACCESS FULL| MYST_COUNTRY_BOUNDARIES |     1 |  3857 |     5   (0)| 00:00:01 |
-- |*  4 |    TABLE ACCESS FULL| MYST_MAJOR_CITIES       |     1 |  3823 |     3   (0)| 00:00:01 |
-- -----------------------------------------------------------------------------------------------
--  
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
--  
--    3 - filter("CB"."CNTRY_NAME"='Poland')
--    4 - filter("MDSYS"."SDO_WITHIN_DISTANCE"("CB"."STGEOM","MC"."STGEOM",'distance=100 
--               unit=km')='TRUE')
--  
-- Note
-- -----
--    - dynamic statistics used: dynamic sampling (level=2)



--05 B
select
    MIN(mc.stgeom.GET_SDO_GEOM().SDO_POINT.X) as MinX,
    MAX(mc.stgeom.GET_SDO_GEOM().SDO_POINT.X) as MaxX,
    MIN(mc.stgeom.GET_SDO_GEOM().SDO_POINT.Y) as MinY,
    MAX(mc.stgeom.GET_SDO_GEOM().SDO_POINT.Y) as MaxY
FROM myst_major_cities mc;
--       MINX       MAXX       MINY       MAXY
-- ---------- ---------- ---------- ----------
-- 12,8549994 26,3166674 45,8680002 57,7859992

INSERT INTO USER_SDO_GEOM_METADATA
VALUES (
    'myst_major_cities',
    'stgeom',
    MDSYS.SDO_DIM_ARRAY(
        MDSYS.SDO_DIM_ELEMENT('X', 12.8549994, 26.3166674, 1),
        MDSYS.SDO_DIM_ELEMENT('Y', 45.8680002, 57.7859992, 1)
    ),
    8307
);


select
    MIN(SDO_GEOM.SDO_MIN_MBR_ORDINATE(mb.stgeom.GET_SDO_GEOM(), 1)) as MinX,
    MAX(SDO_GEOM.SDO_MAX_MBR_ORDINATE(mb.stgeom.GET_SDO_GEOM(), 1)) as MaxX,
    MIN(SDO_GEOM.SDO_MIN_MBR_ORDINATE(mb.stgeom.GET_SDO_GEOM(), 2)) as MinY,
    MAX(SDO_GEOM.SDO_MAX_MBR_ORDINATE(mb.stgeom.GET_SDO_GEOM(), 2)) as MaxY
FROM myst_country_boundaries mb;
--       MINX       MAXX       MINY       MAXY
-- ---------- ---------- ---------- ----------
--  12,603676  26,369824    45,8464    58,0213

INSERT INTO USER_SDO_GEOM_METADATA
VALUES (
    'myst_country_boundaries',
    'stgeom',
    MDSYS.SDO_DIM_ARRAY(
        MDSYS.SDO_DIM_ELEMENT('X', 12.603676, 26.369824, 1),
        MDSYS.SDO_DIM_ELEMENT('Y', 45.8464, 58.0213, 1)
    ),
    8307
);


SELECT * FROM USER_SDO_GEOM_METADATA;



--05 C
CREATE INDEX myst_major_cities_stgeom_idx
ON myst_major_cities(stgeom)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;

CREATE INDEX myst_country_boundaries_stgeom_idx
ON myst_country_boundaries(stgeom)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;


--05 D
SELECT COUNT(*) as ILE
FROM myst_country_boundaries cb, myst_major_cities mc
WHERE cb.cntry_name = 'Poland'
    AND SDO_WITHIN_DISTANCE(cb.stgeom, mc.stgeom, 'distance=100 unit=km') = 'TRUE';
--        ILE
-- ----------
--         67


EXPLAIN PLAN FOR
SELECT COUNT(*) as ILE
FROM myst_country_boundaries cb, myst_major_cities mc
WHERE cb.cntry_name = 'Poland'
    AND SDO_WITHIN_DISTANCE(cb.stgeom, mc.stgeom, 'distance=100 unit=km') = 'TRUE';
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
-- Odp.: Niestety indeksy nie sa uzywane, nadal wykorzystywany jest pelen dostep do tabel.
-- 
-- Plan hash value: 1954295368
--  
-- -----------------------------------------------------------------------------------------------
-- | Id  | Operation           | Name                    | Rows  | Bytes | Cost (%CPU)| Time     |
-- -----------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT    |                         |     1 |  7680 |     8   (0)| 00:00:01 |
-- |   1 |  SORT AGGREGATE     |                         |     1 |  7680 |            |          |
-- |   2 |   NESTED LOOPS      |                         |     1 |  7680 |     8   (0)| 00:00:01 |
-- |*  3 |    TABLE ACCESS FULL| MYST_COUNTRY_BOUNDARIES |     1 |  3857 |     5   (0)| 00:00:01 |
-- |*  4 |    TABLE ACCESS FULL| MYST_MAJOR_CITIES       |     1 |  3823 |     3   (0)| 00:00:01 |
-- -----------------------------------------------------------------------------------------------
--  
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
--  
--    3 - filter("CB"."CNTRY_NAME"='Poland')
--    4 - filter("MDSYS"."SDO_WITHIN_DISTANCE"("CB"."STGEOM","MC"."STGEOM",'distance=100 
--               unit=km')='TRUE')
--  
-- Note
-- -----
--    - dynamic statistics used: dynamic sampling (level=2)