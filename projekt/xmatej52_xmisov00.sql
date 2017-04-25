DROP TABLE Zamestnanec CASCADE CONSTRAINTS;
DROP TABLE Rezervace   CASCADE CONSTRAINTS;
DROP TABLE Objednavka  CASCADE CONSTRAINTS;
DROP TABLE Potravina   CASCADE CONSTRAINTS;
DROP TABLE Stul        CASCADE CONSTRAINTS;
DROP TABLE Surovina    CASCADE CONSTRAINTS;
DROP TABLE OObsahujeP  CASCADE CONSTRAINTS;
DROP TABLE PObsahujeS  CASCADE CONSTRAINTS;
DROP TABLE RObsahujeS  CASCADE CONSTRAINTS;
DROP TABLE Uctenka     CASCADE CONSTRAINTS;

DROP SEQUENCE Zamestnanec_seq;

ALTER SESSION SET NLS_DATE_FORMAT = 'dd.mm.yyyy, hh24:mi';

CREATE TABLE Zamestnanec ( /**/
  ID          INTEGER PRIMARY KEY,
  prac_pozice VARCHAR(32) NOT NULL,
  jmeno       VARCHAR(64) NOT NULL,
  rod_cislo   INTEGER NOT NULL,
  kontakt     VARCHAR(128),
  cislo_uctu  INTEGER,
  plat        INTEGER     NOT NULL
);

CREATE TABLE Rezervace ( /**/
  ID          INTEGER PRIMARY KEY,
  cas         DATE         NOT NULL,
  jmeno_obj   VARCHAR(64)  NOT NULL,
  kontakt_obj VARCHAR(128) NOT NULL,
  jmeno_zak   VARCHAR(64),
  kontakt_zak VARCHAR(128),
  ID_zam      INTEGER      NOT NULL REFERENCES Zamestnanec(ID)
);

CREATE TABLE Stul ( /**/
  cislo       INTEGER PRIMARY KEY,
  lokace      VARCHAR(32),
  pocet_zidli INTEGER
);

CREATE TABLE RObsahujeS (
  id_rezervace INTEGER NOT NULL REFERENCES Rezervace(ID),
  cislo_stolu  INTEGER NOT NULL REFERENCES Stul(cislo)
);

CREATE TABLE Objednavka ( /**/
  ID              INTEGER PRIMARY KEY,
  cas             DATE NOT NULL,
  poznamka        VARCHAR(512)
);

CREATE TABLE Potravina ( /**/
  jmeno          VARCHAR(128) PRIMARY KEY,
  druh           VARCHAR(32) NOT NULL,
  doba_pripravy  INTEGER,
  popis_pripravy VARCHAR(2048),
  cena           FLOAT NOT NULL,
  prodano_kusu   INTEGER NOT NULL,
  talir          VARCHAR(32),
  sklenice       VARCHAR(32)
);

CREATE TABLE OObsahujeP ( /**/
  ID     INTEGER       NOT NULL  REFERENCES Objednavka(ID),
  jmeno  VARCHAR(128)  NOT NULL  REFERENCES Potravina(jmeno),
  mnozstvi INTEGER     NOT NULL
);

CREATE TABLE Surovina ( /**/
  jmeno VARCHAR(128) PRIMARY KEY,
  alergeny VARCHAR(64)
);

CREATE TABLE PObsahujeS ( /**/
  jmenoP VARCHAR(128) NOT NULL REFERENCES Potravina(jmeno),
  jmenoS VARCHAR(128) NOT NULL REFERENCES Surovina(jmeno),
  mnozstvi INTEGER NOT NULL
);

CREATE TABLE Uctenka (
  ID         INTEGER PRIMARY KEY,
  datum      DATE     NOT NULL,
  zaloha     INTEGER,
  suma       INTEGER  NOT NULL,
  objednavka INTEGER
);
--------------------------------------------------------------------------------
-- PROCEDURY
-- procedura ktera zjisti kolik zadany zamestnanec vytvoril rezervaci, vysledek je v %
CREATE OR REPLACE PROCEDURE procento_vytvorenych_rezervaci(id_zamestnance IN NUMBER)
is
  cursor nova_data is SELECT * FROM Rezervace;
  radek nova_data%ROWTYPE;
  pocet_vyt NUMBER;
  pocet_rez NUMBER;
  jmeno_zam Zamestnanec.jmeno%TYPE;
BEGIN
  pocet_vyt := 0;
  SELECT count(*) INTO pocet_rez FROM Rezervace;
  SELECT jmeno INTO jmeno_zam FROM Zamestnanec WHERE ID = id_zamestnance;
  OPEN nova_data;
  LOOP
    FETCH nova_data INTO radek;
    EXIT WHEN nova_data%NOTFOUND;
    IF (radek.ID_zam = id_zamestnance) THEN
      pocet_vyt := pocet_vyt + 1;
    END IF;
  END LOOP;
  dbms_output.put_line('Jmeno zamestnance: ' || jmeno_zam || ', Procento vytvorenych rezervaci: ' || (pocet_vyt * 100)/pocet_rez || '%');
EXCEPTION
  WHEN ZERO_DIVIDE THEN
    dbms_output.put_line('Jmeno zamestnance: ' || jmeno_zam || ', Procento vytvorenych rezervaci: 0%');
  WHEN OTHERS THEN
    Raise_Application_Error(-20002, 'Neznama chyba');
END;
/
-- procedura ktera zjisti pocet zidli v danne lokaci
CREATE OR REPLACE PROCEDURE pocet_zidli(id_lokace IN VARCHAR)
is
  cursor nova_data is SELECT * FROM Stul;
  radek nova_data%ROWTYPE;
  celkovy_pocet NUMBER;
BEGIN
  celkovy_pocet := 0;
  OPEN nova_data;
  LOOP
    FETCH nova_data INTO radek;
    EXIT WHEN nova_data%NOTFOUND;
    IF (radek.lokace = id_lokace) THEN
      celkovy_pocet := celkovy_pocet + radek.pocet_zidli;
    END IF;
  END LOOP;
  dbms_output.put_line('Lokace: ' || id_lokace || ', Pocet zidli: ' || celkovy_pocet);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20002, 'Neznama chyba');
END;
/
--------------------------------------------------------------------------------
-- TRIGGERY
-- TRIGGER generujici ID
CREATE SEQUENCE Zamestnanec_seq START WITH 1;
CREATE OR REPLACE TRIGGER Zamestnanec_tri_ID
BEFORE INSERT ON Zamestnanec
FOR EACH ROW
BEGIN
  SELECT Zamestnanec_seq.NEXTVAL
  INTO   :new.ID
  FROM   dual;
END Zamestnanec_tri_ID;
/
-- TRIGGER kontrolujici rodne cislo
CREATE OR REPLACE TRIGGER Zamestnanec_tri_rod_cislo
	BEFORE INSERT OR UPDATE OF rod_cislo ON Zamestnanec
--  REFERENCING NEW AS row
	FOR EACH ROW
WHEN (MOD (new.rod_cislo, 11) != 0)
BEGIN
    RAISE_APPLICATION_ERROR(-20001,'Spatne rodne cislo');
END Zamestnanec_tri_rod_cislo;
/
--------------------------------------------------------------------------------
-- OPRAVNENI
GRANT ALL ON Zamestnanec TO xmisov00;
GRANT ALL ON Rezervace TO xmisov00;
GRANT ALL ON Objednavka TO xmisov00;
GRANT ALL ON Potravina TO xmisov00;
GRANT ALL ON Stul TO xmisov00;
GRANT ALL ON Surovina TO xmisov00;
GRANT ALL ON OObsahujeP TO xmisov00;
GRANT ALL ON PObsahujeS TO xmisov00;
GRANT ALL ON RObsahujeS TO xmisov00;
GRANT ALL ON Uctenka TO xmisov00;

GRANT EXECUTE ON pocet_zidli TO xmisov00;
GRANT EXECUTE ON procento_vytvorenych_rezervaci TO xmisov00;

--------------------------------------------------------------------------------
-- ZKUSEBNI DATA
-- (U 4. zamestnance je chybne rodne cislo - trigger detekuje chybu)
INSERT INTO Zamestnanec VALUES (
    1, 'kuchar', 'Ladislav Hrusticka', 9911124839 , '+420 565 535 879', 1234567890100, 15000
);
INSERT INTO Zamestnanec VALUES (
    2, 'cisnik', 'Ursula Jablickova', 9062250010, '+420 603 214 715', 7359658920100, 12000
);
INSERT INTO Zamestnanec VALUES (
    3, 'barman', 'Igor Tresnicka', 9004250013, '+420 725 735 615', 6782135480200, 14500
);

-- spatne rodne cislo
INSERT INTO Zamestnanec VALUES (
    4, 'barman', 'Borys Brambora', 930789632, '+420 725 112 145', 6256641256200, 16000
);

INSERT INTO Stul VALUES (
  1, 'Zahrada', 6
);
INSERT INTO Stul VALUES (
  2, 'Kuracky sal', 8
);
INSERT INTO Stul VALUES (
  3, 'Nekuracky sal', 4
);
INSERT INTO Stul VALUES (
  4, 'Zahrada', 4
);

INSERT INTO Rezervace VALUES (
  0, '01.01.2017, 10:30', 'Filip Kachnicka', '603 305 452', NULL , NULL , 1
);
INSERT INTO Rezervace VALUES (
  1, '04.01.2017, 12:00', 'Alexandr Maly', '714 413 725', NULL , NULL , 1
);
INSERT INTO Rezervace VALUES (
  2, '04.01.2017, 12:00', 'Firma s.r.o', '603 305 452', 'Dagmar Styrska' , 'dgstyrska@suznam.org' , 2
);

INSERT INTO RObsahujeS VALUES (
  0, 1
);
INSERT INTO RObsahujeS VALUES (
  1, 1
);
INSERT INTO RObsahujeS VALUES (
  2, 2
);
INSERT INTO RObsahujeS VALUES (
  2, 3
);

INSERT INTO Potravina VALUES (
    'Veprovy steak', 'Veprove', 90, 'Hodit flakotu masa na panev a osmazit', 90, 0, 'Melky talir', NULL
);
INSERT INTO Potravina VALUES (
    'Pivo', 'Alkohol', NULL, NULL, 25, 0, NULL, 'Pullitr'
);
INSERT INTO Potravina VALUES (
    'Malinovka', 'Nealko', NULL, NULL, 15, 0, NULL, 'Tretinka'
);
INSERT INTO Potravina VALUES (
    'Mleko', 'Nealko', NULL, NULL, 15, 0, NULL, 'Tretinka'
);

INSERT INTO Surovina VALUES (
    'Malinova limonada', NULL
);
INSERT INTO Surovina VALUES (
    'veprova krkovice', NULL
);
INSERT INTO Surovina VALUES (
    'Plzen 12', NULL
);
INSERT INTO Surovina VALUES (
    'mleko', '7' /* muze byt i 7, 1, ...*/
);

INSERT INTO PObsahujeS VALUES (
    'Veprovy steak', 'veprova krkovice', 200 /*gram*/
);
INSERT INTO PObsahujeS VALUES (
    'Pivo', 'Plzen 12', 5 /*deci*/
);
INSERT INTO PObsahujeS VALUES (
    'Malinovka', 'Malinova limonada', 3 /*deci*/
);
INSERT INTO PObsahujeS VALUES (
    'Mleko', 'mleko', 3 /*deci*/
);
INSERT INTO Objednavka VALUES (
    0, '01.01.2017, 10:00', NULL
);
INSERT INTO Objednavka VALUES (
    1, '01.01.2017, 12:00', 'Placeno stravenkou'
);
INSERT INTO Objednavka VALUES (
    2, '01.01.2017, 12:30', 'Pochvalen kuchar'
);

INSERT INTO OObsahujeP VALUES (
    0, 'Veprovy steak', 1
);
INSERT INTO OObsahujeP VALUES (
    0, 'Pivo', 2
);
INSERT INTO OObsahujeP VALUES (
    1, 'Veprovy steak', 1
);
INSERT INTO OObsahujeP VALUES (
    2, 'Veprovy steak', 2
);
INSERT INTO OObsahujeP VALUES (
    2, 'Pivo', 6
);

INSERT INTO Uctenka VALUES (
    0, '01.01.2017, 11:56', NULL, 140, 0
);
INSERT INTO Uctenka VALUES (
    1, '01.01.2017, 13:15', NULL, 90, 1
);

INSERT INTO Uctenka VALUES (
    2, '01.01.2017, 12:02', NULL, 40, 2 /* platba zalohy*/
);
INSERT INTO Uctenka VALUES (
    3, '01.01.2017, 15:47', 40, 330, 2
);
COMMIT;

-------------------------------------------------------------------------------
-- UKAZKA FUNKCNOSTI PROCEDUR

set serveroutput ON;
-- neexistujici zamestnanes - vyvolani chyby
exec procento_vytvorenzch_rezrvaci(0);

-- pocet rezervaci, ktere vytvorili v %
exec procento_vytvorenych_rezervaci(1);
exec procento_vytvorenych_rezervaci(2);

-- a ted deleni nulou
exec procento_vytvorenych_rezervaci(3);

-- pocet zidli v zahrade
exec pocet_zidli('Zahrada');

--------------------------------------------------------------------------------
-- SELECT
-- Vypise pracovni pozice a jaky je nejvyssi plat na danne pracovni pozici
SELECT Z.prac_pozice, max(Z.plat)
FROM Zamestnanec Z GROUP BY Z.prac_pozice;

-- Pocet zamestnancu na pracovnich pozicich.
SELECT Z.prac_pozice, count(Z.prac_pozice)
FROM Zamestnanec Z GROUP BY Z.prac_pozice;
-- GROUP splneno

-- Vypise cisla stolu ktere byly rezervovany, v case kdy jsou rezervovane,
-- kdo rezervaci vytvoril a kdo si rezervaci objednal.
Select ROS.cislo_stolu, R.cas, Z.jmeno, R.jmeno_obj
FROM Zamestnanec Z, Rezervace R, RObsahujeS ROS
WHERE Z.ID = R.ID_zam AND ROS.id_rezervace = R.ID;
-- Group a slouceni tri tabulek splneno

-- Vypise suroviny, ktere obsahuji alergeny a obsazene alergeny
SELECT S1.jmeno, S1.alergeny FROM Surovina S1
WHERE EXISTS (
  SELECT S2.alergeny FROM Surovina S2
  where S2.jmeno = S1.jmeno and S1.alergeny IS NOT NULL
);
-- Exists, group a slouceni 3 tabulek splneno

-- Vypise potraviny, ktere byly objednany 1.1. 2017 dopoledne
SELECT OOP.jmeno FROM OObsahujeP OOP
WHERE OOP.ID IN (
  SELECT O.ID FROM Objednavka O
  WHERE O.cas BETWEEN '01.01.2017, 00:00' AND '01.01.2017, 12:00'
) GROUP BY OOP.jmeno;
-- IN, exists, group a slouceni 3 tabulek splneno

-- Vypise potraviny (ne suroviny) obsahujici alergeny a danne alergeny
Select POS.jmenoP, S.alergeny
FROM Surovina S, PObsahujeS POS
Where POS.jmenoS = S.jmeno AND S.alergeny IS NOT NULL;

-- Vypise ID rezervace, jeji cas a jmeno zamestnance, ktery ji vytvoril
SELECT R.ID, R.cas, Z.jmeno
FROM Zamestnanec Z, Rezervace R
WHERE Z.ID = R.ID_ZAM;
-- IN, exists, group a slouceni 2 a 3 tabulek splneno