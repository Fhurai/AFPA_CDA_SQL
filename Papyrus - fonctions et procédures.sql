use [Papyrus]
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
	print @jj;
	print datepart(dd, @pdate);
	print @pdate;
	set @mm = convert(varchar(2), datepart(mm, @pdate));
	set @jj = convert(varchar(4), datepart(yy, @pdate));
	-- assemblage pour restitution
	return @jj + @psep + @mm + @psep + @aa;
end

drop function dbo.fn_Dateformat