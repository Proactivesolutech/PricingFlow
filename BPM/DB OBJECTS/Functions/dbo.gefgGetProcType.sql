/****** Object:  UserDefinedFunction [dbo].[gefgGetParticipantId]    Script Date: 6/8/2016 10:24:16 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[gefgGetProcType]
(@SbfdPk VARCHAR(100)) 
RETURNS VARCHAR(100)
BEGIN
	DECLARE @ProcType VARCHAR(100)
	SELECT	@ProcType = LOWER(BtbToolNm) 
	FROM	BpmFlow WITH(NOLOCK) 
	JOIN	BpmToolBox (NOLOCK) ON BtbPk = BfwBtbFk AND BtbDelid = 0
	WHERE	BfwPk = @SbfdPk AND BfwDelId = 0
	
	RETURN @ProcType
END
GO


