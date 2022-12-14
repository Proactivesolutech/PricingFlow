USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[PrcShflBpmProcess_todel]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PrcShflBpmProcess_todel]
(
	@Action			VARCHAR(10)		=	NULL,
	@FlowNmTmp		VARCHAR(50)		=	NULL,
	@ModelXml		NTEXT			=	NULL,
	@ProcessJSON	VARCHAR(MAX)	=	NULL,
	@SrcJSON		VARCHAR(MAX)	=	NULL,
	@TrgJSON		VARCHAR(MAX)	=	NULL,
	@PageDetlJson	VARCHAR(MAX)	=	NULL,
	@LaneJson		VARCHAR(MAX)	=	NULL,
	@GlobalXml		VARCHAR(MAX)	=	NULL,
	@FlowRmks		VARCHAR(500)	=	NULL,
	@TrigFk			BIGINT			=	NULL,
	@FlowPk			BIGINT			=	NULL,
	@TblNm			VARCHAR(100)	=	NULL
)
AS
BEGIN

--RAISERROR('Wait',16,1)
--RETURN

	SET NOCOUNT ON
	SET ANSI_WARNINGS ON
	
	DECLARE @CurDt DATETIME, @TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT
	DECLARE @FlowFk BIGINT, @MinFk BIGINT , @MaxFk BIGINT, @InMinFk BIGINT, @InMaxFk BIGINT, @RwCnt INT = 0,
			@FlowDpdFk	BIGINT,@VerNo INT, @FlowNm VARCHAR(50), @RoleFk BIGINT,
			@RolId VARCHAR(100),@RowId VARCHAR(40), @VerFlowFk BIGINT, @PrcNm VARCHAR(100)
	
	DECLARE @TblGenId VARCHAR(MAX), @ElmId VARCHAR(100), @ElmFk BIGINT, @QryBuilder VARCHAR(MAX), @UsrFk BIGINT
	DECLARE @CrtCol VARCHAR(MAX), @Colnms VARCHAR(MAX), @ColLabls VARCHAR(MAX),@UsrNm VARCHAR(100),@DfltTbl VARCHAR(20)

	CREATE TABLE #Tbl_Crt_Tmplt_Tmp(xx_id BIGINT, label VARCHAR(100),typeId VARCHAR(100),innerText VARCHAR(500), elem VARCHAR(100))
	CREATE TABLE #UsrRights(xx_id BIGINT,RolFk BIGINT, PageId VARCHAR(100))
	CREATE TABLE #LaneDtls(xx_id BIGINT, LaneName VARCHAR(100), LaneId VARCHAR(100), LaneFlowNodeId VARCHAR(100), RoleFk BIGINT, Flg INT)
	
	SELECT @CurDt = GETDATE(), @RowId = NEWID(), @UsrNm = 'ADMIN'
	
	CREATE TABLE #ProcessDtls
	(
		xx_id BIGINT, ProcType VARCHAR(100), id VARCHAR(100), ParentId VARCHAR(100),
		ProcId VARCHAR(100),ProcLabel VARCHAR(100), EvtDefn VARCHAR(50)
	)

	CREATE TABLE #TmpSeqSubDtls
	(
		SbfdPk BIGINT,SbsdSbdFk BIGINT, ToolFk BIGINT, SbsdId VARCHAR(100), SbsdSrcId VARCHAR(100), 
		SbsdSrcFk BIGINT, SbsdDestId VARCHAR(100), SbsdDestFk BIGINT, SbsdSeqTreeId VARCHAR(100), SbsdDpdFk BIGINT
	)	
	
	CREATE TABLE #ProcTmp(SbdFk BIGINT, SbdId VARCHAR(100) , BtbFk BIGINT, ProcLbl VARCHAR(100), PrtId VARCHAR(100), PrtFk BIGINT)
	CREATE TABLE #PageDataTbl 
	(
		xx_id BIGINT,FlowFk BIGINT,ElemPk BIGINT,ElemID VARCHAR(100),ElemDesc VARCHAR(200),ElemPageHtml VARCHAR(MAX),
		ElemPageUrl VARCHAR(500), ElemPageType INT, ElemSubProcId BIGINT, CmdTxt VARCHAR(500),IsAuto BIT, ElemScript VARCHAR(MAX),
		ElmRmks VARCHAR(500), ElmCd VARCHAR(5),ElmIsRtnNeed BIT
	)
	CREATE TABLE #PageInsDtls(PagePk BIGINT,PageSbfdFk BIGINT)
	CREATE TABLE #SeqSrcTbl(xx_id BIGINT, Id VARCHAR(100), SrcId VARCHAR(100), Flg INT)
	CREATE TABLE #SeqTrgTbl(xx_id BIGINT, Id VARCHAR(100), TrgId VARCHAR(100), Flg INT)
	
	CREATE TABLE #SeqTbl
	(
		FinBioFk BIGINT, FinFlowFk BIGINT, FinProcFlg INT, FinId VARCHAR(100), FinSrcId VARCHAR(100), FinSrcFk BIGINT, 
		FinTrgId VARCHAR(100), FinTrgFk BIGINT, seqTreeId VARCHAR(100) , Flg INT, IsUpdt INT DEFAULT 0,
		PrtSNo INT, BtbFk BIGINT
	)
		
	CREATE TABLE #GlobalDtls(xx_id BIGINT, FlowNm VARCHAR(50), FlowVersNo INT,FlowDpdFk BIGINT)
				
	IF @ProcessJSON !='[]'
		BEGIN
			INSERT INTO #ProcessDtls
			EXEC PrcParseJSON @ProcessJSON,'ProcType,id,ParentId,ProcId,ProcLabel,eventDefn'
		END
	
	IF @SrcJSON != '[]'
		BEGIN
			INSERT INTO #SeqSrcTbl(xx_id, Id, SrcId)
			EXEC PrcParseJSON @SrcJSON,'ProcId,SourceId'
		END

	IF @TrgJSON != '[]'
		BEGIN
			INSERT INTO #SeqTrgTbl(xx_id, Id, TrgId)
			EXEC PrcParseJSON @TrgJSON,'ProcId,TargetId'
		END
	
	IF @PageDetlJson !='[]' AND @PageDetlJson != ''
		BEGIN
			INSERT INTO #PageDataTbl
			EXEC PrcParseJSON @PageDetlJson,'FlowFk,ElemPk,ElemID,ElemDesc,ElemPageHtml,ElemPageUrl,ElemPageType,ElemSubProcId,CmdTxt,IsAuto,ElemScript,ElmRmks,ElmCd,ElmIsRtnNeed'
		END
	
	IF @LaneJson != '[]' AND @LaneJson != ''
		BEGIN
			INSERT INTO #LaneDtls(xx_id,LaneName,LaneId,LaneFlowNodeId)
			EXEC PrcParseJSON @LaneJson,'LaneName,LaneId,LaneFlowNodeId'
			
			INSERT INTO #LaneDtls(xx_id,LaneName,LaneId,LaneFlowNodeId,RoleFk,Flg)
			SELECT		xx_id,REPLACE( REPLACE(REPLACE(LaneName, CHAR(13),' '), CHAR(10),' '), '   ', ' '),LaneId,LaneFlowNodeId,RolPk,1
			FROM		#LaneDtls
			LEFT JOIN	GenRole(NOLOCK) ON 
			REPLACE( REPLACE(REPLACE(LaneName, CHAR(13),' '), CHAR(10),' '), '   ', ' ') = RolNm --COLLATE Latin1_General_CI_AI
			AND RolDelid = 0

		END
	IF @GlobalXml != '[]' AND @GlobalXml != ''
		BEGIN
			INSERT INTO #GlobalDtls
			EXEC PrcParseJSON @GlobalXml,'FlowNm,FlowVersNo,FlowDpdFk'
			
			SELECT @FlowDpdFk = FlowDpdFk,@VerNo = (ISNULL(FlowVersNo,0) + 1),@FlowNm = FlowNm  FROM #GlobalDtls
		END
		
	BEGIN TRY
	 
	IF @@TRANCOUNT = 0
		SET @TranCount = 1
	
	IF @TranCount = 1
		BEGIN TRAN

			IF @Action IN ('PrcSave','PrcEdit')
				BEGIN
					
					--- Check For Role Exist
					IF EXISTS(SELECT 'X' FROM #LaneDtls WHERE ISNULL(RoleFk,0) = 0 AND Flg = 1)
						BEGIN

							SELECT	@ErrMsg = 'Role Details does not Match for - ';

							SELECT  LaneName,RoleFk INTO #Lanes FROM #LaneDtls 
							WHERE	ISNULL(RoleFk,0) = 0 AND Flg = 1
							GROUP BY LaneName, RoleFk

							SELECT	@ErrMsg = @ErrMsg + LaneName + ','  FROM #Lanes
							
							SET	@ErrMsg = LEFT(@ErrMsg, (LEN(@ErrMsg)-1))
							
							RAISERROR('%s',16,1,@ErrMsg)
							RETURN
						END
						
					SET @FlowNm = @FlowNmTmp 

					IF @Action = 'PrcSave'
						BEGIN -- New Version
							INSERT INTO BpmMas
							(
								BpmNm,BpmFolderPath,BpmTrigFk,BpmRowId,BpmCreatedBy,BpmCreatedDt,BpmModifiedBy,
								BpmModifiedDt,BpmDelFlg,BpmDelId
							)
							--OUTPUT	INSERTED.*
							SELECT @FlowNm,'',@TrigFk,@RowId,@UsrNm,@CurDt,@UsrNm,@CurDt,NULL,0
						
							SELECT @FlowFk = SCOPE_IDENTITY(),@Error = @@ERROR, @Rowcount = @@ROWCOUNT
						
							IF @Error <> 0
								BEGIN
									RAISERROR('Error - Flow Master Header Insert.',16,1)
									RETURN
								END	
							IF @Rowcount = 0
								BEGIN
									RAISERROR('Flow Master - No Data Found to Insert.',16,1)
									RETURN
								END	
						END
					ELSE -- Update Version
						BEGIN
							SET @FlowFk = @FlowPk;
						END	
					
					--------------------------------------- Version Table Insert Starts --------------------------------------------------------------
					
					INSERT INTO BpmVersions
					(
						BvmBpmFk,BvmXML,BvmVerNo,BvmPublish,BvmNotes,BvmRowId,BvmCreatedBy,BvmCreatedDt,BvmModifiedBy,
						BvmModifiedDt,BvmDelFlg,BvmDelId
					)
					--OUTPUT	INSERTED.*
					SELECT @FlowFk,@ModelXml,@VerNo,'',ISNULL(@FlowRmks,''),@RowId,@UsrNm,@CurDt,@UsrNm,@CurDt,NULL,0
					
					SELECT @VerFlowFk = SCOPE_IDENTITY(),@Error = @@ERROR, @Rowcount = @@ROWCOUNT
					
					IF @Error <> 0
						BEGIN
							RAISERROR('Error - Flow Master Version Header Insert.',16,1)
							RETURN
						END	
					IF @Rowcount = 0
						BEGIN
							RAISERROR('Flow Master Version - No Data Found to Insert.',16,1)
							RETURN
						END	

					SET @DfltTbl = 'GEN_' + CONVERT(VARCHAR(20),@FlowFk);
					--------------------------------------- Version Table Insert Starts --------------------------------------------------------------
					
					--------------------------------------- Flow Table Insert Starts --------------------------------------------------------------
					INSERT INTO BpmFlow
					(
						BfwBvmFk,BfwBtbFk,BfwId,BfwLabel,BfwPrtRef,BfwSubBvmFk,BfwLaneRef,BfwRowId,BfwCreatedBy,
						BfwCreatedDt,BfwModifiedBy,BfwModifiedDt,BfwDelFlg,BfwDelId
					)
					OUTPUT		Inserted.BfwPk, Inserted.BfwId,Inserted.BfwBtbFk, Inserted.BfwLabel, Inserted.BfwPrtRef, 0 
					INTO		#ProcTmp
					SELECT		@VerFlowFk,BtbPk,id,ProcLabel,ParentId,NULL,NULL,@RowId,@UsrNm,@CurDt,@UsrNm,@CurDt,NULL,0
					FROM		#ProcessDtls
					JOIN		BpmToolBox (NOLOCK) ON LOWER(BtbToolNm) = LOWER(ProcType) --COLLATE Latin1_General_CI_AI
					
					SELECT @Error = @@ERROR, @Rowcount = @@ROWCOUNT
					
					IF @Error <> 0
						BEGIN
							RAISERROR('Error - Flow Master Detail Insert.',16,1)
							RETURN
						END	
					IF @Rowcount = 0
						BEGIN
							RAISERROR('Flow Master Details - No Data Found to Insert.',16,1)
							RETURN
						END	
	
					--------------------------------------- Flow Table Insert Starts --------------------------------------------------------------
					--------------------------------------- Input/Output Table Insert Starts --------------------------------------------------------------
					INSERT	INTO #SeqTbl(FinId, FinSrcId, FinTrgId)
					SELECT	S.Id, SrcId, TrgId 
					FROM	#SeqSrcTbl S
					JOIN	#SeqTrgTbl T ON S.Id = T.Id


					INSERT	INTO #SeqTbl(FinId, FinSrcId, FinTrgId)
					SELECT	Id, SrcId, ''
					FROM	#SeqSrcTbl S
					WHERE	NOT EXISTS(SELECT 'X' FROM #SeqTbl WHERE FinId = Id)

					INSERT	INTO #SeqTbl(FinId, FinSrcId, FinTrgId)
					SELECT	Id, '', TrgId
					FROM	#SeqTrgTbl T
					WHERE	NOT EXISTS(SELECT 'X' FROM #SeqTbl WHERE FinId = Id)

					UPDATE #SeqTbl SET FinSrcFk = SbdFk FROM #ProcTmp WHERE SbdId = FinSrcId
					UPDATE #SeqTbl SET FinTrgFk = SbdFk FROM #ProcTmp WHERE SbdId = FinTrgId

					INSERT INTO BpmObjInOut 
					(
						BioBvmFk,BioBfwFk,BioBtbFk,BioId,BioInBfwFk,BioInId,BioOutBfwFk,BioOutId,BioSubBfwFk,BioTreeId,
						BioRowId,BioCreatedBy,BioCreatedDt,BioModifiedBy,BioModifiedDt,BioDelFlg,BioDelId
					)
					--OUTPUT INSERTED.*
					SELECT	@VerFlowFk, SbdFk, C.BtbPk, FinId, FinSrcFk, FinSrcId, FinTrgFk, FinTrgId,NULL,seqTreeId,
							@RowId,@UsrNm,@CurDt,@UsrNm,@CurDt,NULL,0
					FROM		#SeqTbl(NOLOCK) A
					JOIN		#ProcTmp(NOLOCK) B ON A.FinId = B.SbdId
					JOIN		BpmToolBox(NOLOCK) C ON B.BtbFk = C.BtbPk
					
					SELECT @Error = @@ERROR, @Rowcount = @@ROWCOUNT
					
					IF @Error <> 0
						BEGIN
							RAISERROR('Error - Sequence Detail Insert.',16,1)
							RETURN
						END	
					IF @Rowcount = 0
						BEGIN
							RAISERROR('Sequence Details - No Data Found to Insert.',16,1)
							RETURN
						END	
				
				-- TreeID Update
				EXEC	PrcArriveSeqTreeId  @VerFlowFk, 1
				--------------------------------------- Input/Output Table Insert Ends --------------------------------------------------------------
				--------------------------------------------- Page Table Insert Starts --------------------------------------------------------------
					INSERT	INTO BpmUIDefn
					(
						BudBfwFk,BudCd,BudIsRtnNeed,BudDesignTyp,BudDesignData,BudURL,BudDecIsAuto,BudDecExp,BudScript,BudNotes,
						BudRowId,BudCreatedBy,BudCreatedDt,BudModifiedBy,BudModifiedDt,BudDelFlg,BudDelId
					)
					OUTPUT	INSERTED.BudPk,INSERTED.BudBfwFk INTO #PageInsDtls
					SELECT	BfwPk, ElmCd,ElmIsRtnNeed, ElemPageType, REPLACE( REPLACE(REPLACE(ElemPageHtml, CHAR(13),' '), CHAR(10),' '), '   ', ' '),ElemPageUrl,
							ISNULL(IsAuto,0),ISNULL(CmdTxt,''),ISNULL(ElemScript,''),ISNULL(ElmRmks,''),
							@RowId,@UsrNm,@CurDt,@UsrNm,@CurDt,NULL,0
					FROM	#PageDataTbl 
					JOIN	BpmFlow (NOLOCK) ON BfwBvmFk = @VerFlowFk AND RTRIM(BfwId) = RTRIM(ElemID) --COLLATE Latin1_General_CI_AI AND BfwDelId = 0
					WHERE	ElemPageType != 4

					SELECT @Error = @@ERROR, @Rowcount = @@ROWCOUNT
					
					IF @Error <> 0
						BEGIN
							RAISERROR('Error - Page Master Insert.',16,1)
							RETURN
						END	
					IF @Rowcount = 0
						BEGIN
							RAISERROR('Page Master - No Data Found to Insert.',16,1)
							RETURN
						END

					-- Roles Rights Insert
					IF EXISTS(SELECT 'X' FROM #LaneDtls)
						BEGIN
							INSERT INTO ShflPgRightsDtls(PgrdRolFk,PgrdPgFk,PgrActDt,PgrdDelId)
							SELECT	RoleFk, PagePk, @CurDt,0
							FROM	#LaneDtls
							JOIN	#ProcTmp ON SbdId = LaneFlowNodeId
							JOIN	#PageInsDtls ON SbdFk = PageSbfdFk
							WHERE	Flg = 1
							
							SELECT @Error = @@ERROR, @Rowcount = @@ROWCOUNT
							
							UPDATE	BpmFlow SET BfwLaneRef = LaneId 
							FROM	#LaneDtls
							WHERE	BfwBvmFk = @VerFlowFk AND BfwId = LaneFlowNodeId --COLLATE Latin1_General_CI_AI AND BfwDelid = 0
						END
					ELSE
						BEGIN
							SELECT	@RoleFk = RolPk, @RolId = SbdId, @PrcNm = ProcId 
							FROM	GenRole(NOLOCK) 
							JOIN	#ProcTmp ON RolNm = ProcLbl
							JOIN	BpmToolBox (NOLOCK) ON BtbPk = BtbFk AND LOWER(BtbToolNm) = 'bpmn:participant'
							JOIN	#ProcessDtls ON id = SbdId
							AND		RolDelid = 0
							
							IF ISNULL(@RoleFk,0) = 0
								BEGIN
									RAISERROR('%s',16,1,'Roles Required')
									RETURN
								END
							
							INSERT INTO ShflPgRightsDtls(PgrdRolFk,PgrdPgFk,PgrActDt,PgrdDelId)
							SELECT	@RoleFk, PagePk, @CurDt,0
							FROM	#ProcTmp
							JOIN	#PageInsDtls ON SbdFk = PageSbfdFk

							SELECT @Error = @@ERROR, @Rowcount = @@ROWCOUNT
							
							UPDATE	BpmFlow SET BfwLaneRef = @RolId 
							WHERE	BfwBvmFk = @VerFlowFk AND BfwPrtRef = @PrcNm AND BfwDelid = 0
						END
						
					IF @Error <> 0
						BEGIN
							RAISERROR('Error - Page Rights Insert.',16,1)
							RETURN
						END	
					IF @Rowcount = 0
						BEGIN
							RAISERROR('Page Rights - No Data Found to Insert.',16,1)
							RETURN
						END
												
				--------------------------------------- Page Table Insert Ends --------------------------------------------------------------
				
				--------------------------------------- Dynamic Table Creation Flow  --------------------------------------------------------------
				DECLARE @DynMinFk BIGINT = 0, @DynMaxFk BIGINT = 0,@RowCnt NVARCHAR(MAX)
				SELECT	@DynMinFk = MIN(xx_id), @DynMaxFk = MAX(xx_id) FROM #PageDataTbl 
				WHERE	ISNULL(ElemPageHtml,'') != '' AND ElemPageType = 1

				WHILE @DynMinFk <= @DynMaxFk
					BEGIN
								
						SELECT @CrtCol = '', @Colnms = '', @ColLabls = '' , @TblGenId = '' , @ElmFk = 0 , @QryBuilder = ''
								
						SELECT	@TblGenId = REPLACE( REPLACE(REPLACE(ElemPageHtml, CHAR(13),' '), CHAR(10),' '), '   ', ' '),
								@ElmId = ElemId FROM #PageDataTbl WHERE xx_id = @DynMinFk
			

						SELECT	@ElmFk = SbdFk FROM #ProcTmp, BpmToolBox(NOLOCK) WHERE SbdId = @ElmId AND BtbFk = BtbPk -- Only Start Screen
						DELETE FROM #Tbl_Crt_Tmplt_Tmp
								
						IF ISNULL(@ElmFk,0) > 0
							BEGIN
								INSERT INTO #Tbl_Crt_Tmplt_Tmp
								EXEC PrcParseJSON @TblGenId,'label,type,innerText,elem'
						--SELECT * FROM #Tbl_Crt_Tmplt_Tmp RETURN		
								UPDATE #Tbl_Crt_Tmplt_Tmp SET typeId = 'text' WHERE LOWER(elem) = 'select'

								SELECT	@CrtCol = ISNULL(@CrtCol,'') + REPLACE(REPLACE(label,' ','_'),'-','') + ' VARCHAR(100),',
										@Colnms = ISNULL(@Colnms,'') + REPLACE(REPLACE(label,' ','_'),'-','') + '~',
										@ColLabls = ISNULL(@ColLabls,'') + label + '~'
								FROM	#Tbl_Crt_Tmplt_Tmp
								WHERE	ISNULL(typeid,'') NOT IN ('submit','button') 
								AND		ISNULL(innerText,'') = ''
							
								SET @CrtCol =  REPLACE(REPLACE( REPLACE(REPLACE(@CrtCol, CHAR(13),' '), CHAR(10),' '), '   ', ' '),'_	','_')
								SET @Colnms =  REPLACE(REPLACE( REPLACE(REPLACE(@Colnms, CHAR(13),' '), CHAR(10),' '), '   ', ' '),'_	','_')

-----------------DYNAMIC COLUMN CREATION---------------
						DECLARE @Altr VARCHAR(1000),@Cnt BIGINT,@Mincnt BIGINT
						SELECT @Cnt = MAX(xx_id) FROM #Tbl_Crt_Tmplt_Tmp
						SELECT @Mincnt = MIN(xx_id) FROM #Tbl_Crt_Tmplt_Tmp
				SET @TblNm=''	
				IF ISNULL(@TblNm,'') = ''
				BEGIN
					IF(OBJECT_ID(@DfltTbl + '_' + @ElmId,'U') IS NOT NULL)
					BEGIN
								IF ISNULL(@CrtCol,'') != ''
									BEGIN
										WHILE (@Mincnt<=@Cnt)
										BEGIN
											SET @Colnms=''
											SELECT @Colnms =  label FROM #Tbl_Crt_Tmplt_Tmp WHERE xx_id =@Mincnt
									
									DECLARE @ColCnt BIGINT,@TotColCnt BIGINT
									
									SELECT @TotColCnt = COUNT(*) 
									FROM INFORMATION_SCHEMA.COLUMNS 
									WHERE TABLE_NAME = @DfltTbl + '_' + @ElmId AND COLUMN_NAME NOT IN ('KeyFk','HisPk','BranchFk','DataPk','FlowFk')
								
							
									--SELECT COLUMN_NAME INTO #ColmNms
									--FROM INFORMATION_SCHEMA.COLUMNS 
									--WHERE TABLE_NAME = 'GEN_2135_Task_148gi38_h6xx' AND COLUMN_NAME NOT IN ('KeyFk','HisPk','BranchFk','DataPk','FlowFk')
--SELECT * FROM INFORMATION_SCHEMA.COLUMNS  WHERE TABLE_NAME = 'GEN_2135_Task_148gi38_h6xx'
									
									IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS 
									WHERE TABLE_NAME = @DfltTbl + '_' + @ElmId AND COLUMN_NAME = @Colnms)
									BEGIN
										SET @ColCnt = ISNULL(@ColCnt,0)+1
									END

											SET @Altr = ''
											SET @Altr = 'ALTER TABLE '+@DfltTbl + '_' + @ElmId+' ADD '+@Colnms+' VARCHAR(100)'
									
												IF NOT EXISTS(SELECT * FROM sys.columns
												WHERE Name = @Colnms AND OBJECT_ID = OBJECT_ID(N''+@DfltTbl + '_' + @ElmId+''))
												BEGIN 
												--SELECT @Altr
													EXEC (@Altr)
												END
													SELECT @Mincnt = @Mincnt + 1
										END
									END
									SELECT @RowCnt = 'SELECT @x = COUNT(*) FROM '+@DfltTbl + '_' + @ElmId+''
									
									DECLARE @xx INT,@x INT
									SET @xx = 0

									EXEC sp_executesql @RowCnt, N'@x INT OUT', @xx OUT

									IF @xx > 0
									BEGIN 
										IF @ColCnt <> @TotColCnt
										BEGIN
												RAISERROR('%s',16,1,'Column names cannot be updated')
												RETURN
										END
									END
					END
				
					SELECT @QryBuilder = 'IF(OBJECT_ID(''' + @DfltTbl + '_' + @ElmId +''',''U'') IS NULL) BEGIN CREATE TABLE '+ @DfltTbl + '_' +  @ElmId +'(KeyFk BIGINT, HisPk BIGINT, BranchFk BIGINT, DataPk BIGINT PRIMARY KEY IDENTITY(1,1),FlowFk BIGINT ,IsActive INT DEFAULT 1,LastModifiedTime DATETIME DEFAULT GETDATE(), '+ LEFT(@CrtCol,(LEN(@CrtCol) - 1)) +') END'
					EXEC (@QryBuilder)

				END
				ELSE
				BEGIN
					IF(OBJECT_ID(@TblNm,'U') IS NOT NULL)
					BEGIN
								IF ISNULL(@CrtCol,'') != ''
									BEGIN
										WHILE (@Mincnt<=@Cnt)
										BEGIN
											SET @Colnms=''
											SELECT @Colnms =  label FROM #Tbl_Crt_Tmplt_Tmp WHERE xx_id =@Mincnt
											SET @Altr = ''
											SET @Altr = 'ALTER TABLE '+@TblNm+' ADD '+@Colnms+' VARCHAR(100)'
									
												IF NOT EXISTS(SELECT * FROM sys.columns
												WHERE Name = @Colnms AND OBJECT_ID = OBJECT_ID(N''+@TblNm+''))
												BEGIN 
													EXEC (@Altr)
												END
													SELECT @Mincnt = @Mincnt+1
										END
										--SELECT @QryBuilder = 'IF(OBJECT_ID(''' + @DfltTbl + '_' + @ElmId +''',''U'') IS NULL) BEGIN CREATE TABLE '+ @DfltTbl + '_' +  @ElmId +'(KeyFk BIGINT, HisPk BIGINT, BranchFk BIGINT, DataPk BIGINT PRIMARY KEY IDENTITY(1,1) , '+ LEFT(@CrtCol,(LEN(@CrtCol) - 1)) +') END'
										--EXEC (@QryBuilder)
									END
					END

					SELECT @QryBuilder = 'IF(OBJECT_ID(''' + @TblNm +''',''U'') IS NULL) BEGIN CREATE TABLE '+ @TblNm +'(KeyFk BIGINT, HisPk BIGINT, BranchFk BIGINT, DataPk BIGINT PRIMARY KEY IDENTITY(1,1),FlowFk BIGINT ,IsActive INT DEFAULT 1,LastModifiedTime DATETIME DEFAULT GETDATE(),  '+ LEFT(@CrtCol,(LEN(@CrtCol) - 1)) +') END'
					EXEC (@QryBuilder)

				END
										INSERT INTO BpmFlowTbl(FtVerFlowFk,FtBfwFk,FtProcId,FtDataField,FtDataLabel,FtDelid,FtActDt)
										--OUTPUT INSERTED.*
										SELECT	@VerFlowFk, @ElmFk, @ElmId, LEFT(@Colnms,(LEN(@Colnms) - 1)), LEFT(@ColLabls,(LEN(@ColLabls) - 1)),
												0,@CurDt
			--END

							END
						SELECT @DynMinFk = MIN(xx_id) FROM #PageDataTbl WHERE xx_id > @DynMinFk AND ISNULL(ElemPageHtml,'') != '' AND ElemPageType = 1
					END


				---------------------------------------  Dynamic Table Creation Flow --------------------------------------------------------------

				--------------------------------------- SubProcess Insert Work Starts --------------------------------------------------------------
				IF EXISTS(SELECT 'X' FROM #PageDataTbl WHERE ElemPageType = 4)
					BEGIN

						-- Get Flow and Element Reference & TreeId for concatenation.
							SELECT	BioBfwFk 'BfwFk', ElemSubProcId 'SubverFk'
							INTO	#SubPrtDtls
							FROM	#PageDataTbl(NOLOCK)
							JOIN	BpmObjInOut (NOLOCK) ON BioId = ElemID AND BioDelId = 0
							WHERE	ElemPageType = 4


						-- Update the Attached Sub Process
							UPDATE	BpmFlow 
							SET		BfwSubBvmFk = SubverFk
							FROM	#SubPrtDtls WHERE BfwPk = BfwFk AND BfwDelId = 0

							IF @@ERROR > 0
								BEGIN
									RAISERROR('%s',16,1,'Error while Updating SubProcess')
								END

						-- Get the Attached Sub Process Flow Sequence.
							INSERT INTO #TmpSeqSubDtls
							(
								SbfdPk , SbsdSbdFk, ToolFk, SbsdId, SbsdSrcId, SbsdSrcFk, SbsdDestId, SbsdDestFk, SbsdSeqTreeId,SbsdDpdFk
							)
							SELECT	BfwFk , BioBfwFk, BioBtbFk, BioId, BioInId, BioInBfwFk, BioOutId, BioOutBfwFk,'', BioSubBfwFk
							FROM	BpmObjInOut (NOLOCK)
							JOIN	#SubPrtDtls ON SubverFk = BioBvmFk
							WHERE	BioDelId = 0

							SELECT @Error = @@ERROR, @RwCnt = @@ROWCOUNT
							IF @Error > 0
								BEGIN
									RAISERROR('%s',16,1,'Error while Inserting SubProcess Sequence Flow')
								END

							IF @RwCnt = 0
								BEGIN
									RAISERROR('%s',16,1,'No Records found for Inserting SubProcess Sequence Flow')
								END

						-- Insert newly attached Process.
							INSERT INTO BpmObjInOut
							(
								BioBvmFk,BioBfwFk,BioBtbFk,BioId,BioInBfwFk,BioInId,BioOutBfwFk,BioOutId,BioSubBfwFk,BioRowId,BioCreatedBy,
								BioCreatedDt,BioModifiedBy,BioModifiedDt,BioDelFlg,BioDelId
							)
							--OUTPUT INSERTED.*
							SELECT	@VerFlowFk, SbsdSbdFk, ToolFk, SbsdId, SbsdSrcFk,SbsdSrcId, SbsdDestFk, SbsdDestId, 
									BfwFk, @RowId,@UsrNm,@CurDt,@UsrNm,@CurDt,NULL,0
							FROM	#TmpSeqSubDtls 
							JOIN	#SubPrtDtls ON SbfdPk = BfwFk

							IF @@ERROR > 0
								BEGIN
									RAISERROR('%s',16,1,'Error while Inserting New SubProcess Sequence Flow')
								END								
					END
					--------------------------------------- SubProcess Insert Work Ends -------------------------------------------------------------- 

			SELECT @FlowFk 'FlowFk'			
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
