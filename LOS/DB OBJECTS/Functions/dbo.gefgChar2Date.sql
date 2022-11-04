CREATE Function gefgChar2Date(@dt Char(10))
returns	Char(11)
--++ With Encryption
as
Begin
	Declare @res char(11)
	if (@dt = NULL or Ltrim(Rtrim(@dt)) = '') set @dt = NULL
	Select @res = convert(char(11),convert(datetime,@dt,103),106)
	return (@res)
End

