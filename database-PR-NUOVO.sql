-- CREAZIONE DELLO SCHEMA DEL DATABASE
DROP TABLE IF EXISTS Allenatore, Atleta, Categoria, Gara, Manifestazione, Societa, Specialita, Stadio,
 edizioneManifestazione, prestazioneCorsa,  prestazioneSL, tesseramentoAllenatore, tesseramentoAtleta;
-- Creazione della Struttura della tabella `Societa`
DROP TABLE IF EXISTS Societa;
CREATE TABLE Societa(
codice INT PRIMARY KEY,
nome VARCHAR(40),
numeroAtleti INT DEFAULT 0,
email VARCHAR(20),
provincia VARCHAR(20),
regione VARCHAR(20),
telefono VARCHAR(10)
) ENGINE=MyISAM  ;
--
-- Creazione della Struttura della tabella `Allenatore`
CREATE TABLE IF NOT EXISTS Allenatore(
matricola INT PRIMARY KEY,
nome VARCHAR(20),
cognome VARCHAR(20),
dataNascita DATE
) ENGINE=MyISAM;
--
-- Creazione della Struttura della tabella `tesseramentoAllenatore`
CREATE TABLE IF NOT EXISTS tesseramentoAllenatore(
matricolaAllenatore INT,
codiceSocieta INT,
anno YEAR,
PRIMARY KEY ( matricolaAllenatore, anno),
FOREIGN KEY (matricolaAllenatore) REFERENCES Allenatore(matricola)
ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (codiceSocieta) REFERENCES Societa(codice)
ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=MyISAM;
--
-- Creazione della Struttura della tabella `Categoria`
CREATE TABLE IF NOT EXISTS Categoria(
codice CHAR(2) PRIMARY KEY,
nome varchar(20)
) ENGINE=MyISAM;
--
-- Creazione della Struttura della tabella `Atleta`
CREATE TABLE IF NOT EXISTS Atleta(
matricola INT PRIMARY KEY,
nome VARCHAR(20),
cognome VARCHAR(20),
dataNascita DATE,
sesso ENUM ('M','F'),
matricolaAllenatore INT,
FOREIGN KEY (matricolaAllenatore) REFERENCES Allenatore(matricola),
categoria CHAR(2) REFERENCES Categoria(codice)
) ENGINE=MyISAM;
--
-- Creazione della Struttura della tabella `tesseramentoAtleta`
CREATE TABLE IF NOT EXISTS tesseramentoAtleta(
matricolaAtleta INT,
codiceSocieta INT,
anno YEAR,
PRIMARY KEY ( matricolaAtleta, anno),
FOREIGN KEY (matricolaAtleta) REFERENCES Atleta(matricola)
ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (codiceSocieta) REFERENCES Societa(codice)
ON DELETE CASCADE ON UPDATE CASCADE
)ENGINE=MyISAM;
--
-- Creazione della Struttura della tabella `Stadio`
CREATE TABLE IF NOT EXISTS Stadio(
nome VARCHAR(20),
citta VARCHAR(20),
via VARCHAR(20),
numeroCivico SMALLINT,
indoorOutdoor ENUM('I','O'),
societa INT,
PRIMARY KEY (nome, citta),
FOREIGN KEY (societa) REFERENCES Societa(codice)
ON UPDATE CASCADE ON DELETE SET NULL
)ENGINE=MyISAM;
--
-- Creazione della Struttura della tabella `Manifestazione`
CREATE TABLE IF NOT EXISTS Manifestazione(
codice INT PRIMARY KEY,
nome VARCHAR(20)
) ENGINE=MyISAM;
--
-- Creazione della Struttura della tabella `edizioneManifestazione`
CREATE TABLE IF NOT EXISTS edizioneManifestazione(
edizione INT,
manifestazione INT,
dataInizio DATE,
dataFine DATE,
nomeStadio VARCHAR(20),
cittaStadio VARCHAR(20),
PRIMARY KEY (edizione, manifestazione),
FOREIGN KEY (manifestazione) REFERENCES Manifestazione(codice)
ON UPDATE CASCADE ON DELETE SET NULL,
FOREIGN KEY (nomeStadio, cittaStadio) REFERENCES Stadio(nome, citta)
ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=MyISAM;
--
-- Creazione della Struttura della tabella `Specialita`
CREATE TABLE IF NOT EXISTS Specialita(
codice CHAR(2) PRIMARY KEY,
nome VARCHAR(20)
) ENGINE=MyISAM;
--
-- Creazione della Struttura della tabella `Gara`
CREATE TABLE IF NOT EXISTS Gara(
id INT PRIMARY KEY,
edizione INT,
manifestazione INT,
categoria CHAR(2),
specialita CHAR(2),
FOREIGN KEY (categoria) REFERENCES Categoria(codice)
ON UPDATE CASCADE ON DELETE SET NULL,
FOREIGN KEY (specialita) REFERENCES Specialita(codice)
ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=MyISAM;
--
-- Creazione della Struttura della tabella `prestazioneCorsa`
CREATE TABLE IF NOT EXISTS prestazioneCorsa(
idGara INT,
atleta INT,
tempo TIME(2),
posizione INT,
tipoFase ENUM('B', 'S', 'F'),
data DATE,
oraInizio TIME,
PRIMARY KEY(idGara, atleta,tipoFase),
FOREIGN KEY (idGara) REFERENCES Gara(codice)
ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY (atleta) REFERENCES Atleta(codice)
ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=MyISAM;
--
-- Creazione della Struttura della tabella `prestazioneSL`
CREATE TABLE IF NOT EXISTS prestazioneSL(
idGara INT,
atleta INT,
misura DECIMAL(2,2),
posizione INT,
tipoFase ENUM('B', 'S', 'F'),
data DATE,
oraInizio TIME,
PRIMARY KEY( idGara, atleta, tipoFase),
FOREIGN KEY (idGara) REFERENCES Gara(codice)
ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY (atleta) REFERENCES Atleta(codice)
ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=MyISAM;
--
-- CREAZIONE DI FUNZIONI E TRIGGER
--
-- FUNZIONE che ricevuti come parametri la matricola di un atleta e un determinato anno ne ritorna
-- la categoria in quell' anno.
DROP FUNCTION IF EXISTS Fcategoria; 
DELIMITER $$ 
CREATE FUNCTION Fcategoria (mat INTEGER, anno YEAR) 
RETURNS CHAR(2) 
BEGIN 
DECLARE annoNascita INTEGER; 
DECLARE eta INTEGER; 
DECLARE codiceCat CHAR(1); 
DECLARE codiceSesso CHAR(1); 
SELECT YEAR(dataNascita)INTO annoNascita FROM Atleta WHERE matricola=mat; 
SELECT sesso INTO codiceSesso FROM Atleta WHERE matricola=mat; 
SET eta = anno-annoNascita; 
IF (eta<18) THEN SET codiceCat = 'A'; END IF; 
IF (eta=18 OR eta=19) THEN SET codiceCat = 'J';  END IF; 
if (eta>19 AND eta<35) THEN SET codiceCat= 'S';  END IF; 
if (eta>34) THEN SET codiceCat='M';  END IF; 
RETURN CONCAT(codiceCat,codiceSesso);   
END$$ 
DELIMITER ;
--
-- FUNZIONE che ricevuti come paramentri il sesso e la dataNascita di un atleta
-- e un'anno ritorna la categoria corrispondente in quell'anno
DROP FUNCTION IF EXISTS FcategoriaS; 
DELIMITER $$ 
CREATE FUNCTION FcategoriaS (sesso char(1), dataN DATE, anno YEAR) 
RETURNS CHAR(2) 
BEGIN 
DECLARE eta INTEGER; 
DECLARE codiceCat CHAR(1);   
SET eta = anno-YEAR(dataN); 
IF (eta<18) THEN SET codiceCat = 'A'; END IF; 
IF (eta=18 OR eta=19) THEN SET codiceCat = 'J';  END IF; 
if (eta>19 AND eta<35) THEN SET codiceCat= 'S';  END IF; 
if (eta>34) THEN SET codiceCat='M';  END IF; 
RETURN CONCAT(codiceCat,sesso);   
END$$ 
DELIMITER ;
--
-- TRIGGER che quando avviene l'inserimento nella base di dati di un atleta
-- ne setta la categoria nell'anno in corso
DROP TRIGGER IF EXISTS TcatAtleta; 
DELIMITER $$ 
CREATE TRIGGER TcatAtleta 
BEFORE INSERT ON Atleta 
FOR EACH ROW
BEGIN
SET new.categoria=FcategoriaS(new.sesso,new.dataNascita,YEAR(CURDATE()));
END$$ 
DELIMITER ;
--
-- TRIGGER che controlla se durante l'inserimento delle prestazioni 
-- un'Atleta in base alla sua categoria se
-- ha potuto partecipare e quella gara ( perchè la sua categoria coincideva con la categoria ammassa alla gara)
DROP TRIGGER IF EXISTS controllaCategoria; 
DELIMITER $$ 
CREATE TRIGGER controllaCategoria 
BEFORE INSERT ON prestazioneCorsa
FOR EACH ROW
BEGIN
DECLARE catAtleta CHAR(2);
DECLARE catGara CHAR(2);
DECLARE strErrore VARCHAR(80);
SET catAtleta=Fcategoria(new.atleta,YEAR(new.data));
SELECT categoria INTO catGara FROM Gara WHERE id=new.idGara;
IF(catAtleta <> catGara) 
THEN 
	SET strErrore=CONCAT('L atleta con matricola ',new.atleta,' non ha partecipato alla gara con codice ',new.idGara);
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = strErrore;
END IF;
END$$ 
DELIMITER ;

-- TRIGGER
DROP TRIGGER IF EXISTS AggSocAtletiIns; 
DELIMITER $$ 
CREATE TRIGGER AggSocAtletiIns 
AFTER INSERT ON tesseramentoAtleta
FOR EACH ROW
BEGIN
DECLARE ct INTEGER;
IF new.Anno = YEAR(CURDATE())
THEN
	SELECT numeroAtleti INTO ct FROM Societa WHERE new.codiceSocieta=Societa.codice AND new.anno = YEAR(CURDATE());
	UPDATE Societa SET numeroAtleti=ct+1 WHERE new.codiceSocieta=Societa.codice;
END IF;
END$$ 
DELIMITER ;

-- TRIGGER
DROP TRIGGER IF EXISTS AggSocAtletiDel; 
DELIMITER $$ 
CREATE TRIGGER AggSocAtletiDel 
AFTER DELETE ON tesseramentoAtleta
FOR EACH ROW
BEGIN
DECLARE ct INTEGER;
IF old.Anno = YEAR(CURDATE())
	THEN
	SELECT numeroAtleti INTO ct FROM Societa WHERE old.codiceSocieta=Societa.codice;
	UPDATE Societa SET numeroAtleti = ct-1 WHERE old.codiceSocieta=Societa.codice;
END IF;
END$$ 
DELIMITER ;
--
--
--  POPOLAMENTO DEL DATABASE
--
-- Dump dei dati per la tabella `Societa`
DELETE FROM Societa;
INSERT INTO Societa(codice, nome, email, provincia, regione,telefono) VALUES
(0,'ATLETICA VICENTINA','av@gmail.com','Vicenza','Veneto','1111111111'),
(1,'GRUPPO SPORTIVO ALPINI ASIAGO','asiago@gmail.com','Vicenza','Veneto','222222222'),
(2,'POLISPORTIVA AURORA 76 ASD','aurora@gmail.com','Vicenza','Veneto','1231231231'),
(3,'C.U.S. PADOVA','cuspd@gmail.com','Padova','Veneto','3453453453'),
(4,'G.S. FIAMME ORO PADOVA','fopd@gmail.com','Padova','Veneto','5675675675'),
(5,'ATLETICA VIS ABANO','abano@gmail.com','Padova','Veneto','6786786786'),
(6,'A.A.A.MALO','aamalo@gmail.co.','Vicenza','Veneto','8908908908'),
(7,'G.S.A. VENEZIA','ven@gmail.com','Venezia','Veneto','2345234523'),
(8,'S.A.F. BOLZANO','safbz@libero.it','Bolzano','Trentino-Alto Adige','5678567856'),
(9,'GS VALSUGANA TRENTINO','valsugana@live.it','Trento','Trentino-Alto Adige','1234512345');
--
-- Dump dei dati per la tabella `Allenatore`
DELETE FROM Allenatore;
INSERT INTO Allenatore(matricola,nome,cognome, dataNascita) VALUES
(1,'Diana', 'Tomasi','1960-10-10'),
(2,'Giuseppe','Cestonaro','1956-01-20'),
(3,'Luca','Donato','1987-04-28'),
(4,'Silvia','Zanon','1995-08-19'),
(5,'Marco','Groppo','1989-05-06'),
(6,'Matteo','Matteazzi','1960-07-07');
--
-- Dump dei dati per la tabella `tesseramentoAllenatore`
DELETE FROM tesseramentoAllenatore;
INSERT INTO tesseramentoAllenatore(matricolaAllenatore,codiceSocieta,anno) VALUES
(1,0,2014),
(1,0,2015),
(1,0,2016),
(1,0,2017),
(2,0,2015),
(2,1,2016),
(2,0,2017),
(3,2,2013),
(3,2,2014),
(3,2,2016),
(3,2,2017),
(4,2,2016),
(4,2,2017),
(5,1,2013),
(5,8,2014),
(5,8,2015),
(5,5,2016),
(5,5,2017),
(6,3,2014),
(6,7,2015),
(6,7,2017);
--
-- Dump dei dati per la tabella `Categoria`
DELETE FROM Categoria;
INSERT INTO Categoria (codice,nome) VALUES
('AM', 'Allievo Maschile'),
('JM', 'Juniores Maschile'),
('SM', 'Seniores Maschile'),
('MM', 'Master Maschile'),
('AF', 'Allievo Femminile'),
('JF', 'Juniores Femminile'),
('SF', 'Seniores Femminile'),
('MF', 'Master Femminile');
--
-- Dump dei dati per la tabella `Atleta`
DELETE FROM Atleta;
INSERT INTO Atleta(matricola,nome,cognome,dataNascita,sesso,matricolaAllenatore) VALUES
(1,'Marco','Del Duca','1985-04-1','M',1),
(2,'Matteo','Todescato','1998-06-30','M',1),
(3,'Marco','Smith','1999-09-07','M',2),
(4,'Rebecca','Lonedo','1999-12-05','F',3),
(5,'Federica','Traverso','2000-07-14','F',5),
(6,'Yassin','Rackik','1999-03-03','M',6),
(7,'Thomas','Cal','2001-02-06','M',4),
(8,'Francesca','Bosco','1998-04-09','F',2),
(9,'Tommaso','Griggio','2000-03-15','M',5),
(10,'Pietro','Raggi','2001-10-31','M',1),
(11,'Roberto','Sirio','2000-09-14','M',1),
(12,'Matteo','Lira','1995-03-09','M',4),
(13,'Matteo','Ricci','1994-10-31','M',4),
(14,'Filippo','Lora','1989-05-05','M',6),
(15,'Luca','Giordani','2000-12-01','M',2);
-- Dump dei dati per la tabella `tesseramentoAtleta`
DELETE FROM tesseramentoAtleta;
INSERT INTO tesseramentoAtleta (matricolaAtleta,codiceSocieta,anno) VALUES
(2,0,2014),
(2,0,2015),
(2,0,2016),
(1,0,2015),
(1,1,2016),
(3,2,2013),
(3,2,2014),
(3,2,2015),
(4,2,2015),
(4,2,2016),
(5,1,2013),
(5,8,2014),
(5,8,2015),
(6,8,2014),
(6,7,2015),
(6,4,2016),
(7,8,2015),
(7,1,2016),
(8,4,2015),
(9,2,2013),
(9,2,2014),
(9,3,2015),
(10,4,2014),
(10,5,2016),
(11,3,2013),
(11,3,2014),
(11,3,2015),
(12,8,2014),
(12,8,2015),
(12,5,2016),
(13,8,2014),
(13,7,2015),
(13,4,2016),
(14,7,2014),
(14,7,2015),
(14,8,2016),
(15,2,2015),
(15,2,2016);
--
-- Dump dei dati per la tabella `Stadio`
DELETE FROM Stadio;
INSERT INTO Stadio(nome,citta,via,numeroCivico,indoorOutdoor, societa) VALUES
('Perraro','Vicenza','via Rosmini',8,'O',1),
('Dal Maso','Camisano Vicentino','via Stadio',2,'O',2),
('Menti','Padova','via Tombola',11,'I',4),
('Menti','Venezia','via Laguna',56,'O',7),
('Crippa','Trento','via Albero',23,'O',9),
('Brichi','Bolzano','piazza Liberazione',1,'O',8);
--
-- Dump dei dati per la tabella `Manifestazione`
DELETE FROM Manifestazione;
INSERT INTO Manifestazione(codice,nome) VALUES
(0,'Palio della Quercia'),
(1,'Gara di San Marco'),
(2,'Memorial Mennea'),
(3,'Trofeo Primavera'),
(4,'Meeting del Brenta'),
(5,'Campionati Italiani');
--
-- Dump dei dati per la tabella `edizioneManifestazione`
DELETE FROM edizioneManifestazione;
INSERT INTO edizioneManifestazione(edizione,manifestazione,dataInizio,dataFine,nomeStadio,cittaStadio) VALUES
(1,0,'2014-09-01','2014-09-02','Perraro','Vicenza'),
(2,0,'2015-09-03','2015-09-06','Perraro','Vicenza'),
(3,0,'2016-09-02','2016-09-08','Dal Maso','Camisano Vicentino'),
(1,1,'2016-06-25','2016-06-29','Menti','Venezia'),
(2,1,'2014-06-22','2014-06-25','Menti','Venezia'),
(1,2,'2015-10-18','2015-10-22','Dal Maso','Camisano Vicentino'),
(1,3,'2015-05-30','2015-06-03','Menti','Padova'),
(1,4,'2014-07-07','2014-07-11','Menti','Padova'),
(1,5,'2013-08-16','2013-08-18','Menti','Venezia'),
(2,5,'2014-08-15','2014-08-18','Crippa','Trento'),
(3,5,'2015-08-18','2015-08-19','Perraro','Vicenza'),
(4,5,'2016-08-20','2016-08-22','Brichi','Bolzano');
--
-- Dump dei dati per la tabella `Specialia`
DELETE FROM Specialita;
INSERT INTO Specialita (codice,nome) VALUES
('HJ','Salto in alto'),
('LJ','Salto in lungo'),
('SP', 'Lancio de peso'),
('DT', 'Lancio del disco'),
('C1', '100 metri'),
('C2', '400 metri'),
('C3', '1000 metri');
--
-- Dump dei dati per la tabella `Gara`
DELETE FROM Gara;
INSERT INTO Gara (id,edizione,manifestazione,categoria,specialita) VALUES
(1,2,0,'AM','C3'),
(2,1,2,'AM','C3'),
(3,1,3,'AM','C3'),
(4,3,5,'AM','C3'),
(5,1,1,'AM','C3'),
(6,1,3,'SM','C3'),
(7,1,2,'AM','C1'),
(8,3,5,'AF','C3'),
(9,4,5,'SM','LJ');
--
-- Dump dei dati per la tabella `prestazioneCorsa`
DELETE FROM prestazioneCorsa;
INSERT INTO prestazioneCorsa(idGara,atleta,tempo,posizione,tipoFase,data, oraInizio) VALUES
(1,2,'00:02:35.40',1,'F','2015-09-06','11:40'),
(1,15,'00:02:37.90',2,'F','2015-09-06','11:40'),
(1,11,'00:02:38.50',3,'F','2015-09-06','11:40'),
(1,7,'00:02:40.10',4,'F','2015-09-06','11:40'),
(1,6,'00:02:40.40',5,'F','2015-09-06','11:40'),
(1,3,'00:02:40.40',6,'F','2015-09-06','11:40'),
(1,7,'00:02:40.20',1,'B','2015-09-05','15:10'),
(1,6,'00:02:42.32',2,'B','2015-09-05','15:10'),
(1,15,'00:02:39.18',1,'B','2015-09-04','22:00'),
(1,9,'00:02:41.00',7,'F','2015-09-06','11:40'),
(2,6,'00:02:37.67',1,'F','2015-10-22','16:40'),
(2,3,'00:02:37.68',2,'F','2015-10-22','16:40'),
(2,9,'00:02:38.10',3,'F','2015-10-22','16:40'),
(2,7,'00:02:39.20',4,'F','2015-10-22','16:40'),
(2,11,'00:02:40.00',5,'F','2015-10-22','16:40'),
(3,15,'00:02:35.20',1,'F','2015-06-01','20:00'),
(3,9,'00:02:36.02',2,'F','2015-06-01','20:00'),
(3,2,'00:02:36.51',3,'F','2015-06-01','20:00'),
(4,3,'00:02:35.89',1,'F','2015-08-18','18:00'),
(4,9,'00:02:36.01',2,'F','2015-08-18','18:00'),
(5,15,'00:02:34.99',1,'F','2016-06-25','15:30'),
(5,6,'00:02:35.30',2,'F','2016-06-25','15:30'),
(5,10,'00:02:35.45',3,'F','2016-06-25','15:30'),
(6,13,'00:02:32.67',1,'F','2015-06-01','20:45'),
(6,12,'00:02:33.21',2,'F','2015-06-01','20:45'),
(7,11,'00:00:11.02',1,'F','2015-10-21','21:00'),
(7,7,'00:00:11.40',2,'F','2015-10-21','21:00'),
(8,5,'00:02:36.00',1,'F','2015-08-18','19:00'),
(8,4,'00:02:39.23',2,'F','2015-08-18','19:00'),
(8,8,'00:02:39.45',3,'F','2015-08-18','19:00');
--
-- Dump dei dati per la tabella `PrestazioneSL`
DELETE FROM prestazioneSL;
INSERT INTO prestazioneSL(idGara,atleta,misura,posizione,tipoFase,data,oraInizio) VALUES 
(9,13,7.60,1,'F','2016-08-22','19:00'),
(9,1,7.58,2,'F','2016-08-22','19:00'),
(9,14,7.43,3,'F','2016-08-22','19:00'),
(9,12,7.16,4,'F','2016-08-22','19:00'),
(9,13,7.59,2,'S','2016-08-21','16:00'),
(9,12,7.80,1,'S','2016-08-21','16:00'),
(9,14,7.52,1,'S','2016-08-20','17:00'),
(9,1,7.50,2,'S','2016-08-20','17:00');
