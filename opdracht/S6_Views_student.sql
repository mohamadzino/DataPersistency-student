-- ------------------------------------------------------------------------
-- Data & Persistency
-- Opdracht S6: Views
--
-- (c) 2020 Hogeschool Utrecht
-- Tijmen Muller (tijmen.muller@hu.nl)
-- André Donk (andre.donk@hu.nl)
-- ------------------------------------------------------------------------


-- S6.1.
--
-- 1. Maak een view met de naam "deelnemers" waarmee je de volgende gegevens uit de tabellen inschrijvingen en uitvoering combineert:
--    inschrijvingen.cursist, inschrijvingen.cursus, inschrijvingen.begindatum, uitvoeringen.docent, uitvoeringen.locatie
DROP VIEW IF EXISTS deelnemers; CREATE OR REPLACE VIEW deelnemers AS
select inschrijvingen.cursist,
       inschrijvingen.cursus,
       inschrijvingen.begindatum,
       uitvoeringen.docent,
       uitvoeringen.locatie
from inschrijvingen
         inner join uitvoeringen on inschrijvingen.cursus = uitvoeringen.cursus and inschrijvingen.begindatum = uitvoeringen.begindatum;


-- 2. Gebruik de view in een query waarbij je de "deelnemers" view combineert met de "personeels" view (behandeld in de les):
     CREATE OR REPLACE VIEW personeel AS
 	     SELECT mnr, voorl, naam as medewerker, afd, functie
       FROM medewerkers;
SELECT * from deelnemers
                  inner join personeel on deelnemers.cursist = personeel.mnr;
-- 3. Is de view "deelnemers" updatable ? Waarom ?
--UPDATE deelnemers
--SET cursist = '1000'
--WHERE cursist = '1001';
    -- Nee, want de view selecteerd niet van 1 tabel, dus het is niet automatisch updatable.

-- S6.2.
--
-- 1. Maak een view met de naam "dagcursussen". Deze view dient de gegevens op te halen: 
--      code, omschrijving en type uit de tabel curssussen met als voorwaarde dat de lengte = 1. Toon aan dat de view werkt.
    DROP VIEW IF EXISTS dagcursussen;
CREATE
OR REPLACE VIEW dagcursussen AS
    SELECT code, omschrijving, type
    FROM cursussen
    WHERE lengte = 1;
-- 2. Maak een tweede view met de naam "daguitvoeringen". 
--    Deze view dient de uitvoeringsgegevens op te halen voor de "dagcurssussen" (gebruik ook de view "dagcursussen"). Toon aan dat de view werkt
    DROP VIEW IF EXISTS daguitvoeringen;
CREATE
OR REPLACE VIEW daguitvoeringen AS
    SELECT uitvoeringen.cursus,
           uitvoeringen.begindatum,
           uitvoeringen.docent,
           uitvoeringen.locatie
    FROM uitvoeringen
             INNER JOIN dagcursussen ON uitvoeringen.cursus = dagcursussen.code;
-- 3. Verwijder de views en laat zien wat de verschillen zijn bij DROP view <viewnaam> CASCADE en bij DROP view <viewnaam> RESTRICT
DROP VIEW IF EXISTS dagcursussen CASCADE;
DROP VIEW IF EXISTS daguitvoeringen CASCADE;
DROP VIEW IF EXISTS dagcursussen RESTRICT;
DROP VIEW IF EXISTS daguitvoeringen RESTRICT;
-- RESTRICT: De view wordt niet verwijderd als er nog een andere view of tabel naar de view verwijst.
-- CASCADE: De view wordt verwijderd, en alle andere views en tabellen die naar de view verwijzen worden ook verwijderd.

