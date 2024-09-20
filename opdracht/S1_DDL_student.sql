-- ------------------------------------------------------------------------
-- Data & Persistency
-- Opdracht S1: Data Definition Language
--
-- (c) 2020 Hogeschool Utrecht
-- Tijmen Muller (tijmen.muller@hu.nl)
-- André Donk (andre.donk@hu.nl)
--
--
-- Opdracht: schrijf SQL-queries om onderstaande resultaten op te vragen,
-- aan te maken, verwijderen of aan te passen in de database van de
-- bedrijfscasus.
--
-- Codeer je uitwerking onder de regel 'DROP VIEW ...' (bij een SELECT)
-- of boven de regel 'ON CONFLICT DO NOTHING;' (bij een INSERT)
-- Je kunt deze eigen query selecteren en los uitvoeren, en wijzigen tot
-- je tevreden bent.
--
-- Vervolgens kun je je uitwerkingen testen door de testregels
-- (met [TEST] erachter) te activeren (haal hiervoor de commentaartekens
-- weg) en vervolgens het hele bestand uit te voeren. Hiervoor moet je de
-- testsuite in de database hebben geladen (bedrijf_postgresql_test.sql).
-- NB: niet alle opdrachten hebben testregels.
--
-- Lever je werk pas in op Canvas als alle tests slagen. Draai daarna
-- alle wijzigingen in de database terug met de queries helemaal onderaan.
-- ------------------------------------------------------------------------


-- S1.1. Geslacht
--
-- Voeg een kolom `geslacht` toe aan de medewerkerstabel.
-- Voeg ook een beperkingsregel `m_geslacht_chk` toe aan deze kolom,
-- die ervoor zorgt dat alleen 'M' of 'V' als geldige waarde wordt
-- geaccepteerd. Test deze regel en neem de gegooide foutmelding op als
-- commentaar in de uitwerking.

--alter table medewerkers
--add column geslacht char(1) not null;
--alter table medewerkers
--    add constraint m_geslacht_chk check (geslacht in ('M', 'V'));
--[2024-09-13 19:26:18] [23502] ERROR: column "geslacht" of relation "medewerkers" contains null values
--[2024-09-13 19:26:18] [42703] ERROR: column "geslacht" does not exist
--Deze foutmeldingen kunnen opgelost worden door een default waarde toe te voegen, bv. geslacht char(1) default 'M'
alter table medewerkers
    add column geslacht char(1) not null default 'M';
alter table medewerkers
    add constraint m_geslacht_chk check (geslacht in ('M', 'V'));


-- S1.2. Nieuwe afdeling
--
-- Het bedrijf krijgt een nieuwe onderzoeksafdeling 'ONDERZOEK' in Zwolle.
-- Om de onderzoeksafdeling op te zetten en daarna te leiden wordt de
-- nieuwe medewerker A DONK aangenomen. Hij krijgt medewerkersnummer 8000
-- en valt direct onder de directeur.
-- Voeg de nieuwe afdeling en de nieuwe medewerker toe aan de database.

insert into afdelingen (anr, naam, locatie)
    values (50, 'ONDERZOEK', 'ZWOLLE');
insert into medewerkers (mnr, naam, voorl, chef, gbdatum, maandsal, afd)
    values (8000, 'DONK', 'A', 7839, date('1985-1-1'), 800.00, 50);
UPDATE afdelingen
    set hoofd = 8000 where anr = 50;



-- S1.3. Verbetering op afdelingentabel
--
-- We gaan een aantal verbeteringen doorvoeren aan de tabel `afdelingen`:
--   a) Maak een sequence die afdelingsnummers genereert. Denk aan de beperking
--      dat afdelingsnummers veelvouden van 10 zijn.
--   b) Voeg een aantal afdelingen toe aan de tabel, maak daarbij gebruik van
--      de nieuwe sequence.
--   c) Op enig moment gaat het mis. De betreffende kolommen zijn te klein voor
--      nummers van 3 cijfers. Los dit probleem op.
-- AI gebruikt om op de drop view s3_4 en create view s3_4 aan te komen
drop view s3_4;
alter table afdelingen
    alter
        column anr type numeric(3);
create sequence afdeling_seq
    start with 60 increment by 10;
insert into afdelingen (anr, naam, locatie, hoofd)
    values (nextval('afdeling_seq'), 'MANAGING', 'ZWOLLE', 7839);
insert into afdelingen (anr, naam, locatie, hoofd)
values (nextval('afdeling_seq'), 'MARKETING', 'ZWOLLE', 7839);
insert into afdelingen (anr, naam, locatie, hoofd)
values (nextval('afdeling_seq'), 'SALES', 'ZWOLLE', 7839);
insert into afdelingen (anr, naam, locatie, hoofd)
values (nextval('afdeling_seq'), 'FINANCE', 'ZWOLLE', 7839);
insert into afdelingen (anr, naam, locatie, hoofd)
values (nextval('afdeling_seq'), 'PRODUCTION', 'ZWOLLE', 7839);

drop sequence afdeling_seq;

-- S1.4. Adressen
--
-- Maak een tabel `adressen`, waarin de adressen van de medewerkers worden
-- opgeslagen (inclusief adreshistorie). De tabel bestaat uit onderstaande
-- kolommen. Voeg minimaal één rij met adresgegevens van A DONK toe.
--
--    postcode      PK, bestaande uit 6 karakters (4 cijfers en 2 letters)
--    huisnummer    PK
--    ingangsdatum  PK
--    einddatum     moet na de ingangsdatum liggen
--    telefoon      10 cijfers, uniek
--    med_mnr       FK, verplicht
create table adressen
(
    postcode char(6) not null,
    huisnummer numeric(4) not null,
    ingangsdatum date not null,
    einddatum date,
    telefoon char(10) not null,
    med_mnr numeric(4) not null,
    constraint adressen_pk primary key (postcode, huisnummer, ingangsdatum),
    constraint adressen_fk foreign key (med_mnr) references medewerkers (mnr),
    constraint adressen_postcode_chk check (postcode ~ '^[0-9]{4}[A-Z]{2}$'),
    constraint adressen_einddatum_chk check (einddatum > ingangsdatum),
    constraint adressen_telefoon_un unique (telefoon)
        );
insert into adressen (postcode, huisnummer, ingangsdatum, einddatum, telefoon, med_mnr)
values ('1234AB', 1, '2020-1-1', '2021-1-1', '0612345678', 8000);


-- S1.5. Commissie
--
-- De commissie van een medewerker (kolom `comm`) moet een bedrag bevatten als de medewerker een functie als
-- 'VERKOPER' heeft, anders moet de commissie NULL zijn. Schrijf hiervoor een beperkingsregel. Gebruik onderstaande
-- 'illegale' INSERTs om je beperkingsregel te controleren.
alter table medewerkers
    add constraint medewerkers_comm_chk check (
        (functie = 'VERKOPER' and comm is not null) or
        (functie != 'VERKOPER' and comm is null)
        );
--INSERT INTO medewerkers (mnr, naam, voorl, functie, chef, gbdatum, maandsal, comm)
--VALUES (8001, 'MULLER', 'TJ', 'TRAINER', 7566, '1982-08-18', 2000, 500);

--INSERT INTO medewerkers (mnr, naam, voorl, functie, chef, gbdatum, maandsal, comm)
--VALUES (8002, 'JANSEN', 'M', 'VERKOPER', 7698, '1981-07-17', 1000, NULL);
alter table medewerkers
    drop constraint medewerkers_comm_chk;



-- -------------------------[ HU TESTRAAMWERK ]--------------------------------
-- Met onderstaande query kun je je code testen. Zie bovenaan dit bestand
-- voor uitleg.

SELECT * FROM test_exists('S1.1', 1) AS resultaat
UNION
SELECT * FROM test_exists('S1.2', 1) AS resultaat
UNION
SELECT 'S1.3 wordt niet getest: geen test mogelijk.' AS resultaat
UNION
SELECT * FROM test_exists('S1.4', 6) AS resultaat
UNION
SELECT 'S1.5 wordt niet getest: handmatige test beschikbaar.' AS resultaat
ORDER BY resultaat;


-- Draai alle wijzigingen terug om conflicten in komende opdrachten te voorkomen.
DROP TABLE IF EXISTS adressen;
UPDATE medewerkers SET afd = NULL WHERE mnr < 7369 OR mnr > 7934;
UPDATE afdelingen SET hoofd = NULL WHERE anr > 40;
DELETE FROM afdelingen WHERE anr > 40;
DELETE FROM medewerkers WHERE mnr < 7369 OR mnr > 7934;
ALTER TABLE medewerkers DROP CONSTRAINT IF EXISTS m_geslacht_chk;
ALTER TABLE medewerkers DROP COLUMN IF EXISTS geslacht;
alter table afdelingen
    alter
        column anr type numeric(2);
create view s3_4 as  SELECT (((medewerkers.voorl)::text || '. '::text) || (medewerkers.naam)::text) AS mdw_naam,
                            afdelingen.naam AS afd_naam,
                            afdelingen.locatie
                     FROM (afdelingen
                         JOIN medewerkers ON ((afdelingen.anr = medewerkers.afd)));

