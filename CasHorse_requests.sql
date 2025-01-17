USE [CasHorse]
GO
INSERT INTO [dbo].[Genders]
           ([LabelGender])
     VALUES
           ('Male')
GO
INSERT INTO [dbo].[Genders]
           ([LabelGender])
     VALUES
           ('Female')

GO
DELETE FROM [dbo].[Genders]

GO
ALTER TABLE [dbo].[horses]
DROP idGender

ALTER TABLE [dbo].[horses]
DROP CONSTRAINT FK__horses__idGender__571DF1D5

GO
ALTER TABLE [dbo].[horses]
DROP COLUMN idGender

GO
ALTER TABLE [dbo].[horses]
ADD gender CHAR(1)
GO
ALTER TABLE [dbo].[horses]
ADD CONSTRAINT CHK_gender CHECK (gender = 'M' OR gender = 'F')