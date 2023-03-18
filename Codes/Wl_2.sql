
CREATE TABLE seus (
  id INTEGER,
  ciutat CHAR(40)
  ) PCTFREE 0 ENABLE ROW MOVEMENT;
-- Id Ès clau candidata

CREATE TABLE departaments (		
  id INTEGER,
  nom CHAR(200),
  seu INTEGER,
  tasques CHAR(2000))
 PCTFREE 0 ENABLE ROW MOVEMENT;
 
--PRIMARY KEY(id)) ORGANIZATION
--INDEX PCTFREE 33;
-- Id Ès clau candidata

CREATE TABLE empleats (		
  id INTEGER, 
  nom CHAR(20), 
  sou INTEGER,
  edat INTEGER,
  dpt INTEGER, 
  historial CHAR(50))
 PCTFREE 0 ENABLE ROW MOVEMENT;

-- Id Ès clau candidata

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de seus
INSERT INTO seus (id, ciutat) VALUES (1, 'BARCELONA');
INSERT INTO seus (id, ciutat) VALUES (2, 'GIRONA');
INSERT INTO seus (id, ciutat) VALUES (3, 'ZARAGOZA');
INSERT INTO seus (id, ciutat) VALUES (4, 'MADRID');
INSERT INTO seus (id, ciutat) VALUES (5, 'GRANADA');
INSERT INTO seus (id, ciutat) VALUES (6, 'PARIS');
INSERT INTO seus (id, ciutat) VALUES (7, 'LONDRES');
INSERT INTO seus (id, ciutat) VALUES (8, 'FRANKFURT');
INSERT INTO seus (id, ciutat) VALUES (9, 'LIMA');
INSERT INTO seus (id, ciutat) VALUES (10, 'TOKIO');


-- Insercions de departaments
FOR i IN 1..1100 LOOP
  INSERT INTO departaments (id, nom, seu, tasques) VALUES (i,
    LPAD(dbms_random.string('U',10),200,'*'),
    dbms_random.value(1,10),
LPAD(dbms_random.string('U',10),2000,'*')
    );
  END LOOP;

-- Insercions d'empleats
FOR i IN 1..(120000) LOOP
  INSERT INTO empleats (id, nom, sou, edat, dpt, historial) VALUES (
    i,
    LPAD(dbms_random.string('U',10),20,'*'),
    dbms_random.value(15000,50000),
    dbms_random.value(19,64),
    dbms_random.value(1,900),
    LPAD(dbms_random.string('U',10),50,'*')
    );
  END LOOP;
END;

ALTER TABLE empleats SHRINK SPACE;

ALTER TABLE departaments SHRINK SPACE;

ALTER TABLE departaments MINIMIZE RECORDS_PER_BLOCK;
CREATE BITMAP INDEX Bit_seu ON departaments (seu) PCTFREE 0;
CREATE BITMAP INDEX Bit_id ON departaments (id) PCTFREE 0;
CREATE BITMAP INDEX Bit_nom ON departaments (nom) PCTFREE 0;

ALTER TABLE empleats MINIMIZE RECORDS_PER_BLOCK;
CREATE BITMAP INDEX Bit_dpt ON empleats (dpt) PCTFREE 0;

ALTER TABLE empleats SHRINK SPACE;
CREATE INDEX BTR_edat ON empleats (edat) PCTFREE 33;

--CREATE  INDEX Btr_id ON departaments (id) PCTFREE 33;
--CREATE  INDEX Btr_nom ON departaments (nom) PCTFREE 33;


--ALTER TABLE departaments SHRINK SPACE;
ALTER TABLE seus SHRINK SPACE;

---------------------------------- Update Statistics ----------------------------
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES;
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

select TABLE_NAME, NUM_ROWS, AVG_ROW_LEN from USER_TABLES;

SELECT * FROM empleats e, departaments d WHERE e.dpt = d.id AND sou > 30000;
SELECT AVG(sou) FROM empleats WHERE edat > 35;
SELECT COUNT(*) FROM empleats WHERE dpt = 4;
SELECT * FROM departaments WHERE seu = 2 AND nom > 'CMP';
select * from USER_SEGMENTS;


---------------------------- To check the real costs -------------------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT);
DECLARE 

i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
i4 INTEGER;
r INTEGER;
BEGIN
select value INTO i0
from v$statname c, v$sesstat a
where a.statistic# = c.statistic#
  and sys_context('USERENV','SID') = a.sid
  and c.name in ('consistent gets');
  
SELECT MAX(LENGTH(e.id||e.nom||e.sou||e.edat||e.dpt||e.historial||d.id||d.nom||d.seu||d.tasques)) INTO r FROM empleats e, departaments d  WHERE e.dpt = d.id AND sou > 30000;

select value INTO i1
from v$statname c, v$sesstat a
where a.statistic# = c.statistic#
  and sys_context('USERENV','SID') = a.sid
  and c.name in ('consistent gets');

SELECT AVG(sou) INTO r FROM empleats WHERE edat > 35;

select value INTO i2
from v$statname c, v$sesstat a
where a.statistic# = c.statistic#
  and sys_context('USERENV','SID') = a.sid
  and c.name in ('consistent gets');

SELECT COUNT(*) INTO r FROM empleats WHERE dpt = 4;

select value INTO i3
from v$statname c, v$sesstat a
where a.statistic# = c.statistic#
  and sys_context('USERENV','SID') = a.sid
  and c.name in ('consistent gets');

SELECT MAX(LENGTH(id||nom||seu||tasques)) INTO r FROM departaments WHERE seu=2 AND nom > 'CMP';

select value INTO i4
from v$statname c, v$sesstat a
where a.statistic# = c.statistic#
  and sys_context('USERENV','SID') = a.sid
  and c.name in ('consistent gets');

INSERT INTO measure (id,weight,i,f) VALUES (1,0.25,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.25,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.25,i2,i3);
INSERT INTO measure (id,weight,i,f) VALUES (4,0.25,i3,i4);
END;

SELECT SUM((f-i)*weight) FROM measure;
DROP TABLE measure PURGE;

