-- QUERY che mostra nome, cognome, l'anno di nascita, la loro societa in quell'anno, tempo ottenuto e la data dlla gara delle 5 migliori prestazioni ottenute da atleti appartenenti alla 
-- categoria allievi che nel 2015 nei 1000 m ordinati per prestazione
SELECT a.cognome,a.nome, YEAR(a.dataNascita) AS annoDiNascita, soc.nome AS societa, pc.tempo, pc.data
FROM Atleta a JOIN prestazioneCorsa pc ON (a.matricola=pc.atleta)
	JOIN Gara g ON (pc.idGara=g.id)
	JOIN Specialita s ON (g.specialita=s.codice)
	JOIN tesseramentoAtleta ta ON (a.matricola=ta.matricolaAtleta AND ta.anno='2015')
	JOIN Societa soc ON (ta.codiceSocieta=soc.codice),
	Categoria c
WHERE c.nome='Allievo Maschile'
	AND g.categoria=c.codice
	AND s.nome='1000 metri'
	AND YEAR(pc.data)='2015'
ORDER BY pc.tempo ASC
LIMIT 10; 

-- VISTA che fa vedere solo la migliore prestazione da prestazioneCorsa di ogni atleta di ogni anno per ciascuna specialita 
-- in cui ha gareggiato
DROP VIEW IF EXISTS migliorePrestazioneCorsa;
CREATE VIEW migliorePrestazioneCorsa
AS 
SELECT p1.idGara AS idGara, p1.atleta AS atleta, p1.tempo AS tempo, p1.posizione AS posizione, 
	p1.tipoFase AS tipoFase,p1.data AS data, p1.oraInizio AS oraInizio 
FROM prestazioneCorsa p1 
	JOIN Gara g1 ON (p1.idGara=g1.id) 
WHERE p1.tempo IN ( 
	SELECT MIN(p2.tempo) 
	FROM prestazioneCorsa p2 JOIN Gara g2 ON (p2.idGara=g2.id) 
	WHERE p1.atleta=p2.atleta AND YEAR(p1.data)=YEAR(p2.data) AND g1.specialita=g2.specialita 
	);
	
-- QUERY che mostra nome, cognome,  e tempo ottenuta dei 5 atleti distinti appartenenti 
-- alla categoria allievo mascile che nel 2015 hanno ottenuto le migliori prestazioni in stadi outdoor nei 1000
-- metri ordinati per tempo
SELECT a.nome, a.cognome, soc.nome AS societa, pc.tempo
FROM Atleta a JOIN migliorePrestazioneCorsa pc ON (a.matricola=pc.atleta)
	JOIN Gara g ON (pc.idGara=g.id)
	JOIN Specialita sp ON (g.specialita=sp.codice)
	JOIN tesseramentoAtleta ta ON (a.matricola=ta.matricolaAtleta AND ta.anno=2015)
	JOIN Societa soc ON (ta.codiceSocieta=soc.codice)
	JOIN edizioneManifestazione em ON (g.edizione=em.edizione AND g.manifestazione=em.manifestazione)
	JOIN Stadio st ON (em.nomeStadio=st.nome AND em.cittaStadio=st.citta),
	Categoria c
WHERE c.nome='Allievo Maschile'
	AND g.categoria=c.codice
	AND sp.nome='1000 metri'
	AND st.indoorOutdoor='O'
	AND YEAR(pc.data)='2015'
ORDER BY pc.tempo ASC
LIMIT 5; 

-- nome e cognome degli alenatori,società per cui sono attualmente tesseati e numero di atleti allenati che
--  hanno vinto almeno una gara (tipoFase='f')
SELECT al.Cognome, al.Nome,s.Nome AS Societa, COUNT(atl.matricola) AS atletiVincenti
FROM Allenatore al JOIN tesseramentoAllenatore ta ON (al.matricola=ta.matricolaAllenatore AND ta.anno=YEAR(CURDATE()))
	JOIN Societa s ON (ta.codiceSocieta=s.codice)
	JOIN Atleta atl ON (al.matricola=atl.matricolaAllenatore)
WHERE EXISTS( (	SELECT atl.matricola  FROM prestazioneCorsa pc WHERE  atl.matricola=pc.atleta AND pc.posizione=1 AND pc.tipoFase='F')
UNION (SELECT atl.matricola  FROM prestazioneSL psl WHERE  atl.matricola=psl.atleta AND psl.posizione=1 AND psl.tipoFase='F' ))
GROUP BY (al.matricola)
ORDER BY COUNT(atl.matricola) DESC;


-- nome e cognome degli atleti, nome della manifestazione, data della gara degli atleti, posizione di arrivo che hanno raggiunto il podio in una gara
-- svoltasi nello stadio gestito dalla propria societa in quell'anno
DROP VIEW IF EXISTS risultati;
CREATE VIEW risultati
AS (SELECT p1.idGara AS idGara, p1.atleta AS atleta, p1.posizione AS posizione, 
	p1.tipoFase AS tipoFase,p1.data AS data
	FROM prestazioneCorsa p1)
	UNION
	(SELECT p1.idGara AS idGara, p1.atleta AS atleta, p1.posizione AS posizione, 
	p1.tipoFase AS tipoFase,p1.data AS data
	FROM prestazioneSL p1);
	
SELECT atl.cognome, atl.nome, r.posizione, r.data, s.nome AS societa, st.nome AS stadio, m.nome AS manifestazione
FROM Atleta atl JOIN risultati r ON (atl.matricola=r.atleta)
	JOIN Gara g ON (r.idGara=g.id)
	JOIN edizioneManifestazione em ON (g.edizione=em.edizione AND g.manifestazione=em.manifestazione)
	JOIN Manifestazione m ON (em.manifestazione=m.codice)
	JOIN Stadio st ON (em.nomeStadio=st.nome AND em.cittaStadio=st.citta)
	JOIN tesseramentoAtleta ta ON (atl.matricola=ta.matricolaAtleta AND ta.anno=YEAR(r.data))
	JOIN Societa s ON (ta.codiceSocieta=s.codice)
WHERE st.societa=s.codice AND r.tipoFase='F' AND r.posizione<=3;

-- le provincia della societa per cui erano  tesserati gli atleti che ha ottenuto la peggiore prestazioni in gare di corsa per ogni specialita
--  e per ogni categoria in 
SELECT s.provincia, COUNT(*) AS peggioriPrestazioni
FROM Gara g JOIN prestazioneCorsa pc ON (g.id=pc.idGara)
	JOIN Atleta atl ON(pc.atleta=atl.matricola)
	JOIN tesseramentoAtleta ta ON(atl.matricola=ta.matricolaAtleta AND YEAR(pc.data)=ta.anno)
	JOIN Societa s ON (ta.codiceSocieta=s.codice)
WHERE pc.tempo IN (SELECT MAX(tempo) FROM prestazioneCorsa pc2 JOIN Gara g2 ON (pc2.idGara=g2.id) WHERE g2.categoria=g.categoria AND g2.specialita=g.specialita)
GROUP BY s.provincia
ORDER BY peggioriPrestazioni DESC;

-- altre idee per query
-- media degli atleti per categoria per ogni anno
-- media del numero di prestazioni ottenute da ogni atleta per categoria