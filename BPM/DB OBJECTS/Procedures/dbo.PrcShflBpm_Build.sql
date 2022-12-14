USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[PrcShflBpm_Build]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PrcShflBpm_Build]
(
	@Action			VARCHAR(100)		=	NULL ,
	@RightsJson		VARCHAR(MAX)		=	NULL ,
	@GlobalJSON		VARCHAR(MAX)		=	NULL ,
	@PageJson		VARCHAR(MAX)		=	NULL ,
	@DataJson		VARCHAR(MAX)		=	NULL ,
	@SubFlowFk		BIGINT				=	NULL ,
	@FlowRef		BIGINT				=	NULL
)
AS
BEGIN

	SET NOCOUNT ON
	SET ANSI_WARNINGS ON

	DECLARE @XmlId INT , @ErrorNo INT, @RwCnt INT, @UsrPk BIGINT, @CstmVal1 BIGINT, @NoOfMsg BIGINT

	DECLARE @CurDt DATETIME, @TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT
	
	DECLARE @FlowFk BIGINT,@ElemPk VARCHAR(200),@CurPage BIGINT,@TgtPage BIGINT, @PrtTreeId VARCHAR(100),@ElemId VARCHAR(100)

	DECLARE @ElemType VARCHAR(100), @ElemFk BIGINT , @NxtPageElem BIGINT,@DataKey VARCHAR(200) , @DataMasPk BIGINT,
			@CurVerFlowPk BIGINT , @HisPk BIGINT
	
	DECLARE @PkVal BIGINT, @PkHisVal BIGINT, @CurSeqFk BIGINT,@PrevSeqFk BIGINT, @TgtSbfdFk BIGINT, @PrcType VARCHAR(100)
	
	DECLARE @IsSubPc INT, @DstFk BIGINT ,@PageFk BIGINT, @OldPgFk BIGINT, @LaneId VARCHAR(100), @LaneRolFk BIGINT;
	DECLARE @TblNm VARCHAR(100),@QryBuilder VARCHAR(MAX) , @Val VARCHAR(MAX) ,@ColNm VARCHAR(MAX) 
	
	DECLARE @Count INT,@TempCurSbsdFk BIGINT, @TempNxtSbsdFk BIGINT, @CreatePageType TINYINT, @TgtPageID VARCHAR(200),
			@TempSbfdFk BIGINT, @DfltTbl VARCHAR(20), @DpdFk BIGINT;
	
	DECLARE @MinFk BIGINT, @MaxFk BIGINT, @VerFlowPk BIGINT
	DECLARE @UsrMsgs TABLE(Fk BIGINT)
	
	CREATE TABLE #TempRolLane(xx_id BIGINT, LaneId VARCHAR(100), LaneRolFk BIGINT)
	CREATE TABLE #TempData (TempKeyId VARCHAR(200));
	CREATE TABLE #TmpSeqSubDtls
	(
		SbsdSbdFk BIGINT, SbsdProcFlg INT, SbsdId VARCHAR(100), SbsdSrcId VARCHAR(100), 
		SbsdSrcFk BIGINT, SbsdDestId VARCHAR(100), SbsdDestFk BIGINT, SbsdSeqTreeId VARCHAR(100)
	)
	CREATE TABLE #ChatHdrData(CrUsrFk BIGINT, CrPgFk BIGINT,SbcPk BIGINT)
	CREATE TABLE #HisDtls
	(
		CrUsrFk BIGINT, ToUsrPgFk BIGINT, CrPgFk BIGINT, IsRead BIT, DtlPk BIGINT,HdrPk BIGINT, ChatMsg VARCHAR(MAX), 
		DtTime VARCHAR(50), Grp_No BIGINT, DpdFk BIGINT, PageOrUsrFk BIGINT, PageOrUsr INT,
		SentNm VARCHAR(500),  ActDt DATETIME, Flg INT 
	)

	SET @CurDt = GETDATE()
	
	CREATE TABLE #GlobalDetails
	(
		xx_id BIGINT, TempFlowFk BIGINT, TempFlowXml VARCHAR(MAX),TempElemId VARCHAR(200),CurPage BIGINT,FwdDataPk BIGINT,
		CreatePageType TINYINT,TgtPageID VARCHAR(200), UsrFk BIGINT,VerFlowPk BIGINT,CurVerFlowPk BIGINT,HisPK BIGINT
	)
	
	CREATE TABLE #ProcTmp(SbdFk BIGINT, SbdId VARCHAR(100))
	CREATE TABLE #SeqSrcTbl(xx_id BIGINT, Id VARCHAR(100), SrcId VARCHAR(100), Flg INT)
	CREATE TABLE #SeqTrgTbl(xx_id BIGINT, Id VARCHAR(100), TrgId VARCHAR(100), Flg INT)
	CREATE TABLE #SeqTbl(FinId VARCHAR(100), FinSrcId VARCHAR(100), FinSrcFk BIGINT, FinTrgId VARCHAR(100), FinTrgFk BIGINT)
	CREATE TABLE #PageDetails(xx_id BIGINT,ElemType VARCHAR(100),ElemId VARCHAR(200),ElemLabel VARCHAR(200),ElemValue VARCHAR(MAX),SelectedValue VARCHAR(200));
	CREATE TABLE #UsrRights(xx_id BIGINT,RolFk BIGINT, PageId VARCHAR(100))
	CREATE TABLE #SubProcDtls(SbfdFk BIGINT, FlowFk BIGINT, TreeId VARCHAR(100))
	CREATE TABLE #PageDataTbl 
	(
		xx_id BIGINT,FlowFk BIGINT,ElemPk BIGINT,ElemID VARCHAR(100),ElemDesc VARCHAR(200),ElemPageHtml VARCHAR(MAX),
		ElemPageUrl VARCHAR(500), ElemPageType INT, ElemSubProcId BIGINT, CmdTxt VARCHAR(500),IsAuto BIT, ElemScript VARCHAR(MAX), ElmRmks VARCHAR(500)
	)
	CREATE TABLE #ValData(xx_id BIGINT,id VARCHAR(MAX), idval VARCHAR(MAX))
	DECLARE @TempParellelDestination TABLE(SbfdFk BIGINT, SbsdFk BIGINT, ElmId VARCHAR(100), ElmFlg INT, HisFk BIGINT, DpdFk BIGINT, DstTyp VARCHAR(100), RowId INT)
			
	IF @GlobalJSON !='[]' AND @GlobalJSON != ''
	BEGIN
		INSERT INTO #GlobalDetails
		EXEC PrcParseJSON @GlobalJSON,'FlowFk,FlowXml,ElemId,CurPage,FwdDataPk,CreatePageType,TgtPageID,UsrPk,VerFlowPk,CurVerFlowPk,HisPK'
	END

	IF @PageJson !='[]' AND @PageJson != ''
	BEGIN
			INSERT INTO #PageDataTbl
			EXEC PrcParseJSON @PageJson,'FlowFk,ElemPk,ElemID,ElemDesc,ElemPageHtml,ElemPageUrl,ElemPageType,ElemSubProcId,CmdTxt,IsAuto,ElemScript,ElmRmks'
	END 

	IF @DataJson !='[]' AND @DataJson != ''
	BEGIN
		IF @Action = 'SAVE_ROLES'
			BEGIN
				INSERT INTO #TempRolLane
				EXEC PrcParseJSON @DataJson,'LaneId,RolFk'
				
				SELECT @LaneId = LaneId , @LaneRolFk  = LaneRolFk FROM #TempRolLane
			END
		ELSE
			BEGIN
				INSERT INTO #ValData
				EXEC PrcParseJSON @DataJson,'id,idval'
			END
	END

	IF @RightsJson !='[]' AND @RightsJson != ''
	BEGIN
		INSERT INTO #UsrRights
		EXEC PrcParseJSON @RightsJson,'RolFk,PageId'
	END

	
	BEGIN TRY
	 
	IF @@TRANCOUNT = 0
		SET @TranCount = 1
	
	IF @TranCount = 1
		BEGIN TRAN

			IF @Action = 'GET_FLOW_XML'
			BEGIN
				SELECT @CurPage = CurPage, @FlowFk = TempFlowFk FROM #GlobalDetails

				IF @FlowFk = 0
				BEGIN 
					SELECT		BvmBpmFk 'BpmPk', MAX(BvmPk) 'BvmFk' INTO #FlowDtls
					FROM		BpmVersions(NOLOCK)
					WHERE		BvmDelId = 0
					GROUP BY	BvmBpmFk

					SELECT		BvmXML 'FlowXml',BvmPk 'FlowPk',BpmNm 'FlowNm',BvmVerNo 'FlowVersNo',BpmPk 'BpmFk'
					FROM		BpmMas(NOLOCK) 
					JOIN		BpmVersions (NOLOCK) ON BvmBpmFk = BpmPk AND BvmDelId = 0
					AND			EXISTS(SELECT 'X' FROM #FlowDtls WHERE BvmFk = BvmPk)
					WHERE		BpmDelId = 0
					ORDER BY	BpmPk DESC
				END
				ELSE
				BEGIN
					SELECT	BvmXML 'FlowXml',BpmPk 'BpmFk',BpmNm 'FlowNm',BvmVerNo 'FlowVersNo',BvmPk 'FlowPk',ISNULL(BvmNotes,'') 'Rmks'
					FROM	BpmMas(NOLOCK) 
					JOIN	BpmVersions (NOLOCK) ON BvmPk = @FlowFk AND BvmBpmFk = BpmPk AND BvmDelId = 0
					WHERE	BpmDelId=0;

					SELECT @FlowRef = BvmBpmFk FROM BpmVersions(NOLOCK) WHERE BvmPk = @FlowFk AND BvmDelid = 0
				END	

				SELECT		BpmNm 'FlowNm', MAX(BvmPk) 'FlowFk'
				FROM		BpmMas (NOLOCK) 
				JOIN		BpmVersions (NOLOCK) ON BvmBpmFk = BpmPk AND BvmDelId = 0
				WHERE		BpmPk <> @FlowFk AND BpmDelId = 0
				AND			ISNULL(BpmNm,'') != ''
				GROUP BY	BpmNm

				IF @FlowFk > 0
					BEGIN
						SELECT	CASE LOWER(BtbToolNm) WHEN 'bpmn:startevent' THEN 1 ELSE 0 END 'IsStrt',
								BfwId 'ElemId', BfwId 'ElemDesc',BudDesignData  'ElemHtml',
								BudURL 'ElemPageUrl', BudDesignTyp 'Pagetype', BfwSubBvmFk 'SelProcId',
								ISNULL(BudNotes,'') 'Rmks', ISNULL(BudCd,'') 'ElemCd', ISNULL(BudDecIsAuto,0) 'IsAuto',BudIsRtnNeed 'ElemIsRtnNeed'
						FROM	BpmUIDefn (NOLOCK)
						JOIN	BpmFlow (NOLOCK) ON BfwBvmFk = @FlowFk AND BfwPk = BudBfwFk AND BfwDelId = 0
						JOIN	BpmToolBox (NOLOCK) ON BtbPk = BfwBtbFk AND BtbDelId = 0
						WHERE	BudDelid = 0

						IF EXISTS
						(	
							SELECT 'X' FROM BpmFlow(NOLOCK) WHERE	BfwBvmFk = @FlowFk AND BfwDelId = 0 AND 
							EXISTS(SELECT 'X' FROM BpmToolBox(NOLOCK) WHERE BtbPk = BfwBtbFk AND LOWER(BtbToolNm) = 'bpmn:lane' AND BtbDelId = 0)
						)
						BEGIN
							SELECT  BfwId'RolId', BfwLabel 'RolNm', RolPk 'RolFk'
							FROM	BpmFlow(NOLOCK)
							JOIN	BpmToolBox (NOLOCK) ON BtbPk = BfwBtbFk AND LOWER(BtbToolNm) ='bpmn:lane' AND BtbDelId = 0
							JOIN	GenRole (NOLOCK) ON LTRIM(RTRIM(RolNm)) = LTRIM(RTRIM(BfwLabel)) AND RolDelid = 0
							WHERE	BfwBvmFk = @FlowFk AND BfwDelId = 0
						END
						ELSE
							BEGIN
								SELECT  BfwId'RolId', BfwLabel 'RolNm', RolPk 'RolFk'
								FROM	BpmFlow(NOLOCK)
								JOIN	BpmToolBox (NOLOCK) ON BtbPk = BfwBtbFk AND LOWER(BtbToolNm) ='bpmn:participant' AND BtbDelId = 0
								JOIN	GenRole (NOLOCK) ON LTRIM(RTRIM(RolNm)) = LTRIM(RTRIM(BfwLabel)) AND RolDelid = 0
								WHERE	BfwBvmFk = @FlowFk AND BfwDelId = 0
							END

					END
			END

			IF @Action = 'GET_FLOW_VERSIONS'
			BEGIN
				SELECT		'Version ' + CONVERT(VARCHAR,BvmVerNo) 'VerNo', BvmPk 'FlowFk', BvmNotes 'Rmks'
				FROM		BpmMas(NOLOCK) 
				JOIN		BpmVersions (NOLOCK) ON BvmBpmFk = BpmPk AND BvmDelId = 0
				WHERE		BpmPk = @FlowRef AND BpmDelId = 0
				ORDER BY	BvmPk DESC
			END

			IF @Action = 'LOAD_ROLES'
			BEGIN
				SELECT RolNm 'Roles', RolPk 'RolePk'  FROM GenRole WHERE RolDelid = 0

				SELECT	PrdNm 'Text', PrdPk 'Pk', CASE PrdCd WHEN 'HL' THEN 1 ELSE 0 END 'IsSel'
				FROM	GenPrdMas(NOLOCK)
				WHERE	PrdDelid = 0
					UNION ALL
				SELECT	GeoNm 'Text', GeoPk 'Pk', CASE GeoNm WHEN 'Mumbai' THEN 1 ELSE 0 END 'IsSel'
				FROM	GenGeoMas(NOLOCK)
				WHERE	GeoDelid = 0

				SELECT UsrDispNm, UsrPk FROM GenUsrMas(NOLOCK) 
				WHERE  UsrDelid = 0

				SELECT	TrigNm, TrigPk
				FROM	TrigConfig(NOLOCK) 
			END

			IF @Action = 'PAGE_CHECK'
			BEGIN							
				SELECT	BudPk 'PagePk',BudDesignData 'PageJson',BudDesignTyp 'PageType',BudURL 'PageUrl',
						BudBfwFk 'PageSbfdFk',ISNULL(BudDecIsAuto,0) 'IsAuto', ISNULL(BudDecExp,'') 'CmdTxt',
						ISNULL(BudScript,'') 'PageScript', ISNULL(BudNotes,'') 'Rmks', ISNULL(BudCd,'') 'ElemCd',BudIsRtnNeed 'ElemIsRtnNeed'
				FROM	BpmUIDefn(NOLOCK)
				JOIN	BpmFlow(NOLOCK) ON BfwPk = BudBfwFk AND BfwDelId = 0
				WHERE	BfwDelId = 0 AND BudDelId = 0 AND  EXISTS (SELECT  'X' FROM #GlobalDetails WHERE BfwId = TempElemId)
				AND		EXISTS (SELECT  'X' FROM #GlobalDetails WHERE BfwBvmFk = TempFlowFk) 
			END

			IF @Action = 'FETCH_SUBPROC'
			BEGIN
				SELECT @ElemPk = dbo.gefgGetElementFk(TempElemId) FROM #GlobalDetails

				SELECT BvmXML 'XmlData', BfwBvmFk 'SrcFlowFk', BfwSubBvmFk 'DestFlowFk'
				FROM	BpmFlow (NOLOCK)
				JOIN	BpmVersions (NOLOCK) ON BfwBvmFk = BvmPk AND BvmDelId = 0
				JOIN	BpmMas (NOLOCK) ON BpmPk = BfwSubBvmFk AND BpmDelId = 0
				WHERE	BfwPk = @ElemPk AND BfwDelId = 0
			END

			IF @Action = 'FETCH_BACKPROC'
				BEGIN
					SELECT @ElemPk = dbo.gefgGetElementFk(TempElemId) FROM #GlobalDetails

					SELECT  BvmXML 'XmlData', BfwBvmFk 'SrcFlowFk', BfwSubBvmFk 'DestFlowFk'
					FROM	BpmMas (NOLOCK)
					JOIN	BpmVersions (NOLOCK) ON BvmBpmFk = BpmPk AND BvmDelId = 0
					JOIN	BpmFlow (NOLOCK) ON BfwBvmFk = BpmPk AND ISNULL(BfwSubBvmFk,0) <> 0 AND BfwDelId = 0
					WHERE	BpmDelId = 0 
					AND		EXISTS
					(
						SELECT 'X' FROM BpmFlow (NOLOCK)	
						WHERE BfwBvmFk = BpmPk AND BfwPk = @ElemPk AND BfwDelId = 0
					)	
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
