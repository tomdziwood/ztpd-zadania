--01
CREATE TYPE samochod AS OBJECT (
    marka            VARCHAR2(20),
    model            VARCHAR2(20),
    kilometry        NUMBER,
    data_produkcji   DATE,
    cena             NUMBER(10,2)
);

DESC samochod;

CREATE TABLE samochody OF samochod;

INSERT INTO samochody VALUES
(NEW samochod('FIAT', 'BRAVA', 60000, '1999-11-20', 25000));

INSERT INTO samochody VALUES
(NEW samochod('FORD', 'MONDEO', 80000, '1997-05-10', 45000));

INSERT INTO samochody VALUES
(NEW samochod('MAZDA', '323', 12000, '2000-09-22', 52000));

select * from samochody;



--02
CREATE TABLE wlasciciele (
    imie       VARCHAR2(100),
    nazwisko   VARCHAR2(100),
    auto       samochod
);

DESC wlasciciele;

INSERT INTO wlasciciele VALUES
('JAN', 'KOWALSKI', NEW samochod('FIAT', 'SEICENTO', 30000, '0010-12-02', 19500));

INSERT INTO wlasciciele VALUES
('ADAM', 'NOWAK', NEW samochod('OPEL', 'ASTRA', 34000, '0009-06-01', 33700));

SELECT * FROM wlasciciele;



--03
ALTER TYPE samochod REPLACE AS OBJECT (
    marka VARCHAR2(20),
    model VARCHAR2(20),
    kilometry NUMBER,
    data_produkcji DATE,
    cena NUMBER(10, 2),
    MEMBER FUNCTION wartosc RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY samochod AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
    BEGIN
        RETURN cena * POWER(0.9, EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM data_produkcji));
    END wartosc;
END;

SELECT s.marka, s.cena, s.wartosc() FROM SAMOCHODY s;



--04
ALTER TYPE samochod ADD MAP MEMBER FUNCTION odwzoruj
RETURN NUMBER CASCADE INCLUDING TABLE DATA;

CREATE OR REPLACE TYPE BODY samochod AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
    BEGIN
        RETURN cena * POWER(0.9, EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM data_produkcji));
    END wartosc;
    
    MAP MEMBER FUNCTION odwzoruj RETURN NUMBER IS
    BEGIN
        RETURN FLOOR(kilometry/10000) + EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM data_produkcji);
    END odwzoruj;
END;

SELECT * FROM SAMOCHODY s ORDER BY VALUE(s);



--05
CREATE TYPE wlasciciel AS OBJECT (
    imie VARCHAR2(100),
    nazwisko VARCHAR2(100)
);

DESC wlasciciel;

ALTER TYPE samochod ADD ATTRIBUTE posiadacz REF wlasciciel CASCADE;

desc samochod;

CREATE TABLE wlasciciel_table OF wlasciciel;

INSERT INTO wlasciciel_table VALUES
(NEW wlasciciel('Adam', 'Bialy'));

INSERT INTO wlasciciel_table VALUES
(NEW wlasciciel('Barbara', 'Czarna'));

INSERT INTO wlasciciel_table VALUES
(NEW wlasciciel('Cezary', 'Cezary'));

UPDATE samochody
SET posiadacz = (
    SELECT ref(w)
    FROM wlasciciel_table w
    WHERE imie = 'Cezary'
)
WHERE marka = 'FIAT';

SELECT * FROM SAMOCHODY;



--06
SET SERVEROUTPUT ON;

DECLARE
    TYPE t_przedmioty IS
        VARRAY(10) OF VARCHAR2(20);
    moje_przedmioty t_przedmioty := t_przedmioty('');
BEGIN
    moje_przedmioty(1) := 'MATEMATYKA';
    moje_przedmioty.extend(9);
    FOR i IN 2..10 LOOP
        moje_przedmioty(i) := 'PRZEDMIOT_' || i;
    END LOOP;

    FOR i IN moje_przedmioty.first()..moje_przedmioty.last() LOOP
        dbms_output.put_line(moje_przedmioty(i));
    END LOOP;

    moje_przedmioty.trim(2);
    FOR i IN moje_przedmioty.first()..moje_przedmioty.last() LOOP
        dbms_output.put_line(moje_przedmioty(i));
    END LOOP;
    dbms_output.put_line('Limit: ' || moje_przedmioty.limit());
    dbms_output.put_line('Liczba elementow: ' || moje_przedmioty.count());
    
    moje_przedmioty.extend();
    moje_przedmioty(9) := 9;
    dbms_output.put_line('Limit: ' || moje_przedmioty.limit());
    dbms_output.put_line('Liczba elementow: ' || moje_przedmioty.count());
    
    moje_przedmioty.DELETE();
    dbms_output.put_line('Limit: ' || moje_przedmioty.limit());
    dbms_output.put_line('Liczba elementow: ' || moje_przedmioty.count());
END;
/



--07
DECLARE
    TYPE t_ksiazki IS
        VARRAY(10) OF VARCHAR2(100);
    moje_ksiazki t_ksiazki := t_ksiazki();
BEGIN
    moje_ksiazki.extend(3);
    moje_ksiazki(1) := 'Harry Potter i Kamien Filozoficzny';
    moje_ksiazki(2) := 'Harry Potter i Komnata Tajemnic';
    moje_ksiazki(3) := 'Harry Potter i wiezien Azkabanu';
    moje_ksiazki.extend(6);
    FOR i IN 4..7 LOOP
        moje_ksiazki(i) := 'Harry Potter ' || i;
    END LOOP;

    FOR i IN moje_ksiazki.first()..moje_ksiazki.last() LOOP
        dbms_output.put_line(moje_ksiazki(i));
    END LOOP;

    moje_ksiazki.trim(3);
    FOR i IN moje_ksiazki.first()..moje_ksiazki.last() LOOP
        dbms_output.put_line(moje_ksiazki(i));
    END LOOP;
    dbms_output.put_line('Limit: ' || moje_ksiazki.limit());
    dbms_output.put_line('Liczba elementow: ' || moje_ksiazki.count());
    
    moje_ksiazki.extend();
    moje_ksiazki(7) := 'Harry Potter i Insygnia œmierci';
    dbms_output.put_line('Limit: ' || moje_ksiazki.limit());
    dbms_output.put_line('Liczba elementow: ' || moje_ksiazki.count());
    
    moje_ksiazki.DELETE();
    dbms_output.put_line('Limit: ' || moje_ksiazki.limit());
    dbms_output.put_line('Liczba elementow: ' || moje_ksiazki.count());
END;
/



--08
DECLARE
    TYPE t_wykladowcy IS
        TABLE OF VARCHAR2(20);
    moi_wykladowcy t_wykladowcy := t_wykladowcy();
BEGIN
    moi_wykladowcy.extend(2);
    moi_wykladowcy(1) := 'MORZY';
    moi_wykladowcy(2) := 'WOJCIECHOWSKI';
    moi_wykladowcy.extend(8);
    FOR i IN 3..10 LOOP
        moi_wykladowcy(i) := 'WYKLADOWCA_' || i;
    END LOOP;

    FOR i IN moi_wykladowcy.first()..moi_wykladowcy.last() LOOP
        dbms_output.put_line(moi_wykladowcy(i));
    END LOOP;

    moi_wykladowcy.trim(2);
    FOR i IN moi_wykladowcy.first()..moi_wykladowcy.last() LOOP
        dbms_output.put_line(moi_wykladowcy(i));
    END LOOP;

    moi_wykladowcy.DELETE(5, 7);
    dbms_output.put_line('Limit: ' || moi_wykladowcy.limit());
    dbms_output.put_line('Liczba elementow: ' || moi_wykladowcy.count());
    FOR i IN moi_wykladowcy.first()..moi_wykladowcy.last() LOOP
        IF moi_wykladowcy.EXISTS(i) THEN
            dbms_output.put_line(moi_wykladowcy(i));
        END IF;
    END LOOP;

    moi_wykladowcy(5) := 'ZAKRZEWICZ';
    moi_wykladowcy(6) := 'KROLIKOWSKI';
    moi_wykladowcy(7) := 'KOSZLAJDA';
    FOR i IN moi_wykladowcy.first()..moi_wykladowcy.last() LOOP
        IF moi_wykladowcy.EXISTS(i) THEN
            dbms_output.put_line(moi_wykladowcy(i));
        END IF;
    END LOOP;

    dbms_output.put_line('Limit: ' || moi_wykladowcy.limit());
    dbms_output.put_line('Liczba elementow: ' || moi_wykladowcy.count());
END;
/



--09
DECLARE
    TYPE t_miesiace IS
        TABLE OF VARCHAR2(20);
    moje_miesiace t_miesiace := t_miesiace();
BEGIN
    moje_miesiace.extend(12);
    moje_miesiace(1) := 'Styczen';
    moje_miesiace(2) := 'Luty';
    moje_miesiace(3) := 'Marzec';
    moje_miesiace(4) := 'Kwiecien';
    moje_miesiace(5) := 'Maj';
    moje_miesiace(6) := 'Czerwiec';
    moje_miesiace(7) := 'July';
    moje_miesiace(8) := 'August';
    moje_miesiace(9) := 'Wrzesien';
    moje_miesiace(10) := 'October';
    moje_miesiace(11) := 'November';
    moje_miesiace(12) := 'December';

    FOR i IN moje_miesiace.first()..moje_miesiace.last() LOOP
        dbms_output.put_line(moje_miesiace(i));
    END LOOP;
    dbms_output.put_line('Liczba elementow: ' || moje_miesiace.count());

    moje_miesiace.trim(3);
    FOR i IN moje_miesiace.first()..moje_miesiace.last() LOOP
        dbms_output.put_line(moje_miesiace(i));
    END LOOP;
    dbms_output.put_line('Liczba elementow: ' || moje_miesiace.count());

    moje_miesiace.DELETE(7, 8);
    FOR i IN moje_miesiace.first()..moje_miesiace.last() LOOP
        IF moje_miesiace.EXISTS(i) THEN
            dbms_output.put_line(moje_miesiace(i));
        END IF;
    END LOOP;
    dbms_output.put_line('Liczba elementow: ' || moje_miesiace.count());

    moje_miesiace(7) := 'Lipiec';
    moje_miesiace(8) := 'Sierpien';
    FOR i IN moje_miesiace.first()..moje_miesiace.last() LOOP
        IF moje_miesiace.EXISTS(i) THEN
            dbms_output.put_line(moje_miesiace(i));
        END IF;
    END LOOP;
    dbms_output.put_line('Liczba elementow: ' || moje_miesiace.count());
END;
/



--10
CREATE TYPE jezyki_obce AS
    VARRAY ( 10 ) OF VARCHAR2(20);
/

CREATE TYPE stypendium AS OBJECT (
    nazwa    VARCHAR2(50),
    kraj     VARCHAR2(30),
    jezyki   jezyki_obce
);
/

CREATE TABLE stypendia OF stypendium;

INSERT INTO stypendia VALUES (
    'SOKRATES',
    'FRANCJA',
    jezyki_obce('ANGIELSKI','FRANCUSKI','NIEMIECKI')
);

INSERT INTO stypendia VALUES (
    'ERASMUS',
    'NIEMCY',
    jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI')
);

SELECT *
FROM stypendia;

SELECT s.jezyki
FROM stypendia s;

UPDATE stypendia
SET jezyki = jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI','FRANCUSKI')
WHERE nazwa = 'ERASMUS';

CREATE TYPE lista_egzaminow AS
    TABLE OF VARCHAR2(20);
/

CREATE TYPE semestr AS OBJECT (
    numer      NUMBER,
    egzaminy   lista_egzaminow
);
/

CREATE TABLE semestry OF semestr
NESTED TABLE egzaminy STORE AS tab_egzaminy;

INSERT INTO semestry VALUES ( semestr(1,lista_egzaminow('MATEMATYKA','LOGIKA','ALGEBRA') ) );

INSERT INTO semestry VALUES ( semestr(2,lista_egzaminow('BAZY DANYCH','SYSTEMY OPERACYJNE') ) );

SELECT s.numer, e.*
FROM semestry s, TABLE ( s.egzaminy ) e;

SELECT e.*
FROM semestry s, TABLE ( s.egzaminy ) e;

SELECT *
FROM TABLE (
    SELECT s.egzaminy
    FROM semestry s
    WHERE numer = 1
);

INSERT INTO TABLE (
    SELECT s.egzaminy
    FROM semestry s
    WHERE numer = 2
) VALUES ( 'METODY NUMERYCZNE' );

UPDATE TABLE (
    SELECT s.egzaminy
    FROM semestry s
    WHERE numer = 2
) e
SET e.column_value = 'SYSTEMY ROZPROSZONE'
WHERE e.column_value = 'SYSTEMY OPERACYJNE';

DELETE FROM TABLE (
    SELECT s.egzaminy
    FROM semestry s
    WHERE numer = 2
) e
WHERE e.column_value = 'BAZY DANYCH';



--11
CREATE TYPE koszyk_produktow AS
    TABLE OF VARCHAR2(20);
/

CREATE TYPE zakup AS OBJECT (
    id         NUMBER,
    produkty   koszyk_produktow
);
/

CREATE TABLE zakupy OF zakup
NESTED TABLE produkty STORE AS tab_produkty;

INSERT INTO zakupy VALUES ( zakup(1,koszyk_produktow('MASLO','MAKARON','JOGURT') ) );
INSERT INTO zakupy VALUES ( zakup(2,koszyk_produktow('SZYNKA', 'MASLO', 'CHLEB', 'JAJKA') ) );
INSERT INTO zakupy VALUES ( zakup(4,koszyk_produktow('PIWO', 'PIELUSZKI', 'COLA', 'JOGURT') ) );

SELECT * FROM zakupy;

SELECT z.id, p.*
FROM zakupy z, TABLE ( z.produkty ) p;

SELECT z.id
FROM zakupy z, TABLE ( z.produkty ) p
WHERE p.column_value = 'JOGURT';

DELETE FROM zakupy z
WHERE z.id IN (
    SELECT z.id
    FROM zakupy z, TABLE ( z.produkty ) p
    WHERE p.column_value = 'JOGURT'
);



--12
CREATE TYPE instrument AS OBJECT (
    nazwa    VARCHAR2(20),
    dzwiek   VARCHAR2(20),

MEMBER FUNCTION graj RETURN VARCHAR2
) NOT FINAL;

CREATE TYPE BODY instrument AS
    MEMBER FUNCTION graj RETURN VARCHAR2
        IS
    BEGIN
        RETURN dzwiek;
    END;

END;
/

CREATE TYPE instrument_dety UNDER instrument (
    material   VARCHAR2(20),

OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2,

MEMBER FUNCTION graj (
        glosnosc VARCHAR2
    ) RETURN VARCHAR2
);

CREATE OR REPLACE TYPE BODY instrument_dety AS OVERRIDING
    MEMBER FUNCTION graj RETURN VARCHAR2
        IS
    BEGIN
        RETURN 'dmucham: '
        || dzwiek;
    END;

    MEMBER FUNCTION graj (
        glosnosc VARCHAR2
    ) RETURN VARCHAR2
        IS
    BEGIN
        RETURN glosnosc
        || ': '
        || dzwiek;
    END;

END;
/

CREATE TYPE instrument_klawiszowy UNDER instrument (
    producent   VARCHAR2(20),

OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2
);

CREATE OR REPLACE TYPE BODY instrument_klawiszowy AS OVERRIDING
    MEMBER FUNCTION graj RETURN VARCHAR2
        IS
    BEGIN
        RETURN 'stukam w klawisze: '
        || dzwiek;
    END;

END;
/

DECLARE
    tamburyn    instrument := instrument('tamburyn','brzdek-brzdek');
    trabka      instrument_dety := instrument_dety('trabka','tra-ta-ta','metalowa');
    fortepian   instrument_klawiszowy := instrument_klawiszowy('fortepian','ping-ping','steinway');
BEGIN
    dbms_output.put_line(tamburyn.graj);
    dbms_output.put_line(trabka.graj);
    dbms_output.put_line(trabka.graj('glosno'));
    dbms_output.put_line(fortepian.graj);
end;
/



--13
CREATE TYPE istota AS OBJECT (
    nazwa   VARCHAR2(20),

NOT INSTANTIABLE MEMBER FUNCTION poluj (
        ofiara CHAR
    ) RETURN CHAR
) NOT INSTANTIABLE NOT FINAL;

CREATE TYPE lew UNDER istota (
    liczba_nog   NUMBER,

OVERRIDING MEMBER FUNCTION poluj (
        ofiara CHAR
    ) RETURN CHAR
);

CREATE OR REPLACE TYPE BODY lew AS OVERRIDING
    MEMBER FUNCTION poluj (
        ofiara CHAR
    ) RETURN CHAR
        IS
    BEGIN
        RETURN 'upolowana ofiara: '
        || ofiara;
    END;

END;

DECLARE
    krollew      lew := lew('LEW',4);
    innaistota   istota := istota('JAKIES ZWIERZE'); -- no tak, nie mozna utworzyc instancji dla klasy abstrakcyjnej
BEGIN
    dbms_output.put_line(krollew.poluj('antylopa') );
END;



--14
DECLARE
    tamburyn   instrument;
    cymbalki   instrument;
    trabka     instrument_dety;
    saksofon   instrument_dety;
BEGIN
    tamburyn := instrument('tamburyn','brzdek-brzdek');
    cymbalki := instrument_dety('cymbalki','ding-ding','metalowe');
    trabka := instrument_dety('trabka','tra-ta-ta','metalowa');
    -- saksofon := instrument('saksofon','tra-taaaa');
    -- saksofon := TREAT(instrument('saksofon','tra-taaaa') AS instrument_dety);
END;



--15
CREATE TABLE instrumenty OF instrument;

INSERT INTO instrumenty VALUES ( instrument('tamburyn','brzdek-brzdek') );

INSERT INTO instrumenty VALUES ( instrument_dety('trabka','tra-ta-ta','metalowa') );

INSERT INTO instrumenty VALUES ( instrument_klawiszowy('fortepian','ping-ping','steinway') );

SELECT
    i.nazwa,
    i.graj()
FROM
    instrumenty i;



--16
CREATE TABLE przedmioty (
    nazwa        VARCHAR2(50),
    nauczyciel   NUMBER
        REFERENCES pracownicy ( id_prac )
);

INSERT INTO PRZEDMIOTY VALUES ('BAZY DANYCH',100);
INSERT INTO PRZEDMIOTY VALUES ('SYSTEMY OPERACYJNE',100);
INSERT INTO PRZEDMIOTY VALUES ('PROGRAMOWANIE',110);
INSERT INTO PRZEDMIOTY VALUES ('SIECI KOMPUTEROWE',110);
INSERT INTO PRZEDMIOTY VALUES ('BADANIA OPERACYJNE',120);
INSERT INTO PRZEDMIOTY VALUES ('GRAFIKA KOMPUTEROWA',120);
INSERT INTO PRZEDMIOTY VALUES ('BAZY DANYCH',130);
INSERT INTO PRZEDMIOTY VALUES ('SYSTEMY OPERACYJNE',140);
INSERT INTO PRZEDMIOTY VALUES ('PROGRAMOWANIE',140);
INSERT INTO PRZEDMIOTY VALUES ('SIECI KOMPUTEROWE',140);
INSERT INTO PRZEDMIOTY VALUES ('BADANIA OPERACYJNE',150);
INSERT INTO PRZEDMIOTY VALUES ('GRAFIKA KOMPUTEROWA',150);
INSERT INTO PRZEDMIOTY VALUES ('BAZY DANYCH',160);
INSERT INTO PRZEDMIOTY VALUES ('SYSTEMY OPERACYJNE',160);
INSERT INTO PRZEDMIOTY VALUES ('PROGRAMOWANIE',170);
INSERT INTO PRZEDMIOTY VALUES ('SIECI KOMPUTEROWE',180);
INSERT INTO PRZEDMIOTY VALUES ('BADANIA OPERACYJNE',180);
INSERT INTO PRZEDMIOTY VALUES ('GRAFIKA KOMPUTEROWA',190);
INSERT INTO PRZEDMIOTY VALUES ('GRAFIKA KOMPUTEROWA',200);
INSERT INTO PRZEDMIOTY VALUES ('GRAFIKA KOMPUTEROWA',210);
INSERT INTO PRZEDMIOTY VALUES ('PROGRAMOWANIE',220);
INSERT INTO PRZEDMIOTY VALUES ('SIECI KOMPUTEROWE',220);
INSERT INTO PRZEDMIOTY VALUES ('BADANIA OPERACYJNE',230);



--17
CREATE TYPE zespol AS OBJECT (
    id_zesp   NUMBER,
    nazwa     VARCHAR2(50),
    adres     VARCHAR2(100)
);
/



--18
CREATE OR REPLACE VIEW ZESPOLY_V OF ZESPOL
WITH OBJECT IDENTIFIER(ID_ZESP)
AS SELECT ID_ZESP, NAZWA, ADRES FROM ZESPOLY;



--19
CREATE TYPE przedmioty_tab AS
    TABLE OF VARCHAR2(100);
/

CREATE TYPE pracownik AS OBJECT (
    id_prac         NUMBER,
    nazwisko        VARCHAR2(30),
    etat            VARCHAR2(20),
    zatrudniony     DATE,
    placa_pod       NUMBER(10,2),
    miejsce_pracy   REF zespol,
    przedmioty      przedmioty_tab,

MEMBER FUNCTION ile_przedmiotow RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY pracownik AS
    MEMBER FUNCTION ile_przedmiotow RETURN NUMBER
        IS
    BEGIN
        RETURN przedmioty.count ();
    END ile_przedmiotow;

END;




--20
CREATE OR REPLACE VIEW PRACOWNICY_V OF PRACOWNIK
WITH OBJECT IDENTIFIER (ID_PRAC)
AS SELECT ID_PRAC, NAZWISKO, ETAT, ZATRUDNIONY, PLACA_POD,
MAKE_REF(ZESPOLY_V,ID_ZESP),
CAST(MULTISET( SELECT NAZWA FROM PRZEDMIOTY WHERE NAUCZYCIEL=P.ID_PRAC ) AS PRZEDMIOTY_TAB )
FROM PRACOWNICY P;



--21
SELECT *
FROM PRACOWNICY_V;

SELECT P.NAZWISKO, P.ETAT, P.MIEJSCE_PRACY.NAZWA
FROM PRACOWNICY_V P;

SELECT P.NAZWISKO, P.ILE_PRZEDMIOTOW()
FROM PRACOWNICY_V P;

SELECT *
FROM TABLE( SELECT PRZEDMIOTY FROM PRACOWNICY_V WHERE NAZWISKO='WEGLARZ' );

SELECT NAZWISKO, CURSOR( SELECT PRZEDMIOTY
FROM PRACOWNICY_V
WHERE ID_PRAC=P.ID_PRAC)
FROM PRACOWNICY_V P;



--22
CREATE TABLE pisarze (
    id_pisarza   NUMBER PRIMARY KEY,
    nazwisko     VARCHAR2(20),
    data_ur      DATE
);

CREATE TABLE ksiazki (
    id_ksiazki     NUMBER PRIMARY KEY,
    id_pisarza     NUMBER NOT NULL
        REFERENCES pisarze,
    tytul          VARCHAR2(50),
    data_wydania   DATE
);

INSERT INTO PISARZE VALUES(10,'SIENKIEWICZ',DATE '1880-01-01');
INSERT INTO PISARZE VALUES(20,'PRUS',DATE '1890-04-12');
INSERT INTO PISARZE VALUES(30,'ZEROMSKI',DATE '1899-09-11');
INSERT INTO KSIAZKI(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIA) VALUES(10,10,'OGNIEM I MIECZEM',DATE '1990-01-05');
INSERT INTO KSIAZKI(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIA) VALUES(20,10,'POTOP',DATE '1975-12-09');
INSERT INTO KSIAZKI(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIA) VALUES(30,10,'PAN WOLODYJOWSKI',DATE '1987-02-15');
INSERT INTO KSIAZKI(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIA) VALUES(40,20,'FARAON',DATE '1948-01-21');
INSERT INTO KSIAZKI(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIA) VALUES(50,20,'LALKA',DATE '1994-08-01');
INSERT INTO KSIAZKI(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIA) VALUES(60,30,'PRZEDWIOSNIE',DATE '1938-02-02');

CREATE TYPE ksiazki_tab AS
    TABLE OF VARCHAR2(50);
/

CREATE TYPE pisarz AS OBJECT (
    id_pisarza   NUMBER,
    nazwisko     VARCHAR2(20),
    data_ur      DATE,
    ksiazki      ksiazki_tab,

MEMBER FUNCTION ile_ksiazek RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY pisarz AS
    MEMBER FUNCTION ile_ksiazek RETURN NUMBER
        IS
    BEGIN
        RETURN ksiazki.count ();
    END ile_ksiazek;

END;

CREATE TYPE ksiazka AS OBJECT (
    id_ksiazki     NUMBER,
    tytul          VARCHAR2(50),
    data_wydania   DATE,
    ksiazki        ksiazki_tab,
    autor          REF pisarz,

MEMBER FUNCTION jaki_wiek RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY ksiazka AS
    MEMBER FUNCTION jaki_wiek RETURN NUMBER
        IS
    BEGIN
        RETURN extract ( YEAR FROM SYSDATE ) - extract ( YEAR FROM data_wydania );
    END jaki_wiek;

END;

CREATE OR REPLACE VIEW pisarze_v OF pisarz
WITH OBJECT IDENTIFIER (id_pisarza)
AS SELECT id_pisarza, nazwisko, data_ur,
CAST(MULTISET( SELECT tytul FROM ksiazki WHERE id_pisarza=p.id_pisarza ) AS ksiazki_tab )
FROM pisarze p;

CREATE OR REPLACE VIEW ksiazki_v OF ksiazka
WITH OBJECT IDENTIFIER (id_ksiazki)
AS SELECT id_ksiazki, MAKE_REF(pisarze_v, id_pisarza), tytul, data_wydania
FROM ksiazki;



--23
CREATE TYPE auto AS OBJECT (
    marka            VARCHAR2(20),
    model            VARCHAR2(20),
    kilometry        NUMBER,
    data_produkcji   DATE,
    cena             NUMBER(10,2),

MEMBER FUNCTION wartosc RETURN NUMBER
) NOT FINAL;

CREATE OR REPLACE TYPE BODY auto AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
        wiek      NUMBER;
        wartosc   NUMBER;
    BEGIN
        wiek := round(months_between(SYSDATE,data_produkcji) / 12);
        wartosc := cena - ( wiek * 0.1 * cena );
        IF
            ( wartosc < 0 )
        THEN
            wartosc := 0;
        END IF;
        RETURN wartosc;
    END wartosc;

END;

CREATE TABLE AUTA OF AUTO;

INSERT INTO AUTA VALUES (AUTO('FIAT','BRAVA',60000,DATE '1999-11-30',25000));
INSERT INTO AUTA VALUES (AUTO('FORD','MONDEO',80000,DATE '1997-05-10',45000));
INSERT INTO AUTA VALUES (AUTO('MAZDA','323',12000,DATE '2000-09-22',52000));

CREATE TYPE auto_osobowe UNDER auto (
    liczba_miejsc   NUMBER,
    klimatyzacja    VARCHAR2(3),

OVERRIDING MEMBER FUNCTION wartosc RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY auto_osobowe AS OVERRIDING
    MEMBER FUNCTION wartosc RETURN NUMBER IS
        wartosc   NUMBER;
    BEGIN
        wartosc := cena;
        IF
            ( klimatyzacja = 'tak' )
        THEN
            wartosc := wartosc * 1.5;
        END IF;
        RETURN wartosc;
    END wartosc;

END;
/

CREATE TYPE auto_ciezarowe UNDER auto (
    maksymalna_ladownosc   NUMBER,

OVERRIDING MEMBER FUNCTION wartosc RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY auto_ciezarowe AS OVERRIDING
    MEMBER FUNCTION wartosc RETURN NUMBER IS
        wartosc   NUMBER;
    BEGIN
        wartosc := cena;
        IF
            ( maksymalna_ladownosc > 10000 )
        THEN
            wartosc := wartosc * 2;
        END IF;
        RETURN wartosc;
    END wartosc;

END;
/

INSERT INTO AUTA VALUES (AUTO_OSOBOWE('OPEL','ASTRA',120000,DATE '2005-11-30',30000, 5, 'nie'));
INSERT INTO AUTA VALUES (AUTO_OSOBOWE('NISSAN','QASHQAI',8000,DATE '2015-11-30',95000, 5, 'tak'));
INSERT INTO AUTA VALUES (AUTO_CIEZAROWE('MAN','TGX',90000,DATE '2004-11-30',60000, 8000));
INSERT INTO AUTA VALUES (AUTO_CIEZAROWE('VOLVO','FL12',150000,DATE '2009-11-30',95000, 12000));

SELECT a.marka, a.wartosc() FROM auta a;
-- MARKA                A.WARTOSC()
-- -------------------- -----------
-- FIAT                           0
-- FORD                           0
-- MAZDA                          0
-- OPEL                       30000
-- NISSAN                    142500
-- MAN                        60000
-- VOLVO                     190000