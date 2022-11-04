IF OBJECT_ID('PrcFlushBpmData','P') IS NOT NULL
	DROP PROC PrcFlushBpmData
GO
CREATE PROCEDURE PrcFlushBpmData
(
	@Action VARCHAR(10),
	@LeadFk	BIGINT	= NULL,
	@FlowFk	BIGINT	= NULL,
	@VerFk	BIGINT	= NULL
)
AS
BEGIN
	DECLARE @BvmFk TABLE(BvmFk BIGINT)
	
	INSERT INTO @BvmFk
	SELECT	BvmPk
	FROM	BpmVersions
	WHERE	BvmBpmFk = ISNULL(@FlowFk,BvmBpmFk) AND BvmPk = ISNULL(@VerFk,BvmPk)
	
	IF @Action IN('DEL_DATA','DEL_HIS','DEL_FLOW')
		BEGIN
			DELETE FROM BpmExecStatus 
			WHERE EXISTS(SELECT 'X' FROM @BvmFk WHERE BvmFk = BesBvmFk)
			AND BesKeyFk = ISNULL(@LeadFk,BesKeyFk)
			
			DELETE FROM BpmNextOpUsr WHERE EXISTS(SELECT 'X' FROM @BvmFk WHERE BvmFk = BnoBvmFk)
			AND BnoDataPk = ISNULL(@LeadFk,BnoDataPk)
			
			DELETE FROM BpmExec WHERE EXISTS(SELECT 'X' FROM @BvmFk WHERE BvmFk = BexBvmFk)
			AND BexKeyFk = ISNULL(@LeadFk,BexKeyFk)
		END
	
	IF @Action IN ('DEL_DATA','DEL_FLOW','Q')
		BEGIN
			SELECT QrhPk 'QrhFk', QrdPk 'QrdFk' INTO #QryDtls
			FROM QryHdr 
			JOIN QryDtls ON QrdQrhFk = QrhPk
			WHERE EXISTS(SELECT 'X' FROM @BvmFk WHERE BvmFk = QrhBvmFk)
			AND QrhKeyFk = ISNULL(@LeadFk,QrhKeyFk)
			
			DELETE FROM QryIn WHERE EXISTS(SELECT 'X' FROM #QryDtls WHERE QrIQrdFk = QrdFk)
			DELETE FROM QryOut WHERE EXISTS(SELECT 'X' FROM #QryDtls WHERE QrOQrdFk = QrdFk)
			DELETE FROM QryDtls WHERE EXISTS(SELECT 'X' FROM #QryDtls WHERE QrdPk = QrdFk)
			DELETE FROM QryHdr WHERE EXISTS(SELECT 'X' FROM #QryDtls WHERE QrhPk = QrhFk)
						
			DROP TABLE #QryDtls
		END
		
	IF @Action = 'DEL_FLOW'
		BEGIN
			DELETE T FROM ShflPgRightsDtls T
			JOIN BpmUiDefn ON PgrdPk = BudPk AND EXISTS
			(SELECT 'X' FROM BpmFlow WHERE EXISTS(SELECT 'X' FROM @BvmFk WHERE BvmFk = BfwBvmFk) AND BfwPk = BudBfwFk)
			
			DELETE FROM BpmUiDefn WHERE EXISTS
			(SELECT 'X' FROM BpmFlow WHERE EXISTS(SELECT 'X' FROM @BvmFk WHERE BvmFk = BfwBvmFk) AND BfwPk = BudBfwFk)
			
			DELETE FROM BpmObjInout WHERE EXISTS(SELECT 'X' FROM @BvmFk WHERE BvmFk = BioBvmFk)
			
			DELETE FROM BpmFlow WHERE EXISTS(SELECT 'X' FROM @BvmFk WHERE BvmFk = BfwBvmFk)
			
			DELETE FROM BpmVersions
			WHERE	EXISTS(SELECT 'X' FROM @BvmFk WHERE BvmPk = BvmFk)
			
			DELETE FROM BpmMas
			WHERE	BpmPk = ISNULL(@FlowFk,0)
		END

END
