--01 A
CREATE TABLE figury (
    id NUMBER(1),
    ksztalt MDSYS.SDO_GEOMETRY
);

DESCRIBE figury;


--01 B
INSERT INTO figury
VALUES (
    1,
    MDSYS.SDO_GEOMETRY(
        2003,
        null,
        null,
        MDSYS.SDO_ELEM_INFO_ARRAY(1, 1003, 4),
        MDSYS.SDO_ORDINATE_ARRAY(3,5, 5,3, 7,5)
    )
);


INSERT INTO figury
VALUES (
    2,
    MDSYS.SDO_GEOMETRY(
        2003,
        null,
        null,
        MDSYS.SDO_ELEM_INFO_ARRAY(1, 1003, 3),
        MDSYS.SDO_ORDINATE_ARRAY(1,1, 5,5)
    )
);


INSERT INTO figury
VALUES (
    3,
    MDSYS.SDO_GEOMETRY(
        2002,
        null,
        null,
        MDSYS.SDO_ELEM_INFO_ARRAY(1,4,2, 1,2,1, 5,2,2),
        MDSYS.SDO_ORDINATE_ARRAY(3,2, 6,2, 7,3, 8,2, 7,1)
    )
);



--01 C
INSERT INTO figury
VALUES (
    4,
    MDSYS.SDO_GEOMETRY(
        2002,
        null,
        null,
        MDSYS.SDO_ELEM_INFO_ARRAY(1,4,2, 1,2,1, 7,2,2),
        MDSYS.SDO_ORDINATE_ARRAY(3,12, 6,12, 7,13, 8,12, 7,11)
    )
);



--01 D
SELECT f.id, SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(f.ksztalt, 0.01)
FROM figury f;



--01 E
DELETE FROM figury
WHERE ID IN (
    SELECT f.id
    FROM figury f
    WHERE SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(f.ksztalt, 0.01) NOT LIKE 'TRUE'
);



--01 F
COMMIT;