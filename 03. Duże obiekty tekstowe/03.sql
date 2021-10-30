-- aktywowanie wypisywania komunikatow w konsoli podczas procedur pl/sql
SET SERVEROUTPUT ON;

--01
CREATE TABLE dokumenty (
    id         NUMBER(12) PRIMARY KEY,
    dokument   CLOB
);

DESC dokumenty;


--02
DECLARE
    tekst CLOB;
BEGIN
    tekst := '';
    FOR lcntr IN 1..10000
    LOOP
        tekst := tekst || 'Oto tekst. ';
    END LOOP;

    INSERT INTO dokumenty
    VALUES (1, tekst);

END;
/


--03 a)
SELECT * FROM dokumenty;

--03 b)
SELECT id, upper(dokument)
FROM dokumenty;

--03 c)
SELECT id, length(dokument)
FROM dokumenty;

--03 d)
SELECT id, dbms_lob.getlength(dokument)
FROM dokumenty;

--03 e)
SELECT id, substr(dokument, 5, 1000)
FROM dokumenty;

--03 f)
SELECT id, dbms_lob.substr(dokument, 1000, 5)
FROM dokumenty;


--04
INSERT INTO dokumenty
VALUES (2, empty_clob());


--05
INSERT INTO dokumenty
VALUES (3, NULL);


--06
SELECT * FROM dokumenty;
--1	Oto tekst. Oto tekst. Oto tekst. Oto tekst. Oto tekst. Oto tekst. Oto te...
--2	
--3	(null)

SELECT id, upper(dokument)
FROM dokumenty;
--1	OTO TEKST. OTO TEKST. OTO TEKST. OTO TEKST. OTO TEKST. OTO TEKST. OTO TE...
--2	
--3	(null)

SELECT id, length(dokument)
FROM dokumenty;
--1	110000
--2	0
--3	(null)

SELECT id, dbms_lob.getlength(dokument)
FROM dokumenty;
--1	110000
--2	0
--3	(null)

SELECT id, substr(dokument, 5, 1000)
FROM dokumenty;
--1	tekst. Oto tekst. Oto tekst. Oto tekst. Oto tekst. Oto tekst. Oto tekst...
--2	
--3	(null)

SELECT id, dbms_lob.substr(dokument, 1000, 5)
FROM dokumenty;
--1	tekst. Oto tekst. Oto tekst. Oto tekst. Oto tekst. Oto tekst. Oto tekst...
--2	(null)
--3	(null)


--07
SELECT *
FROM all_directories;
--SYS	ZSBD_DIR	/u01/app/oracle/oradata/DBLAB02/dblab02_students/zsbd_dir	3


--08
DECLARE
    lobd CLOB;
    fils BFILE := bfilename('ZSBD_DIR', 'dokument.txt');
    doffset INTEGER := 1;
    soffset INTEGER := 1;
    langctx INTEGER := 0;
    warn INTEGER := NULL;
    
BEGIN
    SELECT dokument INTO lobd
    FROM dokumenty
    WHERE id = 2
    FOR UPDATE;

    dbms_lob.fileopen(fils, dbms_lob.file_readonly);
    dbms_lob.loadclobfromfile(lobd, fils, dbms_lob.getlength(fils), doffset, soffset, 873, langctx, warn);
    dbms_lob.fileclose(fils);
    
    COMMIT;
    
    dbms_output.put_line('Status operacji: ' || warn);
END;
/


--09
UPDATE dokumenty
SET dokument = TO_CLOB(bfilename('ZSBD_DIR', 'dokument.txt'), 873)
WHERE id = 3;


--10
SELECT * FROM dokumenty;
--1	Oto tekst. Oto tekst. Oto tekst. Oto tekst. Oto tekst. Oto tekst. Oto te...
--2	To jest testowy dokument. Zbyt ogromny na VARCHAR2. Odpowiedni dla niego...
--3	To jest testowy dokument. Zbyt ogromny na VARCHAR2. Odpowiedni dla niego...


--11
SELECT id, dbms_lob.getlength(dokument)
FROM dokumenty;
--1	110000
--2	558937
--3	558937


--12
DROP TABLE dokumenty;


--13
CREATE OR REPLACE PROCEDURE CLOB_CENSOR (
    text IN OUT CLOB,
    word VARCHAR2
) IS
    writing_offset INTEGER;
    searching_offset INTEGER;
    replacement VARCHAR2(32767);
    word_length INTEGER;
BEGIN
    word_length := LENGTH(word);

    FOR i IN 1..word_length
    LOOP
        replacement := replacement || '*';
    END LOOP;

    searching_offset := 1;
    writing_offset := DBMS_LOB.INSTR(text, word, searching_offset, 1);
    WHILE writing_offset != 0
    LOOP
        DBMS_LOB.WRITE(text, word_length, writing_offset, replacement);
    
        searching_offset := writing_offset + word_length;
        writing_offset := DBMS_LOB.INSTR(text, word, searching_offset, 1);
    END LOOP;
END;
/

--14
CREATE TABLE biographies_copy AS SELECT * FROM ZSBD_TOOLS.BIOGRAPHIES;

SELECT * FROM biographies_copy;

DECLARE
    clob_var CLOB;
BEGIN
    SELECT bio INTO clob_var FROM biographies_copy WHERE id = 1 FOR UPDATE;
    CLOB_CENSOR (clob_var, 'Cimrman');
END;
/

SELECT * FROM biographies_copy;


--15
DROP TABLE biographies_copy;