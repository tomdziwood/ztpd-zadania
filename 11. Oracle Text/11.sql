--01
CREATE TABLE cytaty AS SELECT * FROM ZSBD_TOOLS.cytaty;

SELECT * FROM cytaty;


--02
SELECT autor, tekst
FROM cytaty
WHERE UPPER(tekst) LIKE '%PESYMISTA%' AND
    UPPER(tekst) LIKE '%OPTYMISTA%';
-- AUTOR              TEKST
-- ------------------ ---------------------------------------------------------------------------------
-- Winston Churchill  Pesymista widzi trudnoœci w ka¿dej nadarzaj¹cej siê okazji, optymista widzi okazjê w ka¿dej trudnoœci.


--03
CREATE INDEX cytaty_idx ON cytaty(tekst)
INDEXTYPE IS CTXSYS.CONTEXT;


--04
SELECT autor, tekst
FROM cytaty
WHERE CONTAINS(tekst, 'pesymista and optymista') > 0;
-- AUTOR              TEKST
-- ------------------ ---------------------------------------------------------------------------------
-- Winston Churchill  Pesymista widzi trudnoœci w ka¿dej nadarzaj¹cej siê okazji, optymista widzi okazjê w ka¿dej trudnoœci.


--05
SELECT autor, tekst
FROM cytaty
WHERE CONTAINS(tekst, 'pesymista not optymista') > 0;
-- AUTOR              TEKST
-- ------------------ ---------------------------------------------------------------------------------
-- Oscar Wilde        Pesymista to ktoœ, kto postawiony przed wyborem jednego z dwojga z³ego – wybiera oba.


--06
SELECT autor, tekst
FROM cytaty
WHERE CONTAINS(tekst, 'near((pesymista, optymista), 3)') > 0;
-- no rows selected


--07
SELECT autor, tekst
FROM cytaty
WHERE CONTAINS(tekst, 'near((pesymista, optymista), 10)') > 0;
-- AUTOR              TEKST
-- ------------------ ---------------------------------------------------------------------------------
-- Winston Churchill  Pesymista widzi trudnoœci w ka¿dej nadarzaj¹cej siê okazji, optymista widzi okazjê w ka¿dej trudnoœci.


--08
SELECT autor, tekst
FROM cytaty
WHERE CONTAINS(tekst, '¯yci%') > 0;
-- AUTOR              TEKST
-- ------------------ ---------------------------------------------------------------------------------
-- Herodot            Ca³e nasze ¿ycie to dzia³anie i pasja. Unikaj¹c zaanga¿owania w dzia³ania i pasje naszych czasów, ryzykujemy, ¿e w ogóle nie zaznamy ¿ycia.
-- Arystoteles        Jesteœmy tym, co w swoim ¿yciu powtarzamy. Doskona³oœæ nie jest jednorazowym aktem, lecz nawykiem.
-- Benjamin Franklin  Kochasz ¿ycie? Nie trwoñ zatem swego czasu, poniewa¿ ono jest z niego utkane.
-- Konfucjusz         Wybierz sobie zawód, który lubisz, a ca³e ¿ycie nie bêdziesz musia³ pracowaæ.
-- Oscar Wilde        M³odym ludziom zdaje siê, ¿e pieni¹dze s¹ najwa¿niejsz¹ rzecz¹ w ¿yciu. Gdy siê zestarzej¹, s¹ ju¿ tego pewni.
-- Blaise Pascal      Ca³e ¿ycie ucieka na zwalczaniu jakichœ przeszkód. A kiedy tego dokonamy – spokój staje siê nie do zniesienia.


--09
SELECT autor, CONTAINS(tekst, '¯yci%') as DOPASOWANIE, tekst
FROM cytaty
WHERE CONTAINS(tekst, '¯yci%') > 0;
-- AUTOR              DOPASOWANIE  TEKST
-- ------------------ ------------ --------------------------------------------------------------------
-- Herodot            11           Ca³e nasze ¿ycie to dzia³anie i pasja. Unikaj¹c zaanga¿owania w dzia³ania i pasje naszych czasów, ryzykujemy, ¿e w ogóle nie zaznamy ¿ycia.
-- Arystoteles        6            Jesteœmy tym, co w swoim ¿yciu powtarzamy. Doskona³oœæ nie jest jednorazowym aktem, lecz nawykiem.
-- Benjamin Franklin  6            Kochasz ¿ycie? Nie trwoñ zatem swego czasu, poniewa¿ ono jest z niego utkane.
-- Konfucjusz         6            Wybierz sobie zawód, który lubisz, a ca³e ¿ycie nie bêdziesz musia³ pracowaæ.
-- Oscar Wilde        6            M³odym ludziom zdaje siê, ¿e pieni¹dze s¹ najwa¿niejsz¹ rzecz¹ w ¿yciu. Gdy siê zestarzej¹, s¹ ju¿ tego pewni.
-- Blaise Pascal      6            Ca³e ¿ycie ucieka na zwalczaniu jakichœ przeszkód. A kiedy tego dokonamy – spokój staje siê nie do zniesienia.


--09
SELECT autor, CONTAINS(tekst, '¯yci%') as DOPASOWANIE, tekst
FROM cytaty
WHERE CONTAINS(tekst, '¯yci%') > 0 AND
    rownum = 1
ORDER BY DOPASOWANIE DESC;
-- AUTOR              DOPASOWANIE  TEKST
-- ------------------ ------------ --------------------------------------------------------------------
-- Herodot            11           Ca³e nasze ¿ycie to dzia³anie i pasja. Unikaj¹c zaanga¿owania w dzia³ania i pasje naszych czasów, ryzykujemy, ¿e w ogóle nie zaznamy ¿ycia.


--11
SELECT autor, tekst
FROM cytaty
WHERE CONTAINS(tekst, 'fuzzy(probelm)') > 0;
-- AUTOR              TEKST
-- ------------------ --------------------------------------------------------------------------------
-- Paulo Coelho       Kiedy ju¿ rozwi¹¿esz jakiœ problem, przekonujesz siê, ¿e by³o to dziecinnie ³atwe.
-- Albert Einstein    Nie jestem bardzo bystry, po prostu d³ugo siedzê nad problemem.


--12
INSERT INTO cytaty(id, autor, tekst)
VALUES (39, 'Bertrand Russell', 'To smutne, ¿e g³upcy s¹ tacy pewni siebie, a ludzie rozs¹dni tacy pe³ni w¹tpliwoœci.');

commit;


--13
SELECT autor, tekst
FROM cytaty
WHERE CONTAINS(tekst, 'g³upcy') > 0;
-- no rows selected
-- Nowa wartosc do tabeli 'cytaty' zostala wstawiona, ale to jednak nie oznacza, Å¼e zaÅ‚oÅ¼ony indeks na tekÅ›cie siÄ™ zaktualizowaÅ‚.


--14
SELECT *
FROM DR$CYTATY_IDX$I;

SELECT *
FROM DR$CYTATY_IDX$I
WHERE TOKEN_TEXT LIKE 'G£UP%';
-- TOKEN_TEXT  TOKEN_TYPE  TOKEN_FIRST  TOKEN_LAST  TOKEN_COUNT  TOKEN_INFO
-- ----------- ----------- ------------ ----------- ------------ ----------
-- G£UPIEMU    0           38           38          1            (BLOB)


--15
DROP INDEX cytaty_idx;

CREATE INDEX cytaty_idx ON cytaty(tekst)
INDEXTYPE IS CTXSYS.CONTEXT;


--16
SELECT *
FROM DR$CYTATY_IDX$I
WHERE TOKEN_TEXT LIKE 'G£UP%';
-- TOKEN_TEXT  TOKEN_TYPE  TOKEN_FIRST  TOKEN_LAST  TOKEN_COUNT  TOKEN_INFO
-- ----------- ----------- ------------ ----------- ------------ ----------
-- G£UPCY      0           39           39          1            (BLOB)
-- G£UPIEMU    0           38           38          1            (BLOB)

SELECT autor, tekst
FROM cytaty
WHERE CONTAINS(tekst, 'g³upcy') > 0;
-- AUTOR              TEKST
-- ------------------ --------------------------------------------------------------------
-- Bertrand Russell   To smutne, ¿e g³upcy s¹ tacy pewni siebie, a ludzie rozs¹dni tacy pe³ni w¹tpliwoœci.


--17
DROP INDEX cytaty_idx;
DROP TABLE cytaty;



-- Zaawansowane indeksowanie i wyszukiwanie

--01
CREATE TABLE quotes AS SELECT * FROM ZSBD_TOOLS.quotes;


--02
CREATE INDEX quotes_idx ON quotes(text)
INDEXTYPE IS CTXSYS.CONTEXT;

--03
SELECT author, text
FROM quotes
WHERE CONTAINS(text, 'work') > 0;
-- AUTHOR             TEXT
-- ------------------ --------------------------------------------------------------------------------
-- Meir Lehman        An evolving system increases its complexity unless work is done to reduce it.
-- Mich Ravera        If it doesn't work, it doesn't matter how fast it doesn't work.

SELECT author, text
FROM quotes
WHERE CONTAINS(text, '$work') > 0;
-- AUTHOR             TEXT
-- ------------------ --------------------------------------------------------------------------------
-- John Ousterhout    The greatest performance improvement of all is when a system goes from not-working to working.
-- Meir Lehman        An evolving system increases its complexity unless work is done to reduce it.
-- Mich Ravera        If it doesn't work, it doesn't matter how fast it doesn't work.

SELECT author, text
FROM quotes
WHERE CONTAINS(text, 'working') > 0;
-- AUTHOR             TEXT
-- ------------------ --------------------------------------------------------------------------------
-- John Ousterhout    The greatest performance improvement of all is when a system goes from not-working to working.

SELECT author, text
FROM quotes
WHERE CONTAINS(text, '$working') > 0;
-- AUTHOR             TEXT
-- ------------------ --------------------------------------------------------------------------------
-- John Ousterhout    The greatest performance improvement of all is when a system goes from not-working to working.
-- Meir Lehman        An evolving system increases its complexity unless work is done to reduce it.
-- Mich Ravera        If it doesn't work, it doesn't matter how fast it doesn't work.


--04
SELECT author, text
FROM quotes
WHERE CONTAINS(text, 'it') > 0;
-- no rows selected
-- slowo 'it' musi nie byc indeksowane


--05
SELECT * FROM CTX_STOPLISTS;
-- SPL_OWNER  SPL_NAME            SPL_COUNT   SPL_TYPE                                                                                                                        
-- ---------- ------------------- ----------- -----------------------
-- CTXSYS     EMPTY_STOPLIST      0           BASIC_STOPLIST                                                                                                                  
-- CTXSYS     DEFAULT_STOPLIST    114         BASIC_STOPLIST                                                                                                                  
-- CTXSYS     EXTENDED_STOPLIST   0           BASIC_STOPLIST                                                                                                                  

-- Zdaje sie, ze system musial korzystac z domyslnej stoplisty 'DEFAULT_STOPLIST', przez co slowo 'it' nie zostalo zaindeksowane


--06
SELECT * FROM CTX_STOPWORDS;

SELECT * FROM CTX_STOPWORDS WHERE SPW_WORD='it';
-- SPW_OWNER  SPW_STOPLIST      SPW_TYPE    SPW_WORD  SPW_LANGUAGE  SPW_LANG_DEPENDENT  SPW_PATTERN
-- ---------- ----------------- ----------- --------- ------------- ------------------- -------------------
-- CTXSYS     DEFAULT_STOPLIST  STOP_WORD   it        (null)        Y                   (null)


--07
DROP INDEX quotes_idx;

CREATE INDEX quotes_idx ON quotes(text)
INDEXTYPE IS CTXSYS.CONTEXT
PARAMETERS ('stoplist CTXSYS.EMPTY_STOPLIST');


--08
SELECT author, text
FROM quotes
WHERE CONTAINS(text, 'it') > 0;
-- AUTHOR                 TEXT
-- ---------------------- --------------------------------------------------------------------------------
-- Bram Cohen             The mark of a mature programmer is willingness to throw out code you spent time on when you realize it's pointless.
-- Pamela Zave            The purpose of software engineering is to control complexity, not to create it.
-- Alan Cooper            The value of a prototype is in the education it gives you, not in the code itself.
-- Roedy Green            The longer it takes for a bug to surface, the harder it is to find.
-- Meir Lehman            An evolving system increases its complexity unless work is done to reduce it.
-- Ralph Johnson          Before software can be reusable it first has to be usable.
-- Atli Bjorgvin Oddsson  Don't document the problem, fix it.
-- Herb Sutter            It is far, far easier to make a correct program fast than it is to make a fast program correct.
-- Joe Zachary            If something seems wrong but you dismiss it, it will come back to haunt you at the worst possible time.
-- Dennis Ritchie         Unix is simple. It just takes a genius to understand its simplicity.
-- Bjarne Stroustrup      If you think it's simple, then you have misunderstood the problem.
-- Mich Ravera            If it doesn't work, it doesn't matter how fast it doesn't work.


--09
SELECT author, text
FROM quotes
WHERE CONTAINS(text, 'fool and humans') > 0;
-- AUTHOR           TEXT
-- ---------------- --------------------------------------------------------------------------------
-- Martin Fowler    Any fool can write code that a computer can understand. Good programmers write code that humans can understand.


--10
SELECT author, text
FROM quotes
WHERE CONTAINS(text, 'fool and computer') > 0;
-- AUTHOR           TEXT
-- ---------------- --------------------------------------------------------------------------------
-- Martin Fowler    Any fool can write code that a computer can understand. Good programmers write code that humans can understand.


--11
SELECT author, text
FROM quotes
WHERE CONTAINS(text, '(fool and humans) WITHIN SENTENCE') > 0;
-- ORA-29902: b³¹d podczas wykonywania podprogramu ODCIIndexStart()
-- ORA-20000: Oracle Text error:
-- DRG-10837: sekcja SENTENCE nie istnieje
-- 29902. 00000 -  "error in executing ODCIIndexStart() routine"
-- *Cause:    The execution of ODCIIndexStart routine caused an error.
-- *Action:   Examine the error messages produced by the indextype code and
--            take appropriate action
-- Wniosek - stworzony indeks nie jest przygotowany na przeszukiwanie rozpoznawajace zdania.


--12
DROP INDEX quotes_idx;


--13
begin
    ctx_ddl.create_section_group('nullgroup', 'NULL_SECTION_GROUP');
    ctx_ddl.add_special_section('nullgroup', 'SENTENCE');
    ctx_ddl.add_special_section('nullgroup', 'PARAGRAPH');
end;
/


--14
CREATE INDEX quotes_idx ON quotes(text)
INDEXTYPE IS CTXSYS.CONTEXT
PARAMETERS ('stoplist CTXSYS.EMPTY_STOPLIST
                section group nullgroup');


--15
SELECT author, text
FROM quotes
WHERE CONTAINS(text, '(fool and humans) WITHIN SENTENCE') > 0;
-- no rows selected

SELECT author, text
FROM quotes
WHERE CONTAINS(text, '(fool and computer) WITHIN SENTENCE') > 0;
-- AUTHOR           TEXT
-- ---------------- --------------------------------------------------------------------------------
-- Martin Fowler    Any fool can write code that a computer can understand. Good programmers write code that humans can understand.


--16
SELECT author, text
FROM quotes
WHERE CONTAINS(text, 'humans') > 0;
-- AUTHOR                 TEXT
-- ---------------------- --------------------------------------------------------------------------------
-- Martin Fowler          Any fool can write code that a computer can understand. Good programmers write code that humans can understand.
-- Marek Wojciechowski    I really needed one more quote concerning non-humans...
-- Jest te¿ wykryty tekst zawierajacy non-humans -> podczas indeksowania slowa non i humans musialy zostac rozbite i zaindeksowane osobno

--17
DROP INDEX quotes_idx;

begin
    ctx_ddl.create_preference('lex_z_m','BASIC_LEXER');
    ctx_ddl.set_attribute('lex_z_m', 'printjoins', '-');
    ctx_ddl.set_attribute ('lex_z_m', 'index_text', 'YES');
end;
/

CREATE INDEX quotes_idx ON quotes(text)
INDEXTYPE IS CTXSYS.CONTEXT
PARAMETERS ('stoplist CTXSYS.EMPTY_STOPLIST
                section group nullgroup
                LEXER lex_z_m');


--18
SELECT author, text
FROM quotes
WHERE CONTAINS(text, 'humans') > 0;
-- AUTHOR                 TEXT
-- ---------------------- --------------------------------------------------------------------------------
-- Martin Fowler          Any fool can write code that a computer can understand. Good programmers write code that humans can understand.


--19
SELECT author, text
FROM quotes
WHERE CONTAINS(text, 'non\-humans') > 0;
-- AUTHOR                 TEXT
-- ---------------------- --------------------------------------------------------------------------------
-- Marek Wojciechowski    I really needed one more quote concerning non-humans...


--20
begin
    ctx_ddl.drop_preference('lex_z_m');
end;
/

DROP INDEX quotes_idx;