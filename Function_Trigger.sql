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

