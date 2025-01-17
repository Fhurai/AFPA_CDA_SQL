USE [Papyrus]
GO

SELECT NUMCOM, DATECOM
FROM [Papyrus].[dbo].[COMMANDE]
WHERE MONTH(DATECOM) IN (3, 4)
GO

create function fn_Dateformat
(@pdate datetime, @psep char(1))
returns char(10)
as
begin
-- variables nécessaires
declare @jj char(2);
declare @mm char(2);
declare @aa char(4);
-- calcul des différentes parties de la date
set @jj = convert(varchar(2), datepart(dd, @pdate));
set @mm = convert(varchar(2), datepart(mm, @pdate));
set @aa = convert(varchar(4), datepart(yy, @pdate));
-- assemblage pour restitution
return @jj + @psep + @mm + @psep + @aa ;
end
GO

SELECT NUMCOM, [dbo].[fn_Dateformat](DATECOM, '/')
FROM [Papyrus].[dbo].[COMMANDE]
WHERE MONTH(DATECOM) IN (3, 4)
GO