SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[gefgGetCmpCnfgVal]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[gefgGetCmpCnfgVal]
GO

CREATE Function dbo.gefgGetCmpCnfgVal
(
	@CnfgStr Varchar(50) = NULL,
	@CmpFK Int = NULL
)
Returns Int

with encryption
As
BEGIN
	Declare @CmpCnfgVal Int
	Declare @CnfgStrPK Int

	SELECT @CnfgStrPK =  ccfPK FROM GenCmpConfigHdr with (NoLock) where ccfObjName = @CnfgStr and ccfDelId = 0
	
	
	IF ISNULL(@CmpCnfgVal,0) = 0
		Select @CmpCnfgVal = cnfVal FROM GenCmpConfigDtls with (NoLock) Where cnfccfFK = @CnfgStrPK and cnfcmpfk = @CmpFK and cnfDelId = 0

	Return @CmpCnfgVal
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO