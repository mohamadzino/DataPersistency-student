-- ------------------------------------------------------------------------
-- Data & Persistency
-- Opdracht S3: Multiple Tables
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
-- Lever je werk pas in op Canvas als alle tests slagen.
-- ------------------------------------------------------------------------


-- S3.1.
-- Produceer een overzicht van alle cursusuitvoeringen; geef de
-- code, de begindatum, de lengte en de naam van de docent.
DROP VIEW IF EXISTS s3_1; CREATE OR REPLACE VIEW s3_1 AS                                                     -- [TEST]
select cursussen.code, uitvoeringen.begindatum, cursussen.lengte, medewerkers.naam
from (uitvoeringen inner join medewerkers on uitvoeringen.docent = medewerkers.mnr)
    inner join cursussen on uitvoeringen.cursus = cursussen.code;

-- S3.2.
-- Geef in twee kolommen naast elkaar de achternaam van elke cursist (`cursist`)
-- van alle S02-cursussen, met de achternaam van zijn cursusdocent (`docent`).
DROP VIEW IF EXISTS s3_2; CREATE OR REPLACE VIEW s3_2 AS                                                     -- [TEST]
select cursist.naam as cursist_achternaam, docent.naam as docent_achternaam
from inschrijvingen
         inner join uitvoeringen on inschrijvingen.begindatum = uitvoeringen.begindatum
         inner join medewerkers cursist on inschrijvingen.cursist = cursist.mnr
         INNER join medewerkers docent on uitvoeringen.docent = docent.mnr
where inschrijvingen.cursus = 'S02';

-- S3.3.
-- Geef elke afdeling (`afdeling`) met de naam van het hoofd van die
-- afdeling (`hoofd`).
DROP VIEW IF EXISTS s3_3; CREATE OR REPLACE VIEW s3_3 AS                                                     -- [TEST]
select afdelingen.naam as afd_naam, medewerkers.voorl || '. ' ||  medewerkers.naam as hoofd_naam
from afdelingen inner join medewerkers on afdelingen.hoofd = medewerkers.mnr;

-- S3.4.
-- Geef de namen van alle medewerkers, de naam van hun afdeling (`afdeling`)
-- en de bijbehorende locatie.
DROP VIEW IF EXISTS s3_4; CREATE OR REPLACE VIEW s3_4 AS                                                     -- [TEST]
select medewerkers.voorl || '. ' || medewerkers.naam as mdw_naam, afdelingen.naam as afd_naam, afdelingen.locatie
from afdelingen inner join medewerkers on afdelingen.anr = medewerkers.afd;

-- S3.5.
-- Geef de namen van alle cursisten die staan ingeschreven voor de cursus S02 van 12 april 2019
DROP VIEW IF EXISTS s3_5; CREATE OR REPLACE VIEW s3_5 AS                                                     -- [TEST]
select medewerkers.voorl || '. ' || medewerkers.naam as cursist_naam
from inschrijvingen inner join medewerkers on inschrijvingen.cursist = medewerkers.mnr
where inschrijvingen.cursus = 'S02' and inschrijvingen.begindatum = '2019-04-12';

-- S3.6.
-- Geef de namen van alle medewerkers en hun toelage.
DROP VIEW IF EXISTS s3_6; CREATE OR REPLACE VIEW s3_6 AS                                                     -- [TEST]
select medewerkers.voorl || '. ' || medewerkers.naam as mdw_naam, schalen.toelage
from schalen
    inner join medewerkers on medewerkers.maandsal >= schalen.ondergrens and medewerkers.maandsal <= schalen.bovengrens;


-- -------------------------[ HU TESTRAAMWERK ]--------------------------------
-- Met onderstaande query kun je je code testen. Zie bovenaan dit bestand
-- voor uitleg.

SELECT * FROM test_select('S3.1') AS resultaat
UNION
SELECT * FROM test_select('S3.2') AS resultaat
UNION
SELECT * FROM test_select('S3.3') AS resultaat
UNION
SELECT * FROM test_select('S3.4') AS resultaat
UNION
SELECT * FROM test_select('S3.5') AS resultaat
UNION
SELECT * FROM test_select('S3.6') AS resultaat
ORDER BY resultaat;

