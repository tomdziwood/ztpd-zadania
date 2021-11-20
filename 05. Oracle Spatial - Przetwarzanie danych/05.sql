--01 A
INSERT INTO USER_SDO_GEOM_METADATA
VALUES (
'figury',
'ksztalt',
MDSYS.SDO_DIM_ARRAY(
    MDSYS.SDO_DIM_ELEMENT('X', 1, 8, 0.01),
    MDSYS.SDO_DIM_ELEMENT('Y', 1, 7, 0.01)
),
null
);

SELECT * FROM USER_SDO_GEOM_METADATA;


--01 B
SELECT SDO_TUNE.ESTIMATE_RTREE_INDEX_SIZE(3000000,8192,10,2,0) FROM DUAL;



--01 C
CREATE INDEX ksztalt_idx
ON figury(ksztalt)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;


--01 D
SELECT id
FROM figury
WHERE SDO_FILTER(ksztalt, SDO_GEOMETRY(2001, null, SDO_POINT_TYPE(3, 3, null), null, null)) = 'TRUE';
--         ID
-- ----------
--          3
--          2
--          1
--
-- Figury maja niby cos wspolnego z tym punktem, bo prostokat otaczajacy te figury faktycznie ma cos wspolnego z tym punktem.


--01 E
SELECT id
FROM figury
WHERE SDO_RELATE(
    ksztalt,
    SDO_GEOMETRY(2001, null, SDO_POINT_TYPE(3,3,null), null, null),
    'mask=ANYINTERACT') = 'TRUE';
-- Tak, rzeczywiscie tylko kwadrat ma cos wspolnego z punktem (3, 3).



--02 A
SELECT id, admin_name as miasto, SDO_NN_DISTANCE(1) as odl
FROM major_cities
WHERE SDO_NN(
    geom,
    (SELECT geom FROM major_cities WHERE admin_name LIKE 'Warszawa' and ROWNUM = 1),
    'sdo_num_res=10 unit=km',
    1
) = 'TRUE'
    AND
admin_name NOT LIKE 'Warszawa'
ORDER BY odl;
--         ID MIASTO                                            ODL
-- ---------- ------------------------------------------ ----------
--         40 Skierniewice                               67,5124503
--         28 Ciechanow                                  75,6596515
--         37 Siedlce                                    87,0433225
--         47 Radom                                      94,9927374
--         31 Plock                                      95,8482844
--         26 Ostroleka                                  100,253135
--         43 Lodz                                       117,555194
--         22 Lomza                                      125,950215
--         46 Piotrkow                                   130,163989


--02 B
SELECT id, admin_name as miasto
FROM major_cities
WHERE SDO_WITHIN_DISTANCE(
    geom,
    (SELECT geom FROM major_cities WHERE city_name LIKE 'Warsaw' and ROWNUM = 1),
    'distance=100 unit=km') = 'TRUE'
    AND
admin_name NOT LIKE 'Warszawa';
--         ID MIASTO                                    
-- ---------- ------------------------------------------
--         47 Radom                                     
--         37 Siedlce                                   
--         31 Plock                                     
--         40 Skierniewice                              
--         28 Ciechanow


--02 C
SELECT cntry_name as KRAJ, city_name as MIASTO
FROM major_cities
WHERE SDO_RELATE(
    (SELECT geom FROM country_boundaries WHERE cntry_name LIKE 'Slovakia'),
    geom,
    'mask=contains+coveredby') = 'TRUE'
ORDER BY MIASTO;
-- KRAJ                                     MIASTO                                  
-- ---------------------------------------- ----------------------------------------
-- Slovakia                                 Banska Bystrica                         
-- Slovakia                                 Bratislava                              
-- Slovakia                                 Kosice


--02 D
SELECT id, cntry_name as PANSTWO,
    SDO_GEOM.SDO_DISTANCE(
        (SELECT geom FROM country_boundaries WHERE cntry_name LIKE 'Poland'),
        geom,
        1,
        'unit=km') as ODL
FROM country_boundaries
WHERE SDO_RELATE(
    (SELECT geom FROM country_boundaries WHERE cntry_name LIKE 'Poland'),
    geom,
    'mask=anyinteract') = 'FALSE'
ORDER BY ODL;
--         ID PANSTWO                                         ODL
-- ---------- ---------------------------------------- ----------
--         13 Hungary                                  77,7709089
--          6 Denmark                                  95,2735305
--         17 Romania                                  101,673496
--         14 Austria                                  143,550326
--          3 Sweden                                   154,434436
--          4 Latvia                                   191,637527
--         16 Serbia                                   334,474141
--         15 Slovenia                                  344,57186
--         18 Croatia                                  369,176676
--          2 Estonia                                  392,517272
--         19 Italy                                    453,048617


--03 A
SELECT id, cntry_name,
    SDO_GEOM.SDO_LENGTH(
        SDO_GEOM.SDO_INTERSECTION(
            (SELECT geom FROM country_boundaries WHERE cntry_name LIKE 'Poland'),
            geom,
            1),
        1,
        'unit=km') as ODLEGLOSC
FROM country_boundaries
WHERE SDO_RELATE(
    (SELECT geom FROM country_boundaries WHERE cntry_name LIKE 'Poland'),
    geom,
    'mask=touch') = 'TRUE'
ORDER BY ODLEGLOSC;
--         ID CNTRY_NAME                                ODLEGLOSC
-- ---------- ---------------------------------------- ----------
--          5 Lithuania                                81,5177571
--          1 Russia                                   197,207816
--          7 Byelarus                                 322,347642
--         12 Slovakia                                  374,43977
--         11 Germany                                  376,071787
--         10 Ukraine                                  391,361617
--          9 Czech Republic                           524,572827


--03 B
SELECT cntry_name
FROM country_boundaries
ORDER BY SDO_GEOM.SDO_AREA(geom, 1, 'unit=SQ_KM') DESC
FETCH FIRST 1 ROWS ONLY;
-- CNTRY_NAME                              
-- ----------------------------------------
-- Poland


--03 C
SELECT SDO_GEOM.SDO_AREA(
    SDO_GEOM.SDO_MBR(
        SDO_GEOM.SDO_UNION(
            (SELECT geom FROM major_cities WHERE admin_name LIKE 'Warszawa'),
            (SELECT geom FROM major_cities WHERE admin_name LIKE 'Lodz'),
            1
        )
    ),
    1,
    'unit=SQ_KM'
) as SQ_KM
FROM dual;
--      SQ_KM
-- ----------
-- 5478,85784


--03 D
SELECT (tmp_tab.unia.GET_DIMS() || tmp_tab.unia.GET_LRS_DIM() || '0' || tmp_tab.unia.GET_GTYPE()) as GTYPE
FROM (
    SELECT SDO_GEOM.SDO_UNION(
        (SELECT geom FROM country_boundaries WHERE cntry_name LIKE 'Poland'),
        (SELECT geom FROM major_cities WHERE city_name LIKE 'Prague'),
        1
    ) AS unia
    FROM dual
) tmp_tab;
-- GTYPE                                                                                                                    
-- -------------------------------------------------------------------------------------------------------------------------
-- 2004


--03 E
SELECT city_name, cntry_name
FROM (
    SELECT cb.cntry_name, mc.city_name,
        SDO_GEOM.SDO_DISTANCE(
            SDO_GEOM.SDO_CENTROID(cb.geom, 1),
            mc.geom,
            1,
            'unit=km'
        ) AS ODL
    FROM country_boundaries cb
        JOIN major_cities mc ON SDO_RELATE(
            cb.geom,
            mc.geom,
            'mask=anyinteract'
        ) = 'TRUE'
    ORDER BY ODL)
WHERE ROWNUM = 1;
-- CITY_NAME                                CNTRY_NAME                              
-- ---------------------------------------- ----------------------------------------
-- Riga                                     Latvia 


--03 F
SELECT tmp_tab.name, sum(tmp_tab.dlugosc) as dlugosc
FROM
    (SELECT name,
        SDO_GEOM.SDO_LENGTH(
            SDO_GEOM.SDO_INTERSECTION(
                (SELECT geom FROM country_boundaries WHERE cntry_name LIKE 'Poland'),
                geom,
                1),
            1,
            'unit=km'
        ) AS dlugosc
    FROM rivers
    WHERE SDO_RELATE(
        (SELECT geom FROM country_boundaries WHERE cntry_name LIKE 'Poland'),
        geom,
        'mask=ANYINTERACT') = 'TRUE') tmp_tab
GROUP BY name
ORDER BY dlugosc DESC;
-- NAME                              DLUGOSC
-- ------------------------------ ----------
-- Vistula                        889,708495
-- Odra                           486,588345
-- San                            281,470861
-- Bug                             216,03788
-- Nogat                           43,417527
-- Oder                           41,3857369
-- Morava                         4,22518082
-- Oder-Havel-Kanal                        0