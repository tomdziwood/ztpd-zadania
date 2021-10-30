--01
CREATE TABLE movies (
    id NUMBER(12) PRIMARY KEY,
    title VARCHAR2(400) NOT NULL,
    category VARCHAR2(50),
    year CHAR(4),
    cast VARCHAR2(4000),
    director VARCHAR2(4000),
    story VARCHAR2(4000),
    price NUMBER(5, 2),
    cover BLOB,
    mime_type VARCHAR2(50)
);

DESC movies;


--02
SELECT * FROM descriptions;
SELECT * FROM covers;

SELECT *
FROM descriptions d
    LEFT OUTER JOIN covers c ON d.id = c.movie_id;

DESC descriptions;


INSERT INTO movies
SELECT d.id, d.title, d.category, TRIM(d.year), d.cast, d.director, d.story, d.price, c.image, c.mime_type
FROM descriptions d
    LEFT OUTER JOIN covers c ON d.id = c.movie_id;

SELECT * FROM movies;


--03
SELECT id, title
FROM movies
WHERE cover IS NULL;


--04
SELECT id, title, DBMS_LOB.GETLENGTH(cover) AS filesize
FROM movies
WHERE cover IS NOT NULL;


--05
SELECT id, title, DBMS_LOB.GETLENGTH(cover) AS filesize
FROM movies
WHERE cover IS NULL;


--06
SELECT *
FROM all_directories;


--07
UPDATE movies
SET cover = EMPTY_BLOB(),
    mime_type = 'image/jpeg'
WHERE id = 66;


--08
SELECT id, title, DBMS_LOB.GETLENGTH(cover) AS filesize
FROM movies
WHERE id >= 65;


--09
DECLARE
    lobd blob;
    fils BFILE := BFILENAME('ZSBD_DIR','escape.jpg');
BEGIN
    
    SELECT cover INTO lobd
    FROM movies
    where id=66
    FOR UPDATE;
    
    DBMS_LOB.FILEOPEN(fils, DBMS_LOB.file_readonly);
    DBMS_LOB.LOADFROMFILE(lobd, fils, DBMS_LOB.GETLENGTH(fils));
    DBMS_LOB.FILECLOSE(fils);
    
    COMMIT;
END;
/


--10
CREATE TABLE temp_covers(
    movie_id NUMBER(12),
    image BFILE,
    mime_type VARCHAR2(50)
);


--11
INSERT INTO temp_covers
VALUES (65, BFILENAME('ZSBD_DIR','eagles.jpg'), 'image/jpeg');

COMMIT;


--12
SELECT movie_id, DBMS_LOB.GETLENGTH(image) AS filesize
FROM temp_covers;


--13
DECLARE
    image_bfile_var BFILE;
    mime_type_var VARCHAR2(50);
    blob_tmp_var BLOB;
BEGIN
    
    SELECT image, mime_type
    INTO image_bfile_var, mime_type_var
    FROM temp_covers
    WHERE movie_id=65;
    
    DBMS_LOB.CREATETEMPORARY(blob_tmp_var, TRUE);
    
    DBMS_LOB.fileopen(image_bfile_var, DBMS_LOB.file_readonly);
    DBMS_LOB.LOADFROMFILE(blob_tmp_var, image_bfile_var, DBMS_LOB.GETLENGTH(image_bfile_var));
    DBMS_LOB.FILECLOSE(image_bfile_var);
    
    UPDATE movies
    SET cover = blob_tmp_var,
        mime_type = mime_type_var
    WHERE id = 65;
    
    DBMS_LOB.FREETEMPORARY(blob_tmp_var);
    
    COMMIT;
END;
/


--14
SELECT id as movie_id, DBMS_LOB.GETLENGTH(cover) AS filesize
FROM movies
WHERE id >= 65;


--15
DROP TABLE movies;
DROP TABLE temp_covers;
COMMIT;