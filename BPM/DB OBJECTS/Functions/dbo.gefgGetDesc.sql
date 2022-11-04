/****** Object:  UserDefinedFunction [dbo].[gefgGetPrtFk]    Script Date: 6/8/2016 10:24:16 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[gefgGetDesc]
(@DescFk	BIGINT, @Flg INT) 
RETURNS VARCHAR(100)
BEGIN
	DECLARE @DescNm VARCHAR(100), @DpdFk BIGINT
	
	IF @Flg = 1
		SELECT @DescNm = RTRIM(UsrDispNm) FROM GenUsrMas WITH(NOLOCK) WHERE UsrPk = @DescFk AND UsrDelid = 0
		
	IF @Flg = 2
		BEGIN
			SELECT @DpdFk = BudBfwFk FROM BpmUIDefn WITH(NOLOCK) WHERE BudPk = @DescFk AND BudDelId = 0
			SELECT @DescNm = BfwLabel FROM Bpmflow WITH(NOLOCK) WHERE BfwPk = @DpdFk AND BfwDelId = 0	
		END
		
	IF @Flg = 3
		BEGIN
			SELECT @DescNm = BfwLabel FROM Bpmflow WITH(NOLOCK) WHERE BfwPk = @DescFk AND BfwDelId = 0	
		END
	RETURN @DescNm
END

GO
