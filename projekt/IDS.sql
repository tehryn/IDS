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

ALTER SESSION SET NLS_DATE_FORMAT = 'dd.mm.yyyy, hh24:mi';

CREATE TABLE Zamestnanec ( /**/
  Id           INTEGER PRIMARY KEY,
  prac_pozice VARCHAR(32) NOT NULL,
  jmeno       VARCHAR(64) NOT NULL,
  rod_cislo   INTEGER     NOT NULL,
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
  ID         INTEGER  PRIMARY KEY,
  datum      DATE     NOT NULL,
  zaloha     INTEGER,
  suma       INTEGER  NOT NULL,
  objednavka INTEGER
);

INSERT INTO Zamestnanec VALUES (
    01, 'kuchar', 'Ladislav Hrusticka', 6611111166 , '+420 565 535 879', 1234567890100, 15000
);
INSERT INTO Zamestnanec VALUES (
    02, 'cisnik', 'Ursula Jablickova', 8012241811, '+420 603 214 715', 7359658920100, 12000
);
INSERT INTO Zamestnanec VALUES (
    03, 'barman', 'Igor Tresnicka', 9302291666, '+420 725 735 615', 6782135480200, 14500
);

INSERT INTO Stul VALUES (
  1, 'Zaharada', 6
);
INSERT INTO Stul VALUES (
  2, 'Kuracky sal', 8
);
INSERT INTO Stul VALUES (
  3, 'Nekuracky sal', 4
);

INSERT INTO Rezervace VALUES (
  0, '01.01.2017, 10:30', 'Filip Kachnicka', '603 305 452', NULL , NULL , 01
);
INSERT INTO Rezervace VALUES (
  1, '04.01.2017, 12:00', 'Alexandr Maly', '714 413 725', NULL , NULL , 01
);
INSERT INTO Rezervace VALUES (
  2, '04.01.2017, 12:00', 'Firma s.r.o', '603 305 452', 'Dagmar Styrska' , 'dgstyrska@suznam.org' , 02
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

/*
COMMIT;
SELECT * FROM Zamestnanec;
SELECT * FROM Rezervace;
SELECT * FROM Objednavka;
SELECT * FROM Stul;
SELECT * FROM Uctenka;
SELECT * FROM Potravina;
SELECT * FROM Surovina;
SELECT * FROM PObsahujeS;
SELECT * FROM RObsahujeS;
SELECT * FROM OObsahujeP;
*/