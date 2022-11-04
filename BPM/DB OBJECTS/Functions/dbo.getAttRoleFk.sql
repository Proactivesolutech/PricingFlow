/****** Object:  UserDefinedFunction [dbo].[gefgGetPrtFk]    Script Date: 6/8/2016 10:24:16 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[getAttRoleFk]
(@ElmFk	BIGINT) 
RETURNS BIGINT
BEGIN
	
	DECLARE @RoleFk BIGINT , @ElmDesc VARCHAR(100)
	
	SELECT	@ElmDesc =  LTRIM(RTRIM(BfwLaneRef)) FROM BpmFlow(NOLOCK) WHERE BfwPk = @ElmFk AND BfwDelid = 0
	
	SELECT	@RoleFk = RolPk
	FROM	GenRole(NOLOCK) 
	JOIN	BpmFlow (NOLOCK) ON BfwId = @ElmDesc AND LTRIM(RTRIM(BfwLabel)) = LTRIM(RTRIM(RolNm)) AND BfwDelid = 0
	WHERE	RolDelid = 0
	
	RETURN @RoleFk
END

GO
