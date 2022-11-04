SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GefgCurFormat_Print]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[GefgCurFormat_Print]
GO


CREATE Function [GefgCurFormat_Print]
(
	@Number Numeric(27,7),
	@CmpFK Int=0 --Assuming that all the Locations will be using same currency and qty formats.	
)
Returns varchar(50)
As
BEGIN
	Declare @Number1 Numeric(27,7)  			
	Declare @RoundTo TinyInt 
	SELECT @CmpFK =Cmppk from GenCmpMas (NOLOCK) where CmpDelid=0
	SELECT @RoundTo =  dbo.gefgGetCmpCnfgVal('gCurrDigit_Print',@CmpFK)
	SET @Number1 = @Number
	
	SELECT @RoundTo =  IsNull(@RoundTo,4)


	if @Number < 0 							
		Set @Number = @Number*-1
	else
		Set @Number = @Number


	IF @Number > 99999999999999999999.9999999 Return 'Invalid Currency Value'

	IF @RoundTo > 7 Return 'Invalid RoundTo'
	SELECT @Number = 
	CASE @RoundTo
	WHEN 0 THEN Round(@Number,0)
	WHEN 1 THEN Round(@Number,1)
	WHEN 2 THEN Round(@Number,2)
	WHEN 3 THEN Round(@Number,3)
	WHEN 4 THEN Round(@Number,4)
	WHEN 5 THEN Round(@Number,5)
	WHEN 6 THEN Round(@Number,6)
	WHEN 7 THEN Round(@Number,7)
	END
	DECLARE @Result nvarchar(255)
	DECLARE @i int
	DECLARE @FirstPart char(3)
	DECLARE @RemainingPart nvarchar(255)
	DECLARE @FirstRemainingPart nvarchar(255)
	DECLARE @LastRemainingPart int
	DECLARE @Sayi1 Numeric(35,0)
	DECLARE @Sonuc nvarchar(255)
	DECLARE @Numb2Char VarChar(50)
	DECLARE @IntPart VarChar(50)
	DECLARE @DeciPart VarChar(50)
	SELECT @Numb2Char  = Ltrim(Rtrim(convert(varchar(50),@Number)))
	
	SELECT @IntPart  = Left(@Numb2Char,CharIndex('.',@Numb2Char)-1)
	SELECT @DeciPart  = substring(@Numb2Char,CharIndex('.',@Numb2Char)+1,@RoundTo)
	IF Len(@DeciPart) > 0  SELECT @DeciPart = '.'+@DeciPart
	
	
	SET @Sayi1 = convert(Numeric(27,0),@IntPart)
	SET @LastRemainingPart=convert(Numeric(20,0), len(@Sayi1)/3)
	SET @FirstPart = convert(nvarchar(3),left(convert(nvarchar(255),@Sayi1),len(@Sayi1)-@LastRemainingPart*3))
	SET @FirstRemainingPart=convert(nvarchar(255),right(convert(nvarchar(255),@Sayi1),@LastRemainingPart*3))
	SET @i=1
	SET @RemainingPart=''
	IF len(@Sayi1) % 3!=0
	BEGIN
		WHILE @i<=@LastRemainingPart*3
		Begin
			SET @RemainingPart= @RemainingPart+ substring(@FirstRemainingPart,@i,3)+ ','
			SET @i=@i+3
		END
		SET @Sonuc=rtrim(@FirstPart)+','+@RemainingPart
		SET @Result=@Sonuc
	end
	ELSE IF len(@Sayi1) % 3=0
	begin
		WHILE @i<=len(@Sayi1)
		begin
			SET @RemainingPart=@RemainingPart+substring(convert(nvarchar(255),@Sayi1),@i,3)+ ','
			SET @i=@i+3
		END
		SET @Result=@RemainingPart
	END
	if @Number1 < 0 Set @Result = '-' + @Result		
	Return left(@Result,len(@Result)-1)+@DeciPart		
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

