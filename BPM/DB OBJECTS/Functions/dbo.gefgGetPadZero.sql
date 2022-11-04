/****** Object:  UserDefinedFunction [dbo].[gefgGetPadZero]    Script Date: 6/8/2016 10:24:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   Function [dbo].[gefgGetPadZero](@totpadlen int,@pval Numeric(20))
Returns varchar(50)
as
Begin
/*

Author Name 	: Robin
Created On	: 24.04.2001
Section		: 
Purpose		: Pad Numbers for the given length,and pads with the value(Max Width = 50)
Spl. Comments	: 
Remarks		: 

Sample  :  Select prdbo.GetPadZero(5,890)

*/
	 DECLARE @RetVal varchar(50)
	 select @retval = right('00000000000000000000000000000000000000000000000000'+convert(varchar(20),@Pval),@totpadlen)
	 return @retval

End
GO