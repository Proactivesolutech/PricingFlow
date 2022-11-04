/****** Object:  UserDefinedFunction [dbo].[gefgGetPrtFk]    Script Date: 6/8/2016 10:24:16 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[getFlowNm]
(@VerFk	BIGINT) 
RETURNS VARCHAR(100)
BEGIN
	
	DECLARE @FlowNm VARCHAR(100)
	
	SELECT	@FlowNm =  BpmNm 
	FROM	BpmVersions (NOLOCK), BpmMas(NOLOCK) 
	WHERE	BvmBpmFk = BpmPk AND BvmPk = @VerFk AND BvmDelid = 0 AND BpmDelid = 0
	
	RETURN @FlowNm
END

GO
