USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[PrcSaveKeyData]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[PrcSaveKeyData]
(
@Action VARCHAR(100),
@keyNm VARCHAR(100) = null,
@BRnchFk BIGINT = null,
@UsrFk BIGINT = null
)
AS 
BEGIN	
	IF @Action ='Save'
	BEGIN
		INSERT INTO BpmFlowKeyTable(KeyNm,KeyBrnchFk,keyDelid)
		OUTPUT INSERTED.*
		SELECT @keyNm,@BRnchFk ,0
	END
	IF @Action = 'Select'
	BEGIN 
		SELECT KeyNm,KeyBrnchFk,KeyPk FROM BpmFlowKeyTable WHERE keyDelid = 0
	END
	IF @Action = 'GetBpmList'
	BEGIN
		SELECT	BpmNm 'BpmNm', BpmPk 'BpmPk',MAX(BvmPk) 'Version'
		FROM	BpmMas (NOLOCK) 
		JOIN	BpmVersions (NOLOCK) ON BvmBpmFk = BpmPk AND BvmDelId = 0
		WHERE	BpmDelId = 0
		GROUP BY BpmNm, BpmPk 
		

		--SELECT		BpmNm 'BpmNm', BpmPk 'BpmPk',MAX(BvmPk) 'Version'
		--FROM		BpmObjInOut (NOLOCK)
		--JOIN		BpmToolBox (NOLOCK) ON BtbPk = BioBtbFk AND BtbToolNm = 'bpmn:StartEvent' AND BtbDelid = 0
		--JOIN		GenUsrRoleDtls (NOLOCK) ON UrdUsrFk = @UsrFk AND UrdRolFk = dbo.getAttRoleFk(BioBfwFk) AND UrdDelid = 0
		--JOIN		BpmVersions(NOLOCK) ON BvmPk = BioBvmFk AND BvmDelid = 0
		--JOIN		BpmMas (NOLOCK) ON BpmPk = BvmBpmFk AND BpmDelid = 0
		--WHERE		BioDelId = 0 AND ISNULL(BioSubBfwFk,0) = 0
		--GROUP BY	BpmNm,BpmPk


	END
	
END



GO
