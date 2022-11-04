IF EXISTS(SELECT NULL FROM sysobjects WHERE name='PrcGetLeadHis' AND [type]='P')
	DROP PROC PrcGetLeadHis
GO
CREATE PROCEDURE PrcGetLeadHis
(
	@LeadPk BIGINT		 =	NULL,
	@VerFk	BIGINT		 =	NULL,
	@BpmFks	VARCHAR(100) =	NULL,
	@Action	VARCHAR(15)	 =	NULL
)
AS
BEGIN
	SET NOCOUNT ON 
	
	CREATE TABLE #HisDtls
	(
		ScreenName VARCHAR(100), InScrNm VARCHAR(100), OutScrnNm VARCHAR(100), SeqFk BIGINT, 
		BfwFk BIGINT, InFk BIGINT, OutFk BIGINT, HisPk BIGINT,SanFk BIGINT, RndNo INT,CrDt DATETIME, LdFk BIGINT
	)
	CREATE TABLE #StsInfo 
	(
		PgCd VARCHAR(50),PgNm VARCHAR(100),UsrNm VARCHAR(100),Dt VARCHAR(50), Tim VARCHAR(50), HisPk INT, 
		LdFk BIGINT, TreeId VARCHAR(MAX), RNo INT, ExecDt DATETIME
	)
	DECLARE @MinFk BIGINT, @MaxFk BIGINT, @QryString VARCHAR(MAX), @QryCols VARCHAR(MAX), @QryAlias VARCHAR(MAX)
	
	IF @Action IN ('TAT','TATEXPORT')
		CREATE TABLE #AllScrnDtls
		(
			BtbFk BIGINT, BioBvmFk BIGINT, BioId VARCHAR(50), BioPk BIGINT, BioOutBfwFk BIGINT, 
			DestTyp VARCHAR(100), BudPk BIGINT, BudDesignData VARCHAR(MAX), BudURL VARCHAR(MAX),
			BudDesignTyp TINYINT, BudBfwFk BIGINT, PgNm VARCHAR(100), BudDecIsAuto TINYINT,
			BudDecExp VARCHAR(100), BudScript VARCHAR(100), BudCd VARCHAR(5),BudIsRtnNeed BIGINT,  BioinBfwFk BIGINT,
			TreeId VARCHAR(MAX)
		)
		
	IF ISNULL(@BpmFks,'') != ''
		BEGIN
			SELECT @VerFk = BvmPk FROM dbo.split(@BpmFks,'~','T')
			JOIN BpmVersions(NOLOCK) ON BvmBpmFk =  items  AND BvmDelid = 0
			AND EXISTS(SELECT 'X' FROM BpmExec(NOLOCK) WHERE BexKeyFk = ISNULL(@LeadPk,BexKeyFk) AND BexBvmFk = BvmPk AND BexDelid = 0)
		END
	
	
	INSERT	INTO #HisDtls(ScreenName,InScrNm,OutScrnNm,SeqFk,BfwFk,InFk,OutFk,HisPk,SanFk,RndNo,CrDt,LdFk)
	SELECT	BfwLabel 'ScreenName', dbo.gefgGetDesc(BioInBfwFk,3) 'InScrNm', dbo.gefgGetDesc(BioOutBfwFk,3) 'OutScrnNm', 
			BexBioFk 'SeqFk', BioBfwFk 'BfwFk', BioInBfwFk 'InFk', BioOutBfwFk 'OutFk', BexPk 'HisPk',ISNULL(BexDpdFk,0) 'SanFk',
			ISNULL(BexRoundNo,1) 'RndNo',BexCreatedDt 'CrDt', BexKeyFk
	FROM	BpmExec(NOLOCK) 
	JOIN	BpmObjInout (NOLOCK) ON BioBvmFk = @VerFk AND BioPk = BexBioFk AND BioDelid = 0
	JOIN	BpmFlow(NOLOCK)ON BioBvmFk = @VerFk AND BfwPk = BioBfwFk AND BfwDelid = 0
	WHERE	BexKeyFk = ISNULL(@LeadPk,BexKeyFk) AND BexBvmFk = @VerFk  AND BexDelid = 0
		
	IF @Action IN ('TAT','TATEXPORT')
		BEGIN
			INSERT INTO #AllScrnDtls
			SELECT	BioBtbFk 'BtbFk', BioBvmFk 'BioBvmFk', BioId 'BioId',BioPk 'BioPk',
					BioOutBfwFk 'BioOutBfwFk', dbo.gefgGetProcType(BioOutBfwFk) 'DestTyp',
					BudPk 'BudPk', BudDesignData 'BudDesignData',BudURL 'BudURL', BudDesignTyp 'BudDesignTyp', 
					BudBfwFk 'BudBfwFk', dbo.gefggetDesc(BudPk,2) 'PgNm' ,
					ISNULL(BudDecIsAuto,0) 'BudDecIsAuto', ISNULL(BudDecExp,'') 'BudDecExp',
					ISNULL(BudScript,'') 'BudScript',BudCd 'BudCd',BudIsRtnNeed 'BudIsRtnNeed', BioinBfwFk 'BioinBfwFk',
					ISNULL(BioTreeId,'') 'TreeId'
			FROM	BpmObjInOut(NOLOCK) 
			JOIN	BpmUIDefn(NOLOCK) ON BudBfwFk = BioBfwFk AND BudDelId = 0
			WHERE	BioBvmFk = @VerFk AND BioDelid = 0
			
			IF @Action IN ('TAT')
				SELECT		LdFk FROM #HisDtls GROUP BY LdFk

			SELECT @MinFk = MIN(LdFk) , @MaxFk = MAX(LdFk) FROM #HisDtls

			WHILE @MinFk <= @MaxFk
				BEGIN
					INSERT INTO #StsInfo
					SELECT		ISNULL(PgCd,BudCd) 'PgCd',ISNULL(Page,PgNm) 'PgNm',ISNULL(dbo.gefggetDesc(UsrFk,1), '') 'UsrNm',
								ISNULL(CONVERT(VARCHAR(20), CrDt, 106),'') 'Dt',
								ISNULL(CONVERT(VARCHAR(15),CAST(CrDt AS TIME),100),'') 'Tim' , 
								ISNULL(Flg,0) 'HisPk', @MinFk 'LdFk', TreeId 'TreeId', 
								ROW_NUMBER() OVER (PARTITION BY TreeId ORDER BY CrDt,TreeId), CrDt
					FROM		#AllScrnDtls
					LEFT JOIN	
					(
						SELECT		ISNULL(BudCd,'') 'PgCd',dbo.gefggetDesc(BudPk,2) 'Page', ISNULL(BesUsrFk,0) 'UsrFk', 
									ISNULL(BesCreatedDt, CrDt) 'CrDt', 
									HisPk, BudPk 'PagePk' ,CASE ISNULL(BesPk,0) WHEN 0 THEN 1 ELSE 2 END 'Flg',
									LdFk 'LdFk'
						FROM		#HisDtls
						JOIN		BpmUIDefn(NOLOCK) ON BudBfwFk = BfwFk AND BudDelId = 0
						LEFT JOIN	BpmExecStatus(NOLOCK) ON BesBexFk = HisPk AND BesDelid = 0
						WHERE		LdFk = @MinFk
					)A ON BudPk = PagePk 
					WHERE		BudDesignTyp = 1
					
					SELECT @MinFk = MIN(LdFk) FROM #HisDtls WHERE LdFk > @MinFk
				END
			
			IF @Action IN ('TAT')
				SELECT PgCd,UsrNm,Dt,Tim,HisPk,LdFk,TreeId FROM #StsInfo ORDER BY LdFk,TreeId
			ELSE
				BEGIN
					
					IF EXISTS(SELECT 'X' FROM #StsInfo)
						BEGIN
							SELECT @QryCols = STUFF(
							(
								SELECT N',' + QUOTENAME(PgCd)
								FROM (
										SELECT DISTINCT PgCd, TreeId FROM #StsInfo
									 ) AS Dtls
								ORDER BY TreeId
								FOR XML PATH('')
							),1, 1, N''),
							@QryAlias = STUFF(
							(
								SELECT ',ISNULL(' + QUOTENAME(PgCd) + ','''') ''' + PgNm + ''''
								FROM (
										SELECT DISTINCT PgCd,PgNm,TreeId FROM #StsInfo
									 ) AS Dtls
								ORDER BY TreeId
								FOR XML PATH('')
							),1, 1, N'');

							SELECT @QryString = 'SELECT LeadPk, ' + @QryAlias + ' FROM 
												(
												  SELECT LdFk LeadPk,PgCd,CONVERT(VARCHAR,ExecDt,105) + '' '' + Tim DtTim
												  FROM #StsInfo WHERE RNo = 1
												) SRC
												PIVOT
												(
												  MAX(DtTim)
												  FOR PgCd IN ('+ @QryCols +')
												) PIV;'
							EXEC (@QryString)
						END
				END
		END
	ELSE
		BEGIN
			SELECT	'Flow - ' + BpmNm + ' Version - '+ CAST(BvmVerNo AS VARCHAR) 'Flow'
			FROM	BpmMas(NOLOCK)
			JOIN	BpmVersions(NOLOCK) ON BvmBpmFk = BpmPk AND BvmPk = @VerFk
		 
			SELECT		'History Details of Lead'
			SELECT		ISNULL(ScreenName,'') 'Screen Name',ISNULL(InScrNm,'') 'Source Screen',ISNULL(OutScrnNm,'') 'Target Screen',
						SeqFk,BfwFk,InFk,OutFk,SanFk,RndNo,HisPk,CrDt
			FROM		#HisDtls
			ORDER BY	HisPk DESC

			SELECT		'Completed Screen Details of Lead'
			SELECT		ISNULL(BfwLabel,'') 'Screen Name', ISNULL(dbo.gefgGetDesc(BioInBfwFk,3),'') 'Source Screen', 
						ISNULL(dbo.gefgGetDesc(BioOutBfwFk,3),'') 'Target Screen',
						BesBioFk 'SeqFk', BioBfwFk 'BfwFk', BioInBfwFk 'InFk', BioOutBfwFk 'OutFk', BesPk 'FinishedPk',
						BesBexFk 'HisPk', ISNULL(BesDpdFk,0) 'SanFk',ISNULL(BesRoundNo,1) 'RndNo',BesCreatedDt 'CrDt'
			FROM		BpmExecStatus(NOLOCK) 
			JOIN		GenUsrMas (NOLOCK) ON UsrPk = BesUsrFk 
			JOIN		GenGeoMas (NOLOCK) ON GeoPk = BesBrnchFk
			JOIN		BpmObjInout (NOLOCK) ON BioBvmFk = @VerFk AND BioPk = BesBioFk AND BioDelid = 0
			JOIN		BpmFlow(NOLOCK)ON BioBvmFk = @VerFk AND BfwPk = BioBfwFk AND BfwDelid = 0
			WHERE		BesKeyFk = ISNULL(@LeadPk,BesKeyFk) AND BesBvmFk = @VerFk  AND BesDelid = 0
			ORDER BY	BesPk DESC
			
			SELECT	'Pending Screen Details of Lead with User Ref'

			SELECT	 ISNULL(ScreenName,'') 'ScreenName',ISNULL(InScrNm,'') 'Source Screen',ISNULL(OutScrnNm,'') 'Target Screen',
					 dbo.gefgGetDecPass(UsrPwd) 'Password', BnoPk,SeqFk,BfwFk,InFk,OutFk,HisPk,SanFk,RndNo,CrDt, UsrNm, UsrDispNm
			FROM	 #HisDtls
			JOIN	 BpmNextOpUsr (NOLOCK) ON BnoBexFk =  HisPk AND BnoBfwFk = BfwFk AND BnoDataPk = ISNULL(@LeadPk,BnoDataPk)
			JOIN	 GenUsrMas (NOLOCK) ON UsrPk = BnoUsrFk
			WHERE	 NOT EXISTS(SELECT 'X' FROM BpmExecStatus(NOLOCK) WHERE BesBexFk = HisPk AND BesDelid = 0)
			ORDER BY HisPk DESC
			
			SELECT 'User Rights for the Screen'
			SELECT  ISNULL(ScreenName,'') 'Screen Name',ISNULL(InScrNm,'') 'Source Screen',ISNULL(OutScrnNm,'') 'Target Screen',
					UsrNm 'UsrNm', BnoBudFk 'PagePk', BudDesignData 'BuildData', BudURL 'URL', SeqFk,BfwFk,InFk,OutFk,HisPk,BnoPk,SanFk,RndNo,CrDt
			FROM	BpmNextOpUsr(NOLOCK)
			JOIN	#HisDtls ON HisPk = BnoBexFk 
			JOIN	GenUsrMas(NOLOCK) ON UsrPk = BnoUsrFk
			JOIN	BpmUiDefn(NOLOCK) ON BudPk = BnoBudFk
			WHERE	BnoDataPk = ISNULL(@LeadPk,BnoDataPk) AND BnoBvmFk = @VerFk
			AND		EXISTS(SELECT 'X' FROM BpmExecStatus(NOLOCK) WHERE BesBexFk = HisPk AND BesDelid = 0)
		END			
END