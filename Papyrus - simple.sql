---------------------
-- Affichage
---------------------
-- 1 -- Commandes pour fournisseur 1802.
SELECT [NUMCOM] AS 'Commandes du fournisseur 1802'
FROM [Papyrus].[dbo].[COMMANDE]
WHERE [NUMFOU] = 1802
GO

-- 2 -- Fournisseurs des commandes.
SELECT DISTINCT [NUMFOU] AS 'Fournisseurs'
FROM [Papyrus].[dbo].[COMMANDE]
GO

-- 3 -- Nombre de commandes passées et le nombre de fournisseurs concernés.
SELECT COUNT(*) AS 'Nombre commande fournisseur',
	COUNT(DISTINCT [NUMFOU]) AS 'Nombre fournisseurs'
FROM [Papyrus].[dbo].[COMMANDE]
GO

-- 4 -- Liste des articles dont le stock physique est en dessous du stock d'alerte et dont la quantité annuelle est inférieur à 1000.
SELECT [PRODUIT].[LIBART] AS 'Article à commander'
FROM [Papyrus].[dbo].[PRODUIT]
WHERE ([QTEANN] < 1000)
	AND ([STKALE] >= [STKPHY])
GO

-- 5 -- Commandes passées au mois de mars et avril.
SELECT [NUMCOM] AS 'Commandes passées entre mars et avril',
	[DATECOM] AS 'Date de la commande'
FROM [Papyrus].[dbo].[COMMANDE]
WHERE MONTH([DATECOM]) BETWEEN 3
		AND 4
GO

-- 6 -- Commandes ayant recontré un problème.
SELECT [NUMCOM] AS 'Commande problématique',
	[DATECOM] AS 'Date de la commande'
FROM [Papyrus].[dbo].[COMMANDE]
WHERE [OBSCOM] NOT IN (
		'RAS',
		'Tout est ok',
		'Bien reçu',
		'Rien à dire'
		)
GO

-- 7 -- Liste des commandes avec leurs valeurs totales, triées par valeur totale décroissante.
SELECT [NUMCOM] AS 'Commande',
	SUM(PRIUNI * QTECDE) AS 'Prix Total'
FROM [Papyrus].[dbo].[LIGNE]
GROUP BY [NUMCOM]
ORDER BY 'Prix Total' DESC
GO

-- 8 -- Liste des commandes par nom fournisseur.
SELECT [NOMFOU] AS 'Nom Fournisseur',
	[NUMCOM] AS 'Commande',
	[DATECOM] AS 'Date commande'
FROM [Papyrus].[dbo].[COMMANDE]
INNER JOIN [FOURNISSEUR] ON [FOURNISSEUR].NUMFOU = [COMMANDE].NUMFOU
ORDER BY NOMFOU,
	DATECOM ASC;
GO

-- 9 -- Liste des commandes ayant l'observation 'Commande incomplète'.
SELECT COMMANDE.[NUMCOM] AS 'Commande',
	[NOMFOU] AS 'Fournisseur',
	[LIBART] AS 'Article',
	LIGNE.PRIUNI * LIGNE.QTECDE AS 'Prix Total'
FROM [Papyrus].[dbo].[COMMANDE]
INNER JOIN [LIGNE] ON LIGNE.NUMCOM = COMMANDE.NUMCOM
INNER JOIN PRODUIT ON PRODUIT.CODART = LIGNE.CODART
INNER JOIN FOURNISSEUR ON FOURNISSEUR.NUMFOU = COMMANDE.NUMFOU
WHERE [OBSCOM] LIKE 'Commande incomplète'

-- 10 -- Liste du chiffre d'affaires TTC des fournisseurs.
SELECT [NOMFOU] AS 'Fournisseur',
	SUM(PRIUNI * QTECDE) * 1.2 AS 'Chiffre affaires TTC'
FROM [Papyrus].[dbo].[LIGNE]
INNER JOIN COMMANDE ON COMMANDE.NUMCOM = LIGNE.NUMCOM
INNER JOIN FOURNISSEUR ON FOURNISSEUR.NUMFOU = COMMANDE.NUMFOU
WHERE YEAR(COMMANDE.DATECOM) = 2018
GROUP BY NOMFOU
ORDER BY 'Chiffre affaires TTC' DESC
GO

---------------------
-- Update
---------------------
-- 1 -- Augmentation de tarif de 4% pour prix1 et de 2% pour prix2 concernant le fournisseur 1803.
UPDATE [Papyrus].[dbo].[VENDRE]
SET [PRIX1] = PRIX1 * 1.4,
	[PRIX2] = PRIX2 * 1.2
WHERE [NUMFOU] = 1803
GO

-- 2 -- Suppression du produit RIHG.
DELETE
FROM [Papyrus].[dbo].[LIGNE]
WHERE [CODART] = 'RIHG'
GO

DELETE
FROM [Papyrus].[dbo].VENDRE
WHERE [CODART] = 'RIHG'
GO

DELETE
FROM [Papyrus].[dbo].[PRODUIT]
WHERE [CODART] = 'RIHG'
GO

-- 3 -- Suppression des entêtes de commandes qui n'ont aucune ligne.
DELETE
FROM [Papyrus].[dbo].[COMMANDE]
WHERE [NUMCOM] NOT IN (
		SELECT DISTINCT NUMCOM
		FROM [Papyrus].[dbo].[LIGNE]
		)
GO