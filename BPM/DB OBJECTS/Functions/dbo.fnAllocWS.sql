create function dbo.fnAllocWS(@pass varchar(100))
	returns varchar(1000)
as
begin

	declare @alp table(pos int, ascv int, chrv char(1), typ char(1),smv int)
	declare @c int, @p int, @s int
	declare @rpass nvarchar(1000) --,@pass varchar(100)
	set @c=97
	set @p=1

	while @c<=122
	begin
		insert into @alp values(@p,@c,char(@c),'S',97+122)
		set @c=@c+1
		set @p=@p+1
	end

	set @c=65
	set @p=1
	while @c<=90
	begin
		insert into @alp values(@p,@c,char(@c),'C',65+90)
		set @c=@c+1
		set @p=@p+1
	end

	set @c=48
	set @p=1
	while @c<=57
	begin
		insert into @alp values(@p,@c,char(@c),'N',48+57)
		set @c=@c+1
		set @p=@p+1
	end
	
	set @c=33
	set @p=1
	while @c<=47
	begin
		insert into @alp values(@p,@c,char(@c),'A',33+47)
		set @c=@c+1
		set @p=@p+1
	end
	
	set @c=58
	set @p=1
	while @c<=64
	begin
		insert into @alp values(@p,@c,char(@c),'A',58+64)
		set @c=@c+1
		set @p=@p+1
	end
	
	set @c=91
	set @p=1
	while @c<=96
	begin
		insert into @alp values(@p,@c,char(@c),'A',91+96)
		set @c=@c+1
		set @p=@p+1
	end
	
	set @c=123
	set @p=1
	while @c<=126
	begin
		insert into @alp values(@p,@c,char(@c),'A',123+126)
		set @c=@c+1
		set @p=@p+1
	end
	
	--set @pass = 'sa'
	set @s=1
	set @rpass=''
	while @s<=len(@pass)
	begin
		
		select @rpass = @rpass + chrv from @alp where ascv=(select smv-ascv from @alp where ascv=ascii(substring(@pass,@s,1)))
		--insert into @ptbl values(substring(@pass,@s,1))
	---------
	declare @f int, @r float
	--set @f=@s
	set @f=ascii(substring(@pass,@s,1))
	set @r=1
	while @f>0
	begin
		set @r=@r*@f
		set @f=@f-1
	end
	---------
		set @rpass = @rpass + convert(nvarchar,@r)
		set @s=@s+1
	end
	return @rpass
end

