USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[PrcBpmArvNextSeq]    Script Date: 9/26/2017 11:01:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[PrcBpmArvNextSeq]
(
	@Action			VARCHAR(50)		=	NULL,	/* FORWARD_DATA, GET ENTRY STATUS */
	@UsrPk			BIGINT			=	NULL, 
	@FlowFk			BIGINT			=	NULL,	/* Current Version FlowFk */
	@DataMasPk		BIGINT			=	NULL,	/* Base Data Pk */
	@HisPk			BIGINT			=	NULL,	/* Current Incomplete History Reference */
	@CurBfwFk		BIGINT			=	NULL,	/* Current Flow (Required when Return Flow is set to Current Screen) */
	@CurSeqFk		BIGINT			=	NULL,	/* Current SeqFk (If History Pk is provided, this is not needed */
	@TgtFlowID		VARCHAR(100)	=	NULL,	/* Target Flow ID (Sent only during Returning to Particular Page or Decision(uesr choice) */
	@IsManCal		BIT				=	0,		/* If Forward_Data is Called this is set to 1 else 0 for Final Select */ 
	@RtnOption		INT				=	0,		/* 1 - Return to Current Screen with Normal Flow , 2 - Return to Current Screen Directly */
	@ValData		VARCHAR(MAX)	=	NULL,	/* Data Comes here only when it is new Data Entry */
	@BrnchFk		BIGINT			=	NULL ,
	@KeyDpdFk		VARCHAR(100)	=	NULL,
	@IsRej			TINYINT			=	0
)
AS
BEGIN


--IF @Action = 'FORWARD_DATA'
--BEGIN
--	RAISERROR('Wait',16,1)
--	RETURN
--END

	SET NOCOUNT ON 
	SET ANSI_WARNINGS ON
	
	/*************************** Global Datas ********************************/
	DECLARE @CurDt DATETIME, @RowId VARCHAR(40), @UsrNm VARCHAR(100),@TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT
	
	/*************************** Forward Datas ********************************/
	DECLARE @TgtFlowDtlFk BIGINT, @IsAuto INT, @QryBuilder VARCHAR(MAX), @InsertNext BIT = 0;
	DECLARE @Count INT,@TempCurSbsdFk BIGINT,@TgtSeqFk BIGINT , @SubProcsFk BIGINT,@ElemType VARCHAR(100),
			@CreatePageType TINYINT, @IsSubPc INT, @RtnFlowID VARCHAR(100), @RtnBfwFk BIGINT, @RoundNo INT, @LstInsertPg VARCHAR(100),@FilUsrFk BIGINT;
	DECLARE @PendingUsrWorks TABLE(PendUsrFk BIGINT,PgRef BIGINT,AsgndWork BIGINT,Flg INT)
	DECLARE @DestDtls TABLE(BfwFk BIGINT)
	DECLARE @TblNm VARCHAR(100), @PgJson VARCHAR(MAX), @FlowNm  VARCHAR(100),@BrnchNm VARCHAR(100)

	DECLARE @InCount BIGINT, @FinishedCount BIGINT, @ElmId VARCHAR(100)
	DECLARE @ColNm VARCHAR(MAX), @Val VARCHAR(MAX), @MaxFk BIGINT, @MinFk BIGINT, @DestFk BIGINT;
	DECLARE	@TgtPrtTreeId VARCHAR(MAX), @TrgPrtStg INT, @SanCnt INT = 0
	DECLARE @CurPrtTreeId VARCHAR(MAX), @CurPrtStg INT, @IsFromTo INT = 0, @PrevFlowFk BIGINT, 
			@PrevPrtTreeId VARCHAR(MAX), @PrevPrtStg INT, @CurSerNo INT, @TrgSerNo INT,@IsEnd BIT
	
	DECLARE @TempParellelDestination TABLE(SbfdFk BIGINT, SbsdFk BIGINT, ElmId VARCHAR(100), ElmFlg INT, HisFk BIGINT, DpdFk BIGINT, DstTyp VARCHAR(100), RowId INT, SNo INT IDENTITY(1,1))
	DECLARE @HisDtls TABLE(BexFk BIGINT, BexBioFk BIGINT, BexBrnchFk BIGINT)
	DECLARE @DecSeq TABLE(BioPk BIGINT, IsValid INT, HisPk BIGINT)
	DECLARE @CrntHis TABLE(PcFk BIGINT, FdUsrFk BIGINT)
	DECLARE @RightsDtls TABLE(PgFk BIGINT)
	DECLARE @CompletedDtls TABLE(BioFk BIGINT)
	
	CREATE TABLE #Tbl_Crt_Tmplt_Tmp(xx_id BIGINT, label VARCHAR(100), value VARCHAR(100), id VARCHAR(100))
	CREATE TABLE #ParallelDpdRef(KeyDpdFk BIGINT, RowNo BIGINT IDENTITY(1,1))
	CREATE TABLE #SeqFlowDtls
	(
		SNo BIGINT IDENTITY(1,1),BioBfwFk BIGINT, BioInFk BIGINT,  BioTrgFk BIGINT, TreeId VARCHAR(MAX), 
		TreeStg INT, BioRef BIGINT, BioSubBfwFk BIGINT, BioId VARCHAR(100), BioOutId VARCHAR(100), BioInId VARCHAR(100),
		BioBtbFk BIGINT
	)	
	CREATE TABLE #FlowDtls_History
	(
		PcPk BIGINT,PagePk BIGINT,PageJson VARCHAR(MAX),PageUrl VARCHAR(MAX),PageType VARCHAR(10),
		PageSbfdFk BIGINT,PgNm VARCHAR(100) ,SbsdFlowFk BIGINT,
		IsAuto TINYINT, PageExp VARCHAR(100) ,IsRtnNeed TINYINT, PageScript VARCHAR(100), 
		TableNm VARCHAR(500)
	)
	CREATE TABLE #BetweenNodes(BioFk BIGINT,Stg INT, SibTreeId VARCHAR(MAX))
	CREATE TABLE #TempRights_Geo_Next(UsrRef BIGINT,GeoFk BIGINT,LvlNo INT)
	CREATE TABLE #TempRights_RolePages_Next(SbfdFk BIGINT,SbsdPk BIGINT, PagePk BIGINT, UsrFk BIGINT,UsrBGeoFk BIGINT)
	CREATE TABLE #DataDtls_Next
	(
		PcPk BIGINT, FlowPk BIGINT, SbsdFk BIGINT, PagePk BIGINT, Pg_status VARCHAR(100),
		DataPk BIGINT, BranchFk BIGINT, BfwFk BIGINT, UsrFk BIGINT 
	)
	
	CREATE TABLE #ValData(xx_id BIGINT,id VARCHAR(MAX), idval VARCHAR(MAX))
	CREATE TABLE #All_His_Datas(FlowFk BIGINT, BexKeyFk BIGINT, BexBioFk BIGINT, BexPk BIGINT)
	
	CREATE TABLE #AllScrnDtls
	(
		BtbFk BIGINT, BioBvmFk BIGINT, BioId VARCHAR(50), BioPk BIGINT, BioOutBfwFk BIGINT, 
		DestTyp VARCHAR(100), BudPk BIGINT, BudDesignData VARCHAR(MAX), BudURL VARCHAR(MAX),
		BudDesignTyp TINYINT, BudBfwFk BIGINT, PgNm VARCHAR(100), BudDecIsAuto TINYINT,
		BudDecExp VARCHAR(100), BudScript VARCHAR(100), BudCd VARCHAR(5),BudIsRtnNeed BIGINT,  BioinBfwFk BIGINT,
		TreeId VARCHAR(MAX)
	)

	DECLARE @ColSelect VARCHAR(MAX),  @IsStrScr INT, @ProcFlg INT
	DECLARE @DataField VARCHAR(MAX), @DataLabel VARCHAR(MAX), @ColTbl VARCHAR(MAX), @ElmFk BIGINT
	CREATE TABLE #PgHdr
	(
		TblNm VARCHAR(100),PgNm VARCHAR(100),PgColsLbl VARCHAR(MAX), PgColsDataField VARCHAR(MAX), OrdNo INT, 
		ProcFlg INT, IsFlowStrt INT, UsrNm VARCHAR(100), DtTime VARCHAR(100), BexPk BIGINT, AprOrRej TINYINT
	)
	
	DECLARE @PrcFk BIGINT

	SELECT @PrcFk = BvmBpmFk FROM BpmVersions(NOLOCK) WHERE BvmPk = @FlowFk
	
	SELECT @CurDt = GETDATE(), @RowId = NEWID(), @UsrNm = 'ADMIN'
	
	IF @ValData !='[]' AND @ValData != ''
	BEGIN
		INSERT INTO #ValData
		EXEC PrcParseJSON @ValData,'id,idval'
	END
	
	BEGIN TRY

	IF @@TRANCOUNT = 0
		SET @TranCount = 1
	
	IF @TranCount = 1
		BEGIN TRAN	
							
			/***************************** Post History Data for the Current Seq and Show the Next Screen to the User Starts ****************************************/
			IF @Action = 'FORWARD_DATA'
				BEGIN
					
					DELETE FROM #SeqFlowDtls
					
					INSERT INTO #SeqFlowDtls(BioBfwFk,BioInFk,BioTrgFk,TreeId,TreeStg,BioRef,BioSubBfwFk,BioId,BioOutId,BioInId,BioBtbFk)
					SELECT		BioBfwFk, BioInBfwFk, BioOutBfwFk, BioTreeId, CONVERT(BIGINT,LEFT(ISNULL(BioTreeId,''),3)), 
								BioPk,ISNULL(BioSubBfwFk,0),BioId,ISNULL(BioOutId,''),ISNULL(BioInId,''),BioBtbFk
					FROM		BpmObjInOut(NOLOCK) WHERE BioBvmFk = @FlowFk AND BioDelid = 0
					ORDER BY	BioTreeId
							
					--RETURN
					IF EXISTS(SELECT 'X' FROM BpmExecStatus(NOLOCK) WHERE BesBexFk = @HisPk AND BesDelId = 0)
						BEGIN
							RAISERROR('Process Completed by some other User. Refresh & Try Again',16,1)
							RETURN
						END

					-- Get Screen Table Related to this Data.						
						SELECT	DISTINCT @TblNm = 'GEN_' + CONVERT(VARCHAR(20), @PrcFk)+ '_' + BfwId
						FROM	BpmExec (NOLOCK) 
						JOIN	BpmObjInOut (NOLOCK) ON BioPk = BexBioFk AND BioDelId = 0
						JOIN	BpmFlow(NOLOCK) ON BfwPk = BioBfwFk AND BfwDelid = 0
						WHERE	BexBvmFk = @FlowFk AND BexKeyFk = @DataMasPk AND BexPk = @HisPk AND BexDelid = 0
					
					-- Get List of Columns
						SELECT  COLUMN_NAME  INTO #ColList
						FROM	INFORMATION_SCHEMA.COLUMNS
						WHERE	TABLE_NAME = @TblNm

						SELECT	@Val = ISNULL(@Val,'') + '''' + idval + ''',', @ColNm = ISNULL(@ColNm,'') + COLUMN_NAME + ','
						FROM	#ValData
						JOIN	#ColList ON COLUMN_NAME = id

						IF @TblNm LIKE '%Task%'
						BEGIN
						SELECT @QryBuilder = 'UPDATE '+@TblNm+' SET IsActive = 0 WHERE KeyFk = '+CONVERT(VARCHAR(20),@DataMasPk)+' AND BranchFk = '+CONVERT(VARCHAR(20),@BrnchFk)+' AND FlowFk = '+CONVERT(VARCHAR(20),@FlowFk)+''
						--SELECT @QryBuilder
						IF ISNULL(@QryBuilder,'') != ''
							EXEC(@QryBuilder)
						END
						SELECT @QryBuilder=''
						SELECT @QryBuilder = 'INSERT INTO '+ @TblNm +'(HisPk,BranchFk,KeyFk,FlowFk, '+ LEFT(@ColNm,(LEN(@ColNm)-1))+ ') SELECT '+ CONVERT(VARCHAR(20),@HisPk) + ','+ CONVERT(VARCHAR(20),@BrnchFk) + ',' + CONVERT(VARCHAR(20),@DataMasPk) +','+CONVERT(VARCHAR(20),@FlowFk) +','+ LEFT(@Val,(LEN(@Val)-1))
						
						IF ISNULL(@QryBuilder,'') != ''
							EXEC(@QryBuilder)

						
					-- If Page Returned has specified Target Page. Get ID and Assing to Target ID.
						SELECT	@RtnFlowID = BfwId, @RoundNo =  ISNULL(BexRoundNo,1) FROM BpmExec(NOLOCK) 
						JOIN	BpmUIDefn (NOLOCK) ON BudBfwFk = BexRtnBfwFk AND BudDelId = 0
						JOIN	BpmFlow(NOLOCK) ON BfwPk = BudBfwFk AND BfwDelId = 0
						WHERE	BexBvmFk = @FlowFk AND BexKeyFk = @DataMasPk AND BexPk = @HisPk AND BexDelId = 0
					
						IF ISNULL(@RtnFlowID,'') != ''
							SET @TgtFlowID = @RtnFlowID
					
					-- Get Round No.
						SELECT	@RoundNo = ISNULL(BexRoundNo,1) FROM BpmExec (NOLOCK) 
						WHERE	BexBvmFk = @FlowFk AND BexKeyFk = @DataMasPk AND BexPk = @HisPk AND BexDelId = 0
					
					-- If Forward Data is pushed to back Screen by User.
						IF ISNULL(@RtnOption,0) = 2  -- For Returning to Current Screen
							SELECT @RtnBfwFk = @CurBfwFk
						ELSE IF ISNULL(@RtnOption,0) = 1 -- For Normal Work Flow
							SELECT @RtnBfwFk = NULL , @RoundNo = @RoundNo + 1;
						ELSE
							SET @RtnBfwFk = NULL
							
					-- Get the Current Page Sequence Id.
						IF ISNULL(@CurSeqFk,0) = 0 -- SeqId Value is Not null, When Proc is called from Conditional Process.
							BEGIN
								SELECT @CurSeqFk = BexBioFk FROM BpmExec(NOLOCK) WHERE BexPk = @HisPk ANd BexDelId = 0
							END
																
					-- Get the Target Page Flow Id and SubProcess Id if Exists.
						IF ISNULL(@TgtFlowID,'') = '' -- Target Flow ID is Not null, When Sent from Decision Page or Return From User. 
							SELECT	@TgtFlowDtlFk = BioTrgFk , @SubProcsFk = BioSubBfwFk
							FROM	#SeqFlowDtls (NOLOCK)
							WHERE	BioRef = @CurSeqFk
						ELSE
							BEGIN
								SELECT	@TgtFlowDtlFk = BioBfwFk, @SubProcsFk = BioSubBfwFk , 
										@ElemType = dbo.gefgGetProcType(BioTrgFk)
								FROM	#SeqFlowDtls (NOLOCK) 
								WHERE	BioId = @TgtFlowID
								
								IF ISNULL(@RtnOption,0) = 0 AND ISNULL(@RtnFlowID,'') = ''
								BEGIN
									DELETE FROM @DecSeq

									INSERT INTO @DecSeq
									SELECT	BioRef, CASE WHEN A.BioTrgFk = @TgtFlowDtlFk THEN 1 ELSE 0 END , BexPk
									FROM	#SeqFlowDtls A (NOLOCK)
									JOIN	BpmExec(NOLOCK) ON BexBvmFk = @Flowfk AND BexKeyFk = @DataMasPk  AND BexRoundNo = @RoundNo
									AND		BioRef = BexBioFk AND BexDelId = 0
									WHERE	EXISTS
									(
										SELECT 'X' FROM #SeqFlowDtls B (NOLOCK) WHERE B.BioRef = @CurSeqFk 
										AND B.BioBfwFk = A.BioBfwFk
									)
									AND NOT EXISTS(SELECT 'X' FROM BpmExecStatus(NOLOCK) WHERE BesBexFk = BexPk AND BesDelid = 0)
									
									SELECT	@CurSeqFk = BioPk FROM @DecSeq WHERE IsValid = 1									
									
									DELETE FROM BpmExec WHERE EXISTS(SELECT 'X' FROM @DecSeq WHERE BexPk = HisPk)
									
									INSERT INTO BpmExec
									(
										BexKeyFk,BexBioFk,BexAutoPass,BexRtnBfwFk,BexRoundNo,BexBvmFk,BexUsrFk,BexBrnchFk,BexDpdFk,
										BexRowId,BexCreatedBy,BexCreatedDt,BexDelFlg,BexDelId, BexIsRej
									)
									SELECT @DataMasPk,@CurSeqFk,0,@RtnBfwFk,@RoundNo,@FlowFk,@UsrPk,@BrnchFk,NULL,
										   @RowId,@UsrNm,@CurDt,NULL,0, @IsRej
									
									SELECT	@HisPk = SCOPE_IDENTITY()
								 END
							END
								
					-- Get Element Type of the Target Flow.
						SELECT @ElemType = '';
						SELECT @ElemType =  dbo.gefgGetProcType(@TgtFlowDtlFk)
						SET @IsSubPc = 0;
					
					
					-- Target Element is Empty only when it is an End Event.
						IF ISNULL(@ElemType,'') = ''
							BEGIN
								-- If SubProcess End Event reaches redirect to Parent Process.
								IF ISNULL(@TgtFlowDtlFk,0) = 0 AND ISNULL(@SubProcsFk,0) <> 0
									BEGIN
										SELECT	@TgtFlowDtlFk = BioTrgFk,
												@ElemType = dbo.gefgGetProcType(BioTrgFk)
										FROM	#SeqFlowDtls (NOLOCK)
										WHERE	BioBfwFk = @SubProcsFk
										
										SET @SubProcsFk = NULL;
									END
								ELSE
									BEGIN
										RAISERROR('End of the Flow, Cannot Proceed!',16,1)
										RETURN
									END
							END
						
					--Check for SubProcess End Loop, (if Next Seq is SubProcess End, Next Seq Flow will be Obtained from this Loop).Continue till SubProc Ends
						-- Loop Executes when Page does not exists for End Event
						IF @ElemType = 'bpmn:endevent'
							BEGIN
								SET @IsSubPc = 1;
								WHILE @IsSubPc = 1
									BEGIN
										IF @ElemType = 'bpmn:endevent' AND ISNULL(@TgtFlowDtlFk,0) <> 0 AND ISNULL(@SubProcsFk,0) <> 0
											BEGIN
												SELECT	@TgtFlowDtlFk = BioOutId, @SubProcsFk = BioSubBfwFk, @ElemType = dbo.gefgGetProcType(BioTrgFk)
												FROM	#SeqFlowDtls (NOLOCK) 
												WHERE	BioBfwFk = @SubProcsFk
												
											END
										
										IF EXISTS
										(
											SELECT	'X' FROM #SeqFlowDtls (NOLOCK) 
											JOIN	BpmToolBox (NOLOCK) ON BtbPk = BioBtbFk AND LOWER(BtbToolNm) = 'bpmn:endevent'
											WHERE	BioBfwFk = @TgtFlowDtlFk 
											AND		ISNULL(BioSubBfwFk,0) <> 0
										)
											SET @IsSubPc = 1
										ELSE
											SET @IsSubPc = 0
									END
							END	
							
					--Check for SubProcess Loop, (if Next Seq is SubProcess , Next Seq Flow will be Obtained from this Loop). Continue till SubProc Ends
						IF @ElemType = 'bpmn:subprocess'
						BEGIN
							SET @IsSubPc = 1;
							WHILE @IsSubPc = 1
								BEGIN
									SET @DestFk = 0;
									
									IF @ElemType = 'bpmn:subprocess'
									BEGIN
										
										SET @DestFk = @TgtFlowDtlFk;
										
										-- Start Event Sequence
											SELECT  @TgtFlowDtlFk = BioTrgFk,  @ElemType = dbo.gefgGetProcType(BioTrgFk)
											FROM	#SeqFlowDtls(NOLOCK) 
											JOIN	BpmToolBox (NOLOCK) ON BtbPk = BioBtbFk AND LOWER(BtbToolNm) = 'bpmn:startevent'
											WHERE	BioSubBfwFk = @TgtFlowDtlFk
											
											SELECT	@TgtSeqFk = BioRef 
											FROM	#SeqFlowDtls(NOLOCK)
											WHERE	BioInFk = @DestFk 
											AND		BioBfwFk = @TgtFlowDtlFk
									END
									
									IF EXISTS
									(
										SELECT 'X' FROM #SeqFlowDtls (NOLOCK) WHERE BioSubBfwFk = @TgtFlowDtlFk 
									)
										SET @IsSubPc = 1
									ELSE
										SET @IsSubPc = 0
								END
						END

					-- Based on Target Flow , get Current Sequence.
					IF ISNULL(@TgtSeqFk,0) = 0 
						BEGIN
						-- Get Current Sequence	
							SELECT	@TgtSeqFk = BioRef 
							FROM	#SeqFlowDtls (NOLOCK)
							WHERE	BioBfwFk = @TgtFlowDtlFk
							AND		ISNULL(NULLIF(BioSubBfwFk,0),0) = ISNULL(NULLIF(@SubProcsFk,0),ISNULL(NULLIF(BioSubBfwFk,0),0)) 
						END

					IF ISNULL(@TgtSeqFk,0) = 0
						BEGIN
							RAISERROR('No Sequence Data to Insert!',16,1)
							RETURN
						END
					
					-- If Forward Data is pushed back to Screen by User.
					IF ISNULL(@RtnOption,0) = 1
						BEGIN
							--RAISERROR('Wait',16,1)
							--RETURN

							DELETE FROM #BetweenNodes

							SELECT	@PrevFlowFk = BioInFk FROM #SeqFlowDtls(NOLOCK) WHERE BioRef = @TgtSeqFk
							
							SELECT	@PrevPrtStg = TreeStg, @PrevPrtTreeId = TreeId
							FROM	#SeqFlowDtls(NOLOCK)
							WHERE	BioBfwFk = @PrevFlowFk AND BioTrgFk = @TgtFlowDtlFk
													
							SELECT	@CurPrtStg = TreeStg, @CurPrtTreeId = TreeId, @CurSerNo = SNo
							FROM	#SeqFlowDtls(NOLOCK)
							WHERE	BioRef = @CurSeqFk
							
							SELECT	@TrgPrtStg = TreeStg, @TgtPrtTreeId = TreeId, @TrgSerNo = SNo
							FROM	#SeqFlowDtls(NOLOCK)
							WHERE	BioRef = @TgtSeqFk
							
							IF ISNULL(@TgtPrtTreeId,'') = ''
								BEGIN
									RAISERROR('%s',16,1,'TreedID is not Generated!')
									RETURN
								END
							
							IF LEN(@CurPrtTreeId) > 3 -- If Source is Parallel
								BEGIN
									-- Target is Task
									IF LEN(@TgtPrtTreeId) = 3
										SET @IsFromTo = 1
									-- Target is to Same Parallel and also Siblings
									ELSE IF LEN(@TgtPrtTreeId) > 3 AND ISNULL(@CurPrtStg,0) = ISNULL(@TrgPrtStg,0) AND
											LEFT(@CurPrtTreeId,(LEN(@CurPrtTreeId)-3)) = LEFT(@TgtPrtTreeId,(LEN(@TgtPrtTreeId)-3))
										SET @IsFromTo = 2
									-- Target is to Same Parallel and but not Siblings
									ELSE IF LEN(@TgtPrtTreeId) > 3 AND ISNULL(@CurPrtStg,0) = ISNULL(@TrgPrtStg,0) AND
											LEFT(@CurPrtTreeId,(LEN(@CurPrtTreeId)-3)) <> LEFT(@TgtPrtTreeId,(LEN(@TgtPrtTreeId)-3))
										SET @IsFromTo = 3	
									-- Target is to Different Parallel
									ELSE IF LEN(@TgtPrtTreeId) > 3 AND ISNULL(@CurPrtStg,0) <> ISNULL(@TrgPrtStg,0)		
										SET @IsFromTo = 3															
								END
							ELSE	-- If Source is Task
								BEGIN
									IF LEN(@TgtPrtTreeId) > 3
										SET @IsFromTo = 3
								END

							IF @IsFromTo = 3
								BEGIN
									INSERT INTO #BetweenNodes
									SELECT	BioRef, TreeStg,TreeId 
									FROM	#SeqFlowDtls
									WHERE	TreeId LIKE @PrevPrtTreeId + '%' OR TreeStg > @PrevPrtStg
								END
							ELSE IF @IsFromTo = 2
								BEGIN
									INSERT INTO #BetweenNodes
									SELECT	BioRef,TreeStg,TreeId 
									FROM	#SeqFlowDtls
									WHERE	SNo <= @CurSerNo AND SNo >= @TrgSerNo
								END
							ELSE IF @IsFromTo IN(0,1)
								BEGIN
									INSERT INTO #BetweenNodes
									SELECT	BioRef,TreeStg,TreeId 
									FROM	#SeqFlowDtls
									WHERE	TreeStg > @TrgPrtStg
								END
							
							UPDATE	BpmExec
							SET		BexRoundNo = @RoundNo
							WHERE	BexBvmFk = @FlowFk AND BexKeyFk = @DataMasPk 
							AND		BexRoundNo = (@RoundNo-1) AND BexDelId = 0
							AND		NOT EXISTS(SELECT 'X' FROM #BetweenNodes WHERE BioFk = BexBioFk)
							
							UPDATE	BpmExecStatus
							SET		BesRoundNo = @RoundNo
							WHERE	BesBvmFk = @FlowFk AND BesKeyFk = @DataMasPk 
							AND		BesRoundNo = (@RoundNo-1) AND BesDelId = 0
							AND		NOT EXISTS(SELECT 'X' FROM #BetweenNodes WHERE BioFk = BesBioFk)

							IF @IsFromTo NOT IN (0,2)
								BEGIN
									INSERT INTO BpmExecStatus
									(
										BesBexFk,BesKeyFk,BesBioFk,BesAutoPass,BesRtnBfwFk,BesRoundNo,
										BesSysEntry,BesBvmFk, BesBrnchFk,BesDpdFk,BesUsrFk,BesRowId,BesCreatedBy,BesCreatedDt,BesDelFlg,BesDelId, BesIsRej
									)
									SELECT	BexPk,BexKeyFk,BexBioFk,BexAutoPass,BexRtnBfwFk,BexRoundNo,1,BexBvmFk,BexBrnchFk,BexDpdFk,@UsrPk,
											@RowId,@UsrNm,@CurDt,NULL,0, @IsRej
									FROM	BpmExec (NOLOCK)
									WHERE	BexPk <> @HisPk AND BexBvmFk = @FlowFk AND BexKeyFk = @DataMasPk 
									AND		BexDelId = 0
									AND	EXISTS(SELECT 'X' FROM #BetweenNodes WHERE BioFk = BexBioFk)
									AND NOT EXISTS(SELECT 'X' FROM BpmExecStatus (NOLOCK) WHERE BesBexFk = BexPk AND BesDelId = 0)
								END
						END

						IF @ElemType = 'bpmn:terminateeventdefinition'
							BEGIN
								INSERT	INTO BpmExecStatus
								(
									BesBexFk,BesKeyFk,BesBioFk,BesAutoPass,BesRtnBfwFk,BesRoundNo,BesSysEntry,
									BesBvmFk,BesUsrFk,BesBrnchFk,BesDpdFk,
									BesRowId,BesCreatedBy,BesCreatedDt,BesDelFlg,BesDelId, BesIsRej
								)
								SELECT	BexPk,BexKeyFk,BexBioFk,BexAutoPass,BexRtnBfwFk,BexRoundNo,1,BexBvmFk,@UsrPk,BexBrnchFk,BexDpdFk,
										@RowId,@UsrNm,@CurDt,NULL,0,@IsRej
								FROM	BpmExec (NOLOCK)
								WHERE	BexBvmFk = @FlowFk AND BexKeyFk = @DataMasPk AND BexDelId = 0
								AND		NOT EXISTS(SELECT 'X' FROM BpmExecStatus(NOLOCK) WHERE BesBexFk = BexPk AND BesDelid = 0)
								
								INSERT INTO BpmExec
								(
									BexKeyFk,BexBioFk,BexAutoPass,BexRtnBfwFk,BexRoundNo,
									BexBvmFk,BexUsrFk,BexBrnchFk,BexDpdFk,BexRowId,BexCreatedBy,BexCreatedDt,BexDelFlg,BexDelId, BexIsRej
								)
								SELECT	@DataMasPk,@TgtSeqFk,1,@RtnBfwFk,@RoundNo,@FlowFk,@UsrPk,@BrnchFk,@KeyDpdFk,
										@RowId,@UsrNm,@CurDt,NULL,0, @IsRej
								
								SET @HisPk = SCOPE_IDENTITY()
								SET @InsertNext = 1;
							END	
					-- If Type is Parallel or Decsion Seq Ending.
						ELSE IF @ElemType = 'bpmn:callactivity' OR @ElemType = 'bpmn:manualtask'
							BEGIN 
									SELECT @FinishedCount = 0, @InCount = 0;
									
								-- CallActivity - All Should be completed , ManualTask - Any one.
								-- Insert Completed Seq Flow to Finished History Table
									INSERT	INTO BpmExecStatus
									(
										BesBexFk,BesKeyFk,BesBioFk,BesAutoPass,BesRtnBfwFk,BesRoundNo,BesBvmFk,BesUsrFk,BesBrnchFk,BesDpdFk,
										BesRowId,BesCreatedBy,BesCreatedDt,BesDelFlg,BesDelId, BesIsRej
									)
									--OUTPUT INSERTED.*
									SELECT	BexPk,BexKeyFk,BexBioFk,BexAutoPass,BexRtnBfwFk,BexRoundNo,BexBvmFk,@UsrPk,BexBrnchFk,BexDpdFk,
											@RowId,@UsrNm,@CurDt,NULL,0, @IsRej
									FROM	BpmExec (NOLOCK)
									WHERE	BexKeyFk = @DataMasPk AND BexPk = @HisPk AND BexDelId = 0
									
								-- Get All Source Points.
									SELECT	BioRef
									INTO	#InPks
									FROM	#SeqFlowDtls (NOLOCK)
									WHERE	BioBfwFk = @TgtFlowDtlFk
									
									SELECT  @InCount = COUNT(*) FROM #InPks

									INSERT INTO @CompletedDtls
									SELECT	BesBioFk 'BioFk'
									FROM	BpmExecStatus (NOLOCK) 
									JOIN	#SeqFlowDtls ON BioTrgFk = @TgtFlowDtlFk AND BesBioFk = BioRef 
									AND		BesBvmFk = @FlowFk AND BesKeyFk = @DataMasPk AND BesRoundNo = @RoundNo
									GROUP BY BesKeyFk,BesBioFk
									
								-- Get All Data Posted Entries.							
									SELECT	@FinishedCount = COUNT(*)
									FROM	@CompletedDtls

								-- If the Type is Decision, either 1 Process should be completed to Proceed.
									IF @FinishedCount > 0 AND @ElemType = 'bpmn:manualtask'
										SET @InCount = @FinishedCount

								-- If Incount Matches Finished Count
									IF(@InCount = @FinishedCount)
									BEGIN
										IF ISNULL(@KeyDpdFk,0) = 0
											BEGIN
												SELECT	@KeyDpdFk = MAX(ISNULL(BexDpdFk,0))
												FROM	#SeqFlowDtls(NOLOCK) 
												JOIN	BpmExec(NOLOCK) ON BexKeyFk = @DataMasPk AND BexRoundNo = @RoundNo 
												AND		BexBioFk = BioRef AND ISNULL(BexDpdFk,0) > 0 AND BexDelid = 0
												WHERE	BioTrgFk = @TgtFlowDtlFk
											END
											
										INSERT INTO BpmExec
										(
											BexKeyFk,BexBioFk,BexAutoPass,BexRtnBfwFk,BexRoundNo,BexBvmFk,BexUsrFk,BexBrnchFk,BexDpdFk,
											BexRowId,BexCreatedBy,BexCreatedDt,BexDelFlg,BexDelId, BexIsRej
										)
										VALUES
										(
											@DataMasPk,@TgtSeqFk,1,@RtnBfwFk,@RoundNo,@FlowFk,@UsrPk,@BrnchFk,@KeyDpdFk,
											@RowId,@UsrNm,@CurDt,NULL,0, @IsRej
										);
										
										SELECT @HisPk = SCOPE_IDENTITY()
										
										-- Procedure Executes until completion of Further Conditional Process.
											EXEC PrcBpmArvNextSeq 'FORWARD_DATA', @UsrPk, @FlowFk, @DataMasPk, @HisPk, NULL, @TgtSeqFk , NULL, 1 , 0, NULL, @BrnchFk, @KeyDpdFk
									END
							END						
					-- If the Type is Parallel
						ELSE IF @ElemType = 'bpmn:parallelgateway' 
							BEGIN 
							--RETURN
								DELETE FROM @TempParellelDestination

									INSERT INTO #ParallelDpdRef
									SELECT CONVERT(BIGINT,items) FROM dbo.split(@KeyDpdFk,'~','T')
																
								-- Get All Destinations from this Parallel Gateway. (98 - Messsage Flow)
									INSERT INTO @TempParellelDestination(SbfdFk, SbsdFk, ElmId, ElmFlg, DpdFk, DstTyp, RowId)
									SELECT	BioBfwFk,BioRef, BioId, 0, 0,
											dbo.gefgGetProcType(BioBfwFk), DENSE_RANK() OVER(PARTITION BY BioBfwFk ORDER BY BioRef)
									FROM	#SeqFlowDtls A (NOLOCK)
									WHERE	dbo.gefgGetProcType(BioBfwFk) NOT IN ('bpmn:manualtask','bpmn:callactivity')
									AND EXISTS
									(
										SELECT 'X' FROM #SeqFlowDtls B(NOLOCK) 
										WHERE	B.BioBfwFk = @TgtFlowDtlFk AND B.BioTrgFk = A.BioBfwFk 
										AND		A.BioInFk = B.BioBfwFk
									) 

									SELECT @SanCnt = COUNT('X') FROM #ParallelDpdRef 
									-- For 2 Sanction Generation Flow.
									IF ISNULL(@SanCnt,0) > 1
										UPDATE @TempParellelDestination SET DpdFk = KeyDpdFk FROM #ParallelDpdRef WHERE SNo = RowNo 
									ELSE
										UPDATE @TempParellelDestination SET DpdFk = @KeyDpdFk
									
								-- Insert Completed Seq Flow to Finished History Table
									INSERT	INTO BpmExecStatus
									(
										BesBexFk,BesKeyFk,BesBioFk,BesAutoPass,BesRtnBfwFk,BesRoundNo,BesBvmFk,BesUsrFk,BesBrnchFk,BesDpdFk,
										BesRowId,BesCreatedBy,BesCreatedDt,BesDelFlg,BesDelId, BesIsRej
									)
									SELECT	BexPk,BexKeyFk,BexBioFk,BexAutoPass,BexRtnBfwFk,BexRoundNo,BexBvmFk,@UsrPk,	BexBrnchFk,BexDpdFk,
											@RowId,@UsrNm,@CurDt,NULL,0, @IsRej
									FROM	BpmExec (NOLOCK)
									WHERE	BexBvmFk = @FlowFk AND BexKeyFk = @DataMasPk AND BexPk = @HisPk AND BexDelId = 0
									
								-- Insert All Destination Flows in History Table to Forward Data
									INSERT INTO BpmExec
									(
										BexKeyFk,BexBioFk,BexAutoPass,BexRtnBfwFk,BexRoundNo,BexBvmFk,BexUsrFk,BexBrnchFk,BexDpdFk,
										BexRowId,BexCreatedBy,BexCreatedDt,BexDelFlg,BexDelId, BexIsRej
									)
									OUTPUT	INSERTED.BexPk, INSERTED.BexBioFk, INSERTED.BexBrnchFk INTO @HisDtls
									SELECT	@DataMasPk,SbsdFk,CASE RowId WHEN 1 THEN 0 ELSE 1 END,
											@RtnBfwFk,@RoundNo,@FlowFk,@UsrPk,@BrnchFk,DpdFk,
											@RowId,@UsrNm,@CurDt,NULL,0, @IsRej
									FROM	@TempParellelDestination

									IF EXISTS(SELECT 'X' FROM @HisDtls)
										SET @InsertNext = 1;
									
								-- Insert Call Activity or Manual Tasks
									INSERT INTO @TempParellelDestination(SbfdFk, SbsdFk, ElmId, ElmFlg, DpdFk, DstTyp, RowId)
									SELECT	BioBfwFk, BioRef, BioId, 1, 0, '', 1
									FROM	#SeqFlowDtls (NOLOCK) 
									WHERE	BioBfwFk = @TgtFlowDtlFk 
									AND		dbo.gefgGetProcType(BioTrgFk) IN ('bpmn:manualtask','bpmn:callactivity')
																	
								IF EXISTS(SELECT 'X' FROM @TempParellelDestination WHERE ElmFlg = 1)
									BEGIN
										SELECT @MinFk = 0, @MaxFk = 0;
										
										SELECT @MinFk = MIN(SbsdFk), @MaxFk = MAX(SbsdFk) FROM @TempParellelDestination WHERE ElmFlg = 1
										
										WHILE @MinFk <= @MaxFk
											BEGIN
												SET @TgtSeqFk = 0;
												
												SELECT @ElmId = ElmId, @TgtSeqFk = SbsdFk FROM @TempParellelDestination WHERE SbsdFk = @MinFk
												
												INSERT INTO BpmExec
												(
													BexKeyFk,BexBioFk,BexAutoPass,BexRtnBfwFk,BexRoundNo,
													BexBvmFk,BexUsrFk,BexBrnchFk,BexDpdFk,BexRowId,BexCreatedBy,BexCreatedDt,BexDelFlg,BexDelId, BexIsRej
												)
												SELECT	@DataMasPk,@TgtSeqFk,1,@RtnBfwFk,@RoundNo,@FlowFk,@UsrPk,@BrnchFk,@KeyDpdFk,
														@RowId,@UsrNm,@CurDt,NULL,0,@IsRej

												SELECT @HisPk = SCOPE_IDENTITY()
												
												-- Procedure Executes until completion of Further Conditional Process.
													EXEC PrcBpmArvNextSeq 'FORWARD_DATA', @UsrPk, @FlowFk, @DataMasPk, @HisPk, NULL, @TgtSeqFk , NULL, 1 , 0, NULL, @BrnchFk, @KeyDpdFk
												
												SELECT @MinFk = MIN(SbsdFk) FROM @TempParellelDestination WHERE SbsdFk > @MinFk AND ElmFlg = 1
											END
									END
							END
					-- If the Type is Not Parallel			
						ELSE
							BEGIN 

								-- Get Page Details of the Current Sequence.	
									SELECT	BudBfwFk 'PageSbfdFk',BudPk 'PagePk',BudDesignData 'PageJson',
											BudDesignTyp 'PageType',BudURL 'PageUrl',ISNULL(BudDecIsAuto,0) 'IsAuto', 
											ISNULL(BudDecExp,'') 'PageExp',ISNULL(BudScript,'') 'PageScript',BudIsRtnNeed 'IsRtnNeed'
									INTO #TempPageMas
									FROM BpmUIDefn(NOLOCK) 				
									WHERE BudBfwFk = @TgtFlowDtlFk AND BudDelId = 0
								
								-- If the Page is Decision
									IF EXISTS(SELECT NULL FROM #TempPageMas WHERE PageType = 2)
										BEGIN
											SELECT	@IsAuto = IsAuto 
											FROM	#TempPageMas
															
											-- Insert Completed Seq Flow to Finished History Table
												INSERT	INTO BpmExecStatus
												(
													BesBexFk,BesKeyFk,BesBioFk,BesAutoPass,BesRtnBfwFk,BesRoundNo,
													BesBvmFk,BesUsrFk,BesBrnchFk,BesDpdFk,BesRowId,BesCreatedBy,BesCreatedDt,BesDelFlg,BesDelId, BesIsRej
												)
												SELECT	BexPk,BexKeyFk,BexBioFk,BexAutoPass,BexRtnBfwFk,@RoundNo,BexBvmFk,@UsrPk,BexBrnchFk,BexDpdFk,
														@RowId,@UsrNm,@CurDt,NULL,0, @IsRej
												FROM	BpmExec (NOLOCK)
												WHERE	BexBvmFk = @FlowFk AND BexKeyFk = @DataMasPk AND BexPk = @HisPk AND BexDelId = 0

												DELETE FROM @DecSeq
												INSERT INTO @DecSeq(BioPk , IsValid)
												SELECT	BioRef, ROW_NUMBER() OVER(ORDER BY BioRef)
												FROM	#SeqFlowDtls (NOLOCK)
												WHERE	BioBfwFk = @TgtFlowDtlFk
												AND		ISNULL(NULLIF(BioSubBfwFk,0),0) = ISNULL(NULLIF(@SubProcsFk,0),ISNULL(NULLIF(BioSubBfwFk,0),0)) 
													
												-- History Table Insertion for Target	
													INSERT INTO BpmExec
													(
														BexKeyFk,BexBioFk,BexRtnBfwFk,BexRoundNo,
														BexBvmFk,BexUsrFk,BexBrnchFk,BexDpdFk,BexAutoPass,BexRowId,BexCreatedBy,
														BexCreatedDt,BexDelFlg,BexDelId, BexIsRej
													)
													SELECT	@DataMasPk, BioPk, @RtnBfwFk, @RoundNo,@FlowFk,@UsrPk, @BrnchFk,NULL,
															CASE ISNULL(IsValid,0) WHEN 1 THEN 0 ELSE 1 END ,
															@RowId,@UsrNm,@CurDt,NULL,0, @IsRej
													FROM	@DecSeq
												
										END
								-- If Page is Normal Task
									ELSE
										BEGIN
											-- Insert Completed Seq Flow to Finished History Table
												INSERT	INTO BpmExecStatus
												(
													BesBexFk,BesKeyFk,BesBioFk,BesAutoPass,
													BesRtnBfwFk,BesRoundNo,BesBvmFk,BesUsrFk,BesBrnchFk,BesDpdFk,
													BesRowId,BesCreatedBy,BesCreatedDt,BesDelFlg,BesDelId, BesIsRej
												)
												SELECT	BexPk,BexKeyFk,BexBioFk,BexAutoPass,BexRtnBfwFk,BexRoundNo,BexBvmFk,@UsrPk,BexBrnchFk,BexDpdFk,
														@RowId,@UsrNm,@CurDt,NULL,0, @IsRej
												FROM	BpmExec (NOLOCK)
												WHERE	BexBvmFk = @FlowFk AND BexKeyFk = @DataMasPk AND BexPk = @HisPk AND BexDelId = 0
												
											-- If the Page is Normal Task
												INSERT INTO BpmExec
												(
													BexKeyFk,BexBioFk,BexRtnBfwFk,BexRoundNo,BexBvmFk,BexUsrFk,BexBrnchFk,BexDpdFk,
													BexRowId,BexCreatedBy,BexCreatedDt,BexDelFlg,BexDelId, BexIsRej
												)
												VALUES(@DataMasPk,@TgtSeqFk,@RtnBfwFk,@RoundNo,@FlowFk,@UsrPk,@BrnchFk,@KeyDpdFk,
														@RowId,@UsrNm,@CurDt,NULL,0, @IsRej);
												
												SET @HisPk = SCOPE_IDENTITY()
												SET @InsertNext = 1;
										END
							END
						
						IF ISNULL(@InsertNext,0) = 1
							BEGIN

								TRUNCATE TABLE #TempRights_RolePages_Next
								TRUNCATE TABLE #TempRights_Geo_Next

								SELECT	@LstInsertPg = ISNULL(BudCd,BfwLabel)
								FROM	#SeqFlowDtls (NOLOCK)
								JOIN	BpmFlow (NOLOCK) ON BfwPk = BioBfwFk AND BfwDelid = 0
								JOIN	BpmUIDefn (NOLOCK) ON BudBfwFk = BioBfwFk AND BudDelid = 0
								WHERE	BioRef = @CurSeqFk

								IF NOT EXISTS(SELECT 'X' FROM @HisDtls)
									BEGIN
										SELECT	@CurSeqFk = BexBioFk, @BrnchFk = BexBrnchFk 
										FROM	BpmExec(NOLOCK) WHERE BexPk = @HisPk ANd BexDelId = 0
										
										INSERT INTO @HisDtls
										SELECT	@HisPk,@CurSeqFk,@BrnchFk
									END
			--SELECT * FROM @HisDtls
			--SELECT * FROM #SeqFlowDtls (NOLOCK) WHERE  dbo.gefgGetToolNm(BioBtbFk) IN ('bpmn:endevent','bpmn:terminateeventdefinition')
								IF EXISTS
								(
									SELECT 'X' FROM @HisDtls WHERE EXISTS
									(
										SELECT 'X' FROM #SeqFlowDtls (NOLOCK) 
										WHERE BexBioFk = BioRef
										AND	  dbo.gefgGetToolNm(BioBtbFk) IN ('bpmn:endevent','bpmn:terminateeventdefinition')
									)
								)
									SET @IsEnd = 1
								
								-- Get the Flow Pages with Roles with the User Filter.			
									INSERT INTO #TempRights_RolePages_Next(SbfdFk,SbsdPk,PagePk,UsrFk)
									SELECT		BioBfwFk,BioRef, BudPk, UrdUsrFk
									FROM		#SeqFlowDtls(NOLOCK)
									JOIN		BpmUIDefn(NOLOCK) ON BudBfwFk = BioBfwFk AND BudDelId = 0
									JOIN		ShflPgRightsDtls (NOLOCK) ON PgrdPgFk = BudPk AND PgrdDelid = 0
									JOIN		GenUsrRoleDtls (NOLOCK) ON PgrdRolFk = UrdRolFk AND UrdDelid = 0
									WHERE		EXISTS(SELECT 'X' FROM @HisDtls WHERE BexBioFk = BioRef) 
									AND			dbo.gefgGetToolNm(BioBtbFk) NOT IN ('bpmn:endevent','bpmn:terminateeventdefinition')
									GROUP BY	BioBfwFk, BioRef, BudPk , UrdUsrFk
						
									IF NOT EXISTS(SELECT 'X' FROM #TempRights_RolePages_Next) AND ISNULL(@IsEnd,0) = 0 
										BEGIN
											RAISERROR('%s',16,1,'Page Rights not Available for Next Task')
											RETURN
										END
										

										SELECT		UbdUsrFk, UbdGeoFk 'GeoFk', GeoLvlNo 'LvlNo'
									FROM		GenUsrBrnDtls(NOLOCK) 
									JOIN		GenGeoMas(NOLOCK) ON GeoPk = UbdGeoFk AND GeoDelid = 0
									WHERE		UbdDelid = 0
									--AND			EXISTS(SELECT 'X' FROM #TempRights_RolePages_Next WHERE UsrFk = UbdUsrFk)
									

								-- Get All the Geo Locations attached to the User
									INSERT INTO #TempRights_Geo_Next(UsrRef,GeoFk,LvlNo)
									SELECT		UbdUsrFk, UbdGeoFk 'GeoFk', GeoLvlNo 'LvlNo'
									FROM		GenUsrBrnDtls(NOLOCK) 
									JOIN		GenGeoMas(NOLOCK) ON GeoPk = UbdGeoFk AND GeoDelid = 0
									WHERE		UbdDelid = 0
									AND			EXISTS(SELECT 'X' FROM #TempRights_RolePages_Next WHERE UsrFk = UbdUsrFk)
									AND			EXISTS
									(
										SELECT	'X' FROM GenGeoMap(NOLOCK) WHERE GemGeoBFk = @BrnchFk
										AND		GeoPk = CASE ISNULL(GeoLvlNo,0) WHEN 1 THEN GemGeoBFk WHEN 2 THEN GemGeoZFk
														WHEN 3 THEN GemGeoSFk WHEN 4 THEN GemGeoCFk END
										AND		GeoDelid = 0
									)
									
									UPDATE		#TempRights_RolePages_Next SET UsrBGeoFk = GeoFk FROM #TempRights_Geo_Next WHERE UsrFk = UsrRef
									DELETE FROM #TempRights_RolePages_Next WHERE ISNULL(UsrBGeoFk,0) = 0
									
									IF ISNULL(@IsEnd,0) = 0
										BEGIN
											SET @ErrMsg = '';
											
											SELECT @ErrMsg = @ErrMsg + dbo.gefgGetDesc(UsrFk,1) + ',' FROM #TempRights_RolePages_Next  
											WHERE  NOT EXISTS(SELECT 'X' FROM #TempRights_Geo_Next WHERE UsrRef = UsrFk)
											GROUP BY UsrFk

											IF ISNULL(@ErrMsg,'') <> ''
												BEGIN
													SELECT @ErrMsg = 'Branch Rights not Available for User(s)  - ' + LEFT(@ErrMsg,LEN(@ErrMsg)-1) + '.';
													RAISERROR('%s',16,1,@ErrMsg)
													RETURN
												END
										END
																																																
								INSERT INTO #DataDtls_Next(PcPk,FlowPk, SbsdFk, PagePk, Pg_status,DataPk,BfwFk,UsrFk,BranchFk)
								SELECT	BexPk, BexBvmFk, SbsdPk, PagePk, @LstInsertPg,
										BexKeyFk,SbfdFk,UsrFk,BexBrnchFk
								FROM	BpmExec (NOLOCK)  
								JOIN	#TempRights_RolePages_Next ON SbsdPk = BexBioFk
								WHERE	EXISTS
								(
									SELECT	'X' FROM @HisDtls 
									WHERE	BexFk = BexPk
									AND		NOT EXISTS(SELECT 'X' FROM BpmExecStatus(NOLOCK) WHERE BesBexFk = BexFk AND BesDelId = 0)
								) AND ISNULL(BexAutoPass,0) = 0 AND BexDelId = 0
								AND		EXISTS(SELECT 'X' FROM #TempRights_Geo_Next WHERE UsrRef = UsrFk)
								
								--ADDED BY VIJAY S for Point 8
								DECLARE @RolPkey BIGINT
								SET @RolPkey = 0
								BEGIN TRY
									SELECT @RolPkey = RolPk FROM GenRole WHERE RolNm = (
										SELECT DISTINCT A.BfwLabel 
										FROM BPMFLOW A 
										JOIN BPMFLOW B 
										ON A.BfwId=B.BfwLaneRef AND B.BfwBtbFk=(
											SELECT BtbPk 
											FROM BpmToolBox 
											WHERE BtbToolNm = 'bpmn:StartEvent'
										) AND A.BfwBvmFk = @FlowFk 
									)																
								END TRY
								BEGIN CATCH
								END CATCH

								IF EXISTS(SELECT 'X' FROM #DataDtls_Next)
									BEGIN
										IF ISNULL(@RtnOption,0) > 0 AND ISNULL(@TgtFlowID,'') <> ''
											BEGIN										
												SELECT		TOP 1 @FilUsrFk = BesUsrFk
												FROM		BpmExecStatus(NOLOCK)
												JOIN		#DataDtls_Next ON BfwFk = @TgtFlowDtlFk AND DataPk = BesKeyFk 
												AND			BesBioFk = SbsdFk AND BesBvmFk = FlowPk
												WHERE		BesDelId = 0
												ORDER BY	BesPk DESC

												INSERT INTO BpmNextOpUsr
												(
													BnoUsrFk,BnoBexFk,BnoBvmFk,BnoBioFk,BnoBudFk,BnoStatus,BnoDataPk,BnoBfwFk,BnoCreatedDt
												)
												OUTPUT INSERTED.BnoBudFk INTO @RightsDtls
												SELECT		UsrFk,PcPk,FlowPk,SbsdFk,PagePk,Pg_status,DataPk,BfwFk,@CurDt
												FROM		#DataDtls_Next
												WHERE		UsrFk = @FilUsrFk
												
												SET @ErrMsg = '';
												
												SELECT @ErrMsg = @ErrMsg + dbo.gefgGetDesc(PagePk,2) + ',' FROM #DataDtls_Next  
												WHERE  NOT EXISTS(SELECT 'X' FROM @RightsDtls WHERE PgFk = PagePk)
												GROUP BY PagePk

												IF ISNULL(@ErrMsg,'') <> ''
													BEGIN
														SELECT @ErrMsg = 'No User Available for Screens - ' + LEFT(@ErrMsg,LEN(@ErrMsg)-1) + '.';
														RAISERROR('%s',16,1,@ErrMsg)
														RETURN
													END
											END
										ELSE IF (@RolPkey = (SELECT UrdRolFk FROM GenUsrRoleDtls WHERE UrdUsrFk = @UsrPk)) AND ISNULL(@ValData,'') = ''
											BEGIN
												INSERT INTO BpmNextOpUsr
												(
													BnoUsrFk,BnoBexFk,BnoBvmFk,BnoBioFk,BnoBudFk,BnoStatus,BnoDataPk,BnoBfwFk,BnoCreatedDt
												)
												OUTPUT INSERTED.BnoBudFk INTO @RightsDtls
												SELECT		UsrFk,PcPk,FlowPk,SbsdFk,PagePk,Pg_status,DataPk,BfwFk,@CurDt
												FROM		#DataDtls_Next
												WHERE		UsrFk = @UsrPk

												SET @ErrMsg = '';
												
												SELECT @ErrMsg = @ErrMsg + dbo.gefgGetDesc(PagePk,2) + ',' FROM #DataDtls_Next  
												WHERE  NOT EXISTS(SELECT 'X' FROM @RightsDtls WHERE PgFk = PagePk)
												GROUP BY PagePk

												IF ISNULL(@ErrMsg,'') <> ''
													BEGIN
														SELECT @ErrMsg = 'No User Available for Screens - ' + LEFT(@ErrMsg,LEN(@ErrMsg)-1) + '.';
														RAISERROR('%s',16,1,@ErrMsg)
														RETURN
													END
											END
										ELSE
											BEGIN
												SET @FilUsrFk = 0;
	
												INSERT INTO @PendingUsrWorks
												SELECT		BnoUsrFk,0,COUNT(BnoUsrFk),0
												FROM		BpmNextOpUsr(NOLOCK)
												WHERE		NOT EXISTS(SELECT 'X' FROM BpmExecStatus(NOLOCK) WHERE BesBexFk = BnoBexFk AND BesDelid = 0)
												AND			NOT EXISTS(SELECT 'X' FROM GenUsrMas(NOLOCK) WHERE UsrNm = 'ADMIN' AND UsrPk = BnoUsrFk AND UsrDelid = 0)
												AND			EXISTS(SELECT 'X' FROM #DataDtls_Next WHERE UsrFk = BnoUsrFk)
												GROUP BY	BnoUsrFk

												INSERT INTO @PendingUsrWorks
												SELECT		UsrFk,0,0,0
												FROM		#DataDtls_Next
												WHERE		NOT EXISTS(SELECT 'X' FROM @PendingUsrWorks WHERE PendUsrFk = UsrFk)
												AND			NOT EXISTS(SELECT 'X' FROM GenUsrMas(NOLOCK) WHERE UsrNm = 'ADMIN' AND UsrPk = UsrFk AND UsrDelid = 0)
												GROUP BY	UsrFk
												
												INSERT INTO @PendingUsrWorks
												SELECT		PendUsrFk,PagePk,ROW_NUMBER() OVER(PARTITION BY PagePk ORDER BY AsgndWork,PendUsrFk), 1
												FROM		@PendingUsrWorks
												JOIN		#DataDtls_Next ON PendUsrFk = UsrFk
	
												INSERT INTO BpmNextOpUsr
												(
													BnoUsrFk,BnoBexFk,BnoBvmFk,BnoBioFk,BnoBudFk,BnoStatus,BnoDataPk,BnoBfwFk,BnoCreatedDt
												)
												OUTPUT INSERTED.BnoBudFk INTO @RightsDtls
												SELECT		UsrFk, PcPk, FlowPk, SbsdFk,PagePk, Pg_status,DataPk,BfwFk,@CurDt
												FROM		#DataDtls_Next 
												WHERE		EXISTS
												(
													SELECT 'X' FROM @PendingUsrWorks 
													WHERE UsrFk = PendUsrFk AND PgRef =  PagePk AND AsgndWork = 1 AND Flg = 1
												)
												
												SET @ErrMsg = '';
												
												SELECT @ErrMsg = @ErrMsg + dbo.gefgGetDesc(PagePk,2) + ',' FROM #DataDtls_Next  
												WHERE  NOT EXISTS(SELECT 'X' FROM @RightsDtls WHERE PgFk = PagePk)
												GROUP BY PagePk

												IF ISNULL(@ErrMsg,'') <> ''
													BEGIN
														SELECT @ErrMsg = 'No User Available for Screens - ' + LEFT(@ErrMsg,LEN(@ErrMsg)-1) + '.';
														RAISERROR('%s',16,1,@ErrMsg)
														RETURN
													END
											END
									END
							END
				END
			/***************************** Post History Data for the Current Seq and Show the Next Screen to the User Ends ****************************************/
			
			/**************************************************** Return Data Info to the User Starts ***************************************************/					
			
			IF @Action = 'GET_ENTRY_STS'
				BEGIN
					SELECT @BrnchNm = GeoNm FROM GenGeoMas(NOLOCK) WHERE GeoPk = @BrnchFk
					IF ISNULL(@CurSeqFk,0) = 0
						BEGIN
							SELECT @CurSeqFk = BexBioFk FROM BpmExec(NOLOCK) WHERE BexPk = @HisPk ANd BexDelId = 0
						END

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
						WHERE	BioBvmFk = @FlowFk AND BioDelid = 0
						
						--SELECT * FROM #AllScrnDtls
						--DELETE FROM #AllScrnDtls WHERE TreeId IN (SELECT MAX(A.TreeId) FROM #AllScrnDtls A GROUP BY A.BioOutBfwFk HAVING COUNT(BioOutBfwFk) > 1)
						
						INSERT INTO #All_His_Datas(FlowFk,BexKeyFk,BexBioFk,BexPk)					
						SELECT	@FlowFk, BexKeyFk, BexBioFk, BexPk
						FROM	BpmExec(NOLOCK) 
						WHERE	BexBvmFk = @FlowFk AND BexKeyFk = @DataMasPk 
						AND		ISNULL(BexAutoPass,0) = 0 AND BexDelId = 0
			
					 -- Get Page Details of History Data.
						SELECT	BudPk 'PagePk', BudDesignData 'PageJson',BudURL 'PageUrl', BudDesignTyp 'PageType', 
								BudBfwFk 'PageSbfdFk', PgNm 'PgNm' ,
								BexPk 'PcPk', BioBvmFk 'SbsdFlowFk', BioId 'FlowId', ISNULL(BudDecIsAuto,0) 'IsAuto', 
								ISNULL(BudDecExp,'') 'PageExp' , ISNULL(BudScript,'') 'PageScript', 
								CASE WHEN LOWER(BtbToolNm) = 'bpmn:startevent' THEN 2 ELSE 0 END 'SbsdProcFlg', BioPk 'SbsdPk',
								BioOutBfwFk 'SbsdDestFk', DestTyp 'DestTyp',
								BudCd 'PgCd',BudIsRtnNeed 'IsRtnNeed', TreeId 'TreeId', BioInBfwFk 'InFk'
						INTO	#FlowPageDtls
						FROM	#All_His_Datas
						JOIN	#AllScrnDtls(NOLOCK) ON BioPk = BexBioFk		
						JOIN	BpmToolBox (NOLOCK) ON BtbPk = BtbFk AND BtbDelid = 0

					-- This Result Set is not returned when called from 'FORWARD_DATA'
						 IF ISNULL(@IsManCal,0) = 0 
							BEGIN
								 -- Return Page Details.
									INSERT INTO #FlowDtls_History
									SELECT	PcPk 'PcPk',PagePk 'PagePk',PageJson 'PageJson',PageUrl 'PageUrl',PageType 'PageType',
											PageSbfdFk 'PageSbfdFk',PgNm 'SbfdProcLabel' ,SbsdFlowFk 'SbsdFlowFk',
											IsAuto 'IsAuto', PageExp 'PageExp',IsRtnNeed 'IsRtnNeed', PageScript 'PageScript', 
											'GEN_' + CAST(@PrcFk AS VARCHAR) + '_' + FtProcID 'TableNm'
									FROM		#FlowPageDtls
									LEFT JOIN	BpmFlowTbl(NOLOCK) ON FtBfwFk = PageSbfdFk AND FtDelid = 0
									WHERE		NOT EXISTS(SELECT 'X' FROM BpmExecStatus(NOLOCK) WHERE BesBexFk = PcPk AND BesDelId = 0)
									AND			PcPk = @HisPk

									IF EXISTS(SELECT 'X' FROM #FlowDtls_History WHERE ISNULL(PageJson,'') <> '' AND ISNULL(TableNm,'') <> '')
										BEGIN
											SELECT @PgJson = PageJson, @TblNm = TableNm  FROM #FlowDtls_History

											INSERT INTO #Tbl_Crt_Tmplt_Tmp(xx_id,label,value)
											EXEC PrcParseJson @PgJson,'label,value'
											
											UPDATE #Tbl_Crt_Tmplt_Tmp SET id = REPLACE(REPLACE(label,' ','_'),'-',''), value = ISNULL(value,'')
										END
										
									SELECT *,@BrnchNm 'Branch_Name' FROM #FlowDtls_History
							END
					
					SET @TgtFlowDtlFk = 0;
					
					-- To Load Decision Datas of Next Screen in Current Screen			
						SELECT @TgtFlowDtlFk = SbsdDestFk FROM #FlowPageDtls WHERE DestTyp = 'bpmn:exclusivegateway'
						AND NOT EXISTS(SELECT 'X' FROM BpmExecStatus(NOLOCK) WHERE  BesBexFk = PcPk AND BesDelId = 0)
						AND	PcPk = @HisPk
					  
						IF ISNULL(@TgtFlowDtlFk,0) = 0
							BEGIN
								SELECT @TgtFlowDtlFk = SbsdDestFk FROM #FlowPageDtls WHERE DestTyp = 'bpmn:parallelgateway'
								AND NOT EXISTS(SELECT 'X' FROM BpmExecStatus(NOLOCK) WHERE  BesBexFk = PcPk AND BesDelId = 0)
								AND	PcPk = @HisPk

								IF ISNULL(@TgtFlowDtlFk,0) > 0
									BEGIN
										INSERT INTO @DestDtls
										SELECT  DISTINCT BioBfwFk
										FROM	BpmObjInOut A (NOLOCK)
										WHERE	dbo.gefgGetProcType(BioBfwFk) IN ('bpmn:exclusivegateway')
										AND EXISTS
										(
											SELECT 'X' FROM BpmObjInOut B(NOLOCK) 
											WHERE	B.BioBfwFk = @TgtFlowDtlFk AND B.BioOutBfwFk = A.BioBfwFk 
											AND		A.BioinBfwFk = B.BioBfwFk
										)
									END
							END
						ELSE
							BEGIN
								INSERT INTO @DestDtls
								SELECT @TgtFlowDtlFk
							END
							
					-- Return Pages List (If Page is already returned , take the Min HisPk to get the Prev Screens).
						DELETE FROM @CrntHis
						
						INSERT INTO @CrntHis (PcFk)
						SELECT	MIN(BesBexFk)
						FROM	BpmExecStatus (NOLOCK)
						JOIN	#FlowPageDtls ON BesBioFk = SbsdPk AND BesBexFk = PcPk
						WHERE	BesBvmFk = @FlowFk AND BesKeyFk = @DataMasPk AND BesBioFk = @CurSeqFk AND BesDelId = 0
						
						--Modified by VIJAY S						
						IF EXISTS(SELECT 'X' FROM @CrntHis WHERE ISNULL(PcFk,0) <> 0)
							BEGIN
							SELECT *,(SELECT BudDesignData FROM BpmUIDefn WHERE BudBfwFk = PageSbfdFk) AS FlowJson FROM 
								(SELECT		PagePk, PageSbfdFk ,PgNm, FlowId
								FROM		#FlowPageDtls
								JOIN		BpmExecStatus(NOLOCK) ON BesBexFk = PcPk AND BesDelId = 0
								JOIN		@CrntHis ON PcFk > BesBexFk
								WHERE		SbsdProcFlg <> 2 AND PageType = 1
								GROUP BY	PagePk, PageSbfdFk ,PgNm, FlowId,TreeId) AS TblX
					----		ORDER BY	TreeId DESC
							END
						ELSE
							BEGIN
							SELECT *,(SELECT BudDesignData FROM BpmUIDefn WHERE BudBfwFk = PageSbfdFk) AS FlowJson FROM 
								(SELECT		PagePk, PageSbfdFk ,PgNm, FlowId
								FROM		#FlowPageDtls
								JOIN		BpmExecStatus(NOLOCK) ON BesBexFk = PcPk AND BesDelId = 0
								WHERE		SbsdProcFlg <> 2 AND PageType = 1
								GROUP BY	PagePk, PageSbfdFk ,PgNm, FlowId,TreeId) AS TblX	
					----		ORDER BY	TreeId DESC								
							END
--SELECT * FROM @DestDtls
					-- Decision Data's
						IF EXISTS(SELECT 'X' FROM @DestDtls)
							BEGIN
								SELECT	BudDesignData 'JsonData', ISNULL(BudDecIsAuto,0) 'IsAuto' 
								FROM	BpmUIDefn(NOLOCK) WHERE EXISTS(SELECT 'X' FROM @DestDtls WHERE BudBfwFk = BfwFk) AND BudDelid = 0
							END
						ELSE
							SELECT '' 'JsonData'

					-- TAT Info
						SELECT		ISNULL(PgCd,BudCd) 'PgCd', ISNULL(dbo.gefggetDesc(UsrFk,1), '') 'UsrNm',
									ISNULL(CONVERT(VARCHAR(20), CrDt, 106),'') 'Dt',
									ISNULL(CONVERT(VARCHAR(15),CAST(CrDt AS TIME),100),'') 'Tim' , 
									ISNULL(Flg,0) 'HisPk'
						FROM		#AllScrnDtls
						LEFT JOIN	
						(
							SELECT		PgCd, ISNULL(BesUsrFk,0) 'UsrFk', ISNULL(BesCreatedDt, BexCreatedDt) 'CrDt', 
										PcPk, PagePk ,CASE ISNULL(BesPk,0) WHEN 0 THEN 1 ELSE 2 END 'Flg', InFk 'InFk'
							FROM		#FlowPageDtls
							JOIN		BpmExec(NOLOCK) ON BexPk = PcPk AND BexDelId = 0
							LEFT JOIN	BpmExecStatus(NOLOCK) ON BesBexFk = BexPk AND BesDelid = 0
						)A ON BudPk = PagePk
						WHERE		BudDesignTyp = 1
						ORDER BY	 ISNULL(CrDt, dbo.gefgChar2Date('01/01/2090')),TreeId

					INSERT INTO #PgHdr
					SELECT		'GEN_' + CONVERT(VARCHAR(20),@PrcFk) + '_' + FtProcId,dbo.gefgGetDesc(PagePk,2) ,FtDataLabel , 
								FtDataField , 
								ROW_NUMBER() OVER(ORDER BY PcPk),
								/*(ORDER BY CASE dbo.gefgGetDesc(PagePk,2) WHEN 'Data Entry' THEN PagePk ELSE PcPk END, 
											CASE dbo.gefgGetDesc(PagePk,2) WHEN 'Data Entry' THEN PcPk END DESC) ),*/
								SbsdProcFlg,
								CASE WHEN FtVerFlowFk = @FlowFk THEN 1 ELSE 0 END, dbo.gefgGetDesc(BnoUsrFk,1), 
								ISNULL(CONVERT(VARCHAR(20), BesCreatedDt, 106),'') + '  ' + ISNULL(CONVERT(VARCHAR(15),CAST(BesCreatedDt AS TIME),100),'') ,
								PcPk, BesIsRej 'AprOrRej'
					FROM		#FlowPageDtls
					JOIN		BpmFlowTbl(NOLOCK) ON FtBfwFk = PageSbfdFk AND FtDelid = 0
					JOIN		BpmNextOpUsr(NOLOCK) ON BnoBexFk = PcPk 
					JOIN		BpmExecStatus(NOLOCK) ON BesBexFk = PcPk AND BesDelid = 0
					ORDER BY	PcPk
					
					--DELETE FROM #PgHdr WHERE BexPk NOT IN (SELECT MAX(BexPk) FROM #PgHdr WHERE PgNm = 'Data Entry') AND PgNm = 'Data Entry'
					
					IF EXISTS(SELECT 'X' FROM #Tbl_Crt_Tmplt_Tmp) AND OBJECT_ID('TEMPDB..#FlowDtls_History') IS NOT NULL
						BEGIN
							SELECT @QryBuilder = '', @ColSelect = '';
							
							SELECT @MinFk = 0, @MaxFk = 0
							
							SELECT	COLUMN_NAME, ROW_NUMBER() OVER(ORDER BY COLUMN_NAME) 'Id' INTO #TblDtls FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @TblNm 
							--AND		COLUMN_NAME NOT IN ('BranchFk', 'KeyFk', 'DataPk' , 'HisPk')
							AND		COLUMN_NAME NOT IN ('BranchFk', 'KeyFk', 'DataPk' , 'HisPk','FlowFk','IsActive','LastModifiedTime')

							SELECT @MinFk = MIN(Id), @MaxFk = MAX(Id) FROM #TblDtls
				
							
							WHILE @MinFk <= @MaxFk
								BEGIN
									SELECT @ColSelect = '';
									SELECT @ColSelect = COLUMN_NAME FROM #TblDtls WHERE id = @MinFk;
									
									
											SELECT	@QryBuilder = @QryBuilder + 'UPDATE #Tbl_Crt_Tmplt_Tmp SET value = ' + @ColSelect + ''
											+ ' FROM #FlowDtls_History , ' + @TblNm + ' WHERE KeyFk =  ' + CAST(@DataMasPk AS VARCHAR) +
											+ ' AND id = ''' + @ColSelect + ''' '
											+ 'AND DataPk IN (SELECT MAX(DataPk) FROM '+ @TblNm +' WHERE KeyFk =  ' + CAST(@DataMasPk AS VARCHAR) + ')'
									
									SELECT @MinFk = MIN(Id) FROM #TblDtls WHERE Id > @MinFk

								END

							IF ISNULL(@QryBuilder,'') <> ''
								BEGIN
									EXEC(@QryBuilder)
									SELECT * FROM #Tbl_Crt_Tmplt_Tmp
								END
							ELSE
								SELECT '' 'Msg'
						END
					ELSE
						SELECT '' 'Msg'
						
					-- Previous Entries posted.
					SELECT @MinFk = 0, @MaxFk = 0
					SELECT @MinFk = MIN(OrdNo), @MaxFk = MAX(OrdNo) FROM #PgHdr
					
					SELECT ISNULL(@MaxFk,0) 'MaxRowCount'
					
					--ADDED BY VIJAY S FOR FILE UPLOAD
					SELECT FileupldNewnm, REPLACE(CONCAT('..', SUBSTRING(FileupldPath, CHARINDEX('\RS\', FileupldPath), LEN(FileupldPath) - CHARINDEX('\RS\', FileupldPath) + 1), FileupldNewnm),'\','/') as FileupldPath, FileupldRemarks FROM FileupldAttachment WHERE FileupldProcFk = @DataMasPk
					
					DECLARE @TempData TABLE(AprOrRej BIGINT, FlowNm VARCHAR(50), PgNm VARCHAR(50), UsrNm VARCHAR(100), ExecDt VARCHAR(100) ,KeyFk BIGINT, DataPk BIGINT, HisPk BIGINT, FlowFk BIGINT,FldLst VARCHAR(MAX))
					DECLARE @UsrRef VARCHAR(100), @DtTime VARCHAR(100), @PcPk BIGINT , @AprOrRej TINYINT,@PgNm VARCHAR(100)
					DECLARE @ColSelect1 VARCHAR(MAX),@ColSelect2 VARCHAR(MAX),@QryBuilder2 VARCHAR(MAX) 
					--WHILE @MinFk <= @MaxFk
					WHILE @MaxFk >= @MinFk
					BEGIN
						SELECT @ColSelect = '' , @TblNm = '' , @IsStrScr = 0, @QryBuilder = '', @ColSelect1 = '',@QryBuilder2='',@ColSelect2=''
						
						SELECT	@TblNm = TblNm, @IsStrScr = IsFlowStrt , @ProcFlg = ProcFlg , @UsrRef = UsrNm, @DtTime = DtTime, 
								@PcPk = BexPk, @AprOrRej = ISNULL(AprOrRej,0),@PgNm = PgNm
						--FROM	#PgHdr WHERE OrdNo = @MinFk 
						FROM	#PgHdr WHERE OrdNo = @MaxFk 

						SELECT	@ColSelect = @ColSelect +'ISNULL('+ COLUMN_NAME + ','''')'+COLUMN_NAME+',' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @TblNm 
						--AND		COLUMN_NAME NOT IN ('BranchFk', 'KeyFk', 'DataPk' , 'HisPk')
						AND		COLUMN_NAME NOT IN ('BranchFk', 'KeyFk', 'DataPk' , 'HisPk','FlowFk','IsActive','LastModifiedTime')
						
						SELECT	@ColSelect1 = @ColSelect1 + COLUMN_NAME + ',' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @TblNm 
						AND		COLUMN_NAME NOT IN ('BranchFk', 'KeyFk', 'DataPk' , 'HisPk','FlowFk','IsActive','LastModifiedTime')
						
						SELECT	@ColSelect2 = @ColSelect2 + COLUMN_NAME + ',' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @TblNm 
						AND		COLUMN_NAME IN ('KeyFk','DataPk' , 'HisPk','FlowFk')

						SELECT @FlowNm = BpmNm FROM BpmVersions(NOLOCK), BpmMas(NOLOCK) WHERE BvmBpmFk = BpmPk AND BvmPk = @FlowFk AND BvmDelid = 0
						
						IF @IsStrScr = 1 AND @ProcFlg = 2
							BEGIN
								SELECT @QryBuilder = 'SELECT ''' + CAST(@AprOrRej AS VARCHAR(1)) + ''' [AprOrRej],''' + ISNULL(@FlowNm,'') + ''' [FlowNm],''' + ISNULL(@PgNm,'') + ''' PgNm,''' + ISNULL(@UsrRef,'') + ''' [User],''' + ISNULL(@DtTime,'') + ''' [ExecDt],' + LEFT(@ColSelect,(LEN(@ColSelect)-1)) 
								+ '  ,''' + LEFT(@ColSelect1,(LEN(@ColSelect1)-1))  + ''' FldLst '
								+ ' FROM ' + @TblNm + ' WHERE DataPk = ' + CONVERT(VARCHAR(20),@DataMasPk) + ' AND HisPk = ' + CONVERT(VARCHAR(20),@PcPk)

								SELECT @QryBuilder2 = 'SELECT ''' + CAST(@AprOrRej AS VARCHAR(1)) + ''' [AprOrRej],''' + ISNULL(@FlowNm,'') + ''' [FlowNm],''' + ISNULL(@PgNm,'') + ''' PgNm,''' + ISNULL(@UsrRef,'') + ''' [User],''' + ISNULL(@DtTime,'') + ''' [ExecDt],' + LEFT(@ColSelect2,(LEN(@ColSelect2)-1)) 
								+ '  ,''' + LEFT(@ColSelect2,(LEN(@ColSelect2)-1))  + ''' FldLst '
								+ ' FROM ' + @TblNm + ' WHERE DataPk = ' + CONVERT(VARCHAR(20),@DataMasPk) + ' AND HisPk = ' + CONVERT(VARCHAR(20),@PcPk)
							END
						ELSE
							BEGIN
								SELECT @QryBuilder = 'SELECT ''' + CAST(@AprOrRej AS VARCHAR(1)) + ''' [AprOrRej],''' + ISNULL(@FlowNm,'') + ''' [FlowNm],''' + ISNULL(@PgNm,'') + ''' PgNm,''' + ISNULL(@UsrRef,'') + ''' [User],''' + ISNULL(@DtTime,'') + ''' [ExecDt],'  + LEFT(@ColSelect,(LEN(@ColSelect)-1)) 
								+ '  ,''' + LEFT(@ColSelect1,(LEN(@ColSelect1)-1))  + ''' FldLst '
								+ ' FROM ' + @TblNm + ' WHERE KeyFk = ' + CONVERT(VARCHAR(20),@DataMasPk) + ' AND HisPk = ' + CONVERT(VARCHAR(20),@PcPk)

								SELECT @QryBuilder2 = 'SELECT ''' + CAST(@AprOrRej AS VARCHAR(1)) + ''' [AprOrRej],''' + ISNULL(@FlowNm,'') + ''' [FlowNm],''' + ISNULL(@PgNm,'') + ''' PgNm,''' + ISNULL(@UsrRef,'') + ''' [User],''' + ISNULL(@DtTime,'') + ''' [ExecDt],'  + LEFT(@ColSelect2,(LEN(@ColSelect2)-1)) 
								+ '  ,''' + LEFT(@ColSelect2,(LEN(@ColSelect2)-1))  + ''' FldLst '
								+ ' FROM ' + @TblNm + ' WHERE KeyFk = ' + CONVERT(VARCHAR(20),@DataMasPk) + ' AND HisPk = ' + CONVERT(VARCHAR(20),@PcPk)
							END
--print @QryBuilder	
						
						--EXEC (@QryBuilder2)
						IF ISNULL(@QryBuilder,'') <> ''
							EXEC (@QryBuilder)

						IF ISNULL(@QryBuilder2,'') <> ''
							INSERT INTO @TempData(AprOrRej, FlowNm , PgNm , UsrNm , ExecDt ,DataPk , FlowFk , HisPk ,KeyFk , FldLst)
							EXEC (@QryBuilder2)

						--SELECT @MinFk = MIN(OrdNo) FROM #PgHdr WHERE OrdNo > @MinFk
						SELECT @MaxFk = MAX(OrdNo) FROM #PgHdr WHERE OrdNo < @MaxFk
					END
				END	
		/**************************************************** Return Data Info to the User Ends ***************************************************/								
			SELECT * FROM @TempData							
	IF @Trancount = 1 AND @@TRANCOUNT = 1
		COMMIT TRAN
			
	END TRY
	BEGIN CATCH

		IF @Trancount = 1 AND @@TRANCOUNT = 1
			ROLLBACK TRAN	
		
		SELECT	@ErrMsg = ERROR_MESSAGE() + ',' + ERROR_PROCEDURE() + ':' + RTRIM(ERROR_LINE()),
				@ErrSeverity = ERROR_SEVERITY()
		
		RAISERROR('%s', @ErrSeverity, 1,@ErrMsg) 		
		RETURN
			
	END CATCH					
END









