USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[PrcShflBpm_Proj]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PrcShflBpm_Proj]
(
	@Action			VARCHAR(100)		=	NULL,
	@ProcessJSON	VARCHAR(MAX)		=	NULL,
	@ValData		VARCHAR(MAX)		=	NULL,
	@RtnOption		INT					=	0,
	@Branch			VARCHAR(100)		=	NULL,
	@DataFk			BIGINT				=	NULL
)
AS
BEGIN

	SET NOCOUNT ON
	SET ANSI_WARNINGS ON
	
	DECLARE @UsrNm VARCHAR(200),@UsrPwd VARCHAR(200),@UsrPk BIGINT;
	DECLARE @CurDt DATETIME, @TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT
	
	DECLARE @HisDtls TABLE(BexFk BIGINT, BioOutId VARCHAR(100))
	DECLARE @AprLvl TABLE(AprTyp CHAR(1), AprLvl TINYINT)
	DECLARE	@CLvlNo TINYINT, @DLvlNo TINYINT;
	DECLARE @FlowFk BIGINT,@ElemPk VARCHAR(200),@CurPage BIGINT,@TgtPage BIGINT, @NoOfMsg BIGINT, @SbcFk BIGINT, @SPDpdFk BIGINT,
			@DblEntry INT, @CurBfwFk BIGINT, @BrnchFk BIGINT, @SanFk VARCHAR(100)
	DECLARE @TgtPages TABLE(RowNo INT IDENTITY(1,1),TgtPageID VARCHAR(100))
	DECLARE @ElemType VARCHAR(100), @ElemFk BIGINT , @NxtPageElem BIGINT,@DataKey VARCHAR(200) , @DataMasPk BIGINT;
	
	DECLARE @PkVal BIGINT, @CurSeqFk BIGINT,@PrevSeqFk BIGINT, @IsAuto INT, @QryBuilder VARCHAR(MAX),
			@DfltTbl VARCHAR(20) , @Val VARCHAR(MAX),@ColNm VARCHAR(MAX);

	DECLARE @Count INT,@TempCurSbsdFk BIGINT,@TempNxtSbsdFk BIGINT , @CreatePageType TINYINT, @TgtPageID VARCHAR(200),
			@TempSbfdFk BIGINT, @VerFlowPk BIGINT,@CurVerFlowPk BIGINT , @HisPk BIGINT , @IsManCal INT --, @ProcFlg INT
	DECLARE @CrntHis TABLE(PcFk BIGINT, FdUsrFk BIGINT)
	DECLARE @IsSubPc INT, @BranchFk BIGINT;
	DECLARE @UsrMsgs TABLE(Fk BIGINT)
	DECLARE @DataField VARCHAR(MAX), @DataLabel VARCHAR(MAX), @ColTbl VARCHAR(MAX), @TblNm VARCHAR(100),
			@ElmFk BIGINT, @ColType VARCHAR(MAX), @MinFk BIGINT, @MaxFk BIGINT

	CREATE TABLE #FlowPKS (FlowPk BIGINT)
	CREATE TABLE #StrtTblDtls(TblNm VARCHAR(100), DataFld VARCHAR(MAX), DataLbl VARCHAR(MAX), SbfdFk BIGINT)
	CREATE TABLE #DataDtls(PcPk BIGINT, FlowPk BIGINT, SbsdFk BIGINT, PagePk BIGINT, Pg_status VARCHAR(100),IsRightFlg INT,DataPk BIGINT, BranchFk BIGINT, BfwFk BIGINT)
	CREATE TABLE #TempRights_RolePages(SbfdFk BIGINT,SbsdPk BIGINT, PagePk BIGINT, RightsFlg INT)
	CREATE TABLE #TempRights_Geo(GeoFk BIGINT,LvlNo INT)
	CREATE TABLE #TempData (TempKeyId VARCHAR(200));	
	CREATE TABLE #ChatHdrData(CrUsrFk BIGINT, CrPgFk BIGINT,SbcPk BIGINT)
	CREATE TABLE #SanctionData(DpdFk BIGINT,DataPk BIGINT, HisPk BIGINT, SvCd VARCHAR(50))
	CREATE TABLE #HisDtls
	(
		CrUsrFk BIGINT, ToUsrFk BIGINT, CrPgFk BIGINT, IsRead BIT, DtlPk BIGINT,HdrPk BIGINT, ChatMsg VARCHAR(MAX), 
		DtTime VARCHAR(50), Grp_No BIGINT, DpdFk BIGINT, SentNm VARCHAR(500),  ActDt DATETIME, Flg INT 
	)
	CREATE TABLE #PendingProcess
	(
		DataPk BIGINT,UsrFk BIGINT,PcPk BIGINT,Flownm VARCHAR(100),FlowPk BIGINT, SbsdFk BIGINT,PagePk BIGINT,Pg_status VARCHAR(100),
		BfwFk BIGINT, BpmBranchFk BIGINT, Roles VARCHAR(100), ExecDt VARCHAR(20),
		DTime VARCHAR(20), Cd VARCHAR(50), KeyDpdFk BIGINT
	)
	CREATE TABLE #ValData(xx_id BIGINT,id VARCHAR(MAX), idval VARCHAR(MAX))
	Create Table #LeadDet(SNo BIGINT, LeadPk Int, LeadID Varchar(50),LedNm Varchar(100), PrdNm Varchar(100), Branch VARCHAR(100), PrdIcon VARCHAR(50))
	
	SET @CurDt = GETDATE()
	
	CREATE TABLE #GlobalDetails
	(
		xx_id BIGINT, TempFlowFk BIGINT, TempFlowXml VARCHAR(MAX),TempElemId VARCHAR(200),CurPage BIGINT,FwdDataPk BIGINT,
		CreatePageType TINYINT,TgtPageID VARCHAR(200),UsrNm VARCHAR(200),UsrPwd VARCHAR(200),UsrPk BIGINT,VerFlowPk BIGINT,CurVerFlowPk BIGINT,
		HisPK BIGINT, DblEntry INT, CurBfwFk  BIGINT,UsrCd VARCHAR(50), BrnchFk BIGINT, SanFk VARCHAR(100)
	)

	IF @ProcessJSON !='[]' AND @ProcessJSON != ''
	BEGIN
		INSERT INTO #GlobalDetails
		EXEC PrcParseJSON @ProcessJSON,'FlowFk,FlowXml,ElemId,CurPage,FwdDataPk,CreatePageType,TgtPageID,UsrNm,UsrPwd,UsrPk,VerFlowPk,CurVerFlowPk,HisPK,DblEntry,CurProcFk,UsrCd,BrnchFk,SanFk'
	END

	IF @ValData !='[]' AND @ValData != ''
	BEGIN
		IF @Action = 'LEADHIS'
			BEGIN
				INSERT INTO #LeadDet
				EXEC PrcParseJSON @ValData,'LedPk,LedId,LedNm,PrdNm,Branch,PrdIcon'
			END
		ELSE
			BEGIN
				INSERT INTO #ValData
				EXEC PrcParseJSON @ValData,'id,idval'
			END
	END
	
	BEGIN TRY
	 
	IF @@TRANCOUNT = 0
		SET @TranCount = 1
	
	IF @TranCount = 1
		BEGIN TRAN		

			IF @Action = 'USR_LOGIN'
				BEGIN
					SELECT @UsrNm = UsrNm FROM #GlobalDetails
					SELECT @UsrPwd = UsrPwd FROM #GlobalDetails
					
					SELECT	@UsrPk =  UsrPk 
					FROM	GenUsrMas(NOLOCK) 
					WHERE	UsrNm = @UsrNm AND dbo.gefgGetDecPass(UsrPwd) = @UsrPwd AND UsrDelid = 0
					
					IF ISNULL(@UsrPk,0) > 0
						BEGIN
							DECLARE @BpmPk BIGINT
							SELECT @BpmPk = MAX(BpmPk) FROM BpmMas(NOLOCK) --WHERE BpmPk = 2137

							SELECT	UsrDispNm, UsrPk ,@BpmPk 'BpmPk'  FROM GenUsrMas(NOLOCK) 
							WHERE	UsrPk = @UsrPk AND UsrDelId = 0

							SELECT		RolLvlNo 'Role', RolSubLvlNo 'SubRole',RolIsAdmin 'IsAdmin'
							FROM		GenUsrRoleDtls (NOLOCK) 
							JOIN		GenRole(NOLOCK) ON RolPk = UrdRolFk AND RolDelid = 0
							WHERE		UrdUsrFk = @UsrPk AND UrdDelid = 0
							
							SELECT	DISTINCT GemGeoBFk 'BrnchFk'
							FROM	GenUsrBrnDtls(NOLOCK)
							JOIN	GenGeoMas(NOLOCK) ON GeoPk = UbdGeoFk AND GeoDelid = 0
							JOIN	GenGeoMap(NOLOCK) ON GeoPk = CASE ISNULL(GeoLvlNo,0) 
																WHEN 1 THEN GemGeoBFk WHEN 2 THEN GemGeoZFk
																WHEN 3 THEN GemGeoSFk WHEN 4 THEN GemGeoCFk END
														AND GemDelid = 0
							WHERE	UbdUsrFk = @UsrPk AND UbdDelid = 0
						END
				END
			
			IF @Action = 'LEADHIS'
				BEGIN

					;With Ct21
					As
					(
						Select A.LeadPk, A.LeadID, A.LedNm, A.PrdNm, A.Branch, A.PrdIcon, Max(B.BnoPk) BnoPk, B.BnoBvmFk 
						From #LeadDet A
						Join BpmNextOpUsr B On A.LeadPk = B.BnoDataPk --AND B.BnoBvmFk = 90
						Group BY A.LeadPk, A.LeadID, A.LedNm,A.PrdNm,A.Branch,A.PrdIcon,B.BnoBvmFk 
					),
					Cte2
					As
					(
						Select A.LeadPk, A.LeadID, A.LedNm,A.PrdNm, A.Branch, A.PrdIcon, A.BnoPk, B.BnoBexFk, B.BnoBioFk, A.BnoBvmFk 
						From Ct21 A
						Join BpmNextOpUsr B On A.BnoPk = B.BnoPk 
					)


					Select A.LeadPk, A.LeadID, A.LedNm,A.PrdNm, A.Branch, A.PrdIcon, A.BnoPk, B.BnoBexFk, B.BnoBioFk, C.UsrDispNm, D.BudURL, D.BudCd,
						   dbo.gefggetdesc(D.BudBfwFk,3) 'PageNm', A.BnoBvmFk 
					Into #FlowDet
					From Cte2 A
					Join BpmNextOpUsr B On A.BnoBexFk = B.BnoBexFk And A.BnoBioFk = B.BnoBioFk
					Join GenUsrMas C On B.BnoUsrFk = C.UsrPk 
					Join BpmUIDefn D On B.BnoBudFk = D.BudPk

					;With Tbl_ScrnHis
					As
					(
						select		A.LeadPk,dbo.gefggetdesc(D.BudBfwFk,3) 'Page', D.BudURL 'Url',D.BudCd 'Cd',
									ROW_NUMBER() OVER(PARTITION BY A.LeadPk,D.BudBfwFk ORDER BY  A.LeadPk,D.BudBfwFk) 'RowNo',
									BesPk 'BesPk', BesBexFk 'BexFk'
						from		#LeadDet A
						join		BpmExecStatus B(NOLOCK) ON A.LeadPk = B.BesKeyFk  AND B.BesDelid = 0--AND B.BesBvmFk = 90
						join		BpmObjInout C (NOLOCK) ON B.BesBioFk = C.BioPk AND C.BioDelid = 0
						join		BpmUiDefn D (NOLOCK) ON C.BioBfwFk = D.BudBfwFk AND ISNULL(D.BudURL,'') <> '' AND D.BudDelid = 0
					)
					SELECT		LeadPk 'DataPk',Page,Cd,Url,BesPk,BexFk INTO #ScrnDatas
					FROM		Tbl_ScrnHis 
					WHERE		RowNo = 1
					
					INSERT INTO #SanctionData
					SELECT		MAX(BexDpdFk) 'DpdFk', DataPk 'DataPk', 0 'HisPk', ''
					FROM		#ScrnDatas S1
					JOIN		BpmExec Sts(NOLOCK) ON S1.BexFk = Sts.BexPk AND ISNULL(Sts.BexDpdFk,0) > 0
					AND			NOT EXISTS(SELECT 'X' FROM BpmVersions (NOLOCK) WHERE BvmBpmFk = 68 AND BvmPk = BexBvmFk AND BvmDelid = 0)
					GROUP BY	DataPk
						UNION ALL
					SELECT		BexDpdFk 'DpdFk', DataPk 'DataPk', BexPk 'HisPk', ''
					FROM		#ScrnDatas S1
					JOIN		BpmExec Sts(NOLOCK) ON S1.BexFk = Sts.BexPk AND ISNULL(Sts.BexDpdFk,0) > 0
					AND			EXISTS(SELECT 'X' FROM BpmVersions (NOLOCK) WHERE BvmBpmFk = 68 AND BvmPk = BexBvmFk AND BvmDelid = 0)
					
					UPDATE		#SanctionData SET SvCd = BudCd
					FROM		BpmNextopUsr(NOLOCK) , BpmUiDefn(NOLOCK), #ScrnDatas WHERE BudPk = BnoBudFk AND BudDelid = 0 AND HisPk = BnoBexFk
					
					select A.LeadPk, A.LeadID, A.LedNm,A.PrdNm, A.Branch, A.BudURL, A.BudCd, A.PageNm,A.PrdIcon 
						,STUFF((
							select ',' + [UsrDispNm]
							from #FlowDet t1
							where t1.LeadPk = A.LeadPk
							for xml path(''), type
						).value('.', 'varchar(max)'), 1, 1, '') [Users],A.BnoBvmFk
					from #FlowDet A
					join #ScrnDatas B ON A.LeadPk = B.DataPk
					group by A.LeadPk, A.LeadID, A.LedNm,A.PrdNm,A.Branch,A.BudURL, A.BudCd, A.PageNm,A.PrdIcon ,A.BnoBvmFk
					order by A.LedNm
					
					SELECT		B.DataPk,Page,Cd,Url,ISNULL(C.DpdFk,0) 'DpdFk' FROM #ScrnDatas B
					LEFT JOIN	#SanctionData C ON B.DataPk = C.DataPk AND Cd = CASE C.HisPk WHEN 0 THEN Cd ELSE C.SvCd END
					ORDER BY	B.DataPk,BesPk DESC
				END
				
			IF @Action = 'GET_ENTRY_DATA'
			BEGIN

				SELECT  @UsrPk = UsrPk,@UsrNm = UsrCd FROM #GlobalDetails
				
				SELECT	@UsrPk = UsrPk FROM GenUsrMas (NOLOCK) WHERE UsrNm = @UsrNm AND UsrDelId = 0 

				INSERT INTO @AprLvl
				SELECT  AprTyp,AprLvl
				FROM	GenUsrRoleDtls(NOLOCK) 
				JOIN	LosApprover(NOLOCK) ON AprRolFk = UrdRolFk
				WHERE   UrdUsrFk = @UsrPk AND UrdDelid = 0
				
				SELECT  @CLvlNo = MAX(AprLvl) FROM @AprLvl WHERE AprTyp = 'C'
				SELECT  @DLvlNo = MAX(AprLvl) FROM @AprLvl WHERE AprTyp = 'D'
				
				SELECT	@UsrPk 'UsrFk'
				
				INSERT INTO #PendingProcess
				SELECT		 BnoDataPk 'DataPk',BnoUsrFk 'UsrFk', BnoBexFk 'PcPk', dbo.getFlowNm(BnoBvmFk) 'FlowNm',
							 BnoBvmFk 'FlowPk', BnoBioFk 'SbsdFk',BnoBudFk 'PagePk',ISNULL(BnoStatus,'') 'Pg_status',
							 BnoBfwFk 'BfwFk' , BexBrnchFk 'BpmBranchFk',
							 UsrDispNm 'Roles', dbo.gefgDMY(BexCreatedDt) 'ExecDt',
							 CASE	WHEN DATEDIFF(YEAR, CONVERT(DATETIME,BexCreatedDt,103), @CurDt)  > 0 
									THEN CAST(DATEDIFF(YEAR, CONVERT(DATETIME,BexCreatedDt,103), @CurDt) AS VARCHAR)+ ' year(s) ago'
									WHEN DATEDIFF(DAY, CONVERT(DATETIME,BexCreatedDt,103), @CurDt)  > 0 
									THEN CAST(DATEDIFF(DAY, CONVERT(DATETIME,BexCreatedDt,103), @CurDt) AS VARCHAR)+ ' day(s) ago'
									WHEN DATEDIFF(HOUR, CONVERT(DATETIME,BexCreatedDt,103), @CurDt) > 0
									THEN CAST(DATEDIFF(HOUR, CONVERT(DATETIME,BexCreatedDt,103), @CurDt) AS VARCHAR) + ' hour(s) ago' 
									ELSE CAST(DATEDIFF(MINUTE, CONVERT(DATETIME,BexCreatedDt,103), @CurDt) AS VARCHAR) + ' minute(s) ago'  END 'Time',
							ISNULL(BudCd,'') 'Cd', ISNULL(BexDpdFk,0) 'KeyDpdFk'
				FROM		BpmNextOpUsr(NOLOCK)
				JOIN		BpmExec (NOLOCK) ON BnoBexFk = BexPk AND BexDelid = 0	
				JOIN		GenUsrMas(NOLOCK) ON UsrPk = BexUsrFk AND UsrDelId = 0	
				JOIN		BpmUiDefn(NOLOCK) ON BudPk = BnoBudFk AND BudDelid = 0
				WHERE		NOT EXISTS (SELECT NULL FROM BpmExecStatus(NOLOCK) WHERE BesBexFk = BnoBexFk AND BesDelId = 0)
				AND			BnoUsrFk = @UsrPk ORDER BY PcPk DESC

				SELECT		 DataPk,UsrFk, PcPk, FlowNm, FlowPk, SbsdFk, PagePk, Pg_status,BfwFk,BpmBranchFk,Roles,
							 DTime'Time', Cd, KeyDpdFk , ISNULL(@CLvlNo,0) 'CLvlNo', ISNULL(@DLvlNo,0) 'DLvlNo',
							 KeyNm 'LeadNm','' 'PCd' , '' 'LeadID' , KeyPk 'Pk'
				FROM		 #PendingProcess
				LEFT OUTER JOIN BpmFlowKeyTable(NOLOCK) ON KeyPk = DataPk 
				ORDER BY	 PcPk DESC
				
				SELECT		MAX(BvmPk) 'FlowPk',  BpmNm 'FlowNm'
				FROM		BpmMas(NOLOCK)
				JOIN		BpmVersions(NOLOCK) ON BvmBpmFk = BpmPk AND BvmDelid = 0
				WHERE		BpmPk IN (57,66,68) AND BpmDelid = 0 
				GROUP BY	BpmNm
			/*
				SELECT		MAX(BvmPk) 'FlowPk', BpmNm 'FlowNm'
				FROM		BpmObjInOut (NOLOCK)
				JOIN		BpmToolBox (NOLOCK) ON BtbPk = BioBtbFk AND BtbToolNm = 'bpmn:StartEvent' AND BtbDelid = 0
				JOIN		GenUsrRoleDtls (NOLOCK) ON UrdUsrFk = @UsrPk AND UrdRolFk = dbo.getAttRoleFk(BioBfwFk) AND UrdDelid = 0
				JOIN		BpmVersions(NOLOCK) ON BvmPk = BioBvmFk AND BvmDelid = 0
				JOIN		BpmMas (NOLOCK) ON BpmPk = BvmBpmFk AND BpmDelid = 0
				WHERE		BioDelId = 0 AND ISNULL(BioSubBfwFk,0) = 0
				GROUP BY	BpmNm
				*/
			END

			IF @Action = 'GET_FLOW_DATA'
			BEGIN

				SELECT  @UsrPk = UsrPk,@UsrNm = UsrCd FROM #GlobalDetails
				
				SELECT	@UsrPk = UsrPk FROM GenUsrMas (NOLOCK) WHERE UsrNm = @UsrNm AND UsrDelId = 0 

				INSERT INTO @AprLvl
				SELECT  AprTyp,AprLvl
				FROM	GenUsrRoleDtls(NOLOCK) 
				JOIN	LosApprover(NOLOCK) ON AprRolFk = UrdRolFk
				WHERE   UrdUsrFk = @UsrPk AND UrdDelid = 0
				
				SELECT  @CLvlNo = MAX(AprLvl) FROM @AprLvl WHERE AprTyp = 'C'
				SELECT  @DLvlNo = MAX(AprLvl) FROM @AprLvl WHERE AprTyp = 'D'
				
				SELECT	@UsrPk 'UsrFk'
				
				INSERT INTO #PendingProcess
				SELECT		 BnoDataPk 'DataPk',BnoUsrFk 'UsrFk', BnoBexFk 'PcPk', dbo.getFlowNm(BnoBvmFk) 'FlowNm',
							 BnoBvmFk 'FlowPk', BnoBioFk 'SbsdFk',BnoBudFk 'PagePk',ISNULL(BnoStatus,'') 'Pg_status',
							 BnoBfwFk 'BfwFk' , BexBrnchFk 'BpmBranchFk',
							 UsrDispNm 'Roles', dbo.gefgDMY(BexCreatedDt) 'ExecDt',
							 CASE	WHEN DATEDIFF(YEAR, CONVERT(DATETIME,BexCreatedDt,103), @CurDt)  > 0 
									THEN CAST(DATEDIFF(YEAR, CONVERT(DATETIME,BexCreatedDt,103), @CurDt) AS VARCHAR)+ ' year(s) ago'
									WHEN DATEDIFF(DAY, CONVERT(DATETIME,BexCreatedDt,103), @CurDt)  > 0 
									THEN CAST(DATEDIFF(DAY, CONVERT(DATETIME,BexCreatedDt,103), @CurDt) AS VARCHAR)+ ' day(s) ago'
									WHEN DATEDIFF(HOUR, CONVERT(DATETIME,BexCreatedDt,103), @CurDt) > 0
									THEN CAST(DATEDIFF(HOUR, CONVERT(DATETIME,BexCreatedDt,103), @CurDt) AS VARCHAR) + ' hour(s) ago' 
									ELSE CAST(DATEDIFF(MINUTE, CONVERT(DATETIME,BexCreatedDt,103), @CurDt) AS VARCHAR) + ' minute(s) ago'  END 'Time',
							ISNULL(BudCd,'') 'Cd', ISNULL(BexDpdFk,0) 'KeyDpdFk'
				FROM		BpmNextOpUsr(NOLOCK)
				JOIN		BpmExec (NOLOCK) ON BnoBexFk = BexPk AND BexDelid = 0	
				JOIN		GenUsrMas(NOLOCK) ON UsrPk = BexUsrFk AND UsrDelId = 0	
				JOIN		BpmUiDefn(NOLOCK) ON BudPk = BnoBudFk AND BudDelid = 0
				WHERE		NOT EXISTS (SELECT NULL FROM BpmExecStatus(NOLOCK) WHERE BesBexFk = BnoBexFk AND BesDelId = 0) AND BnoDataPk LIKE '%'+CAST(ISNULL(@DataFk,BnoDataPk)AS VARCHAR(20))+'%'
				AND			BnoUsrFk = @UsrPk ORDER BY PcPk DESC

				SELECT		 DataPk,UsrFk, PcPk, FlowNm, FlowPk, SbsdFk, PagePk, Pg_status,BfwFk,BpmBranchFk,Roles,
							 DTime'Time', Cd, KeyDpdFk , ISNULL(@CLvlNo,0) 'CLvlNo', ISNULL(@DLvlNo,0) 'DLvlNo',
							 KeyNm 'LeadNm','' 'PCd' , '' 'LeadID' , KeyPk 'Pk'
				FROM		 #PendingProcess
				LEFT OUTER JOIN BpmFlowKeyTable(NOLOCK) ON KeyPk = DataPk 
				ORDER BY	 PcPk DESC
				
				SELECT		MAX(BvmPk) 'FlowPk',  BpmNm 'FlowNm'
				FROM		BpmMas(NOLOCK)
				JOIN		BpmVersions(NOLOCK) ON BvmBpmFk = BpmPk AND BvmDelid = 0
				WHERE		BpmPk IN (57,66,68) AND BpmDelid = 0 
				GROUP BY	BpmNm
			/*
				SELECT		MAX(BvmPk) 'FlowPk', BpmNm 'FlowNm'
				FROM		BpmObjInOut (NOLOCK)
				JOIN		BpmToolBox (NOLOCK) ON BtbPk = BioBtbFk AND BtbToolNm = 'bpmn:StartEvent' AND BtbDelid = 0
				JOIN		GenUsrRoleDtls (NOLOCK) ON UrdUsrFk = @UsrPk AND UrdRolFk = dbo.getAttRoleFk(BioBfwFk) AND UrdDelid = 0
				JOIN		BpmVersions(NOLOCK) ON BvmPk = BioBvmFk AND BvmDelid = 0
				JOIN		BpmMas (NOLOCK) ON BpmPk = BvmBpmFk AND BpmDelid = 0
				WHERE		BioDelId = 0 AND ISNULL(BioSubBfwFk,0) = 0
				GROUP BY	BpmNm
				*/
			END

			IF @Action = 'FORWARD_DATA'
			BEGIN		
				SELECT	@HisPk = HisPk ,@CurBfwFk = CurBfwFk,@DataMasPk = FwdDataPk, @CurVerFlowPk = CurVerFlowPk , @UsrPk = UsrPk,
						@TgtPageID = TgtPageID, @DblEntry = DblEntry, @BrnchFk = BrnchFk, @SanFk = SanFk
				FROM	#GlobalDetails;

				IF ISNULL(@DblEntry,0) = 1
				BEGIN
					EXEC PrcBpmArvNextSeq 'FORWARD_DATA', @UsrPk, @CurVerFlowPk, @DataMasPk, @HisPk, @CurBfwFk, NULL, NULL, 0, @RtnOption, @ValData, @BrnchFk, @SanFk, @Branch

					INSERT INTO @HisDtls
					SELECT	BexPk, BioOutId FROM BPMExec(NOLOCK)
					JOIN	BpmObjInout(NOLOCK) ON BioPk = BexBioFk AND dbo.gefgGetProcType(BioBfwFk) = 'bpmn:exclusivegateway' AND BioDelid = 0
					WHERE	BexPk > @HisPk AND BexKeyFk = @DataMasPk AND BexBvmFk = @CurVerFlowPk AND BexDelId = 0 
					AND NOT EXISTS(SELECT 'X' FROM BPMExecStatus (NOLOCK) WHERE BesBexFk = BexPk AND BesDelid = 0)
					
					INSERT INTO @TgtPages
					SELECT items FROM dbo.split(@TgtPageID,'~',1)
					
					SELECT @MinFk = MIN(RowNo), @MaxFk = MAX(RowNo) FROM @TgtPages

					WHILE @MinFk <= @MaxFk
						BEGIN
							SELECT @TgtPageID = '', @HisPk = 0;
							
							SELECT @TgtPageID = TgtPageID FROM @TgtPages WHERE RowNo = @MinFk
							SELECT @HisPk = BexFk FROM @HisDtls WHERE BioOutId = @TgtPageID

							EXEC PrcBpmArvNextSeq 'FORWARD_DATA', @UsrPk, @CurVerFlowPk, @DataMasPk, @HisPk, @CurBfwFk, NULL, @TgtPageID, 0, @RtnOption, @ValData, @BrnchFk, @SanFk, @Branch
							
							SELECT @MinFk = MIN(RowNo) FROM @TgtPages WHERE RowNo > @MinFk
						END
				END
				ELSE			
					EXEC PrcBpmArvNextSeq 'FORWARD_DATA', @UsrPk, @CurVerFlowPk, @DataMasPk, @HisPk, @CurBfwFk, NULL, @TgtPageID, 0, @RtnOption, @ValData, @BrnchFk, @SanFk, @Branch
				
				--SET @IsManCal = 1;
				--SET @Action = 'GET_ENTRY_STS'
			END
			
			IF @Action = 'GET_ENTRY_STS'
			BEGIN
				SELECT	@HisPk = HisPk ,@CurBfwFk = CurBfwFk,@DataMasPk = FwdDataPk, @CurVerFlowPk = CurVerFlowPk , @UsrPk = UsrPk,
						@TgtPageID = TgtPageID,@BrnchFk = BrnchFk
				FROM	#GlobalDetails;
	
				EXEC PrcBpmArvNextSeq @Action, @UsrPk, @CurVerFlowPk, @DataMasPk, @HisPk, @CurBfwFk, NULL,  @TgtPageID, @IsManCal,NULL,NULL,@BrnchFk
			END
		    
			IF @Action = 'LIST_FLOW'
				BEGIN
					SELECT	KeyNm 'Leadname', KeyPk 'LeadPk', GeoNm 'branchname'  FROM BpmFlowKeyTable (NOLOCK)
					JOIN	GenGeoMas (NOLOCK) ON GeoPk = KeyBrnchFk AND GeoDelid = 0
					WHERE	keyDelid = 0

					SELECT BpmPk, BpmNm FROM BpmMas(NOLOCK) WHERE BpmDelid = 0
				END

		    IF @Action = 'IS_PENDING_QUERY'
				BEGIN
					SELECT	@CurBfwFk = CurBfwFk,@DataMasPk = FwdDataPk
					FROM	#GlobalDetails;
					
					IF EXISTS
					(
						SELECT  'X'
						FROM	QryHdr(NOLOCK) 
						WHERE	QrhKeyFk = @DataMasPk AND QrhBfwFk = @CurBfwFk AND ISNULL(QrhSoln,0) <> 1 AND QrhDelid = 0 
					)
						SELECT 1 'QryExists'
					ELSE
						SELECT 0 'QryExists'
				END	
		
	IF @Trancount = 1 AND @@TRANCOUNT = 1
		COMMIT TRAN
			
	END TRY
	BEGIN CATCH

		IF @Trancount = 1 AND @@TRANCOUNT = 1
			ROLLBACK TRAN	
		
		SELECT	@ErrMsg = ERROR_MESSAGE() ,--+ ',' + ERROR_PROCEDURE() + ':' + RTRIM(ERROR_LINE()),
				@ErrSeverity = ERROR_SEVERITY()
		
		RAISERROR('%s', @ErrSeverity, 1,@ErrMsg) 		
		RETURN
			
	END CATCH
		
END





GO
