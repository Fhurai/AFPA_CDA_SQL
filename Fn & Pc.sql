USE [Papyrus]
GO

---------------------
-- 2.1
---------------------
SELECT NUMCOM,
	DATECOM
FROM [Papyrus].[dbo].[COMMANDE]
WHERE MONTH(DATECOM) IN (
		3,
		4
		)
GO

DROP FUNCTION [dbo].[fn_Dateformat]
GO

CREATE FUNCTION fn_Dateformat (
	@pdate DATETIME,
	@psep CHAR(1)
	)
RETURNS CHAR(10)
AS
BEGIN
	-- variables nécessaires
	DECLARE @jj CHAR(2);
	DECLARE @mm CHAR(2);
	DECLARE @aa CHAR(4);

	-- calcul des différentes parties de la date
	SET @jj = RIGHT('00' + convert(VARCHAR(2), datepart(dd, @pdate)), 2);
	SET @mm = RIGHT('00' + convert(VARCHAR(2), datepart(mm, @pdate)), 2);
	SET @aa = convert(VARCHAR(4), datepart(yy, @pdate));

	-- assemblage pour restitution
	RETURN @jj + @psep + @mm + @psep + @aa;
END
GO

SELECT NUMCOM AS 'Commande',
	[dbo].[fn_Dateformat](DATECOM, '/') AS 'Date Commande'
FROM [Papyrus].[dbo].[COMMANDE]
WHERE MONTH(DATECOM) IN (
		3,
		4
		)
GO

---------------------
-- 2.2
---------------------
SELECT NUMFOU,
	NOMFOU,
	SATISF
FROM [Papyrus].[dbo].[FOURNISSEUR]
GO

DROP FUNCTION [dbo].[fn_Satisfaction]
GO

CREATE FUNCTION fn_Satisfaction (@psatisf INT)
RETURNS VARCHAR(20)
AS
BEGIN
	DECLARE @labelSatisf VARCHAR(20)

	SET @labelSatisf = 'sans commentaire';

	IF (
			@psatisf = 1
			OR @psatisf = 2
			)
	BEGIN
		SET @labelSatisf = 'Mauvais';
	END
	ELSE IF (
			@psatisf = 3
			OR @psatisf = 4
			)
	BEGIN
		SET @labelSatisf = 'Passable';
	END
	ELSE IF (
			@psatisf = 5
			OR @psatisf = 6
			)
	BEGIN
		SET @labelSatisf = 'Moyen';
	END
	ELSE IF (
			@psatisf = 7
			OR @psatisf = 8
			)
	BEGIN
		SET @labelSatisf = 'Bon';
	END
	ELSE IF (
			@psatisf = 9
			OR @psatisf = 10
			)
	BEGIN
		SET @labelSatisf = 'Excellent';
	END

	RETURN @labelSatisf;
END
GO

SELECT NUMFOU AS 'N° Fournisseur',
	NOMFOU AS 'Fournisseur',
	[dbo].[fn_Satisfaction](SATISF) AS 'Satisfaction'
FROM [Papyrus].[dbo].[FOURNISSEUR]
ORDER BY SATISF DESC
GO

---------------------
-- 2.3
---------------------
SELECT FOURNISSEUR.NUMFOU,
	NOMFOU,
	SUM(QTECDE * PRIUNI * 1.2) AS CA,
	YEAR(DATECOM) AS 'Année'
FROM [Papyrus].[dbo].[FOURNISSEUR]
INNER JOIN [Papyrus].[dbo].[COMMANDE]
	ON FOURNISSEUR.NUMFOU = COMMANDE.NUMFOU
INNER JOIN [Papyrus].[dbo].[LIGNE]
	ON COMMANDE.NUMCOM = LIGNE.NUMCOM
--WHERE YEAR(DATECOM) = 2018
GROUP BY FOURNISSEUR.NUMFOU,
	NOMFOU,
	YEAR(DATECOM)
GO

DROP FUNCTION [dbo].[fn_CA_Fournisseur]
GO

CREATE FUNCTION fn_CA_Fournisseur (
	@pfourn INT,
	@pannee INT
	)
RETURNS TABLE
AS
RETURN (
		SELECT FOURNISSEUR.NUMFOU,
			NOMFOU,
			FORMAT(SUM(QTECDE * PRIUNI * 1.2), 'C', 'fr-fr') AS CA
		FROM [Papyrus].[dbo].[FOURNISSEUR]
		INNER JOIN [Papyrus].[dbo].[COMMANDE]
			ON FOURNISSEUR.NUMFOU = COMMANDE.NUMFOU
		INNER JOIN [Papyrus].[dbo].[LIGNE]
			ON COMMANDE.NUMCOM = LIGNE.NUMCOM
		WHERE YEAR(DATECOM) = @pannee
			AND FOURNISSEUR.NUMFOU = @pfourn
		GROUP BY FOURNISSEUR.NUMFOU,
			NOMFOU
		)
GO

SELECT *
FROM [dbo].[fn_CA_Fournisseur](1801, 2018)
GO

---------------------
-- 2.3.1
---------------------
CREATE TABLE FOURNISSEUR_IND (
	NUMFOU INT NOT NULL,
	NOMFOU VARCHAR(35) NULL,
	RUEFOU VARCHAR(35) NULL,
	POSFOU CHAR(5) NULL,
	VILFOU VARCHAR(30) NULL,
	CONFOU VARCHAR(15) NULL,
	SATISF INT NULL,
	CONSTRAINT PK_FOURNISSEUR_IND PRIMARY KEY (NUMFOU)
	)
GO

INSERT [dbo].[FOURNISSEUR_IND] (
	[NUMFOU],
	[NOMFOU],
	[RUEFOU],
	[POSFOU],
	[VILFOU],
	[CONFOU],
	[SATISF]
	)
VALUES (
	1701,
	N'Les Gros Bits',
	N'1 Rue du Port',
	N'38140',
	N'Rives',
	N'Michel',
	8
	)

INSERT [dbo].[FOURNISSEUR_IND] (
	[NUMFOU],
	[NOMFOU],
	[RUEFOU],
	[POSFOU],
	[VILFOU],
	[CONFOU],
	[SATISF]
	)
VALUES (
	1706,
	N'Internet.com',
	N'8 rue Principale',
	N'77940',
	N'Schnafon',
	N'Simon',
	7
	)
GO

DROP FUNCTION [dbo].[fn_Compte]
GO

CREATE FUNCTION [dbo].[fn_Compte] ()
RETURNS INT
	WITH SCHEMABINDING
AS
BEGIN
	DECLARE @rowsCount INT

	SET @rowsCount = (
			SELECT COUNT(*)
			FROM [dbo].[FOURNISSEUR_IND]
			)

	RETURN @rowsCount;
END
GO

DROP TABLE [dbo].[FOURNISSEUR_IND]
GO

---------------------
-- 3.1
---------------------
CREATE PROCEDURE [dbo].[prc_Lst_fournis]
AS
BEGIN
	SELECT DISTINCT NUMFOU
	FROM dbo.COMMANDE
END
GO

EXEC prc_Lst_fournis
GO

sp_help prc_Lst_fournis
	-- Name / Owner / Type / Created_datetime
GO

sp_helptext prc_Lst_fournis
	-- Body of procedure
GO

---------------------
-- 3.2
---------------------
DROP PROCEDURE [dbo].[prc_Lst_Commandes]
GO

CREATE PROCEDURE [dbo].[prc_Lst_Commandes] @vobs VARCHAR(35)
AS
BEGIN
	SELECT COMMANDE.NUMCOM AS NuméroCommande,
		NOMFOU,
		LIBART,
		QTECDE * PRIUNI AS SousTotal
	FROM COMMANDE
	INNER JOIN FOURNISSEUR
		ON COMMANDE.NUMFOU = FOURNISSEUR.NUMFOU
	INNER JOIN LIGNE
		ON COMMANDE.NUMCOM = LIGNE.NUMCOM
	INNER JOIN PRODUIT
		ON LIGNE.CODART = PRODUIT.CODART
	WHERE OBSCOM LIKE '%' + @vobs + '%'
	ORDER BY COMMANDE.NUMCOM
END
GO

EXEC prc_Lst_Commandes 'ok'
GO

---------------------
-- 3.3
---------------------
DROP PROCEDURE [dbo].[prc_CA_Fournisseur]
GO

CREATE PROCEDURE [dbo].[prc_CA_Fournisseur] @vfourn INT,
	@vannee INT,
	@result VARCHAR(20) OUTPUT
AS
BEGIN
	DECLARE @count INT

	SET @count = (
			SELECT COUNT(*)
			FROM LIGNE l
			INNER JOIN COMMANDE c
				ON c.NUMCOM = l.NUMCOM
			WHERE DATEPART(yyyy, DERLIV) = @vannee
				AND NUMFOU = @vfourn
			);

	IF (@count = 0)
	BEGIN
		RETURN - 100
	END
	ELSE
	BEGIN
		SET @result = (
				SELECT FORMAT(SUM(l.PRIUNI * l.QTECDE * 1.20), 'C', 'fr-fr')
				FROM LIGNE l
				INNER JOIN COMMANDE c
					ON c.NUMCOM = l.NUMCOM
				INNER JOIN FOURNISSEUR f
					ON f.NUMFOU = c.NUMFOU
				WHERE DATEPART(yyyy, DERLIV) = @vannee
					AND f.NUMFOU = @vfourn
				GROUP BY f.NOMFOU
				);
	END
END
GO

DECLARE @Res VARCHAR(20)
DECLARE @fourni INT
DECLARE @annee INT

SET @fourni = 1801
SET @annee = 2018

EXEC prc_CA_Fournisseur @fourni,
	@annee,
	@Res OUTPUT

SELECT 'Le CA du Fournisseur ',
	@fourni,
	' pour l''année ',
	@annee,
	' est de ',
	@Res
GO

---------------------
EXECUTE sp_addmessage @msgnum = 50016,
	@severity = 15,
	@msgtext = ' Fournisseur inexistant',
	@lang = 'us_english'
	--EXECUTE sp_addmessage 50016, 15, ' Fournisseur N° %1 inexistant'
GO

EXECUTE sp_dropmessage 50016,
	@lang = 'all'
GO

RAISERROR (
		50016,
		15,
		1
		)
GO

DROP PROCEDURE [dbo].[prc_CA_Fournisseur2]
GO

CREATE PROCEDURE [dbo].[prc_CA_Fournisseur2] @vfourn INT,
	@vannee INT,
	@result VARCHAR(20) OUTPUT
AS
BEGIN
	DECLARE @count INT

	SET @count = (
			SELECT COUNT(*)
			FROM FOURNISSEUR
			WHERE NUMFOU = @vfourn
			);

	IF (@count = 0)
	BEGIN
		RAISERROR (
				50016,
				15,
				1
				)
		WITH LOG

		RETURN - 100
	END
	ELSE
	BEGIN
		SET @result = (
				SELECT FORMAT(SUM(l.PRIUNI * l.QTECDE * 1.20), 'C', 'fr-fr')
				FROM LIGNE l
				INNER JOIN COMMANDE c
					ON c.NUMCOM = l.NUMCOM
				INNER JOIN FOURNISSEUR f
					ON f.NUMFOU = c.NUMFOU
				WHERE DATEPART(yyyy, DERLIV) = @vannee
					AND f.NUMFOU = @vfourn
				GROUP BY f.NOMFOU
				);
	END
END
GO

DECLARE @Res VARCHAR(20)
DECLARE @fourni INT
DECLARE @annee INT

SET @fourni = 7000
SET @annee = 2018

EXEC prc_CA_Fournisseur2 @fourni,
	@annee,
	@Res OUTPUT

SELECT 'Le CA du Fournisseur ',
	@fourni,
	' pour l''année ',
	@annee,
	' est de ',
	@Res
GO

-- Connexion > Gestoin > Journaux SQL Server > Actuel