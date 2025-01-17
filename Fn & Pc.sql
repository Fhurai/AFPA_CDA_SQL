USE [Papyrus]
GO

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

SELECT NUMCOM as 'Commande',
	[dbo].[fn_Dateformat](DATECOM, '/') as 'Date Commande'
FROM [Papyrus].[dbo].[COMMANDE]
WHERE MONTH(DATECOM) IN (
		3,
		4
		)
GO

---------------------
---------------------

SELECT NUMFOU, NOMFOU, SATISF
FROM [Papyrus].[dbo].[FOURNISSEUR]
GO


DROP FUNCTION [dbo].[fn_Satisfaction]
GO

CREATE FUNCTION fn_Satisfaction 
(@psatisf int)
RETURNS varchar(20)
AS
BEGIN
	DECLARE @labelSatisf VARCHAR(20)

	SET @labelSatisf = 'sans commentaire';

	IF (@psatisf = 1 OR @psatisf = 2)
	BEGIN
		SET @labelSatisf = 'Mauvais';
	END
	ELSE IF (@psatisf = 3 OR @psatisf = 4)
	BEGIN
		SET @labelSatisf = 'Passable';
	END
	ELSE IF (@psatisf = 5 OR @psatisf = 6)
	BEGIN
		SET @labelSatisf = 'Moyen';
	END
	ELSE IF (@psatisf = 7 OR @psatisf = 8)
	BEGIN
		SET @labelSatisf = 'Bon';
	END
	ELSE IF (@psatisf = 9 OR @psatisf = 10)
	BEGIN
		SET @labelSatisf = 'Excellent';
	END

	RETURN @labelSatisf;
END
GO

SELECT NUMFOU as 'N° Fournisseur', 
NOMFOU as 'Fournisseur', 
[dbo].[fn_Satisfaction](SATISF) as 'Satisfaction'
FROM [Papyrus].[dbo].[FOURNISSEUR]
ORDER BY SATISF DESC
GO

---------------------
---------------------

SELECT FOURNISSEUR.NUMFOU, NOMFOU, SUM(QTECDE * PRIUNI * 1.2) as CA, YEAR(DATECOM) as 'Année'
FROM [Papyrus].[dbo].[FOURNISSEUR]
INNER JOIN [Papyrus].[dbo].[COMMANDE] ON FOURNISSEUR.NUMFOU = COMMANDE.NUMFOU
INNER JOIN [Papyrus].[dbo].[LIGNE] ON COMMANDE.NUMCOM = LIGNE.NUMCOM
--WHERE YEAR(DATECOM) = 2018
GROUP BY FOURNISSEUR.NUMFOU, NOMFOU, YEAR(DATECOM)
GO

DROP FUNCTION [dbo].[fn_CA_Fournisseur]
GO

CREATE FUNCTION fn_CA_Fournisseur
(@pfourn INT, @pannee INT)
RETURNS TABLE
AS
RETURN (
	SELECT FOURNISSEUR.NUMFOU, NOMFOU, FORMAT(SUM(QTECDE * PRIUNI * 1.2), 'C', 'fr-fr') as CA
	FROM [Papyrus].[dbo].[FOURNISSEUR]
	INNER JOIN [Papyrus].[dbo].[COMMANDE] ON FOURNISSEUR.NUMFOU = COMMANDE.NUMFOU
	INNER JOIN [Papyrus].[dbo].[LIGNE] ON COMMANDE.NUMCOM = LIGNE.NUMCOM
	WHERE YEAR(DATECOM) = @pannee
	AND FOURNISSEUR.NUMFOU = @pfourn
	GROUP BY FOURNISSEUR.NUMFOU, NOMFOU
)
GO

SELECT * from [dbo].[fn_CA_Fournisseur](1801, 2018)
GO

---------------------
---------------------

create table FOURNISSEUR_IND (
   NUMFOU               int                  not null,
   NOMFOU               varchar(35)          null,
   RUEFOU               varchar(35)          null,
   POSFOU               char(5)              null,
   VILFOU               varchar(30)          null,
   CONFOU               varchar(15)          null,
   SATISF               int                  null,
   constraint PK_FOURNISSEUR_IND primary key (NUMFOU)
)
go

INSERT [dbo].[FOURNISSEUR_IND] ([NUMFOU], [NOMFOU], [RUEFOU], [POSFOU], [VILFOU], [CONFOU], [SATISF]) VALUES (1701, N'Les Gros Bits', N'1 Rue du Port', N'38140', N'Rives', N'Michel', 8)
INSERT [dbo].[FOURNISSEUR_IND] ([NUMFOU], [NOMFOU], [RUEFOU], [POSFOU], [VILFOU], [CONFOU], [SATISF]) VALUES (1706, N'Internet.com', N'8 rue Principale', N'77940', N'Schnafon', N'Simon', 7)
GO

DROP FUNCTION [dbo].[fn_Compte]
GO

CREATE FUNCTION [dbo].[fn_Compte]()
RETURNS INT
WITH SCHEMABINDING
AS
BEGIN
	Declare @rowsCount INT

	SET @rowsCount = (SELECT COUNT(*)
	FROM [dbo].[FOURNISSEUR_IND])

	RETURN @rowsCount;
END
GO

DROP TABLE [dbo].[FOURNISSEUR_IND]
GO

---------------------
---------------------