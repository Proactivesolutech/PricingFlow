BEGIN TRAN
	
	CREATE TABLE #OldBpm(Pk BIGINT, VerPk BIGINT, FlowFk BIGINT)
	CREATE TABLE #DelVersions(VerFk BIGINT)
	DECLARE @QryString VARCHAR(MAX)
	
	INSERT INTO #OldBpm
	SELECT	BpmPk 'Pk', BvmPk 'VerPk', BfwPk 'FlowFk'
	FROM	BpmMas(NOLOCK), BpmVersions(NOLOCK), BpmFlow(NOLOCK) WHERE BpmPk NOT IN (93,100,68) AND BvmBpmFk = BpmPk AND BfwBvmFk = BvmPk
	
	INSERT INTO #DelVersions
	SELECT	DISTINCT BvmPk 'VerPk'
	FROM	BpmMas(NOLOCK), BpmVersions(NOLOCK) WHERE BpmPk IN (68) 
	AND		BvmBpmFk = BpmPk AND BvmVerNo < 14
		UNION ALL
	SELECT	DISTINCT BvmPk 'VerPk'
	FROM	BpmMas(NOLOCK), BpmVersions(NOLOCK) WHERE BpmPk IN (93) 
	AND		BvmBpmFk = BpmPk AND BvmVerNo < 3
		UNION ALL
	SELECT	DISTINCT BvmPk 'VerPk'
	FROM	BpmMas(NOLOCK), BpmVersions(NOLOCK) WHERE BpmPk IN (100) 
	AND		BvmBpmFk = BpmPk AND BvmVerNo < 5
	
	INSERT INTO #OldBpm
	SELECT	BpmPk 'Pk', BvmPk 'VerPk', BfwPk 'FlowFk'
	FROM	BpmMas(NOLOCK), BpmVersions(NOLOCK), BpmFlow(NOLOCK) WHERE EXISTS(SELECT 'X' FROM #DelVersions WHERE VerFk = BvmPk)
	AND		BfwBvmFk = BvmPk AND BvmBpmFk = BpmPk
	

	DELETE	FROM ShflPgRightsDtls WHERE 
	EXISTS	(SELECT 'X' FROM BpmUiDefn(NOLOCK) WHERE EXISTS(SELECT 'X' FROM #OldBpm WHERE BudBfwFk = FlowFk) AND BudPk = PgrdPgFk)
	
	DELETE	FROM BpmUiDefn WHERE EXISTS(SELECT 'X' FROM #OldBpm WHERE BudBfwFk = FlowFk)
	
	DELETE FROM BpmObjInOut WHERE EXISTS(SELECT 'X' FROM #OldBpm WHERE BioBvmFk = VerPk)
	
	DELETE FROM BpmFlow WHERE EXISTS(SELECT 'X' FROM #OldBpm WHERE BfwBvmFk = VerPk)
	
	DELETE FROM BpmVersions WHERE EXISTS(SELECT 'X' FROM #OldBpm WHERE BvmPk = VerPk)
	
	DELETE FROM BpmMas WHERE EXISTS(SELECT 'X' FROM #OldBpm WHERE BpmPk = Pk AND BpmPk NOT IN (93,100,68))
	
	UPDATE BpmMas SET BpmNm = 'Lead to Disbursement' WHERE BpmPk = 93
	UPDATE BpmMas SET BpmNm = 'Lead to Disbursement(PNI)' WHERE BpmPk = 100
	
	SELECT * FROM BpmMas
	SELECT DISTINCT BvmBpmFk FROM BpmVersions
	SELECT DISTINCT BfwBvmFk FROM BpmFlow
	SELECT DISTINCT BioBvmFk FROM BpmObjInOut
	SELECT DISTINCT BfwBvmFk FROM BpmUiDefn, BpmFlow WHERE BudBfwFk = BfwPk
	SELECT DISTINCT BfwBvmFk FROM ShflPgRightsDtls,BpmUiDefn, BpmFlow WHERE BudBfwFk = BfwPk AND BudPk = PgrdPgFk
	
	SELECT	ROW_NUMBER() OVER(PARTITION BY BvmBpmFk ORDER BY BvmVerNo) 'NewVerNo', BvmPk 'Pk' INTO #NewVer
	FROM	BpmVersions(NOLOCK) ORDER BY BvmBpmFk, BvmVerNo
	
	UPDATE BpmVersions SET BvmVerNo = NewVerNo FROM #NewVer WHERE Pk = BvmPk
	
	DECLARE @QryString VARCHAR(MAX)
	
	SELECT	@QryString = ISNULL(@QryString,'') + CHAR(10) + 'EXEC PrcArriveSeqTreeId ' + CAST(Pk AS VARCHAR) + ',1' + CHAR(10)
	FROM	#NewVer
	
	EXEC(@QryString)
	
COMMIT TRAN