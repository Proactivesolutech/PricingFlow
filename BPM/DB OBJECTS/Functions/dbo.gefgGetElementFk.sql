/****** Object:  UserDefinedFunction [dbo].[gefgGetElementFk]    Script Date: 6/8/2016 10:23:53 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[gefgGetElementFk]
(@ElmId VARCHAR(100)) 
RETURNS BIGINT
BEGIN
	DECLARE @ElmFk BIGINT
	SELECT @ElmFk = BfwPk FROM BpmFlow WITH(NOLOCK) WHERE RTRIM(BfwId) = @ElmId AND BfwDelid = 0
	RETURN @ElmFk
END


GO