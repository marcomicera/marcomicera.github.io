SET NAMES latin1;
DROP DATABASE IF EXISTS `impresagiardinaggio`;
CREATE DATABASE  IF NOT EXISTS `impresagiardinaggio`;
USE `impresagiardinaggio`;
SET FOREIGN_KEY_CHECKS = 1;
SET GLOBAL EVENT_SCHEDULER = ON;

--
-- Creazione tabella `account`
--
DROP TABLE IF EXISTS `account`;
CREATE TABLE `account` (
  `Nickname` char(50) NOT NULL,
  `CittaResidenza` char(50) DEFAULT NULL,
  `Password` char(50) NOT NULL,
  `Email` char(50) NOT NULL,
  `Nome` char(50) NOT NULL,
  `Cognome` char(50) NOT NULL,
  `DomandaSegreta` char(50) NOT NULL,
  `RispostaSegreta` char(50) NOT NULL,
  `NumPostPubblicati` int(11) unsigned NOT NULL DEFAULT '0',
  UNIQUE (`Email`),
  PRIMARY KEY (`Nickname`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Controllo password
DROP TRIGGER IF EXISTS `ControlloPassword`;
DELIMITER $$
CREATE TRIGGER `ControlloPassword` BEFORE INSERT ON `account` FOR EACH ROW
BEGIN
	IF(LENGTH(NEW.`Password`) < 8) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Password troppo corta.';
	END IF;
    
    IF(NEW.`Nickname` = NEW.`Password`) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =
			'Impossibile scegliere la password uguale al nickname.';
	END IF;
END $$
DELIMITER ;

-- Controllo domanda e risposta segreta
DROP TRIGGER IF EXISTS `ControlloDomandaRispostaSegreta`;
DELIMITER $$
CREATE TRIGGER `ControlloDomandaRispostaSegreta` 
	BEFORE INSERT ON `account` FOR EACH ROW
BEGIN
	IF(NEW.`DomandaSegreta` = NEW.`RispostaSegreta`) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Impossibile scegliere la domanda segreta 
			uguale alla risposta segreta.';
	END IF;
END $$
DELIMITER ;

--
-- Creazione tabella `agentepatogeno`
--
DROP TABLE IF EXISTS `agentepatogeno`;
CREATE TABLE `agentepatogeno` (
  `Nome` char(50) NOT NULL,
  `Tipo` char(50) NOT NULL,
  PRIMARY KEY (`Nome`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `agentipatogenipatologia`
--
DROP TABLE IF EXISTS `agentipatogenipatologia`;
CREATE TABLE `agentipatogenipatologia` (
  `CodPatologia` int(11) unsigned NOT NULL,
  `NomeAgentePatogeno` char(50) NOT NULL,
  PRIMARY KEY (`CodPatologia`,`NomeAgentePatogeno`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `arredamento`
--
DROP TABLE IF EXISTS `arredamento`;
CREATE TABLE `arredamento` (
  `Versione` int(11) unsigned NOT NULL,
  `CodSpazio` int(11) unsigned NOT NULL,
  PRIMARY KEY (`Versione`,`CodSpazio`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `componente`
--
DROP TABLE IF EXISTS `componente`;
CREATE TABLE `componente` (
  `Nome` char(50) NOT NULL,
  PRIMARY KEY (`Nome`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `componentiterreno`
--
DROP TABLE IF EXISTS `componentiterreno`;
CREATE TABLE `componentiterreno` (
  `CodTerreno` int(11) unsigned NOT NULL,
  `NomeComponente` char(50) NOT NULL,
  `Concentrazione` float(13, 2) unsigned NOT NULL, -- mg/m^3
  PRIMARY KEY (`CodTerreno`,`NomeComponente`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Controllo sulle percentuali delle componenti di un terreno
DROP TRIGGER IF EXISTS `ControllaPercentualiComponenti`;
DELIMITER $$
CREATE TRIGGER `ControllaPercentualiComponenti` 
	BEFORE INSERT ON `componentiterreno` FOR EACH ROW
BEGIN
	SET @PercentualeComponentiTerreno = (	SELECT SUM(`Concentrazione`)
											FROM `componentiterreno`
											WHERE `CodTerreno` = 
												NEW.`CodTerreno`);

	IF(@PercentualeComponentiTerreno + NEW.`Concentrazione` > 100) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La concentrazione di componenti in un terreno
			non puo\' superare il 100%.';
	END IF;
END $$
DELIMITER ;

--
-- Creazione tabella `contenitore`
--
DROP TABLE IF EXISTS `contenitore`;
CREATE TABLE `contenitore` (
  `CodContenitore` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Dimensione` int(11) unsigned NOT NULL, -- centimetri (diametro)
  `Idratazione` float (13, 2) NOT NULL, -- percentuale
  `Irrigazione` float (13, 2) NOT NULL, -- percentuale
  `CodRipiano` int(11) unsigned DEFAULT NULL,
  `Pieno` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`CodContenitore`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `elementinecessarispecie`
--
DROP TABLE IF EXISTS `elementinecessarispecie`;
CREATE TABLE `elementinecessarispecie` (
  `NomeSpecie` char(50) NOT NULL,
  `NomeElemento` char(50) NOT NULL,
  `Concentrazione` float(13, 2) unsigned NOT NULL, -- mg/m^3
  PRIMARY KEY (`NomeSpecie`,`NomeElemento`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `elementistatosalute`
--
DROP TABLE IF EXISTS `elementistatosalute`;
CREATE TABLE `elementistatosalute` (
  `CodContenitore` int(11) unsigned NOT NULL,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,
  `NomeElemento` char(50) NOT NULL,
  `Concentrazione` float(13, 2) unsigned NOT NULL, -- mg/m^3
  PRIMARY KEY (`CodContenitore`,`Timestamp`,`NomeElemento`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `elementiterreno`
--
DROP TABLE IF EXISTS `elementiterreno`;
CREATE TABLE `elementiterreno` (
  `NomeElemento` char(50) NOT NULL,
  `CodTerreno` int(11) unsigned NOT NULL,
  `Concentrazione` float(13, 2) unsigned NOT NULL, -- mg/m^3
  PRIMARY KEY (`NomeElemento`,`CodTerreno`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Controllo sulle percentuali degli elementi di un terreno
DROP TRIGGER IF EXISTS `ControllaPercentualiElementi`;
DELIMITER $$
CREATE TRIGGER `ControllaPercentualiElementi` 
	BEFORE INSERT ON `elementiterreno` FOR EACH ROW
BEGIN
	SET @PercentualeElementiTerreno = (	SELECT SUM(`Concentrazione`)
										FROM `elementiterreno`
										WHERE `CodTerreno` = 
											NEW.`CodTerreno`);

	IF(@PercentualeElementiTerreno + NEW.`Concentrazione` > 100) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La concentrazione di elementi in un terreno 
			non puo\' superare il 100%.';
	END IF;
END $$
DELIMITER ;

--
-- Creazione tabella `elemento`
--
DROP TABLE IF EXISTS `elemento`;
CREATE TABLE `elemento` (
  `Nome` char(50) NOT NULL,
  `PerMinConflitto` float(13, 2) unsigned NOT NULL,
  PRIMARY KEY (`Nome`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `esigenzaconcimazionepianta`
--
DROP TABLE IF EXISTS `esigenzaconcimazionepianta`;
CREATE TABLE `esigenzaconcimazionepianta` (
  `CodPianta` int(11) unsigned NOT NULL,
  `CodManutenzione` int(11) unsigned NOT NULL,
  PRIMARY KEY (`CodPianta`,`CodManutenzione`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `immagine`
--
DROP TABLE IF EXISTS `immagine`;
CREATE TABLE `immagine` (
  `URL` char(50) NOT NULL,
  PRIMARY KEY (`URL`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `immaginisintomi`
--
DROP TABLE IF EXISTS `immaginisintomi`;
CREATE TABLE `immaginisintomi` (
  `CodSintomo` int(11) unsigned NOT NULL,
  `URL` char(50) NOT NULL,
  PRIMARY KEY (`CodSintomo`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `manutenzione`
--
DROP TABLE IF EXISTS `manutenzione`;
CREATE TABLE `manutenzione` (
  `CodManutenzione` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `DataInizio` date NOT NULL,
  `Costo` int(11) NOT NULL, -- euro
  `TipoSomm` char(50) DEFAULT NULL, -- disciolto, nebulizzato
  `TipoManutenzione` char(50) NOT NULL, /* potatura, rinvaso, 
										   concimazione, trattamento */
  `TipoCreazione` char(50) NOT NULL, /* su richiesta, programmata, 
									    automatica */
  `Scadenza` date DEFAULT NULL,
  -- it.wikipedia.org/wiki/Potatura#Metodi_di_potatura
  `TipoPotatura` char(50) DEFAULT NULL,
  `NumIntervAnnuali` int(11) unsigned NOT NULL,
  `CodPianta` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`CodManutenzione`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/* Aggiornamento della ridondanza `CostoTotManutenzione`
dell'entità `specie` */
DROP TRIGGER IF EXISTS `AggiornamentoCostoTotManutenzione`;
DELIMITER $$
CREATE TRIGGER `AggiornamentoCostoTotManutenzione` 
	AFTER INSERT ON `manutenzione` FOR EACH ROW
BEGIN
	/* Se si tratta di una manutenzione svolta,
	e non di una concimazione necessaria */
	IF(NEW.`CodPianta` IS NOT NULL) THEN
		UPDATE `specie`
		SET `CostoTotManutenzione` = `CostoTotManutenzione` + NEW.Costo
		WHERE `Nome` = (SELECT `NomeSpecie`
						FROM `pianta`
						WHERE `CodPianta` = NEW.`CodPianta`);
	END IF;
END $$
DELIMITER ;

-- Controllo data scadenza
DROP TRIGGER IF EXISTS `ControllaDataScadenza`;
DELIMITER $$
CREATE TRIGGER `ControllaDataScadenza`
	BEFORE INSERT ON `manutenzione` FOR EACH ROW
BEGIN
	IF(NEW.`Scadenza` < NEW.`DataInizio`) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'La scadenza non può avvenire 
				prima della data di inizio.';
        END IF;
END $$
DELIMITER ;

--
-- Creazione tabella `media`
--
DROP TABLE IF EXISTS `media`;
CREATE TABLE `media` (
  `URL` char(50) NOT NULL,
  PRIMARY KEY (`URL`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `mediapost`
--
DROP TABLE IF EXISTS `mediapost`;
CREATE TABLE `mediapost` (
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP 
    ON UPDATE CURRENT_TIMESTAMP,
  `Utente` char(50) NOT NULL,
  `URL` char(50) NOT NULL,
  PRIMARY KEY (`Timestamp`,`Utente`,`URL`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Aggiornamento della ridondanza `NumMedia` dell'entità `thread`
DROP TRIGGER IF EXISTS `AggiornamentoNumMedia`;
CREATE TRIGGER `AggiornamentoNumMedia` 
	AFTER INSERT ON `mediapost` FOR EACH ROW
	UPDATE `thread`
	SET `NumMedia` = `NumMedia` + 1
    WHERE `CodThread` = (SELECT `CodThread`
						FROM `post`
						WHERE `Timestamp` = NEW.`Timestamp`
							AND `Utente` = NEW.`Utente`);

--
-- Creazione tabella `ordine`
--
DROP TABLE IF EXISTS `ordine`;
CREATE TABLE `ordine` (
  `CodOrdine` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP 
    ON UPDATE CURRENT_TIMESTAMP,
  `Stato` char(50) NOT NULL, /* pendente, in processazione, 
								in preparazione, spedito, evaso */
  `Utente` char(50) DEFAULT NULL,
  PRIMARY KEY (`CodOrdine`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `patologia`
--
DROP TABLE IF EXISTS `patologia`;
CREATE TABLE `patologia` (
  `CodPatologia` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `DataInizio` date NOT NULL,
  `DataFine` date NOT NULL,
  `Probabilita` float(13, 2) unsigned NOT NULL, -- percentuale
  `Entita` float(13, 2) NOT NULL, -- da 0 a 10
  PRIMARY KEY (`CodPatologia`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `patologiereport`
--
DROP TABLE IF EXISTS `patologiereport`;
CREATE TABLE `patologiereport` (
  `CodPianta` int(11) unsigned NOT NULL,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP 
    ON UPDATE CURRENT_TIMESTAMP,
  `CodPatologia` int(11) unsigned NOT NULL,
  PRIMARY KEY (`CodPianta`,`Timestamp`,`CodPatologia`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `periodimanutenzione`
--
DROP TABLE IF EXISTS `periodimanutenzione`;
CREATE TABLE `periodimanutenzione` (
  `CodManutenzione` int(11) unsigned NOT NULL,
  `DataInizio` date NOT NULL,
  `DataFine` date NOT NULL,
  PRIMARY KEY (`CodManutenzione`,`DataInizio`,`DataFine`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `periodiprodotti`
--
DROP TABLE IF EXISTS `periodiprodotti`;
CREATE TABLE `periodiprodotti` (
  `NomeProdotto` char(50) NOT NULL,
  `DataInizio` date NOT NULL,
  `DataFine` date NOT NULL,
  PRIMARY KEY (`NomeProdotto`,`DataInizio`,`DataFine`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `periodispecie`
--
DROP TABLE IF EXISTS `periodispecie`;
CREATE TABLE `periodispecie` (
  `NomeSpecie` char(50) NOT NULL,
  `DataInizio` date NOT NULL,
  `DataFine` date NOT NULL,
  `Tipo` char(50) NOT NULL, -- fioritura, fruttificazione, riposo
  PRIMARY KEY (`NomeSpecie`,`DataInizio`,`DataFine`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `pianta`
--
DROP TABLE IF EXISTS `pianta`;
CREATE TABLE `pianta` (
  `CodPianta` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `DimAttuale` int(11) unsigned NOT NULL, -- cm
  `Prezzo` int(11) unsigned DEFAULT NULL, -- euro
  `IndiceManutenzione` float(13, 2) unsigned DEFAULT NULL,
  `NomeSpecie` char(50) DEFAULT NULL,
  `CodTerreno` int(11) unsigned NOT NULL,
  `CodContenitore` int(11) unsigned DEFAULT NULL,
  `CodOrdine` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`CodPianta`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/* Stored procedure per le operazioni di aggiornamento delle ridondanze 
e di controllo della capienza delle entità `Sezione`, `Serra` e `Sede` */
DROP PROCEDURE IF EXISTS AggiornaPiantePresentiSezioneSerraSede;
DELIMITER $$
CREATE PROCEDURE AggiornaPiantePresentiSezioneSerraSede(
	IN contenitore int(11),
	IN quantita int(1))
BEGIN
	-- Entità coinvolte
	SET @Sezione = (SELECT `CodSezione`
					FROM `ripiano`
					WHERE `CodRipiano` = (	
						SELECT `CodRipiano`
						FROM `Contenitore`
						WHERE `CodContenitore` = `contenitore`));
	SET @Serra = (	SELECT `CodSerra`
					FROM `sezione`
					WHERE `CodSezione` = @Sezione);

	SET @Sede = (	SELECT `CodSede`
					FROM `serra`
					WHERE `CodSerra` = @Serra);
	
    -- Controllo capienze
	IF(`quantita` > 0) THEN
		SET @PiantePresentiSezione = (	SELECT `PiantePresenti`
										FROM `sezione`
										WHERE `CodSezione` = @Sezione);
		SET @CapienzaSezione = (SELECT `Capienza`
								FROM `sezione`
								WHERE `CodSezione` = @Sezione);
		IF(@PiantePresentiSezione + `quantita` > @CapienzaSezione) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Superata capienza della sezione.';
        END IF;
        
        SET @PiantePresentiSerra = (SELECT `PiantePresenti`
									FROM `serra`
									WHERE `CodSerra` = @Serra);
		SET @CapienzaSerra = (	SELECT `Capienza`
								FROM `serra`
								WHERE `CodSerra` = @Serra);
		IF(@PiantePresentiSerra + `quantita` > @CapienzaSerra) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Superata capienza della serra.';
        END IF;
        
        SET @PiantePresentiSede = (	SELECT `PiantePresenti`
									FROM `sede`
									WHERE `CodSede` = @Sede);
		SET @CapienzaSede = (	SELECT `Capienza`
								FROM `sede`
								WHERE `CodSede` = @Sede);
		IF(@PiantePresentiSede + `quantita` > @CapienzaSede) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Superata capienza della sede.';
        END IF;
    END IF;
    
    -- Aggiornamento ridondanze
    UPDATE `sezione`
	SET `PiantePresenti` = `PiantePresenti` + `quantita`
	WHERE `CodSezione` = @Sezione;
	
	UPDATE `serra`
	SET `PiantePresenti` = `PiantePresenti` + `quantita`
	WHERE `CodSerra` = @Serra;

	UPDATE `sede`
	SET `PiantePresenti` = `PiantePresenti` + `quantita`
	WHERE `CodSede` = @Sede;
END $$
DELIMITER ;

/* Stored procedure per l'aggiornamento della 
ridondanza `NumeroPiante` dell'entità `specie` */
DROP PROCEDURE IF EXISTS AggiornaNumeroPianteSpecie;
CREATE PROCEDURE AggiornaNumeroPianteSpecie(	IN pianta int(11), 
												IN quantita int(1))
	UPDATE `specie`
	SET `NumeroPiante` = `NumeroPiante` + `quantita`
    WHERE `Nome` = (SELECT `NomeSpecie`
					FROM `pianta`
					WHERE `CodPianta` = `pianta`);

-- Stored procedure per l'aggiornamento dello stato di un contenitore
DROP PROCEDURE IF EXISTS AggiornaStatoContenitore;
DELIMITER $$
CREATE PROCEDURE AggiornaStatoContenitore(	IN contenitore int(11), 
											IN nuovoStato tinyint(1))
BEGIN
	-- Controllo dello stato del nuovo contenitore
	IF((SELECT `Pieno`
		FROM `contenitore`
		WHERE `CodContenitore` = `contenitore`) = `nuovoStato`) THEN
        IF(`nuovoStato` = '0') THEN
			SET @messageText = 'Codice del vecchio contenitore errato.';
		ELSEIF(`nuovoStato` = '1') THEN
			SET @messageText = 'Impossibile inserire una nuova pianta 
				in un contenitore già pieno.';
		END IF;

		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = @messageText;
	END IF;
	
    -- Aggiornamento stato
	UPDATE `contenitore`
    SET `Pieno` = `nuovoStato`
    WHERE `CodContenitore` = `contenitore`;
END $$
DELIMITER ;

-- Stored procedure per il controllo della dimensione di un contenitore
DROP PROCEDURE IF EXISTS ControlloDimensioneContenitore;
DELIMITER $$
CREATE PROCEDURE ControlloDimensioneContenitore(IN dimAttuale int(11), 
												IN contenitore int(11))
BEGIN
	SET @DimensioneContenitore = (	SELECT `Dimensione`
									FROM `contenitore`
                                    WHERE `CodContenitore` = contenitore);
	
    IF(`dimAttuale` > @DimensioneContenitore) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'La pianta è attualmente troppo grande per 
			essere inserita nel contenitore';
	END IF;
END $$
DELIMITER ;

-- Stored procedure per il controllo della temperatura di una sezione
DROP PROCEDURE IF EXISTS ControlloTemperaturaSezione;
DELIMITER $$
CREATE PROCEDURE ControlloTemperaturaSezione(	IN pianta int(11), 
                                                IN contenitore int(11))
BEGIN
	SET @tempSezione = (
		SELECT `Temperatura`
		FROM `sezione`
		WHERE `CodSezione` = (
			SELECT `CodSezione`
			FROM `ripiano`
			WHERE `CodRipiano` = (
				SELECT `CodRipiano`
				FROM `contenitore`
				WHERE `CodContenitore` = contenitore
			)
		)
	);
    
    SET @tempMin = (SELECT `TempMin`
					FROM `specie`
					WHERE `Nome` = (SELECT `NomeSpecie`
									FROM `pianta`
									WHERE `CodPianta` = pianta));
                    
	SET @tempMax = (SELECT `TempMax`
					FROM `specie`
					WHERE `Nome` = (SELECT `NomeSpecie`
									FROM `pianta`
									WHERE `CodPianta` = pianta));
	
    IF(@tempSezione > @tempMax OR @tempSezione < @tempMin) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'La temperatura della sezione non e\' 
			compatibile con questa pianta.';
	END IF;
END $$
DELIMITER ;

-- Calcolo dell'indice di manutenzione
DROP TRIGGER IF EXISTS `ImpostaIndiceManutenzione`;
CREATE TRIGGER `ImpostaIndiceManutenzione` 
	BEFORE INSERT ON `pianta` FOR EACH ROW
	SET NEW.`IndiceManutenzione` = (
		SELECT `IndiceAccrescimento` * `DimMax`
		FROM `specie`
		WHERE `Nome` = NEW.`NomeSpecie`) / NEW.`DimAttuale`;

-- Trigger per l'inserimento di una nuova pianta
DROP TRIGGER IF EXISTS `InserimentoPianta`;
DELIMITER $$
CREATE TRIGGER `InserimentoPianta` AFTER INSERT ON `pianta` FOR EACH ROW
BEGIN
	-- Se la pianta e' contenuta in un contenitore
	IF(NEW.`CodContenitore` IS NOT NULL) THEN
		CALL ControlloDimensioneContenitore(NEW.`DimAttuale`, 
											NEW.`CodContenitore`);
        CALL ControlloTemperaturaSezione(NEW.`CodPianta`, 
										 NEW.`CodContenitore`);
        CALL AggiornaStatoContenitore(NEW.`CodContenitore`,
									  '1');
		CALL AggiornaPiantePresentiSezioneSerraSede(NEW.`CodContenitore`, 
													'1');
	END IF;
    CALL AggiornaNumeroPianteSpecie(NEW.`CodPianta`, '1');
END $$
DELIMITER ;

-- Trigger per la modifica di una pianta
DROP TRIGGER IF EXISTS `ModificaPianta`;
DELIMITER $$
CREATE TRIGGER `ModificaPianta` BEFORE UPDATE ON `pianta` FOR EACH ROW
BEGIN
	IF(OLD.`CodContenitore` <> NEW.`CodContenitore`) THEN
		IF(OLD.`CodContenitore` IS NOT NULL) THEN
			CALL AggiornaStatoContenitore(OLD.`CodContenitore`, 
										  '0');
			CALL AggiornaPiantePresentiSezioneSerraSede(
				OLD.`CodContenitore`, 
				'-1'
			);
		END IF;
        IF(NEW.`CodContenitore` IS NOT NULL) THEN
			CALL ControlloDimensioneContenitore(NEW.`DimAttuale`, 
												NEW.`CodContenitore`);
			CALL AggiornaStatoContenitore(NEW.`CodContenitore`, '1');
			CALL AggiornaPiantePresentiSezioneSerraSede(
				NEW.`CodContenitore`, 
				'1'
			);
		END IF;
	END IF;
END $$
DELIMITER ;

-- Trigger per la cancellazione di una pianta
DROP TRIGGER IF EXISTS `CancellazionePianta`;
DELIMITER $$
CREATE TRIGGER `CancellazionePianta` AFTER DELETE ON `pianta` FOR EACH ROW
BEGIN
	CALL AggiornaStatoContenitore(OLD.`CodContenitore`, '0');
	CALL AggiornaPiantePresentiSezioneSerraSede(OLD.`CodContenitore`, '-1');
	CALL AggiornaNumeroPianteSpecie(OLD.`CodPianta`, '-1');
END $$
DELIMITER ;

--
-- Creazione tabella `piantearredamentoinpienaterra`
--
DROP TABLE IF EXISTS `piantearredamentoinpienaterra`;
CREATE TABLE `piantearredamentoinpienaterra` (
  `CodPianta` int(11) unsigned NOT NULL,
  `CodSpazio` int(11) unsigned NOT NULL,
  `Versione` int(11) unsigned NOT NULL,
  `PosX` int(11) NOT NULL,
  `PosY` int(11) NOT NULL,
  PRIMARY KEY (`CodPianta`,`CodSpazio`,`Versione`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `post`
--
DROP TABLE IF EXISTS `post`;
CREATE TABLE `post` (
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,
  `Utente` char(50) DEFAULT 'Utente eliminato',
  `Giudizio` float(2, 1) DEFAULT NULL, -- da 0 a 5
  `Testo` char(50) NOT NULL,
  `CodThread` int(11) unsigned NOT NULL,
  PRIMARY KEY (`Timestamp`,`Utente`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Aggiornamento della ridondanza `NumPostPubblicati` dell'entità `account`
DROP TRIGGER IF EXISTS `AggiornamentoNumPostPubblicati`;
CREATE TRIGGER `AggiornamentoNumPostPubblicati` 
	AFTER INSERT ON `post` FOR EACH ROW
	UPDATE `account`
	SET `NumPostPubblicati` = `NumPostPubblicati` + 1
	WHERE `Nickname` = NEW.`Utente`;

--
-- Creazione tabella `principiattiviprodotto`
--
DROP TABLE IF EXISTS `principiattiviprodotto`;
CREATE TABLE `principiattiviprodotto` (
  `NomeProdotto` char(50) NOT NULL,
  `NomePrincipioAttivo` char(50) NOT NULL,
  `Concentrazione` float(13, 2) unsigned NOT NULL, -- mg/m^3
  PRIMARY KEY (`NomeProdotto`,`NomePrincipioAttivo`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `principioattivo`
--
DROP TABLE IF EXISTS `principioattivo`;
CREATE TABLE `principioattivo` (
  `Nome` char(50) NOT NULL,
  PRIMARY KEY (`Nome`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `prodottipatologia`
--
DROP TABLE IF EXISTS `prodottipatologia`;
CREATE TABLE `prodottipatologia` (
  `CodPatologia` int(11) unsigned NOT NULL,
  `NomeProdotto` char(50) NOT NULL,
  PRIMARY KEY (`CodPatologia`,`NomeProdotto`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `prodottitrattamento`
--
DROP TABLE IF EXISTS `prodottitrattamento`;
CREATE TABLE `prodottitrattamento` (
  `NomeProdotto` char(50) NOT NULL,
  `CodManutenzione` int(11) unsigned NOT NULL,
  `Dose` float(13, 2) NOT NULL, -- mg/m^3
  PRIMARY KEY (`NomeProdotto`,`CodManutenzione`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `prodotto`
--
DROP TABLE IF EXISTS `prodotto`;
CREATE TABLE `prodotto` (
  `Nome` char(50) NOT NULL,
  `Marca` char(50) NOT NULL,
  `TempoMinConsumazFrutti` int(11) DEFAULT '0', -- giorni
  `ModalitaSomm` char(50) DEFAULT NULL, -- disciolto, nebulizzato
  PRIMARY KEY (`Nome`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `prodottocombatte`
--
DROP TABLE IF EXISTS `prodottocombatte`;
CREATE TABLE `prodottocombatte` (
  `NomeProdotto` char(50) NOT NULL,
  `NomeAgentePatogeno` char(50) NOT NULL,
  `Dosaggio` float(13, 2) unsigned NOT NULL, -- mL
  PRIMARY KEY (`NomeProdotto`,`NomeAgentePatogeno`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `reportassunzioni`
--
DROP TABLE IF EXISTS `reportassunzioni`;
CREATE TABLE `reportassunzioni` (
  `CodReportAss` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `CodSede` int(11) unsigned NOT NULL,
  `NumDipendenti` int(11) unsigned NOT NULL,
  `Indeterminato` tinyint(1) DEFAULT '0',
  `DataInizio` date DEFAULT NULL,
  `DataFine` date DEFAULT NULL,
  PRIMARY KEY (`CodReportAss`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Creazione dei reports delle assunzioni
DROP EVENT IF EXISTS `CreaReportAssunzioni`;
DELIMITER $$
CREATE EVENT `CreaReportAssunzioni` ON SCHEDULE EVERY 1 MONTH
STARTS '2014-01-01 23:55:00' DO
BEGIN
	SET @massimoNumeroOrdiniGestibiliDaUnDipendente = '20';
    
    /* Determina per quante volte una sede puo' assumere dipendenti 
    part-time prima di iniziare ad assumere a tempo indeterminato */
    SET @numeroDiAssunzioniPrimaDiIndeterminato = '5';

	CREATE OR REPLACE VIEW `NuoviOrdiniPerSede` AS
		SELECT `CodSede`, COUNT(*) AS `OrdiniUltimoMeseDaGestire`
		FROM `serra`
		WHERE `CodSerra` IN (		
			SELECT DISTINCT(`CodSerra`)
			FROM `sezione`
			WHERE `CodSezione` IN (
				SELECT DISTINCT(`CodSezione`)
				FROM `ripiano`
				WHERE `CodRipiano` IN (
					SELECT DISTINCT(`CodRipiano`)
					FROM `contenitore`
					WHERE `CodContenitore` IN (	
						SELECT DISTINCT(`CodContenitore`)
						FROM `pianta`
						WHERE `CodOrdine` IS NOT NULL
							AND `CodContenitore` IS NOT NULL
							AND `CodOrdine` IN (
								SELECT `CodOrdine`
								FROM `ordine`
								WHERE `Timestamp` BETWEEN 
									CURRENT_TIMESTAMP - INTERVAL 1 MONTH 
										AND 
									CURRENT_TIMESTAMP
									AND (`Stato` = 'pendente' OR
										 `Stato` = 'in processazione')
							)
					 )
				)
			)
		)
		GROUP BY `CodSede`;
        
	CREATE OR REPLACE VIEW `RapportoNuoviOrdiniSuDipendentiPerSede` AS
		SELECT 	NOPS.`CodSede`, 
				`NumDipendenti`/`OrdiniUltimoMeseDaGestire` 
					AS `RapportoOrdiniDipendenti`,
                (	SELECT COUNT(*)
					FROM `reportassunzioni` RA
					WHERE RA.`CodSede` = NOPS.`CodSede`)
					AS `NumeroReportPrecedenti`
        FROM `NuoviOrdiniPerSede` NOPS NATURAL JOIN `Sede` S;

	INSERT INTO `reportassunzioni` (`NumDipendenti`, 
									`CodSede`, 
									`Indeterminato`, 
									`DataInizio`, 
									`DataFine`)
		SELECT	RNO.`CodSede`,
			FLOOR(RNO.`RapportoOrdiniDipendenti`/20) 
				AS `DipendentiDaAssumere`,
            IF((SELECT RA1.`Indeterminato` AS `IndeterminatoUltimoReport`
				FROM `reportassunzioni` RA1
				WHERE RA1.`CodSede` = RNO.`CodSede`
					AND RA1.`CodReportAss` = (	
						SELECT MAX(`CodReportAss`)
						FROM `reportassunzioni` RA2
						WHERE RA2.`CodSede` = RA1.`CodSede`)) = '1',
				'0', 
                IF(RNO.`NumeroReportPrecedenti` <
					@numeroDiAssunzioniPrimaDiIndeterminato, '0', '1')
                ) AS `Indeterminato`,
			CURRENT_DATE AS `DataInizio`,
            CURRENT_DATE + INTERVAL 1 MONTH AS `DataFine`
		FROM `RapportoNuoviOrdiniSuDipendentiPerSede` RNO
		WHERE RNO.`RapportoOrdiniDipendenti` > 
			@massimoNumeroOrdiniGestibiliDaUnDipendente;
END $$
DELIMITER ;

--
-- Creazione tabella `reportdiagnostica`
--
DROP TABLE IF EXISTS `reportdiagnostica`;
CREATE TABLE `reportdiagnostica` (
  `CodPianta` int(11) unsigned NOT NULL,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP 
    ON UPDATE CURRENT_TIMESTAMP,
  `CodTerreno` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`Timestamp`,`CodPianta`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Impostazione dell'attributo `CodTerreno`
DROP TRIGGER IF EXISTS `ImpostaCodTerreno`;
CREATE TRIGGER `ImpostaCodTerreno` 
	BEFORE INSERT ON `reportdiagnostica` FOR EACH ROW
	SET NEW.`CodTerreno` = (SELECT `CodTerreno`
							FROM `pianta`
							WHERE `CodPianta` = NEW.`CodPianta`);

-- Aggiornamento della ridondanza `NumeroEsordi` dell'entità `specie`
DROP TRIGGER IF EXISTS `AggiornamentoNumeroEsordi`;
CREATE TRIGGER `AggiornamentoNumeroEsordi` 
	AFTER INSERT ON `reportdiagnostica` FOR EACH ROW
	UPDATE `specie`
	SET `NumeroEsordi` = `NumeroEsordi` + 1
    WHERE `Nome` = (SELECT `NomeSpecie`
					FROM `pianta`
					WHERE `CodPianta` = NEW.`CodPianta`);

--
-- Creazione tabella `reportmanutenzione`
--
DROP TABLE IF EXISTS `reportmanutenzione`;
CREATE TABLE `reportmanutenzione` (
  `Tipo` char(50) NOT NULL,
  `NumSnapshot` int(11) unsigned NOT NULL DEFAULT '1',
  `NomeSpecie` char(50) NOT NULL,
  `CostoTot` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`Tipo`,`NumSnapshot`,`NomeSpecie`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
	
-- Creazione dei reports di manutenzione
DROP EVENT IF EXISTS `CreaReportManutenzione`;
DELIMITER $$
CREATE EVENT `CreaReportManutenzione` ON SCHEDULE EVERY 3 MONTH
STARTS '2014-01-01 23:55:00' DO
BEGIN
	INSERT INTO `reportmanutenzione`
		SELECT	M.`TipoManutenzione` AS `Tipo`,
				(SELECT COUNT(*)
				 FROM `reportmanutenzione` RM
				 WHERE RM.`NomeSpecie` = P.`NomeSpecie`
					AND RM.`Tipo` = M.`TipoManutenzione`) + 1
					AS `NumSnapshot`,
				P.`NomeSpecie`,
				SUM(M.`Costo`) AS `CostoTot`
		FROM `manutenzione` M INNER JOIN 
			(SELECT `CodPianta`, `NomeSpecie` FROM `pianta`) P
				ON M.`CodPianta` = P.`CodPianta`
		-- manutenzioni svolte, non solo esatte
		WHERE M.`CodPianta` IS NOT NULL 
			AND M.`DataInizio` BETWEEN -- degli ultimi 3 mesi
				CURRENT_DATE - INTERVAL 3 MONTH
					AND 
				CURRENT_DATE
		GROUP BY P.`NomeSpecie`, M.`TipoManutenzione`;
END $$
DELIMITER ;

--
-- Creazione tabella `reportordini`
--
DROP TABLE IF EXISTS `reportordini`;
CREATE TABLE `reportordini` (
  `CodRepOrdini` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `DaOrdinare` tinyint(1) NOT NULL,
  `Clima` char(50) DEFAULT NULL,
  PRIMARY KEY (`CodRepOrdini`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Creazione dei reports degli ordini da effettuare
DROP EVENT IF EXISTS `CreaReportOrdiniDaEffettuare`;
DELIMITER $$
CREATE EVENT `CreaReportOrdiniDaEffettuare` ON SCHEDULE EVERY 1 WEEK
STARTS '2014-01-01 23:55:00' DO
BEGIN
	CREATE OR REPLACE VIEW `LucePerSpecie` AS
		SELECT	S.`Nome` AS `NomeSpecie`,
                IF(	PS.`Tipo` = 'riposo',
					S.`OreLuceRiposo`,
					S.`OreLuceVegetativo`) AS `OreLuce`,
				IF(	PS.`Tipo` = 'riposo',
					'riposo', 
					'vegetativo') AS `TipoPeriodo`,
				DATEDIFF(PS.`DataFine`, PS.`DataInizio`) AS `NumeroGiorni`
		FROM `specie` S INNER JOIN `periodispecie` PS
			ON S.`Nome` = PS.`NomeSpecie`;

	CREATE OR REPLACE VIEW `OreLuceMediePerSpecie` AS
		SELECT	`NomeSpecie`,
				(SUM(`OreLuce` * `NumeroGiorni`))/365 AS `OreLuceMedie`
		FROM (	SELECT	`NomeSpecie`,
						`TipoPeriodo`,
						`OreLuce`,
						SUM(`NumeroGiorni`) AS `NumeroGiorni`
				FROM `LucePerSpecie`
				GROUP BY `NomeSpecie`, `TipoPeriodo`) AS D
		GROUP BY `NomeSpecie`;
        
	CREATE OR REPLACE VIEW `PianteDaOrdinare` AS
		SELECT	P.`NomeSpecie`,
                COUNT(*) AS `PianteDaOrdinare`
		FROM	`ordine` O 
				INNER JOIN 
				`pianta` P ON O.`CodOrdine` = P.`CodOrdine`
				INNER JOIN 
				`specie` S ON P.`NomeSpecie` = S.`Nome`
		WHERE P.`CodOrdine` IS NOT NULL
			AND O.`Stato` = 'pendente'
		GROUP BY P.`NomeSpecie`;

    CREATE OR REPLACE VIEW `PianteEstiveDaOrdinare` AS
		SELECT `NomeSpecie`, `PianteDaOrdinare`
		FROM `PianteDaOrdinare` NATURAL JOIN `OreLuceMediePerSpecie`
        WHERE `OreLuceMedie` > '7.5';

    CREATE OR REPLACE VIEW `PianteInvernaliDaOrdinare` AS
		SELECT `NomeSpecie`, `PianteDaOrdinare`
		FROM `PianteDaOrdinare` NATURAL JOIN `OreLuceMediePerSpecie`
        WHERE `OreLuceMedie` <= '7.5';

	INSERT INTO `reportordini` (`DaOrdinare`, `Clima`)
		SELECT '1', 'estivo'
		FROM `PianteEstiveDaOrdinare`;
   
	INSERT INTO `speciereportordini` (	`CodRepOrdini`,
										`NomeSpecie`, 
										`Quantita`)
		SELECT	(	SELECT MAX(`CodRepOrdini`)
					FROM `reportordini`) AS `CodRepOrdini`,
				`NomeSpecie`,
                `PianteDaOrdinare`
        FROM `PianteEstiveDaOrdinare`;

	INSERT INTO `reportordini` (`DaOrdinare`, `Clima`)
		SELECT '1', 'invernale'
		FROM `PianteInvernaliDaOrdinare`;
	
    INSERT INTO `speciereportordini` (	`CodRepOrdini`, 
										`NomeSpecie`, 
										`Quantita`)
		SELECT	(	SELECT MAX(`CodRepOrdini`) 
					FROM `reportordini`) AS `CodRepOrdini`,
				`NomeSpecie`,
                `PianteDaOrdinare`
        FROM `PianteInvernaliDaOrdinare`;
END $$
DELIMITER ;

-- Creazione dei reports degli ordini da non effettuare
DROP EVENT IF EXISTS `CreaReportOrdiniDaNonEffettuare`;
DELIMITER $$
CREATE EVENT `CreaReportOrdiniDaNonEffettuare` ON SCHEDULE EVERY 1 YEAR
STARTS '2014-01-01 23:55:00' DO
BEGIN

END $$
DELIMITER ;

--
-- Creazione tabella `ripiano`
--
DROP TABLE IF EXISTS `ripiano`;
CREATE TABLE `ripiano` (
  `CodRipiano` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Irrigazione` float (13, 2) NOT NULL, -- percentuale
  `CodSezione` int(11) unsigned DEFAULT NULL,
  `Capienza` int(11) unsigned NOT NULL,
  PRIMARY KEY (`CodRipiano`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Controllo sulla capienza di un ripiano
DROP TRIGGER IF EXISTS `ControllaCapienzaRipiano`;
DELIMITER $$
CREATE TRIGGER `ControllaCapienzaRipiano` 
	BEFORE INSERT ON `ripiano` FOR EACH ROW
BEGIN
	SET @CapienzaSezione = (SELECT `Capienza`
							FROM `sezione`
							WHERE `CodSezione` = NEW.`CodSezione`);

	SET @CapienzaRipiani = (SELECT SUM(`Capienza`)
							FROM `ripiano`
                            WHERE `CodSezione` = NEW.`CodSezione`);

	IF(@CapienzaRipiani + NEW.`Capienza` > @CapienzaSezione) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La capienza di tutti i ripiani di una 
			sezione non può superare quella di quest\'ultima.';
	END IF;
END $$
DELIMITER ;

--
-- Creazione tabella `salute`
--
DROP TABLE IF EXISTS `salute`;
CREATE TABLE `salute` (
  `CodContenitore` int(11) unsigned NOT NULL,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP 
    ON UPDATE CURRENT_TIMESTAMP,
  `Umidita` float(13, 2) NOT NULL, -- percentuale
  `TassoAmmoniaca` float(13, 2) NOT NULL, -- percentuale
  `LivelloGas` float(13, 2) NOT NULL, -- percentuale
  PRIMARY KEY (`Timestamp`,`CodContenitore`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `scheda`
--
DROP TABLE IF EXISTS `scheda`;
CREATE TABLE `scheda` (
  `CodScheda` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `DataAcquisto` date DEFAULT NULL,
  `Settore` int(11) unsigned DEFAULT NULL,
  `Collocazione` char(50) NOT NULL DEFAULT 'piena terra', /* piena terra, 
															 vaso */
  `DimensioneAllAcquisto` int(11) unsigned DEFAULT NULL,
  `PosX` int(11) NOT NULL,
  `PosY` int(11) NOT NULL,
  `CodPianta` int(11) unsigned NOT NULL,
  `CodVaso` int(11) unsigned DEFAULT NULL,
  `Utente` char(50) NOT NULL,
  PRIMARY KEY (`CodScheda`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Impostazione dell'attributo `DimensioneAllAcquisto`
DROP TRIGGER IF EXISTS `ImpostazioneDimensioneAllAcquisto`;
CREATE TRIGGER `ImpostazioneDimensioneAllAcquisto` 
	BEFORE INSERT ON `scheda` FOR EACH ROW
	SET NEW.`DimensioneAllAcquisto` = (	
		SELECT `DimAttuale`
		FROM `pianta`
		WHERE `CodPianta` = NEW.`CodPianta`);

/* Trigger per l'aggiornamento della ridondanza
`NumPianteVendute` di `specie` dopo la vendita di una pianta */
DROP TRIGGER IF EXISTS `AggiornaNumPianteVendute`;
DELIMITER $$
CREATE TRIGGER `AggiornaNumPianteVendute` 
	AFTER INSERT ON `scheda` FOR EACH ROW
BEGIN
	UPDATE `specie`
    SET `NumPianteVendute` = `NumPianteVendute` + 1
    WHERE `Nome` = (SELECT `NomeSpecie`
					FROM `pianta`
					WHERE `CodPianta` = NEW.`CodPianta`);
END $$
DELIMITER ;

--
-- Creazione tabella `sede`
--
DROP TABLE IF EXISTS `sede`;
CREATE TABLE `sede` (
  `CodSede` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `NumDipendenti` int(11) unsigned NOT NULL,
  `Indirizzo` char(50) NOT NULL,
  `PiantePresenti` int(11) NOT NULL DEFAULT '0',
  `Nome` char(50) NOT NULL,
  `Capienza` int(11) unsigned NOT NULL,
  PRIMARY KEY (`CodSede`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `serra`
--
DROP TABLE IF EXISTS `serra`;
CREATE TABLE `serra` (
  `CodSerra` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Nome` char(50) NOT NULL,
  `Indirizzo` char(50) NOT NULL,
  `Larghezza` int(11) unsigned NOT NULL, -- metri
  `Altezza` int(11) unsigned NOT NULL, -- metri
  `Capienza` int(11) unsigned NOT NULL,
  `PiantePresenti` int(11) unsigned NOT NULL DEFAULT '0',
  `CodSede` int(11) unsigned NOT NULL,
  PRIMARY KEY (`CodSerra`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Controllo sulla capienza di una serra
DROP TRIGGER IF EXISTS `ControllaCapienzaSerra`;
DELIMITER $$
CREATE TRIGGER `ControllaCapienzaSerra` 
	BEFORE INSERT ON `serra` FOR EACH ROW
BEGIN
	SET @CapienzaSede = (	SELECT `Capienza`
							FROM `sede`
							WHERE `CodSede` = NEW.`CodSede`);

	SET @CapienzaSerre = (	SELECT SUM(`Capienza`)
							FROM `serra`
							WHERE `CodSede` = NEW.`CodSede`);

	IF(@CapienzaSerre + NEW.`Capienza` > @CapienzaSede) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La capienza di tutte le serre di una 
			sede non può superare quella di quest\'ultima.';
	END IF;
END $$
DELIMITER ;

--
-- Creazione tabella `settore`
--
DROP TABLE IF EXISTS `settore`;
CREATE TABLE `settore` (
  `CodSettore` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Tipo` char(50) NOT NULL, -- piena terra o pavimentato
  `Esposizione` char(50) NOT NULL, -- punti cardinali
  `NumOreLuce` int(11) unsigned NOT NULL,
  `CodSpazio` int(11) unsigned NOT NULL,
  PRIMARY KEY (`CodSettore`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `sezione`
--
DROP TABLE IF EXISTS `sezione`;
CREATE TABLE `sezione` (
  `CodSezione` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Capienza` int(11) unsigned NOT NULL,
  `Irrigazione` float (13, 2) NOT NULL, -- percentuale
  `Illuminazione` float (13, 2) NOT NULL, -- percentuale
  `Umidita` float (13, 2) NOT NULL, -- percentuale
  `Temperatura` float (13, 2) NOT NULL, -- gradi centigradi
  `Quarantena` tinyint(1) NOT NULL,
  `PiantePresenti` int(11) unsigned NOT NULL DEFAULT '0',
  `Nome` char(50) NOT NULL,
  `CodSerra` int(11) unsigned NOT NULL,
  PRIMARY KEY (`CodSezione`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Controllo sulla capienza di una sezione
DROP TRIGGER IF EXISTS `ControllaCapienzaSezione`;
DELIMITER $$
CREATE TRIGGER `ControllaCapienzaSezione` 
	BEFORE INSERT ON `sezione` FOR EACH ROW
BEGIN
	SET @CapienzaSerra = (	SELECT `Capienza`
							FROM `serra`
							WHERE `CodSerra` = NEW.`CodSerra`);

	SET @CapienzaSezioni = (SELECT SUM(`Capienza`)
							FROM `sezione`
							WHERE `CodSerra` = NEW.`CodSerra`);

	IF(@CapienzaSezioni + NEW.`Capienza` > @CapienzaSerra) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La capienza di tutte le sezioni di 
			una serra non può superare quella di quest\'ultima.';
	END IF;
END $$
DELIMITER ;

--
-- Creazione tabella `sintomipatologia`
--
DROP TABLE IF EXISTS `sintomipatologia`;
CREATE TABLE `sintomipatologia` (
  `CodPatologia` int(11) unsigned NOT NULL,
  `CodSintomo` int(11) unsigned NOT NULL,
  PRIMARY KEY (`CodPatologia`,`CodSintomo`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `sintomireport`
--
DROP TABLE IF EXISTS `sintomireport`;
CREATE TABLE `sintomireport` (
  `CodPianta` int(11) unsigned NOT NULL,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP 
    ON UPDATE CURRENT_TIMESTAMP,
  `CodSintomo` int(11) unsigned NOT NULL,
  PRIMARY KEY (`CodPianta`,`Timestamp`,`CodSintomo`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `sintomo`
--
DROP TABLE IF EXISTS `sintomo`;
CREATE TABLE `sintomo` (
  `CodSintomo` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Descrizione` char(200) DEFAULT NULL,
  PRIMARY KEY (`CodSintomo`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `somministrazioneconcimazione`
--
DROP TABLE IF EXISTS `somministrazioneconcimazione`;
CREATE TABLE `somministrazioneconcimazione` (
  `NomeElemento` char(50) NOT NULL,
  `CodManutenzione` int(11) unsigned NOT NULL,
  `Iterazione` int(11) unsigned NOT NULL,
  `Quantita` float(13, 2) unsigned NOT NULL, -- mg/m^3
  PRIMARY KEY (`NomeElemento`,`CodManutenzione`, `Iterazione`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `spazio`
--
DROP TABLE IF EXISTS `spazio`;
CREATE TABLE `spazio` (
  `CodSpazio` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Tipo` char(50) NOT NULL,
  `Utente` char(50) DEFAULT NULL,
  PRIMARY KEY (`CodSpazio`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `specie`
--
DROP TABLE IF EXISTS `specie`;
CREATE TABLE `specie` (
  `Nome` char(50) NOT NULL,
  `Genere` char(50) NOT NULL,
  `Cultivar` char(50) NOT NULL,
  `Infestante` tinyint(1) NOT NULL DEFAULT '0',
  `DimMax` int(11) unsigned NOT NULL, -- centimetri (diametro)
  `IndiceAccrescimento` float(13, 2) NOT NULL, -- di solito da 0 a 20
  `PosLuce` char(50) NOT NULL, -- pieno sole, ombra o mezz'ombra
  `TipoLuce` char(50) NOT NULL, -- in/diretta
  `OreLuceVegetativo` int(11) NOT NULL, -- giornaliere
  `TempMax` int(11) NOT NULL, -- gradi centigradi
  `ConsistenzaTerreno` char(50) DEFAULT NULL,
  `DistanzaMinConflitto` int(11) unsigned DEFAULT NULL, -- centimetri
  `NumeroEsordi` int(11) unsigned DEFAULT '0',
  `NumeroPiante` int(11) unsigned DEFAULT '0',
  `CostoTotManutenzione` int(11) unsigned DEFAULT '0', -- euro
  `Dioica` tinyint(1) NOT NULL DEFAULT '0',
  `TempMin` int(11) NOT NULL, -- gradi centigradi
  `OreLuceRiposo` int(11) NOT NULL, -- giornaliere
  `Fogliame` char(50) NOT NULL,
  `NumIrrigGiornaliereVegetativo` int(11) NOT NULL,
  `NumIrrigGiornaliereRiposo` int(11) NOT NULL,
  `QuantitaIrrigVegetativo` int(11) NOT NULL, -- mL
  `QuantitaIrrigRiposo` int(11) NOT NULL, -- mL
  `PeriodicitaIrrigVegetativo` int(11) NOT NULL, -- ogni quanti giorni
  `PeriodicitaIrrigRiposo` int(11) NOT NULL, -- ogni quanti giorni
  `NumPianteVendute` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`Nome`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Calcolo dell'indice di accrescimento
DROP TRIGGER IF EXISTS `ImpostaIndiceAccrescimento`;
CREATE TRIGGER `ImpostaIndiceAccrescimento` 
	BEFORE INSERT ON `specie` FOR EACH ROW
	SET NEW.`IndiceAccrescimento` = NEW.`DimMax` * 100 /
		(NEW.`NumIrrigGiornaliereVegetativo` * 
			NEW.`QuantitaIrrigVegetativo` * 
			365/NEW.`PeriodicitaIrrigVegetativo`
		+ 0.5 * (NEW.`NumIrrigGiornaliereRiposo` * 
			NEW.`QuantitaIrrigRiposo` * 
			365/NEW.`PeriodicitaIrrigRiposo`));

-- Controllo sulla distanza minima di conflitto
DROP TRIGGER IF EXISTS `ControllaDistanzaMinConflitto`;
DELIMITER $$
CREATE TRIGGER `ControllaDistanzaMinConflitto` 
	BEFORE INSERT ON `specie` FOR EACH ROW
BEGIN
	IF(NEW.`DistanzaMinConflitto` < NEW.`DimMax` / 2) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'DistanzaMinConflitto troppo piccola.';
	END IF;
END $$
DELIMITER ;

-- Controllo del range delle temperature accettabili
DROP TRIGGER IF EXISTS `ControllaTemperature`;
DELIMITER $$
CREATE TRIGGER `ControllaTemperature` 
	BEFORE INSERT ON `specie` FOR EACH ROW
BEGIN
	IF(NEW.`TempMin` > NEW.`TempMax`) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Range di temperature non valido.';
	END IF;
END $$
DELIMITER ;

--
-- Creazione tabella `specieappassionatoaccount`
--
DROP TABLE IF EXISTS `specieappassionatoaccount`;
CREATE TABLE `specieappassionatoaccount` (
  `NomeSpecie` char(50) NOT NULL,
  `Utente` char(50) NOT NULL,
  PRIMARY KEY (`NomeSpecie`,`Utente`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `speciereportordini`
--
DROP TABLE IF EXISTS `speciereportordini`;
CREATE TABLE `speciereportordini` (
  `CodRepOrdini` int(11) unsigned NOT NULL,
  `NomeSpecie` char(50) NOT NULL,
  `Quantita` int(11) unsigned NOT NULL,
  PRIMARY KEY (`CodRepOrdini`,`NomeSpecie`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `terreno`
--
DROP TABLE IF EXISTS `terreno`;
CREATE TABLE `terreno` (
  `CodTerreno` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `PH` int(11) unsigned NOT NULL, -- da 3.5 a 9.0
  `Consistenza` char(50) NOT NULL,
  -- millidarcy (en.wikipedia.org/wiki/Permeability_(earth_sciences)#Units)
  `Permeabilita` float(20, 10) NOT NULL, 
  PRIMARY KEY (`CodTerreno`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `thread`
--
DROP TABLE IF EXISTS `thread`;
CREATE TABLE `thread` (
  `CodThread` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Nome` char(50) NOT NULL,
  `NumMedia` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`CodThread`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `vasiarredamento`
--
DROP TABLE IF EXISTS `vasiarredamento`;
CREATE TABLE `vasiarredamento` (
  `CodVaso` int(11) unsigned NOT NULL,
  `CodSpazio` int(11) unsigned NOT NULL,
  `Versione` int(11) unsigned NOT NULL,
  `CodPianta` int(11) unsigned NOT NULL,
  `PosX` int(11) NOT NULL,
  `PosY` int(11) NOT NULL,
  PRIMARY KEY (`CodVaso`,`CodSpazio`,`Versione`,`CodPianta`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `vaso`
--
DROP TABLE IF EXISTS `vaso`;
CREATE TABLE `vaso` (
  `CodVaso` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Materiale` char(50) NOT NULL,
  `DimensioneX` int(11) unsigned NOT NULL,
  `DimensioneY` int(11) unsigned NOT NULL,
  PRIMARY KEY (`CodVaso`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `vertice`
--
DROP TABLE IF EXISTS `vertice`;
CREATE TABLE `vertice` (
  `PosX` int(11) NOT NULL,
  `PosY` int(11) NOT NULL,
  PRIMARY KEY (`PosX`,`PosY`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Creazione tabella `verticisettore`
--
DROP TABLE IF EXISTS `verticisettore`;
CREATE TABLE `verticisettore` (
  `CodSettore` int(11) unsigned NOT NULL,
  `PosX` int(11) NOT NULL,
  `PosY` int(11) NOT NULL,
  PRIMARY KEY (`CodSettore`,`PosX`,`PosY`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Foreign keys
--
ALTER TABLE `pianta`
  ADD FOREIGN KEY(`NomeSpecie`) REFERENCES `specie`(`Nome`)
    ON DELETE SET NULL ON UPDATE CASCADE,
  ADD FOREIGN KEY(`CodTerreno`) REFERENCES `terreno`(`CodTerreno`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  ADD FOREIGN KEY(`CodOrdine`) REFERENCES `ordine`(`CodOrdine`)
    ON DELETE SET NULL ON UPDATE CASCADE,
  ADD FOREIGN KEY(`CodContenitore`)
	REFERENCES `contenitore`(`CodContenitore`)
		ON DELETE SET NULL ON UPDATE CASCADE;
  
ALTER TABLE `scheda`
  ADD FOREIGN KEY(`CodPianta`) REFERENCES `pianta`(`CodPianta`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  ADD FOREIGN KEY(`CodVaso`) REFERENCES `vaso`(`CodVaso`)
    ON DELETE SET NULL ON UPDATE CASCADE,
  ADD FOREIGN KEY(`Utente`) REFERENCES `account`(`Nickname`)
    ON DELETE CASCADE ON UPDATE CASCADE;
  
ALTER TABLE `ordine`
  ADD FOREIGN KEY(`Utente`) REFERENCES `account`(`Nickname`)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `post`
  ADD FOREIGN KEY(`Utente`) REFERENCES `account`(`Nickname`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  ADD FOREIGN KEY(`CodThread`) REFERENCES `thread`(`CodThread`)
    ON DELETE CASCADE ON UPDATE CASCADE;
  
ALTER TABLE `mediapost`
  ADD FOREIGN KEY(`Timestamp`,`Utente`)
	REFERENCES `post`(`Timestamp`,`Utente`)
		ON DELETE CASCADE ON UPDATE CASCADE,
  ADD FOREIGN KEY(`URL`) REFERENCES `media`(`URL`)
    ON DELETE CASCADE ON UPDATE CASCADE;
  
ALTER TABLE `specieappassionatoaccount`
  ADD FOREIGN KEY(`NomeSpecie`) REFERENCES `specie`(`Nome`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  ADD FOREIGN KEY(`Utente`) REFERENCES `account`(`Nickname`)
    ON DELETE CASCADE ON UPDATE CASCADE;
  
ALTER TABLE `reportmanutenzione`
  ADD FOREIGN KEY(`NomeSpecie`) REFERENCES `specie`(`Nome`)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `speciereportordini`
  ADD FOREIGN KEY(`CodRepOrdini`) REFERENCES `reportordini`(`CodRepOrdini`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  ADD FOREIGN KEY(`NomeSpecie`) REFERENCES `specie`(`Nome`)
    ON DELETE CASCADE ON UPDATE CASCADE;
  
ALTER TABLE `elementinecessarispecie`
  ADD FOREIGN KEY(`NomeSpecie`) REFERENCES `specie`(`Nome`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  ADD FOREIGN KEY(`NomeElemento`) REFERENCES `elemento`(`Nome`)
    ON DELETE CASCADE ON UPDATE CASCADE;
  
ALTER TABLE `elementiterreno`
  ADD FOREIGN KEY(`NomeElemento`) REFERENCES `elemento`(`Nome`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  ADD FOREIGN KEY(`CodTerreno`) REFERENCES `terreno`(`CodTerreno`)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `componentiterreno`
  ADD FOREIGN KEY(`CodTerreno`) REFERENCES `terreno`(`CodTerreno`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  ADD FOREIGN KEY(`NomeComponente`) REFERENCES `componente`(`Nome`)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `salute`
  ADD FOREIGN KEY(`CodContenitore`) 
	REFERENCES `contenitore`(`CodContenitore`)
		ON DELETE CASCADE ON UPDATE CASCADE;
  
ALTER TABLE `elementistatosalute`
  ADD FOREIGN KEY(`CodContenitore`,`Timestamp`) 
	REFERENCES `salute`(`CodContenitore`,`Timestamp`)
		ON DELETE CASCADE ON UPDATE CASCADE,
  ADD FOREIGN KEY(`NomeElemento`) REFERENCES `elemento`(`Nome`)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- I ripiani e i contenitori si possono spostare (ON DELETE SET NULL)  
ALTER TABLE `contenitore`
  ADD FOREIGN KEY(`CodRipiano`) REFERENCES `ripiano`(`CodRipiano`)
    ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE `ripiano`
  ADD FOREIGN KEY(`CodSezione`) REFERENCES `sezione`(`CodSezione`)
    ON DELETE SET NULL ON UPDATE CASCADE;

-- Le sezioni e le serre no (ON DELETE CASCADE)
ALTER TABLE `sezione`
  ADD FOREIGN KEY(`CodSerra`) REFERENCES `serra`(`CodSerra`)
    ON DELETE CASCADE ON UPDATE CASCADE;  
ALTER TABLE `serra`
  ADD FOREIGN KEY(`CodSede`) REFERENCES `sede`(`CodSede`)
    ON DELETE CASCADE ON UPDATE CASCADE;
  
ALTER TABLE `spazio`
  ADD FOREIGN KEY(`Utente`) REFERENCES `account`(`Nickname`)
    ON DELETE SET NULL ON UPDATE CASCADE;
  
ALTER TABLE `verticisettore`
  ADD FOREIGN KEY(`CodSettore`) REFERENCES `settore`(`CodSettore`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  ADD FOREIGN KEY(`PosX`,`PosY`) REFERENCES `vertice`(`PosX`,`PosY`)
    ON DELETE NO ACTION ON UPDATE NO ACTION;
  
ALTER TABLE `arredamento`
  ADD FOREIGN KEY(`CodSpazio`) REFERENCES `spazio`(`CodSpazio`)
    ON DELETE CASCADE ON UPDATE CASCADE;
  
ALTER TABLE `vasiarredamento`
  ADD FOREIGN KEY(`CodVaso`) REFERENCES `vaso`(`CodVaso`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  ADD FOREIGN KEY(`CodSpazio`,`Versione`) 
	REFERENCES `arredamento`(`CodSpazio`,`Versione`)
		ON DELETE CASCADE ON UPDATE CASCADE,
  ADD FOREIGN KEY(`CodPianta`) REFERENCES `pianta`(`CodPianta`)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `piantearredamentoinpienaterra`
  ADD FOREIGN KEY(`CodSpazio`,`Versione`) 
	REFERENCES `arredamento`(`CodSpazio`,`Versione`)
		ON DELETE CASCADE ON UPDATE CASCADE,
  ADD FOREIGN KEY(`CodPianta`) REFERENCES `pianta`(`CodPianta`)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `somministrazioneconcimazione`
  ADD FOREIGN KEY(`NomeElemento`) REFERENCES `elemento`(`Nome`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  ADD FOREIGN KEY(`CodManutenzione`) 
	REFERENCES `manutenzione`(`CodManutenzione`)
		ON DELETE CASCADE ON UPDATE CASCADE;
  
ALTER TABLE `esigenzaconcimazionepianta`
  ADD FOREIGN KEY(`CodPianta`) REFERENCES `pianta`(`CodPianta`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  ADD FOREIGN KEY(`CodManutenzione`) 
	REFERENCES `manutenzione`(`CodManutenzione`)
		ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `periodispecie`
  ADD FOREIGN KEY(`NomeSpecie`) REFERENCES `specie`(`Nome`)
    ON DELETE CASCADE ON UPDATE CASCADE;
  
ALTER TABLE `reportdiagnostica`
  ADD FOREIGN KEY(`CodPianta`) REFERENCES `pianta`(`CodPianta`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  ADD FOREIGN KEY(`CodTerreno`) REFERENCES `terreno`(`CodTerreno`)
    ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `sintomireport`
  ADD FOREIGN KEY(`CodPianta`,`Timestamp`) 
	REFERENCES `reportdiagnostica`(`CodPianta`,`Timestamp`)
		ON DELETE CASCADE ON UPDATE CASCADE,
  ADD FOREIGN KEY(`CodSintomo`) REFERENCES `sintomo`(`CodSintomo`)
    ON DELETE CASCADE ON UPDATE CASCADE;
  
ALTER TABLE `patologiereport`
  ADD FOREIGN KEY(`CodPianta`,`Timestamp`) 
	REFERENCES `reportdiagnostica`(`CodPianta`,`Timestamp`)
		ON DELETE CASCADE ON UPDATE CASCADE,
  ADD FOREIGN KEY(`CodPatologia`) REFERENCES `patologia`(`CodPatologia`)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `periodiprodotti`
  ADD FOREIGN KEY(`NomeProdotto`) REFERENCES `prodotto`(`Nome`)
    ON DELETE CASCADE ON UPDATE CASCADE;
  
ALTER TABLE `principiattiviprodotto`
  ADD FOREIGN KEY(`NomeProdotto`) REFERENCES `prodotto`(`Nome`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  ADD FOREIGN KEY(`NomePrincipioAttivo`) 
	REFERENCES `principioattivo`(`Nome`)
		ON DELETE CASCADE ON UPDATE CASCADE;
  
ALTER TABLE `prodottocombatte`
  ADD FOREIGN KEY(`NomeProdotto`) REFERENCES `prodotto`(`Nome`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  ADD FOREIGN KEY(`NomeAgentePatogeno`) REFERENCES `agentepatogeno`(`Nome`)
    ON DELETE CASCADE ON UPDATE CASCADE;
  
ALTER TABLE `agentipatogenipatologia`
  ADD FOREIGN KEY(`CodPatologia`) REFERENCES `patologia`(`CodPatologia`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  ADD FOREIGN KEY(`NomeAgentePatogeno`) REFERENCES `agentepatogeno`(`Nome`)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `prodottipatologia`
  ADD FOREIGN KEY(`CodPatologia`) REFERENCES `patologia`(`CodPatologia`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  ADD FOREIGN KEY(`NomeProdotto`) REFERENCES `prodotto`(`Nome`)
    ON DELETE CASCADE ON UPDATE CASCADE;
  
ALTER TABLE `sintomipatologia`
  ADD FOREIGN KEY(`CodPatologia`) REFERENCES `patologia`(`CodPatologia`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  ADD FOREIGN KEY(`CodSintomo`) REFERENCES `sintomo`(`CodSintomo`)
    ON DELETE CASCADE ON UPDATE CASCADE;
  
ALTER TABLE `immaginisintomi`
  ADD FOREIGN KEY(`CodSintomo`) REFERENCES `sintomo`(`CodSintomo`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  ADD FOREIGN KEY(`URL`) REFERENCES `immagine`(`URL`)
    ON DELETE CASCADE ON UPDATE CASCADE;
  
ALTER TABLE `prodottitrattamento`
  ADD FOREIGN KEY(`NomeProdotto`) REFERENCES `prodotto`(`Nome`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  ADD FOREIGN KEY(`CodManutenzione`) 
	REFERENCES `manutenzione`(`CodManutenzione`)
		ON DELETE CASCADE ON UPDATE CASCADE;
  
ALTER TABLE `manutenzione`
  ADD FOREIGN KEY(`CodPianta`) REFERENCES `pianta`(`CodPianta`)
    ON DELETE CASCADE ON UPDATE CASCADE;
  
ALTER TABLE `periodimanutenzione`
  ADD FOREIGN KEY(`CodManutenzione`) 
	REFERENCES `manutenzione`(`CodManutenzione`)
		ON DELETE CASCADE ON UPDATE CASCADE;
  
ALTER TABLE `reportassunzioni`
  ADD FOREIGN KEY(`CodSede`) REFERENCES `sede`(`CodSede`)
    ON DELETE CASCADE ON UPDATE CASCADE;
  
ALTER TABLE `settore`
  ADD FOREIGN KEY(`CodSpazio`) REFERENCES `spazio`(`CodSpazio`)
    ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Popolamento
--
INSERT INTO `media` VALUES
  ('./forum/img1.png'),
  ('./forum/img2.png'),
  ('./forum/img3.png'),
  ('./forum/img4.png'),
  ('./forum/img5.png'),
  ('./forum/img6.png'),
  ('./forum/img7.png'),
  ('./forum/img8.png'),
  ('./forum/img9.png'),
  ('./forum/img10.png');

INSERT INTO `thread`	(`CodThread`, `Nome`) VALUES
						('1', 'Bonsai Mania'),
						('2', 'Foto delle vostre piante preferite!'),
						('3', 'Dove posso trovare i migliori pini?'),
						('4', 'Piante natalizie'),
						('5', 'La vostra pianta preferita?'),
						('6', 'Viti: una passione'),
						('7', 'Garden designers'),
						('8', 'Vasi per cactus'),
						('9', 'Suggerimenti'),
						('10', 'Piante tropicali');
  
INSERT INTO `vertice` VALUES
  ('1', '1'), ('1', '2'), ('1', '3'), ('1', '4'), ('1', '5'), ('1', '6'), 
  ('1', '7'), ('1', '8'), ('1', '9'), ('1', '10'),
  ('2', '1'), ('2', '2'), ('2', '3'), ('2', '4'), ('2', '5'), ('2', '6'), 
  ('2', '7'), ('2', '8'), ('2', '9'), ('2', '10'),
  ('3', '1'), ('3', '2'), ('3', '3'), ('3', '4'), ('3', '5'), ('3', '6'), 
  ('3', '7'), ('3', '8'), ('3', '9'), ('3', '10'),
  ('4', '1'), ('4', '2'), ('4', '3'), ('4', '4'), ('4', '5'), ('4', '6'),
  ('4', '7'), ('4', '8'), ('4', '9'), ('4', '10'),
  ('5', '1'), ('5', '2'), ('5', '3'), ('5', '4'), ('5', '5'), ('5', '6'),
  ('5', '7'), ('5', '8'), ('5', '9'), ('5', '10'),
  ('6', '1'), ('6', '2'), ('6', '3'), ('6', '4'), ('6', '5'), ('6', '6'),
  ('6', '7'), ('6', '8'), ('6', '9'), ('6', '10'),
  ('7', '1'), ('7', '2'), ('7', '3'), ('7', '4'), ('7', '5'), ('7', '6'),
  ('7', '7'), ('7', '8'), ('7', '9'), ('7', '10'),
  ('8', '1'), ('8', '2'), ('8', '3'), ('8', '4'), ('8', '5'), ('8', '6'),
  ('8', '7'), ('8', '8'), ('8', '9'), ('8', '10'),
  ('9', '1'), ('9', '2'), ('9', '3'), ('9', '4'), ('9', '5'), ('9', '6'),
  ('9', '7'), ('9', '8'), ('9', '9'), ('9', '10'),
  ('10', '1'), ('10', '2'), ('10', '3'), ('10', '4'), ('10', '5'), 
  ('10', '6'), ('10', '7'), ('10', '8'), ('10', '9'), ('10', '10');

-- Da Wikipedia: Famiglia -> Genere -> Specie
-- Esempi di specie e generi: goo.gl/KSZj8F
-- Esempi di cultivars: en.wikipedia.org/wiki/Lists_of_cultivars
INSERT INTO `specie` (	`Nome`, 
						`Genere`,
						`Cultivar`, 
                        `Infestante`, 
                        `DimMax`, 
                        `PosLuce`, 
                        `TipoLuce`, 
                        `OreLuceVegetativo`, 
                        `TempMax`, 
                        `ConsistenzaTerreno`, 
                        `DistanzaMinConflitto`, 
                        `Dioica`, 
                        `TempMin`, 
                        `OreLuceRiposo`, 
                        `Fogliame`, 
                        `NumIrrigGiornaliereVegetativo`, 
                        `NumIrrigGiornaliereRiposo`, 
                        `QuantitaIrrigVegetativo`, 
                        `QuantitaIrrigRiposo`, 
                        `PeriodicitaIrrigVegetativo`, 
                        `PeriodicitaIrrigRiposo`) VALUES
  ('Mays', 'Zea', 'Mais', '0', '20', 'Pieno sole', 'diretta', 
	'9', '48', 'compatto', '15', '0', '1', '6', 'seghettato', 
	'2', '1', '20', '10', '10', '20'),
  ('Aestivum', 'Triticum', 'Grano', '0', '30', 'Pieno sole', 'diretta', 
	'11', '40', 'laterico', '15', '0', '5', '6', 'lacerato',
	'1', '1', '15', '10', '7', '15'),
  ('Minor', 'Ulmus', 'Olmo', '0', '70', 'Mezz\'ombra', 'indiretta', 
	'10', '45', 'argilloso', '35', '0', '10', '7', 'pennatosetto',
	'2', '0', '10', '7', '10', '30'),
  ('Perennis', 'Bellis', 'Pratolina', '0', '25', 'Mezz\'ombra', 'diretta',
	'8', '29', 'sabbioso', '15', '1', '15', '8', 'lacerato',
	'1', '1', '20', '15', '5', '14'),
  ('Officinalis', 'Taraxacum', 'Tarassaco', '1', '15', 'Ombra', 'indiretta',
	'12', '37', 'sciolto', '12', '0', '5', '4', 'seghettato',
	'1', '1', '25', '10', '15', '20'),
  ('Alba', 'Populus', 'Gattice', '0', '30', 'Ombra', 'indiretta',
	'7', '39', 'ibrido', '15', '1', '10', '6', 'lobato', 
	'1', '0', '18', '18', '20', '20'),
  ('Avium', 'Prunus', 'Ciliegio', '0', '90', 'Pieno sole', 'diretta',
	'11', '35', 'compatto', '60', '1', '7', '5', 'pennatifido',
	'2', '0', '13', '10', '15', '20'),
  ('Moraceae', 'Ficus', 'Trigmus', '0', '30', 'Mezz\'ombra', 'indiretta',
	'9', '46', 'argilloso', '35', '0', '10', '7', 'pennatosetto', 
	'2', '0', '10', '7', '10', '30'),
  ('Tiliaceae', 'Tilia', 'Tritcum', '0', '25', 'Pieno sole', 'diretta', 
	'8', '28', 'sabbioso', '15', '1', '15', '8', 'lacerato',
	'1', '1', '20', '15', '5', '14'),
  ('Rosaceae', 'Spiraea', 'Gattice', '1', '15', 'Mezz\'ombra', 'indiretta',
	'11', '31', 'sciolto', '12', '0', '5', '4', 'seghettato', 
	'1', '1', '25', '10', '15', '20');

INSERT INTO `account` (	`Nickname`, 
						`CittaResidenza`, 
						`Password`,
						`Email`, 
						`Nome`,
						`Cognome`,
						`DomandaSegreta`, 
						`RispostaSegreta`) VALUES
  ('jack86', 'Londra', 'om12km3lk9', 'jk86@qwemk.com',
	'Jack', 'White', 'Nome del gatto di tua suocera', 'Fuffy'),
  ('John244', 'Milano', '31oij4o1k2m3l', 'hn244@ekk.com',
	'John', 'Black', 'Dove sei nato', 'Bologna'),
  ('RobJDK', 'Roma', 'l3ep12ok3', 'robjdk@odlk.com', 
	'Rob', 'Huston', 'Cognome di tua madre', 'White'),
  ('MickeyMouse12', 'Napoli', 'jri3j412klm', 'mickeymouse12@ksmc.com',
	'Mickey', 'Mouse', 'Nome del cane', 'Bobby'),
  ('RoseLover', 'Venezia', 'kop41po2k4', 'roselover11@col.com',
	'Fred', 'Durst', 'Piatto preferito', 'Pizza'),
  ('jonny1', 'Londra', 'o1ij14ò2omkk', 'jonny1_ekd@ekdm.com',
	'Jonny', 'London', 'Film preferito', 'Pulp Fiction'),
  ('Alex_9', 'Roma', 'o3i4u1h24km', 'alex9@jdem.com',
	'Alex', 'White', 'Cantante preferito', 'Freddy Mercury'),
  ('Eric', 'Napoli', 'jbslkjrlkj413l4il', 'eric_lsk@edd.com',
	'Eric', 'Black', 'Data di laurea', '3 novembre 2015'),
  ('Paul311', 'Bologna', '5ji453j6o1', 'kelw@wol.com',
	'Paul', 'Jhonson', 'Quanto sei alto', '176'),
  ('PeterWhite', 'Roma', '12okm3n3knj2', 'sksld@amz.com', 
	'Peter', 'White', 'Film preferito', 'Titanic');

INSERT INTO `spazio` VALUES
  ('1', 'verde', 'Eric'),
  ('2', 'non verde', 'jonny1'),
  ('3', 'non verde', 'jack86'),
  ('4', 'verde', 'RoseLover'),
  ('5', 'non verde', 'Eric'),
  ('6', 'verde', 'MickeyMouse12'),
  ('7', 'non verde', 'RobJDK'),
  ('8', 'verde', 'MickeyMouse12'),
  ('9', 'non verde', 'Eric'),
  ('10', 'verde', 'RobJDK');

INSERT INTO `settore` (	`CodSettore`, 
						`Tipo`, 
						`Esposizione`, 
						`NumOreLuce`, 
						`CodSpazio`) VALUES
  ('1', 'piena terra', 'nord', '11', '9'),
  ('2', 'pavimentato', 'sud-est', '8', '6'),
  ('3', 'piena terra', 'ovest', '5', '5'),
  ('4', 'pavimentato', 'sud', '0', '10'),
  ('5', 'pavimentato', 'nord-est', '5', '9'),
  ('6', 'piena terra', 'est', '12', '4'),
  ('7', 'piena terra', 'nord', '7', '6'),
  ('8', 'pavimentato', 'sud-ovest', '0', '3'),
  ('9', 'piena terra', 'nord', '6', '2'),
  ('10', 'pavimentato', 'nord-ovest', '7', '1');

INSERT INTO `verticisettore` (`CodSettore`, `PosX`, `PosY`) VALUES
  ('1', '1', '1'), ('1', '4', '1'), ('1', '1', '5'), ('1', '4', '5'),
  ('2', '1', '2'), ('2', '4', '2'), ('2', '1', '10'), ('2', '4', '10'),
  ('3', '3', '5'), ('3', '5', '10'), ('3', '1', '10'),
  ('4', '5', '1'), ('4', '2', '2'), ('4', '8', '2'), ('4', '3', '8'), 
	('4', '5', '8'),
  ('5', '7', '4'), ('5', '10', '4'), ('5', '7', '10'),('5', '10', '10'),
  ('6', '1', '6'), ('6', '4', '6'), ('6', '1', '1'),
  ('7', '5', '1'), ('7', '5', '5'), ('7', '9', '1'),
  ('8', '2', '2'), ('8', '2', '7'), ('8', '7', '2'), ('8', '7', '7'),
  ('9', '4', '4'), ('9', '4', '8'), ('9', '8', '4'), ('9', '8', '8'),
  ('10', '3', '3'), ('10', '3', '6'), ('10', '6', '3'), ('10', '6', '6');

INSERT INTO `post` VALUES
  ('2016-12-27 11:56:08', 'jack86', '3.4', 'Secondo me...', '4'),
  ('2015-09-12 12:14:58', 'Paul311', '3.3', 'La pianta che...', '1'),
  ('2016-02-23 15:38:45', 'PeterWhite', '4.7', 'Penso che...', '10'),
  ('2016-01-10 09:12:34', 'Eric', '4.9', 'Secondo me...', '9'),
  ('2015-05-09 14:44:40', 'RoseLover', '1.4', 'A mio parere...', '5'),
  ('2014-12-07 18:21:17', 'Alex_9', '2.3', 'Secondo me...', '6'),
  ('2016-07-01 07:20:57', 'jack86', '4.1', 'Io credo che...', '3'),
  ('2015-08-29 11:16:49', 'RobJDK', '3.0', 'Secondo me...', '2'),
  ('2016-10-28 17:38:38', 'RoseLover', '2.9', 'Secondo me...', '6'),
  ('2015-09-30 08:45:18', 'jack86', '5.0', 'Forse potrebbe...', '4');

INSERT INTO `mediapost` VALUES
  ('2016-12-27 11:56:08', 'jack86', './forum/img3.png'),
  ('2016-02-23 15:38:45', 'PeterWhite', './forum/img4.png'),
  ('2016-02-23 15:38:45', 'PeterWhite', './forum/img9.png'),
  ('2016-02-23 15:38:45', 'PeterWhite', './forum/img2.png'),
  ('2016-02-23 15:38:45', 'PeterWhite', './forum/img8.png'), 
  ('2016-01-10 09:12:34', 'Eric', './forum/img4.png'),
  ('2014-12-07 18:21:17', 'Alex_9', './forum/img7.png'),
  ('2016-07-01 07:20:57', 'jack86', './forum/img1.png'),
  ('2016-07-01 07:20:57', 'jack86', './forum/img6.png'),
  ('2016-07-01 07:20:57', 'jack86', './forum/img5.png'),
  ('2015-08-29 11:16:49', 'RobJDK', './forum/img1.png'),
  ('2015-09-30 08:45:18', 'jack86', './forum/img10.png'),
  ('2015-09-30 08:45:18', 'jack86', './forum/img6.png');

INSERT INTO `specieappassionatoaccount` VALUES
  ('Avium', 'RobJDK'),
  ('Rosaceae', 'jack86'),
  ('Officinalis', 'PeterWhite'),
  ('Tiliaceae', 'Alex_9'),
  ('Alba', 'RoseLover'),
  ('Moraceae', 'MickeyMouse12'),
  ('Minor', 'John244'),
  ('Avium', 'Eric'),
  ('Minor', 'jack86'),
  ('Mays', 'Alex_9');

INSERT INTO `ordine` VALUES
  ('1', '2016-01-14 09:30:15', 'pendente', 'Paul311'),
  ('2', '2016-10-16 18:43:18', 'in processazione', 'Alex_9'),
  ('3', '2016-02-03 14:15:46', 'spedito', 'PeterWhite'),
  ('4', '2016-07-19 16:08:05', 'in preparazione', 'MickeyMouse12'),
  ('5', '2016-09-29 05:05:00', 'in processazione', 'Alex_9'),
  ('6', '2016-05-05 09:13:48', 'pendente', 'jack86'),
  ('7', '2016-11-09 13:59:56', 'in preparazione', 'Eric'),
  ('8', '2016-04-15 22:48:37', 'in processazione', 'jack86'),
  ('9', '2016-03-23 14:36:47', 'spedito', 'Eric'),
  ('10', '2016-12-27 23:14:32', 'evaso', 'jack86');

INSERT INTO `sede` (`CodSede`, 
					`NumDipendenti`, 
					`Indirizzo`, 
					`Nome`, 
					`Capienza`) VALUES
  ('1', '35', 'Via Roma 34, Pisa, Italia', 'Da Giorgi', '400'),
  ('2', '12', 'Via Venezia 19, Roma, Italia', 'PuntoPianta', '300'),
  ('3', '50', 'Via Diotisalvi 9, Napoli, Italia', 'GarDesign', '100'),
  ('4', '38', 'Via Giorgi 5, Bologna, Italia', 'Magazzino Bologna', '200'),
  ('5', '10', 'St James Street 12, Londra, UK', 'Il Pollice Verde', '300'),
  ('6', '26', 'Via G. Paolo II 34, Bari, Italia', 'SOS Piante', '250'),
  ('7', '31', 'Via Garibaldi 34, Brindisi, Italia', 'Mania Bonsai', '120'),
  ('8', '42', 'Via XIV Maggio 1, Pescara, Italia', 'Da Piero', '300'),
  ('9', '68', 'Via Togliatti 3, Brescia, Italia', 'Da zio Mario', '250'),
  ('10', '18', 'Via Veneto 2, Milano, Italia', 'Tutto in Verde', '300');

INSERT INTO `serra` (	`CodSerra`, 
						`Nome`, 
						`CodSede`, 
						`Indirizzo`, 
						`Larghezza`, 
						`Altezza`, 
						`Capienza`) VALUES
('1', 'Serra1-1', '1', 'Via Roma 18, Pisa, Italia', '50', '50', '100'),
('2', 'Serra2-1', '1', 'Via Roma 19, Pisa, Italia', '50', '50', '100'),
('3', 'Serra3-1', '1', 'Via Roma 20, Pisa, Italia', '50', '50', '100'),
('4', 'Serra4-1', '1', 'Via Roma 21, Pisa, Italia', '50', '50', '100'),
('5', 'Serra1-2', '2', 'Via Vittorio Veneto 26, Venezia, Italia', '70', 
	'60', '150'),
('6', 'Serra2-2', '2', 'Via Vittorio Veneto 27, Venezia, Italia', '70', 
	'60', '150'),
('7', 'Serra1-3', '3', 'Via Togliatti 7, Bari, Italia', '40', '40', '80'),
('8', 'Serra1-5', '5', 'Via Giovanni Paolo II 14, Milano, Italia', '80',
	'50', '90'),
('9', 'Serra2-5', '5', 'Via Giovanni Paolo II 15, Milano, Italia', '80',
	'50', '90'),
('10', 'Serra1-6', '6', 'Via Bovio 2, Ancona, Italia', '100', '50', '120'),
('11', 'Serra2-6', '6', 'Via Bovio 3, Ancona, Italia', '100', '50', '120'),
('12', 'Serra1-9', '9', 'Via Garibaldi 9, Catania, Italia', '100', '120', 
	'180'),
('13', 'Serra1-10', '10', 'Via XIV Maggio 10, Milano, Italia', '40', '50'
	'100');

INSERT INTO `sezione` (	`CodSezione`, 
						`Nome`, 
						`CodSerra`, 
						`Capienza`, 
						`Irrigazione`, 
						`Illuminazione`, 
						`Umidita`, 
						`Temperatura`, 
						`Quarantena`) VALUES
  ('1', 'Sezione1-1-1', '1', '20', '75', '50', '13', '20', '0'),
  ('2', 'Sezione2-1-1', '1', '30', '71', '67', '9', '21', '0'),
  ('3', 'Sezione1-2-1', '2', '25', '64', '55', '10', '20.5', '0'),
  ('4', 'Sezione1-3-1', '3', '35', '67', '53', '12', '21.5', '0'),
  ('5', 'Sezione1-4-1', '4', '20', '68', '51', '9.5', '19', '0'),
  ('6', 'Sezione1-1-2', '5', '40', '68', '51', '9.5', '19', '0'),
  ('7', 'Sezione1-2-2', '6', '45', '76', '64', '5', '22', '0'),
  ('8', 'Sezione1-1-3', '7', '25', '84', '71', '11', '22.5', '0'),
  ('9', 'Sezione2-1-3', '7', '10', '70', '35', '18', '18', '1'),
  ('10', 'Sezione1-1-6', '10', '55', '66', '68', '12', '20.5', '0');
                        
INSERT INTO `ripiano` (	`CodRipiano`, 
						`CodSezione`, 
						`Capienza`, 
						`Irrigazione`) VALUES
  ('1', '1', '5', '71'),
  ('2', '1', '5', '72'),
  ('3', '1', '5', '70'),
  ('4', '1', '5', '66'),
  ('5', '2', '10', '69'),
  ('6', '2', '15', '68'),
  ('7', '3', '10', '65'),
  ('8', '3', '15', '65'),
  ('9', '4', '20', '71'),
  ('10', '4', '15', '74'),
  ('11', '6', '20', '79'),
  ('12', '6', '20', '64'),
  ('13', '8', '20', '68'),
  ('14', '9', '10', '77'),
  ('15', '10', '40', '75');

INSERT INTO `contenitore` (	`CodContenitore`, 
							`Dimensione`, 
							`Idratazione`, 
							`Irrigazione`, 
							`CodRipiano`) VALUES
  ('1', '50', '72', '81.5', '1'),
  ('2', '30', '71', '78', '2'),
  ('3', '40', '59.5', '79', '4'),
  ('4', '55', '69', '82', '5'),
  ('5', '20', '74.5', '84', '7'),
  ('6', '70', '78', '87.5', '8'),
  ('7', '10', '82', '77', '9'),
  ('8', '30', '58.5', '84', '10'),
  ('9', '35', '71', '79', '11'),
  ('10', '30', '68', '85.5', '12'),
  ('11', '50', '64.5', '80', '13'),
  ('12', '45', '74', '83.5', '15');

INSERT INTO `salute` VALUES
  ('1', '2014-04-20 09:30:15', '15', '40.5', '23'),
  ('1', '2014-05-20 11:09:47', '16', '37', '27.5'),
  ('1', '2014-08-20 13:41:17', '15.5', '38', '24'),
  ('3', '2015-10-14 17:13:02', '14.7', '45.1', '29'),
  ('3', '2015-11-14 14:16:57', '17.8', '40', '28.5'),
  ('5', '2015-05-08 05:06:12', '15', '38', '26'),
  ('5', '2015-06-08 06:11:35', '15.6', '38', '26.2'),
  ('5', '2015-07-08 05:07:43', '17', '37', '26.9'),
  ('5', '2015-08-08 07:01:55', '16.1', '38', '27.4'),
  ('6', '2016-08-19 04:01:14', '19', '42.3', '25'),
  ('6', '2015-10-19 03:02:12', '18.6', '9', '26');

INSERT INTO `elemento` VALUES
  ('calcio', '16'),
  ('magnesio', '20.8'),
  ('ferro', '25'),
  ('potassio', '11'),
  ('azoto', '12'),
  ('fosforo', '13.7'),
  ('zolfo', '9'),
  ('boro', '19'),
  ('manganese', '7'),
  ('rame', '23'),
  ('zinco', '8'),
  ('molibdeno', '10.5'),
  ('cloro', '15'),
  ('nichel', '11.3');

INSERT INTO `elementistatosalute` VALUES
  ('1', '2014-04-20 09:30:15', 'calcio', '16.2'),
  ('1', '2014-05-20 11:09:47', 'azoto', '13.6'),
  ('1', '2014-05-20 11:09:47', 'boro', '41.0'),
  ('3', '2015-10-14 17:13:02', 'zinco', '21.5'),
  ('3', '2015-10-14 17:13:02', 'ferro', '9.3'),
  ('5', '2015-05-08 05:06:12', 'potassio', '11.5'),
  ('5', '2015-05-08 05:06:12', 'manganese', '4.6'),
  ('5', '2015-06-08 06:11:35', 'nichel', '24.9'),
  ('5', '2015-07-08 05:07:43', 'azoto', '15.4'),
  ('6', '2016-08-19 04:01:14', 'zolfo', '7.5'),
  ('6', '2016-08-19 04:01:14', 'molibdeno', '5.1'),
  ('6', '2015-10-19 03:02:12', 'cloro', '15.2');

-- it.wikipedia.org/wiki/Reazione_del_terreno#Classificazione_dei_terreni
-- PH: acido [3.5, 6.9] | alcalino [7.0, 9.0]
-- Permeabilita: [0.0001, 10^8]
INSERT INTO `terreno` VALUES
  ('1', '6.2', 'sciolto', '204.482'),
  ('2', '3.9', 'argilloso', '204.482'),
  ('3', '4.2', 'sabbioso', '204.482'),
  ('4', '6.0', 'laterico', '204.482'),
  ('5', '6.8', 'compatto', '204.482'),
  ('6', '3.7', 'argilloso', '204.482'),
  ('7', '4.2', 'compatto', '204.482'),
  ('8', '5.3', 'sciolto', '204.482'),
  ('9', '4.7', 'ibrido', '204.482'),
  ('10', '5.9', 'laterico', '204.482');

INSERT INTO `componente` VALUES 
  ('sabbia'), ('torba'), ('ghiaia'), ('argilla'), ('limo');

INSERT INTO `componentiterreno` VALUES
  ('1', 'sabbia', '39'), ('1', 'torba', '8'), ('1', 'argilla', '41'),
  ('2', 'limo', '41'), ('2', 'torba', '13'), ('2', 'sabbia', '11'),
  ('3', 'ghiaia', '12'), ('3', 'argilla', '74.9'),
  ('4', 'sabbia', '75'), ('4', 'limo', '19'), ('4', 'torba', '5'),
  ('5', 'limo', '12.2'), ('5', 'ghiaia', '48.5'), ('5', 'sabbia', '18'),
  ('6', 'torba', '24'), ('6', 'sabbia', '14'), ('6', 'argilla', '24'),
  ('7', 'sabbia', '42'), ('7', 'torba', '45'),
  ('8', 'argilla', '49'), ('8', 'limo', '17'), ('8', 'sabbia', '18.5'),
  ('9', 'ghiaia', '71'), ('9', 'torba', '14'),
  ('10', 'argilla', '23.5'), ('10', 'ghiaia', '48'), ('10', 'sabbia', '24');

INSERT INTO `elementiterreno` (	`CodTerreno`, 
								`NomeElemento`, 
								`Concentrazione`) VALUES
  ('1', 'calcio', '14.2'), ('1', 'rame', '18'), ('1', 'ferro', '62'),
  ('2', 'zinco', '82'), ('2', 'cloro', '12.4'),
  ('3', 'nichel', '46.1'), ('3', 'fosforo', '41'), ('3', 'azoto', '3.9'),
  ('4', 'ferro', '41.6'), ('4', 'boro', '16.5'), ('4', 'azoto', '37'),
  ('5', 'molibdeno', '18'), ('5', 'cloro', '42'), ('5', 'boro', '7.8'),
  ('6', 'boro', '71'), ('6', 'azoto', '4.1'),
  ('7', 'zolfo', '47'), ('7', 'cloro', '13'), ('7', 'fosforo', '31.4'),
  ('8', 'cloro', '70'), ('8', 'potassio', '12.5'), ('8', 'boro', '6.3'),
  ('9', 'zinco', '19.7'), ('9', 'azoto', '76.1'),
  ('10', 'magnesio', '56'), ('10', 'molibdeno', '14.3'), 
    ('10', 'cloro', '4');

INSERT INTO `elementinecessarispecie` VALUES
  ('Mays', 'calcio', '13.4'), ('Mays', 'azoto', '41.2'), 
  ('Mays', 'fosforo', '36.2'), ('Mays', 'cloro', '7.8'), 
  ('Aestivum', 'ferro', '7.9'), ('Aestivum', 'zolfo', '28.4'), 
  ('Aestivum', 'rame', '15.6'), 
  ('Minor', 'magnesio', '9.4'), ('Minor', 'azoto', '18.6'), 
  ('Perennis', 'potassio', '47.1'), ('Perennis', 'fosforo', '11.9'),
  ('Perennis', 'zolfo', '19.5'), ('Perennis', 'molibdeno', '3.5'), 
  ('Officinalis', 'azoto', '29.4'), ('Officinalis', 'zinco', '2.9'), 
  ('Alba', 'zinco', '52.3'),
  ('Avium', 'molibdeno', '16.8'), ('Avium', 'zolfo', '31.2'),
  ('Moraceae', 'ferro', '34.2'), ('Moraceae', 'rame', '12.2'), 
  ('Moraceae', 'cloro', '10.2'), 
  ('Tiliaceae', 'fosforo', '15.3'), ('Tiliaceae', 'nichel', '9.0'),
  ('Rosaceae', 'calcio', '18.5'), ('Rosaceae', 'boro', '51.2'),
  ('Rosaceae', 'manganese', '5.6');

INSERT INTO `pianta` (	`CodPianta`,
						`NomeSpecie`,
						`DimAttuale`,
                        `Prezzo`,
                        `CodTerreno`, 
                        `CodContenitore`, 
                        `CodOrdine`) VALUES
  ('1', 'Mays', '28', '15', '4', NULL, '10'),
  ('2', 'Mays', '23', '20', '4', '8', NULL),
  ('3', 'Aestivum', '12', '48', '2', '9', '6'),
  ('4', 'Minor', '10', '10', '1', NULL, '3'),
  ('5', 'Perennis', '70', '60', '6', '6', NULL),
  ('6', 'Officinalis', '40', '30', '2', NULL, '9'),
  ('7', 'Avium', '47', '20', '8', '1', NULL),
  ('8', 'Moraceae', '15', '30', '7', '5', '1'),
  ('9', 'Tiliaceae', '19', '13', '10', '11', NULL),
  ('10', 'Rosaceae', '5', '8', '9', '7', '2'),
  ('11', 'Alba', '41', '40', '5', '12', '8'),
  ('12', 'Perennis', '34', '38', '3', '3', '5'),
  ('13', 'Minor', '29', '20', '2', NULL, '7'),
  ('14', 'Moraceae', '18', '15', '10', NULL, '4');

INSERT INTO `manutenzione` (`CodManutenzione`,
							`CodPianta`,
							`TipoManutenzione`, /* potatura, rinvaso, 
												concimazione, trattamento */
							`TipoCreazione`, /* su richiesta, 
											    programmata, automatica */
							`Costo`, -- euro
						-- it.wikipedia.org/wiki/Potatura#Metodi_di_potatura
							`TipoPotatura`, 
							`TipoSomm`, -- disciolto, nebulizzato
							`DataInizio`,
							`NumIntervAnnuali`,
							`Scadenza`) VALUES
  ('1', '1', 'potatura', 'su richiesta', '25', 'capitozzatura', NULL, 
	'2013-05-02', '3', '2020-04-05'),
  ('2', '2', 'rinvaso', 'su richiesta', '5', NULL, NULL, 
	'2013-10-05', '1', '2013-10-05'),
  ('3', NULL, 'concimazione', 'programmata', '7', NULL, 'disciolto', 
	'2014-01-14', '12', '2018-01-14'),
  ('4', '4', 'trattamento', 'su richiesta', '19', NULL, 'nebulizzato', 
	'2012-07-20', '5', '2012-11-20'),
  ('5', '5', 'potatura', 'programmata', '30', 'sfogliatura', NULL, 
	'2015-10-10', '3', '2017-10-10'),
  ('6', '6', 'rinvaso', 'su richiesta', '17', NULL, NULL, 
	'2014-05-05', '1', '2014-05-05'),
  ('7', '8', 'potatura', 'su richiesta', '36', 'piegatura', NULL, 
	'2014-07-12', '3', '2014-9-12'),
  ('8', '10', 'trattamento', 'programmata', '45', NULL, 'nebulizzato',
	'2016-12-25', '12', '2018-12-25'),
  ('9', NULL, 'concimazione', 'programmata', '16', NULL, 'disciolto', 
	'2017-01-01', '6', '2017-12-31'),
  ('10', '13', 'rinvaso', 'su richiesta', '8', NULL, NULL,
	'2015-10-09', '1', '2015-10-09');

INSERT INTO `prodotto` VALUES
  ('Muflix', 'MedProducts', '0', 'disciolto'),
  ('Frenox', 'GreenFix', '2', 'nebulizzato'),
  ('Muginex', 'MedProducts', '0', 'disciolto'),
  ('Trenofis', 'Plants Boss', '0', 'disciolto'),
  ('Axerol', 'GreenFix', '5', 'nebulizzato'),
  ('Picrifon', 'MedProducts', '0', 'disciolto'),
  ('Sorivan', 'GreenFix', '15', 'nebulizzato'),
  ('Cifitox', 'MedProducts', '1', 'disciolto'),
  ('Polinaf', 'Plants Boss', '3', 'nebulizzato'),
  ('Sfrex', 'MedProducts', '0', 'nebulizzato');

INSERT INTO `prodottitrattamento` (	`CodManutenzione`, 
									`NomeProdotto`, 
									`Dose`) VALUES
  ('4', 'Muflix', '15'),
  ('4', 'Frenox', '21'),
  ('4', 'Muginex', '2'),
  ('4', 'Trenofis', '4'),
  ('4', 'Axerol', '1'),
  ('8', 'Picrifon', '41'),
  ('8', 'Sorivan', '12'),
  ('8', 'Cifitox', '11'),
  ('8', 'Polinaf', '8'),
  ('8', 'Sfrex', '2');

INSERT INTO `periodimanutenzione` VALUES
  ('1', '2000-02-01', '2000-06-01'),
  ('4', '2000-01-01', '2000-03-01'),
  ('4', '2000-04-01', '2000-06-01'),
  ('4', '2000-07-01', '2000-12-01'),
  ('5', '2000-02-01', '2000-03-01'),
  ('5', '2000-07-01', '2000-09-01'),
  ('5', '2000-10-01', '2000-11-01'),
  ('7', '2000-06-01', '2000-12-01'),
  ('8', '2000-10-01', '2001-05-01'),
  ('9', '2000-12-01', '2000-03-01'),
  ('9', '2000-08-01', '2000-09-01');

INSERT INTO `somministrazioneconcimazione` (	`CodManutenzione`, 
												`NomeElemento`, 
												`Iterazione`, 
												`Quantita`) VALUES
  ('3', 'fosforo', '1', '24.3'),
  ('3', 'fosforo', '2', '20.3'),
  ('3', 'fosforo', '3', '16.3'),
  ('3', 'manganese', '1', '5.0'),
  ('3', 'manganese', '2', '10.0'),
  ('9', 'cloro', '1', '13.2'),
  ('9', 'cloro', '2', '15.2'),
  ('9', 'ferro', '1', '5.4'),
  ('9', 'ferro', '2', '6.3'),
  ('9', 'ferro', '3', '7.2');

INSERT INTO `esigenzaconcimazionepianta` VALUES
  ('1', '3'), ('2', '3'), ('4', '3'), ('7', '3'), ('9', '3'), 
  ('2', '9'), ('3', '9'), ('4', '9'), ('5', '9'), ('10', '9');

INSERT INTO `vaso` (`CodVaso`, 
					`Materiale`, 
					`DimensioneX`, 
					`DimensioneY`) VALUES
  ('1', 'cotto', '20', '20'), --
  ('2', 'ceramica', '30', '30'),
  ('3', 'terracotta', '45', '25'),
  ('4', 'cemento', '70', '70'), --
  ('5', 'cotto', '25', '30'),
  ('6', 'pietra', '35', '35'), --
  ('7', 'ceramia', '40', '20'),
  ('8', 'plastica', '80', '70'), --
  ('9', 'terracotta', '40', '25'),
  ('10', 'pietra', '15', '15'); --

INSERT INTO `scheda` (	`CodScheda`, 
						`CodPianta`, 
						`CodVaso`, 
						`Utente`, 
						`DataAcquisto`, 
						`Settore`, 
						`Collocazione`, 
						`PosX`, 
						`PosY`) VALUES
  ('1', '1', '6', 'jack86', '2016-06-05', '1', 'vaso', '3', '4'),
  ('2', '3', NULL, 'Paul311', '2016-07-12', '2', 'pienat erra', '1', '9'),
  ('3', '4', '1', 'RobJDK', '2016-02-13', '3', 'vaso', '3', '8'),
  ('4', '6', '10', 'Eric', '2016-10-09', '4', 'vaso', '4', '3'),
  ('5', '8', NULL, 'Eric', '2016-04-30', '5', 'piena terra', '8', '5'),
  ('6', '10', NULL, 'Eric', '2016-12-23', '6', 'piena terra', '1', '5'),
  ('7', '11', '8', 'Eric', '2016-08-04', '7', 'vaso', '6', '2'),
  ('8', '12', '4', 'MickeyMouse12', '2016-09-10', '8', 'vaso', '5', '3'),
  ('9', '13', NULL, 'RoseLover', '2016-11-18', '9', 
	'piena terra', '7', '6'),
  ('10', '14', NULL, 'Eric', '2016-01-28', '10', 'piena terra', '4', '5');

INSERT INTO `arredamento` (`CodSpazio`, `Versione`) VALUES
  ('1', '1'), ('1', '2'),
  ('2', '1'), 
  ('3', '1'), ('3', '2'),
  ('4', '1'),
  ('5', '1'),
  ('6', '1'),
  ('7', '1'), ('7', '2'), ('7', '3'),
  ('8', '1'),
  ('9', '1'), ('9', '2'),
  ('10', '1');

INSERT INTO `vasiarredamento` (	`CodVaso`, 
								`CodSpazio`, 
								`Versione`, 
								`CodPianta`, 
								`PosX`, 
								`PosY`) VALUES
  ('4', '6', '1', '12', '1', '9'),
  ('1', '10', '1', '4', '4', '3'),
  ('8', '9', '1', '11', '7', '5'),
  ('8', '9', '2', '11', '8', '5'),
  ('6', '3', '1', '1', '2', '2'),
  ('6', '3', '2', '1', '5', '3'),
  ('10', '1', '1', '6', '6', '4'),
  ('10', '1', '2', '6', '4', '5');

INSERT INTO `piantearredamentoinpienaterra` (	`CodPianta`, 
												`CodSpazio`, 
												`Versione`, 
												`PosX`, 
												`PosY`) VALUES
  ('14', '9', '1', '3', '2'),
  ('14', '9', '2', '3', '4'),
  ('10', '5', '1', '3', '8'),
  ('13', '4', '1', '1', '5'),
  ('3', '6', '1', '6', '2'),
  ('8', '1', '1', '6', '4'),
  ('8', '1', '2', '4', '5');

INSERT INTO `periodispecie` (	`NomeSpecie`, 
								`DataInizio`, 
								`DataFine`, 
								`Tipo`) VALUES
  ('Mays', '2000-10-01', '2001-02-01', 'riposo'),
  ('Mays', '2001-02-01', '2001-08-01', 'fruttificazione'),
  ('Mays', '2001-08-01', '2001-10-01', 'fioritura'),
  ('Aestivum', '2000-01-01', '2000-06-01', 'fioritura'),
  ('Aestivum', '2000-06-01', '2001-01-01', 'riposo'),
  ('Minor', '2000-04-01', '2000-12-01', 'fruttificazione'),
  ('Minor', '2000-12-01', '2001-04-01', 'riposo'),
  ('Perennis', '2000-07-01', '2000-11-01', 'fioritura'),
  ('Perennis', '2000-11-01', '2001-07-01', 'riposo'),
  ('Officinalis', '2000-04-01', '2000-08-01', 'fruttificazione'),
  ('Officinalis', '2000-08-01', '2001-04-01', 'riposo'),
  ('Alba', '2000-09-01', '2001-03-01', 'riposo'),
  ('Alba', '2001-03-01', '2001-09-01', 'fioritura'),
  ('Avium', '2000-10-01', '2001-02-01', 'riposo'),
  ('Avium', '2001-02-01', '2001-10-01', 'fruttificazione'),
  ('Moraceae', '2000-08-01', '2000-09-01', 'fruttificazione'),
  ('Moraceae', '2000-09-01', '2001-08-01', 'riposo'),
  ('Tiliaceae', '2000-05-01', '2000-08-01', 'fruttificazione'),
  ('Tiliaceae', '2000-08-01', '2001-05-01', 'riposo'),
  ('Rosaceae', '2000-04-01', '2000-10-01', 'fioritura'),
  ('Rosaceae', '2000-10-01', '2001-04-01', 'riposo');

INSERT INTO `periodiprodotti` VALUES
  ('Muflix', '2000-02-01', '2000-12-01'),
  ('Frenox', '2000-01-01', '2000-11-01'),
  ('Muginex', '2000-02-01', '2000-05-01'),
  ('Muginex', '2000-06-01', '2000-11-01'),
  ('Trenofis', '2000-01-01', '2000-10-01'),
  ('Axerol', '2000-05-01', '2001-04-01'),
  ('Sorivan', '2000-03-01', '2000-11-01'),
  ('Polinaf', '2000-10-01', '2001-09-01'),
  ('Sfrex', '2000-07-01', '2001-01-01'),
  ('Sfrex', '2000-02-01', '2000-06-01');

INSERT INTO `agentepatogeno` VALUES	
  ('Metcalfa', 'insetto'),	
  ('Psilla', 'insetto'),
  ('Cicalina', 'insetto'),
  ('Dorifora', 'insetto'),
  ('Acarus', 'acaro'),
  ('Crittogamis', 'crittogame'),
  ('Fongomus', 'fungo'),
  ('Brucialis', 'virus'),
  ('Destroplantus', 'virus'),
  ('Platterium', 'batterio');

INSERT INTO `prodottocombatte` (	`NomeProdotto`, 
									`NomeAgentePatogeno`, 
									`Dosaggio`) VALUES
  ('Muflix', 'Metcalfa', '15.4'),
  ('Frenox', 'Psilla', '9.2'),
  ('Muginex', 'Cicalina', '19.2'),
  ('Trenofis', 'Dorifora', '17.0'),
  ('Axerol', 'Acarus', '9.1'),
  ('Picrifon', 'Crittogamis', '24.3'),
  ('Sorivan', 'Fongomus', '17.5'),
  ('Cifitox', 'Brucialis', '11.1'),
  ('Polinaf', 'Destroplantus', '25.7'),
  ('Sfrex', 'Platterium', '16.0');

INSERT INTO `patologia` VALUES
  ('1', '2000-01-01', '2000-12-31', '21.3', '3.5'),
  ('2', '2000-02-01', '2000-12-31', '4.6', '8.2'),
  ('3', '2000-01-01', '2000-11-30', '19.2', '2.4'),
  ('4', '2000-02-01', '2000-12-31', '11.2', '1.3'),
  ('5', '2000-01-01', '2000-11-30', '4.1', '6.9'),
  ('6', '2000-02-01', '2000-12-31', '9.4', '4.0'),
  ('7', '2000-01-01', '2000-12-31', '15.1', '3.1'),
  ('8', '2000-02-01', '2000-12-31', '12.7', '2.4'),
  ('9', '2000-01-01', '2000-12-31', '45.3', '0.8'),
  ('10', '2000-04-01', '2000-12-31', '19.2', '2.4');

INSERT INTO `agentipatogenipatologia` VALUES
  ('1', 'Metcalfa'),
  ('1', 'Psilla'),
  ('2', 'Cicalina'),
  ('3', 'Dorifora'),
  ('4', 'Acarus'),
  ('5', 'Crittogamis'),
  ('6', 'Fongomus'),
  ('6', 'Brucialis'),
  ('7', 'Fongomus'),
  ('8', 'Destroplantus'),
  ('9', 'Platterium'),
  ('9', 'Psilla'),
  ('9', 'Cicalina'),
  ('10', 'Acarus');

INSERT INTO `principioattivo` VALUES
  ('acido acetilsalicilico'),
  ('alcaloide'),
  ('morfina'),
  ('nicotina'),
  ('terpene'),
  ('carotene'),
  ('glicoside'),
  ('digossina'),
  ('atracurio'),
  ('aloe');
  
INSERT INTO `principiattiviprodotto` VALUES
  ('Muflix', 'acido acetilsalicilico', '15.2'),
  ('Muflix', 'alcaloide', '9.2'),
  ('Frenox', 'morfina', '16.3'),
  ('Muginex', 'nicotina', '11.9'),
  ('Trenofis', 'terpene', '25.0'),
  ('Trenofis', 'carotene', '7.3'),
  ('Axerol', 'glicoside', '17.2'),
  ('Picrifon', 'digossina', '28.4'),
  ('Sorivan', 'atracurio', '12.3'),
  ('Sorivan', 'aloe', '4.5'),
  ('Cifitox', 'nicotina', '19.2'),
  ('Polinaf', 'morfina', '12.1'),
  ('Polinaf', 'glicoside', '10.2'),
  ('Sfrex', 'acido acetilsalicilico', '41.2'),
  ('Sfrex', 'alcaloide', '11.4'),
  ('Sfrex', 'atracurio', '2.4');

INSERT INTO `prodottipatologia` VALUES
  ('1', 'Muflix'),
  ('2', 'Frenox'),
  ('3', 'Muginex'),
  ('4', 'Trenofis'),
  ('5', 'Axerol'),
  ('6', 'Picrifon'),
  ('7', 'Sorivan'),
  ('8', 'Cifitox'),
  ('9', 'Polinaf'),
  ('10', 'Sfrex');

INSERT INTO `sintomo` VALUES
  ('1', 'Caduta delle foglie.'),
  ('2', 'Perdita di colore delle foglie.'),
  ('3', 'Lacerazione tronco.'),
  ('4', 'Lacerazione foglie.'),
  ('5', 'Marciume.'),
  ('6', 'Appassimento.'),
  ('7', 'Ingiallimento delle foglie.'),
  ('8', 'Presenza di sali bianchi sul terriccio.'),
  ('9', 'Danni alle radici.'),
  ('10', 'Copertura della foglia di un reticolato di strisce scure.');

INSERT INTO `sintomipatologia` (`CodPatologia`, `CodSintomo`) VALUES
  ('1', '1'),
  ('1', '5'),
  ('2', '8'),
  ('2', '9'),
  ('3', '3'),
  ('4', '4'),
  ('5', '5'),
  ('5', '8'),
  ('6', '5'),
  ('6', '6'),
  ('7', '7'),
  ('8', '5'),
  ('8', '8'),
  ('9', '9'),
  ('10', '10');

INSERT INTO `immagine` VALUES
  ('./sintomi/img1.png'),
  ('./sintomi/img2.png'),
  ('./sintomi/img3.png'),
  ('./sintomi/img4.png'),
  ('./sintomi/img5.png'),
  ('./sintomi/img6.png'),
  ('./sintomi/img7.png'),
  ('./sintomi/img8.png'),
  ('./sintomi/img9.png'),
  ('./sintomi/img10.png');

INSERT INTO `immaginisintomi` (`CodSintomo`, `URL`) VALUES
  ('1', './sintomi/img1.png'),
  ('2', './sintomi/img2.png'),
  ('3', './sintomi/img3.png'),
  ('4', './sintomi/img4.png'),
  ('5', './sintomi/img5.png'),
  ('6', './sintomi/img6.png'),
  ('7', './sintomi/img7.png'),
  ('8', './sintomi/img8.png'),
  ('9', './sintomi/img9.png'),
  ('10', './sintomi/img10.png');

INSERT INTO `reportdiagnostica` (`CodPianta`, `Timestamp`) VALUES
  ('1', '2016-01-14 11:40:15'),
  ('2', '2014-10-16 06:43:18'),
  ('4', '2016-02-03 19:15:46'),
  ('5', '2014-07-19 15:06:26'),
  ('6', '2016-11-29 05:45:00'),
  ('8', '2016-05-05 11:12:41'),
  ('9', '2015-11-08 13:59:56'),
  ('11', '2015-10-12 21:48:37'),
  ('11', '2016-02-23 08:36:57'),
  ('13', '2014-11-27 22:14:32');

INSERT INTO `patologiereport` (	`CodPianta`, 
								`Timestamp`, 
								`CodPatologia`) VALUES
  ('1', '2016-01-14 11:40:15', '1'),
  ('1', '2016-01-14 11:40:15', '4'),
  ('2', '2014-10-16 06:43:18', '2'),
  ('4', '2016-02-03 19:15:46', '3'),
  ('5', '2014-07-19 15:06:26', '4'),
  ('6', '2016-11-29 05:45:00', '5'),
  ('6', '2016-11-29 05:45:00', '9'),
  ('8', '2016-05-05 11:12:41', '3'),
  ('8', '2016-05-05 11:12:41', '6'),
  ('9', '2015-11-08 13:59:56', '7'),
  ('11', '2015-10-12 21:48:37', '2'),
  ('11', '2015-10-12 21:48:37', '8'),
  ('11', '2016-02-23 08:36:57', '9'),
  ('13', '2014-11-27 22:14:32', '10');

INSERT INTO `sintomireport` (`CodPianta`, `Timestamp`, `CodSintomo`) VALUES
  ('1', '2016-01-14 11:40:15', '3'),
  ('2', '2014-10-16 06:43:18', '4'),
  ('4', '2016-02-03 19:15:46', '7'),
  ('4', '2016-02-03 19:15:46', '9'),
  ('5', '2014-07-19 15:06:26', '1'),
  ('5', '2014-07-19 15:06:26', '10'),
  ('5', '2014-07-19 15:06:26', '9'),
  ('6', '2016-11-29 05:45:00', '2'),
  ('8', '2016-05-05 11:12:41', '2'),
  ('9', '2015-11-08 13:59:56', '4'),
  ('9', '2015-11-08 13:59:56', '6'),
  ('11', '2015-10-12 21:48:37', '5'),
  ('11', '2016-02-23 08:36:57', '7'),
  ('13', '2014-11-27 22:14:32', '4'),
  ('13', '2014-11-27 22:14:32', '8');

INSERT INTO `reportassunzioni` VALUES
  ('1', '1', '2', '0', '2000-02-01', '2000-03-01'),
  ('2', '1', '2', '0', '2000-03-01', '2000-04-01'),
  ('3', '1', '2', '0', '2000-04-01', '2000-05-01'),
  ('4', '1', '2', '0', '2000-05-01', '2000-06-01'),
  ('5', '1', '2', '0', '2000-06-01', '2000-07-01'),
  ('6', '1', '2', '1', '2000-07-01', '2001-07-01'),
  ('7', '1', '2', '0', '2000-11-01', '2001-12-01'),
  ('8', '6', '1', '0', '2001-03-01', '2001-04-01'),
  ('9', '6', '1', '0', '2001-04-01', '2001-05-01'),
  ('10', '6', '1', '0', '2001-05-01', '2001-06-01');

INSERT INTO `reportmanutenzione` VALUES
  ('potatura', '1', 'Mays', '20'),
  ('rinvaso', '1', 'Mays', '40'),
  ('potatura', '1', 'Aestivum', '45'),
  ('potatura', '2', 'Mays', '50'),
  ('trattamento', '1', 'Mays', '40'),
  ('rinvaso', '1', 'Minor', '15'),
  ('potatura', '3', 'Mays', '70'),
  ('potatura', '1', 'Officinalis', '35'),
  ('trattamento', '1', 'Rosaceae', '28'),
  ('potatura', '2', 'Officinalis', '75');

INSERT INTO `reportordini` (`CodRepOrdini`, `DaOrdinare`, `Clima`) VALUES
  ('1', '1', 'estivo'),
  ('2', '1', 'invernale'),
  ('3', '1', 'estivo'),
  ('4', '1', 'invernale'),
  ('5', '1', 'estivo'),
  ('6', '1', 'invernale'),
  ('7', '1', 'estivo'),
  ('8', '1', 'invernale'),
  ('9', '1', 'estivo'),
  ('10', '1', 'invernale');

INSERT INTO `speciereportordini` (	`CodRepOrdini`, 
									`NomeSpecie`, 
									`Quantita`) VALUES
  ('1', 'Mays', '2'), ('1', 'Aestivum', '1'),
  ('3', 'Minor', '1'),
  ('4', 'Perennis', '1'),
  ('6', 'Officinalis', '1'), ('6', 'Alba', '1'),
  ('8', 'Avium', '1'),
  ('9', 'Moraceae', '1'), ('9', 'Rosaceae', '3'),
  ('10', 'Tiliaceae', '1'), ('10', 'Moraceae', '1');

--
-- Operazione 1: Ottenere il numero di posts pubblicati da un account
-- 
DROP PROCEDURE IF EXISTS OttieniNumPostPubblicati;
DELIMITER $$
CREATE PROCEDURE OttieniNumPostPubblicati(	IN nick char(50), 
											OUT numeropost int(11))
BEGIN
	SELECT `NumPostPubblicati` INTO numeropost
    FROM `account`
    WHERE `Nickname` = nick;
END $$
DELIMITER ;

--
-- Operazione 2: Ottenere il costo complessivo di
-- 			     manutenzione di una specie di pianta
-- 
DROP PROCEDURE IF EXISTS OttieniCostoTotManutenzione;
DELIMITER $$
CREATE PROCEDURE OttieniCostoTotManutenzione(IN nomespecie char(50), 
											 OUT costo int(11))
BEGIN
	SELECT `CostoTotManutenzione` INTO costo
    FROM `specie`
    WHERE `Nome` = nomespecie;
END $$
DELIMITER ;

--
-- Operazione 3: Ottenere il numero di piante appartenenti ad una sezione
-- 
DROP PROCEDURE IF EXISTS OttieniNumeroPianteSezione;
DELIMITER $$
CREATE PROCEDURE OttieniNumeroPianteSezione(IN sezione int(11), 
											OUT numeropiante int(11))
BEGIN
	SELECT `PiantePresenti` INTO numeropiante
    FROM `sezione`
    WHERE `CodSezione` = sezione;
END $$
DELIMITER ;

--
-- Operazione 4: Ottenere la specie di pianta più venduta
-- 
DROP PROCEDURE IF EXISTS OttieniSpeciePiuVenduta;
DELIMITER $$
CREATE PROCEDURE OttieniSpeciePiuVenduta()
BEGIN
	CREATE OR REPLACE VIEW `PiantePiuVendute` AS
		SELECT `Nome` AS `SpeciePiuVendute`
		FROM `specie`
		WHERE `NumPianteVendute` = (SELECT MAX(`NumPianteVendute`)
									FROM `specie`);
	
    SELECT *
    FROM `PiantePiuVendute`;
END $$
DELIMITER ;

--
-- Operazione 5: Inserire di una nuova pianta nel magazzino
-- 
/*	Consiste nell'inserimento di una tupla nella tabella
	`pianta` ed eventuali altre tuple relative nelle 
	tabelle `periodipianta`, `esigenzaconcimazionepianta`
	e `elementinecessaripianta`. */

--
-- Operazione 6: Creare un nuovo arredamento
-- 
/*	Consiste nell'inserimento di una tupla nella tabella
	`arredamento` ed eventuali altre tuple relative nelle 
	tabelle `piantearredamentoinpienaterra` e
    `vasiarredamento`. */

--
-- Operazione 7: Trovare il thread con più contenuti multimediali
-- 
DROP PROCEDURE IF EXISTS OttieniThreadsConPiuMedia;
DELIMITER $$
CREATE PROCEDURE OttieniThreadsConPiuMedia()
BEGIN
	CREATE OR REPLACE VIEW `ThreadsConPiuMedia` AS
		SELECT `CodThread` AS `ThreadConPiuContenutiMultimediali`
		FROM `thread`
		WHERE `NumMedia` = (SELECT MAX(`NumMedia`)
							FROM `thread`);
	
    SELECT *
    FROM `ThreadsConPiuMedia`;
END $$
DELIMITER ;

--
-- Operazione 8: Ottenere la specie pianta che si ammala più spesso
--
DROP PROCEDURE IF EXISTS OttieniSpecieChePiuSiAmmala;
DELIMITER $$
CREATE PROCEDURE OttieniSpecieChePiuSiAmmala()
BEGIN
	CREATE OR REPLACE VIEW `SpecieChePiuSiAmmalano` AS
		SELECT `Nome` AS `SpecieCheSiAmmalanoDiPiu`
		FROM `specie`
		WHERE `NumeroEsordi` = (SELECT MAX(`NumeroEsordi`)
								FROM `specie`);
	
    SELECT *
    FROM `SpecieChePiuSiAmmalano`;
END $$
DELIMITER ;