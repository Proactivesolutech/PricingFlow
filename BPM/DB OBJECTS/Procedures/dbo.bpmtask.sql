USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[bpmtask]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpmtask]
(
@Action	VARCHAR(100),
@VerFk	BIGINT
)
AS
BEGIN
IF @Action='SELECT'
BEGIN
	SELECT BpmNm,* FROM BpmVersions 
	JOIN BpmFlow ON BvmPk = BfwBvmFk AND BvmDelid = 0
	JOIN BpmObjInout ON BfwBvmFk = BioBvmFk AND BioDelid = 0
	JOIN BpmMas ON BpmPk = BvmBpmFk AND BpmDelid = 0
	WHERE BvmPk = @VerFk AND BvmDelid = 0
END
END
GO
