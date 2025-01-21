use [Papyrus]
GO

-- 3.2.1 - AFTER DELETE
CREATE TRIGGER [dbo].[securityDelete]
On [dbo].[VENDRE]
AFTER DELETE
AS
BEGIN
	DECLARE @countDelete INT;

	SET @countDelete = (select COUNT(*) from deleted);

	if (@countDelete > 1)
		BEGIN
			RAISERROR ('Pas plus d''une suppression à la fois', 10, 1)
			ROLLBACK TRAN
END
END
GO


-- 3.2.2 - AFTER UPDATE
CREATE TABLE [Papyrus].[dbo].[ARTICLES_A_COMMANDER] (
	CODART varchar(4) not null,
	QTE INT not null,
	DATECDE datetime not null
)
go

CREATE TRIGGER [dbo].[securityStock]
on [dbo].[PRODUIT]
AFTER UPDATE
AS
BEGIN
END
GO

-- 3.2.3 - AFTER UPDATE