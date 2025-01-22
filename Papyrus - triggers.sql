-- 3.2.1 - AFTER DELETE
CREATE TRIGGER [Papyrus].[dbo].[securityDelete] ON [Papyrus].[dbo].[VENDRE]
AFTER DELETE
AS
BEGIN
	DECLARE @countDelete INT;

	SET @countDelete = (
			SELECT COUNT(*)
			FROM deleted
			);

	IF (@countDelete > 1)
	BEGIN
		RAISERROR (
				'Pas plus d''une suppression à la fois',
				10,
				1
				)

		ROLLBACK TRANSACTION
	END
END
GO

-- 3.2.2 - AFTER UPDATE
CREATE TABLE [Papyrus].[dbo].[ARTICLES_A_COMMANDER] (
	CODART VARCHAR(4) NOT NULL,
	QTE INT NOT NULL,
	DATECDE DATETIME NOT NULL,
	)
GO

ALTER TABLE [Papyrus].[dbo].[ARTICLES_A_COMMANDER] ADD CONSTRAINT fk_article_acommander FOREIGN KEY (CODART
	) REFERENCES [Papyrus].[dbo].[PRODUIT]
GO

DROP TRIGGER [dbo].[securityStock];
GO

DROP PROCEDURE [dbo].[autoCommande]
GO

CREATE PROCEDURE [dbo].[autoCommande] @countStk INT,
	@codart VARCHAR(4)
AS
BEGIN
	IF (@countStk = 0)
	BEGIN
		RAISERROR (
				'Stock physique vide',
				10,
				1
				)
		WITH LOG

		ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN
		DECLARE @countCmde FLOAT;

		SET @countCmde = (
				SELECT STKALE - (STKPHY + SUM(QTE))
				FROM [Papyrus].[dbo].[PRODUIT]
				INNER JOIN ARTICLES_A_COMMANDER ON ARTICLES_A_COMMANDER.CODART = PRODUIT.CODART
				GROUP BY PRODUIT.CODART,
					STKALE,
					STKPHY
				);

		IF (@countCmde > 0)
		BEGIN
			INSERT INTO [dbo].[ARTICLES_A_COMMANDER] (
				[CODART],
				[QTE],
				[DATECDE]
				)
			VALUES (
				@codart,
				@countCmde,
				GETDATE()
				)
		END
	END
END
GO

CREATE TRIGGER [dbo].[securityStock] ON [Papyrus].[dbo].[PRODUIT]
AFTER UPDATE
AS
BEGIN
	DECLARE produits CURSOR LOCAL FORWARD_ONLY READ_ONLY
	FOR
	SELECT CODART,
		STKPHY
	FROM deleted

	DECLARE @countStk INT;
	DECLARE @codart VARCHAR(4);

	OPEN produits

	FETCH NEXT
	FROM produits
	INTO @codart,
		@countStk

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC autoCommande @countStk,
			@codart

		FETCH NEXT
		FROM produits
		INTO @countStk,
			@codart
	END

	CLOSE produits

	DEALLOCATE produits
END
GO

-- 3.2.3 - AFTER UPDATE
DROP TRIGGER [dbo].[securitySatisfaction]
GO

CREATE TRIGGER [dbo].[securitySatisfaction] ON [Papyrus].[dbo].[FOURNISSEUR]
AFTER UPDATE
AS
BEGIN
	DECLARE @oldSatisf INT;
	DECLARE @newSatisf INT;

	DECLARE fournisseurs CURSOR LOCAL FORWARD_ONLY READ_ONLY
	FOR
	SELECT I.SATISF,
		D.SATISF
	FROM inserted I
	INNER JOIN deleted D ON I.NUMFOU = D.NUMFOU

	OPEN fournisseurs

	FETCH NEXT
	FROM fournisseurs
	INTO @newSatisf,
		@oldSatisf

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF (
				@oldSatisf - @newSatisf > 3
				OR @newSatisf - @oldSatisf > 3
				)
		BEGIN
			RAISERROR (
					'Erreur de saisie de l''indice de satisfaction',
					10,
					1
					);

			ROLLBACK TRANSACTION
		END

		FETCH NEXT
		FROM fournisseurs
		INTO @newSatisf,
			@oldSatisf
	END
END




-----------------------------------------
-------- Correction
-----------------------------------------

-- 1er trigger
 
CREATE TRIGGER trg_PreventMultiDelete
ON VENDRE
AFTER DELETE
AS
BEGIN
    -- Vérifie le nombre de lignes supprimées
    IF (SELECT COUNT(*) FROM deleted) > 1
	-- if @@ROWCOUNT > 1
    BEGIN
     -- 16 = niveau de séverité (peux etre modif par utilisateur  1 = etat (aide a la tracabilité)
        RAISERROR ('Suppression multiple non autorisée dans la table VENTE.', 16  , 1 );
        ROLLBACK TRANSACTION;-- annule l opération si l utilisateur essaye de supp pls lignes
    END
END
 
-- 2ième trigger
 
/* Création de la table */
CREATE TABLE ARTICLE_A_COMMANDER(
	CODART varchar(4) NOT NULL,
	QTE int NOT NULL,
	DATEALERT datetime NOT NULL,
	FOREIGN KEY(CODART) REFERENCES PRODUIT(CODART)
)
GO
/* Création du trigger */
CREATE TRIGGER produit_modifStock ON PRODUIT
FOR UPDATE
AS
BEGIN
	-- On ne s'interesse qu'aux modifications du stock courant
	IF 
		UPDATE (STKPHY)
	BEGIN
		-- Déclaration et ouverture du curseur
		DECLARE curseur CURSOR
		FOR
		SELECT CODART, STKPHY, STKALE
		FROM inserted
		OPEN curseur
		-- Chargement de la première ligne
		DECLARE @produit VARCHAR(4)
		DECLARE @quantite INT
		DECLARE @stockAlerte INT
		FETCH NEXT
		FROM curseur
		INTO @produit, @quantite, @stockAlerte
		-- Parcours de inserted
		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- Si la modification ferait passer le stock d'un article en dessous de 0 on annule la modification
			IF (@quantite < 0)
			BEGIN
				RAISERROR ('Le stock de l''article est insuffisant', 16, -1, @produit) WITH LOG
				-- Fermeture du curseur et rollback
				CLOSE curseur
				DEALLOCATE curseur
				ROLLBACK TRAN
				RETURN
			END
			-- Vérification de la nécessité de commander pour l'article courant
			DECLARE @stockTotal INT
			SET @stockTotal = @quantite
			IF EXISTS(
				SELECT *
				FROM ARTICLE_A_COMMANDER
				WHERE CODART = @produit
			)
			BEGIN
				SET @stockTotal = (
					SELECT SUM(QTE)
					FROM ARTICLE_A_COMMANDER
					WHERE CODART = @produit
					) + @stockTotal
			END
			-- Si le stock total est inférieur ou égal au stock d'alerte on insert une ligne dans ARTICLE_A_COMMANDER
			IF @stockTotal <= @stockAlerte
			BEGIN
				INSERT INTO ARTICLE_A_COMMANDER
				VALUES (@produit, (@stockAlerte - @stockTotal), CURRENT_TIMESTAMP)
			END
			-- Passage à la ligne suivante
			FETCH NEXT
			FROM curseur
			INTO @produit, @quantite, @stockAlerte
		END
		-- Fermeture du curseur
		CLOSE curseur
		DEALLOCATE curseur
	END
END
GO
 
-- v2
CREATE TRIGGER trg_UpdateStock
ON [dbo].[PRODUIT]
AFTER UPDATE
AS
BEGIN
    DECLARE @CODART VARCHAR(10), @STKPHY INT, @STKALE INT;
    DECLARE StockCursor CURSOR FOR
    SELECT i.CODART, i.STKPHY, i.STKALE
    FROM inserted i;
    OPEN StockCursor;
    FETCH NEXT FROM StockCursor INTO @CODART, @STKPHY, @STKALE;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Vérifie si une réduction est effectuée lorsque le stock est déjà à 0
        IF @STKPHY < (SELECT STKPHY FROM deleted WHERE CODART = @CODART) AND (SELECT STKPHY FROM deleted WHERE CODART = @CODART) = 0
        BEGIN
            RAISERROR ('Impossible de réduire le stock : le stock physique est déjà égal à 0', 16, 1) WITH LOG;
            ROLLBACK;
            CLOSE StockCursor;
            DEALLOCATE StockCursor;
            RETURN;
        END
        -- Insère dans ARTICLES_A_COMMANDER si le stock devient inférieur ou égal au stock d’alerte
        IF @STKPHY + ISNULL((SELECT SUM(QTE) FROM [dbo].[ARTICLES_A_COMMANDER] WHERE CODART = @CODART), 0) <= @STKALE
        BEGIN
            INSERT INTO [dbo].[ARTICLES_A_COMMANDER] (CODART, QTE, DATE)
            VALUES (@CODART, @STKALE - (@STKPHY + ISNULL((SELECT SUM(QTE) FROM [dbo].[ARTICLES_A_COMMANDER] WHERE CODART = @CODART), 0)), GETDATE());
        END
        FETCH NEXT FROM StockCursor INTO @CODART, @STKPHY, @STKALE;
    END
    CLOSE StockCursor;
    DEALLOCATE StockCursor;
END;
GO
 
-- trigger n°3
CREATE TRIGGER trg_CheckSatisfactionUpdate
ON [dbo].[FOURNISSEUR]
AFTER UPDATE
AS
BEGIN
    DECLARE @NUMFOU INT, @SATISF_NEW INT, @SATISF_OLD INT;
    DECLARE SatisfactionCursor CURSOR FOR
    SELECT i.NUMFOU, i.SATISF, d.SATISF
    FROM inserted i
    JOIN deleted d ON i.NUMFOU = d.NUMFOU;
    OPEN SatisfactionCursor;
    FETCH NEXT FROM SatisfactionCursor INTO @NUMFOU, @SATISF_NEW, @SATISF_OLD;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF ABS(@SATISF_NEW - @SATISF_OLD) > 3
        BEGIN
            RAISERROR ('La modification de l indice de satisfaction est supérieure à 3 points.', 16, 1);
            ROLLBACK;
            CLOSE SatisfactionCursor;
            DEALLOCATE SatisfactionCursor;
            RETURN;
        END
        FETCH NEXT FROM SatisfactionCursor INTO @NUMFOU, @SATISF_NEW, @SATISF_OLD;
    END
    CLOSE SatisfactionCursor;
    DEALLOCATE SatisfactionCursor;
END;
GO