CREATE Function dbo.gefgGetDecPass
(
	@pass VARCHAR(1000)
)
Returns Varchar(1000)
--++ with encryption
AS
BEGIN
	declare @alp table(pos int, ascv int, chrv char(1), typ char(1),smv int, enc varchar(100) )
	declare @c int, @p int, @s int, @tpass nvarchar(100)
	declare @rpass nvarchar(1000)

	set @c=97
	set @p=1
	
	while @c<=122
	begin
		insert into @alp select @p,@c,char(@c),'S',97+122, dbo.fnAllocWS(char(@c))
		set @c=@c+1
		set @p=@p+1
	end

	set @c=65
	set @p=1
	while @c<=90
	begin
		insert into @alp SELECT @p,@c,char(@c),'C',65+90, dbo.fnAllocWS(char(@c))
		set @c=@c+1
		set @p=@p+1
	end
	
	set @c=48
	set @p=1
	while @c<=57
	begin
		insert into @alp SELECT @p,@c,char(@c),'N',48+57, dbo.fnAllocWS(char(@c))
		set @c=@c+1
		set @p=@p+1
	end

	set @c=33
	set @p=1
	while @c<=47
	begin
		insert into @alp values(@p,@c,char(@c),'A',33+47,dbo.fnAllocWS(char(@c)))
		set @c=@c+1
		set @p=@p+1
	end

	set @c=58
	set @p=1
	while @c<=64
	begin
		insert into @alp values(@p,@c,char(@c),'A',58+64,dbo.fnAllocWS(char(@c)))
		set @c=@c+1
		set @p=@p+1
	end
	
	set @c=91
	set @p=1
	while @c<=96
	begin
		insert into @alp values(@p,@c,char(@c),'A',91+96,dbo.fnAllocWS(char(@c)))
		set @c=@c+1
		set @p=@p+1
	end
	
	set @c=123
	set @p=1
	while @c<=126
	begin
		insert into @alp values(@p,@c,char(@c),'A',123+126,dbo.fnAllocWS(char(@c)))
		set @c=@c+1
		set @p=@p+1
	end
		
	set @s=1
	set @rpass=''
	set @tpass = ''
	while @pass != ''
	begin
		SELECT @tpass = SUBSTRING( @pass, 1, CHARINDEX('+', @pass) + 3 )
		select @rpass = @rpass + chrv from @alp where @tpass = SUBSTRING (enc, 1, LEN(@tpass) )
		SELECT @pass = SUBSTRING( @pass, CHARINDEX('+', @pass) + 4, LEN(@pass) )
		SET @tpass = ''
	END
	Return @rpass
END

