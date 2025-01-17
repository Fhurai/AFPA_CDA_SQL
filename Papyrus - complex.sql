-- 1 -- Fournisseur des départements 75, 78, 92, 77
SELECT SUBSTRING([POSFOU], 0, 3) AS 'Département',
	[NOMFOU]
FROM [Papyrus].[dbo].[FOURNISSEUR]
WHERE [POSFOU] LIKE '75%'
	OR [POSFOU] LIKE '78%'
	OR [POSFOU] LIKE '92%'
	OR [POSFOU] LIKE '77%'
ORDER BY POSFOU DESC,
	NOMFOU ASC
GO

-- 2 -- Liste des commandes supérieur  10K€
SELECT [COMMANDE].[NUMCOM] AS Commande,
	SUM(QTECDE * PRIUNI) AS 'Prix total'
FROM [Papyrus].[dbo].[COMMANDE]
INNER JOIN [Papyrus].[dbo].[LIGNE] ON [LIGNE].[NUMCOM] = [COMMANDE].[NUMCOM]
GROUP BY [COMMANDE].[NUMCOM]
HAVING SUM(QTECDE * PRIUNI) > 10000
	AND SUM(QTECDE) < 1000
GO

-- 3 -- Liste des fournisseurs susceptibles de livre au moins un article
SELECT DISTINCT NOMFOU,
	QTE1
FROM [Papyrus].[dbo].[FOURNISSEUR]
INNER JOIN [Papyrus].[dbo].[VENDRE] ON VENDRE.NUMFOU = FOURNISSEUR.NUMFOU
GO

-- 4 -- Commandes dont le fournisseur est celui de la demande 70210 -> 7
SELECT NUMCOM AS 'Commande',
	DATECOM AS 'Date commande'
FROM [Papyrus].[dbo].[COMMANDE]
WHERE NUMFOU IN (
		SELECT NUMFOU
		FROM [Papyrus].[dbo].[COMMANDE]
		WHERE NUMCOM = 7
		)
GO

SELECT DISTINCT A.NUMCOM AS 'Commande',
	A.DATECOM AS 'Date commande'
FROM [Papyrus].[dbo].[COMMANDE] A
INNER JOIN [Papyrus].[dbo].[COMMANDE] B ON B.NUMFOU = A.NUMFOU
WHERE B.NUMCOM = 7
GO

-- 5 -- Liste des articles moins chers que le moins cher des rubans
SELECT LIBART,
	PRIX1
FROM [Papyrus].[dbo].[PRODUIT]
INNER JOIN [Papyrus].[dbo].[VENDRE] ON VENDRE.CODART = PRODUIT.CODART
WHERE PRIX1 < (
		SELECT MIN(PRIX1)
		FROM [Papyrus].[dbo].[VENDRE]
		WHERE CODART LIKE 'R%'
		)
GO

-- 6 -- Liste des fournisseurs susceptibles de livrer articles avec 150% du STKALE
SELECT PRODUIT.LIBART,
	FOURNISSEUR.NOMFOU
FROM [Papyrus].[dbo].[PRODUIT]
INNER JOIN [Papyrus].[dbo].[VENDRE] ON VENDRE.CODART = PRODUIT.CODART
INNER JOIN [Papyrus].[dbo].[FOURNISSEUR] ON FOURNISSEUR.NUMFOU = VENDRE.NUMFOU
WHERE STKPHY <= (1.5 * STKALE)
ORDER BY LIBART,
	NOMFOU ASC
GO

-- 7 -- Liste des fournisseurs susceptibles de livrer articles avec 150% du STKALE et délai 30j
SELECT DISTINCT PRODUIT.LIBART,
	FOURNISSEUR.NOMFOU
FROM [Papyrus].[dbo].[PRODUIT]
INNER JOIN [Papyrus].[dbo].[VENDRE] ON VENDRE.CODART = PRODUIT.CODART
INNER JOIN [Papyrus].[dbo].[FOURNISSEUR] ON FOURNISSEUR.NUMFOU = VENDRE.NUMFOU
WHERE STKPHY <= (1.5 * STKALE)
	AND DELLIV <= 30
ORDER BY NOMFOU,
	LIBART ASC
GO

-- 8 --
SELECT DISTINCT FOURNISSEUR.NOMFOU AS Fournisseur,
	SUM(STKPHY) AS 'Total des stocks'
FROM [Papyrus].[dbo].PRODUIT
INNER JOIN [Papyrus].[dbo].VENDRE ON VENDRE.CODART = PRODUIT.CODART
INNER JOIN [Papyrus].[dbo].FOURNISSEUR ON FOURNISSEUR.NUMFOU = VENDRE.NUMFOU
WHERE STKPHY > (1.5 * STKALE)
	AND DELLIV <= 30
GROUP BY [FOURNISSEUR].NOMFOU
ORDER BY Fournisseur ASC
GO

-- 9 --
SELECT DISTINCT LIGNE.CODART,
	SUM(QTECDE) AS 'Total commandé',
	SUM(PRODUIT.QTEANN) AS 'Total annuel'
FROM [Papyrus].[dbo].[LIGNE]
INNER JOIN [Papyrus].[dbo].[PRODUIT] ON PRODUIT.CODART = LIGNE.CODART
INNER JOIN [Papyrus].[dbo].[COMMANDE] ON COMMANDE.NUMCOM = LIGNE.NUMCOM
WHERE YEAR(datecom) = '2018'
GROUP BY LIGNE.CODART
HAVING (SUM(PRODUIT.QTEANN) * 0.9) < SUM(QTECDE)
GO

--SELECT produit.CODART,
--	PRODUIT.LIBART,
--	qteann AS qteannuelle,
--	(sum(qtecde)) AS totalcommande
--FROM [Papyrus].[dbo].[PRODUIT]
--INNER JOIN [Papyrus].[dbo].[LIGNE] ON produit.codart = ligne.codart
--INNER JOIN [Papyrus].[dbo].[COMMANDE] ON commande.numcom = ligne.numcom
--WHERE YEAR(datecom) = '2018'
--GROUP BY produit.CODART,
--	produit.LIBART,
--	qteann
--HAVING qteann < sum(qtecde) * 0.9

-- 10 --
SELECT PRODUIT.LIBART AS 'Article',
	FOURNISSEUR.NOMFOU AS 'Fournisseur',
	COMMANDE.NUMCOM AS 'Commande',
	COMMANDE.NUMFOU as 'Id Fournisseur',
	LIGNE.CODART as 'Id Article'
FROM [Papyrus].[dbo].[LIGNE]
INNER JOIN [Papyrus].[dbo].[COMMANDE] ON COMMANDE.NUMCOM = LIGNE.NUMCOM
INNER JOIN [Papyrus].[dbo].[PRODUIT] ON PRODUIT.CODART = LIGNE.CODART
INNER JOIN [Papyrus].[dbo].[FOURNISSEUR] ON FOURNISSEUR.NUMFOU = COMMANDE.NUMFOU
WHERE LIGNE.CODART NOT IN (
		SELECT CODART
		FROM [Papyrus].[dbo].[VENDRE]
		WHERE COMMANDE.NUMFOU = VENDRE.NUMFOU
		)
ORDER BY FOURNISSEUR.NOMFOU,
	PRODUIT.LIBART ASC
GO

select *
from [Papyrus].[dbo].VENDRE
where VENDRE.CODART = 'D5MO'
and VENDRE.NUMFOU = 1702
GO

-- 11 --
SELECT NOMFOU,
	SUM(PRIUNI * QTECDE) AS 'CA Fournisseur'
FROM [Papyrus].[dbo].[LIGNE]
INNER JOIN [Papyrus].[dbo].[COMMANDE] ON COMMANDE.NUMCOM = LIGNE.NUMCOM
INNER JOIN [Papyrus].[dbo].[FOURNISSEUR] ON COMMANDE.NUMFOU = FOURNISSEUR.NUMFOU
GROUP BY FOURNISSEUR.NOMFOU
ORDER BY 'CA Fournisseur' DESC
GO

-- 12 --
SELECT TOP(1) NOMFOU,
	SUM(PRIUNI * QTECDE) AS 'CA Fournisseur'
FROM [Papyrus].[dbo].[LIGNE]
INNER JOIN [Papyrus].[dbo].[COMMANDE] ON COMMANDE.NUMCOM = LIGNE.NUMCOM
INNER JOIN [Papyrus].[dbo].[FOURNISSEUR] ON COMMANDE.NUMFOU = FOURNISSEUR.NUMFOU
GROUP BY FOURNISSEUR.NOMFOU
ORDER BY 'CA Fournisseur' DESC
GO

-- 13 --
UPDATE [Papyrus].[dbo].[COMMANDE]
SET OBSCOM = '*****'
WHERE NUMCOM IN (
		SELECT DISTINCT NUMCOM
		FROM [Papyrus].[dbo].[FOURNISSEUR]
		INNER JOIN [Papyrus].[dbo].[COMMANDE] ON COMMANDE.NUMFOU = FOURNISSEUR.NUMFOU
		WHERE SATISF < 5
		)
GO

----------------------------------
----------------------------------
-- 1 --
--Liste des employés avec un salaire non nul.
-- 2 --
-- Liste des moyennes de salaire et du salaire minimum par département.
-- 3 --
-- Liste des moyennes de salaire et du salaire minimum par département avec une moyenne supérieure à 16000.
-- 4 --
-- Liste des employés dont le salaire est compris dans les salaires du département B00
-- (Requete bizarre)
-- 5 --
-- Liste des employés dont le salaire est supérieur à n'importe quel salaire du département B00
-- 6 --
-- Liste des employés dont le salaire est supérieur à tous les salaires du département B00
-- 7 --
-- Liste des employés qui ont le même salaire tout en travaillant dans des départements différents, triés par département et par salaire.