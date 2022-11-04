CREATE   Function dbo.gefgDMY(@mDate DateTime) 
Returns char(10)
--with encryption
as
Begin 
	Declare @mDateStr char(10),@CmpFk BIGINT,@Typ Int,@Sep INT
	--select @CmpFk=cmppk from profamgcmpmas with(nolock) where cmpdelid=0
	--SELECT @Typ=dbo.gefgGetCmpCnfgVal('CmpDtFormat',@cmpFk)
	--SELECT @Sep=dbo.gefgGetCmpCnfgVal('CmpDtSep',@cmpFk)
	SET @Typ = 3;
	SET @Sep = 1;
	
	If @mdate=''
		select @mDateStr=''
	ELSE IF @Typ=1
		select	@mDateStr = Convert(Char(10), @mDate, 101)
	ELSE IF @Typ=2
		select	@mDateStr = Convert(Char(10), @mDate, 111)
	Else 
		select	@mDateStr = Convert(Char(10), @mDate, 103)

	IF @Sep=2
		SET @mDateStr=replace(@mDateStr,'/','-')
	ELSE IF @Sep=3
		SET @mDateStr=replace(@mDateStr,'/','.')

	Return @mDateStr
End