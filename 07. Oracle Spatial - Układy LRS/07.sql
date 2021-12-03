--01 A
CREATE TABLE A6_LRS (
    geom MDSYS.SDO_GEOMETRY
);


--01 B
INSERT INTO A6_LRS (geom)
VALUES (
    (SELECT geom
    FROM STREETS_AND_RAILROADS
    WHERE SDO_WITHIN_DISTANCE(
        geom,
        (SELECT geom FROM major_cities WHERE city_name LIKE 'Koszalin' and ROWNUM = 1),
        'distance=10 unit=km') = 'TRUE')
);


--01 C
SELECT
    SDO_GEOM.SDO_LENGTH(
        geom,
        1,
        'unit=km') as DISTANCE,
    ST_LINESTRING(geom).ST_NUMPOINTS() AS ST_NUMPOINTS
FROM A6_LRS;
--   DISTANCE ST_NUMPOINTS
-- ---------- ------------
-- 276,681315           22


--01 D
UPDATE A6_LRS
SET geom = SDO_LRS.CONVERT_TO_LRS_GEOM(geom, 0, 276.681315);


--01 E
select
    SDO_GEOM.SDO_MIN_MBR_ORDINATE(SDO_LRS.CONVERT_TO_STD_GEOM(geom), 1) as MinX,
    SDO_GEOM.SDO_MAX_MBR_ORDINATE(SDO_LRS.CONVERT_TO_STD_GEOM(geom), 1) as MaxX,
    SDO_GEOM.SDO_MIN_MBR_ORDINATE(SDO_LRS.CONVERT_TO_STD_GEOM(geom), 2) as MinY,
    SDO_GEOM.SDO_MAX_MBR_ORDINATE(SDO_LRS.CONVERT_TO_STD_GEOM(geom), 2) as MaxY
FROM A6_LRS;
--       MINX       MAXX       MINY       MAXY
-- ---------- ---------- ---------- ----------
--   14,87555       18,5   53,60957   54,62064

INSERT INTO USER_SDO_GEOM_METADATA VALUES (
    'A6_LRS',
    'GEOM',
    MDSYS.SDO_DIM_ARRAY(
        MDSYS.SDO_DIM_ELEMENT('X', 14.8, 19, 1),
        MDSYS.SDO_DIM_ELEMENT('Y', 53.5, 54.7, 1),
        MDSYS.SDO_DIM_ELEMENT('M', 0, 300, 1)
    ),
    8307
);


--01 F
CREATE INDEX lrs_routes_idx
ON A6_LRS(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX;



--02 A
SELECT
    SDO_LRS.VALID_MEASURE(geom, 500) AS VALID_500
FROM A6_LRS;
-- VALID_500
-- ---------
-- FALSE


--02 B
SELECT
    SDO_LRS.GEOM_SEGMENT_END_PT(geom) AS END_PT
FROM A6_LRS;
-- END_PT                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SDO_GEOMETRY(3301, 8307, NULL, SDO_ELEM_INFO_ARRAY(1, 1, 1), SDO_ORDINATE_ARRAY(14,87555, 53,60957, 276,681315))


--02 C
SELECT SDO_LRS.LOCATE_PT(geom, 150, 0) KM150
FROM A6_LRS;
-- MDSYS.SDO_GEOMETRY(3301, 8307, NULL, MDSYS.SDO_ELEM_INFO_ARRAY(1, 1, 1), MDSYS.SDO_ORDINATE_ARRAY(16.4179659033392, 54.2502361808013, 150))


--02 D
SELECT SDO_LRS.CLIP_GEOM_SEGMENT(geom, 120, 160) AS CLIPED
FROM A6_LRS;
-- MDSYS.SDO_GEOMETRY(3302, 8307, NULL, MDSYS.SDO_ELEM_INFO_ARRAY(1, 2, 1), MDSYS.SDO_ORDINATE_ARRAY(16.8000409698085, 54.4010316656192, 120, 16.62392, 54.329121, 133.968914803805, 16.422119, 54.25161, 149.689093897222, 16.2845330230411, 54.2059725567263, 160))


--02 E
SELECT
    SDO_LRS.GET_NEXT_SHAPE_PT(
        geom,
        SDO_LRS.PROJECT_PT(
            geom,
            (SELECT geom FROM major_cities WHERE city_name = 'Slupsk')
        )
    ) as wjazd_na_a6
from A6_LRS;
-- MDSYS.SDO_GEOMETRY(3301, 8307, NULL, MDSYS.SDO_ELEM_INFO_ARRAY(1, 1, 1), MDSYS.SDO_ORDINATE_ARRAY(16.98226, 54.474899, 105.598697563842))


--02 F
select
    SDO_LRS.GEOM_SEGMENT_LENGTH(
        SDO_LRS.OFFSET_GEOM_SEGMENT(
            geom,
            (
                select m.DIMINFO
                from   USER_SDO_GEOM_METADATA m
                where  m.TABLE_NAME = 'A6_LRS'
                    and m.COLUMN_NAME = 'GEOM'
                    and ROWNUM = 1
            ),
            50,
            200,
            50,
            'unit=m arc_tolerance=1'
        )
    ) / 1000 AS koszt
from A6_LRS;
--      KOSZT
-- ----------
-- 150,011727