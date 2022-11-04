IF EXISTS(SELECT NULL FROM sysobjects WHERE name='PrcShflAgtMgmt' AND [type]='P')
	DROP PROC PrcShflAgtMgmt
GO
CREATE PROCEDURE PrcShflAgtMgmt
(
    @Action		  VARCHAR(100)		=	NULL,
	@GlobalJson   VARCHAR(MAX)		=	NULL,
    @HdrJson	  VARCHAR(MAX)		=	NULL,  
	@DtlsJson	  VARCHAR(MAX)		=	NULL ,
	@LfjFk		  BIGINT			=	NULL,
	@DtlFk		  BIGINT			=	NULL,
	@JobSts		  BIT				=	0,
	@RptJson	  VARCHAR(MAX)		=	NULL,
	@editmd		  VARCHAR(MAX)		=	NULL  
)
AS
BEGIN
--RETURN
	SET NOCOUNT ON
	
	DECLARE  @CurDt DATETIME,@TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), 
			 @Error INT, @RowCount INT,@RowId VARCHAR(40),@agt_JobNo VARCHAR(100),@UsrDispNm VARCHAR(100),@LeadPk BIGINT,
			 @agt_JobDt VARCHAR(100),@agt_DocFk VARCHAR(100),@RefFk BIGINT ,  @LajServType BIGINT,@AgtFk BIGINT,@MaxJobNo VARCHAR(100),
			 @LajFk BIGINT, @GeoFk BIGINT, @PrdFk BIGINT, @IsNext BIT = 0,  @IsExist BIT = 1;
	DECLARE  @InCount TINYINT, @OutCount TINYINT, @Sts TINYINT, @Notes VARCHAR(MAX),@FLAG BIGINT = 0,@LapFk BIGINT;
	
	CREATE TABLE #LajDtls(LajPk BIGINT)
	CREATE TABLE #GlobalDtls
	(
		xx_id BIGINT,LeadPk BIGINT, GeoFk BIGINT, UsrPk BIGINT, UsrDispNm VARCHAR(100),
		LeadId VARCHAR(100),PrdFk BIGINT,agt_LajFk BIGINT, agt_RefFk BIGINT,agt_AgtFk BIGINT,agt_LajServType BIGINT
	)	

	CREATE TABLE #HDTLS
	(
		xx_id BIGINT,agt_rptdt VARCHAR(100),agt_rptstatus VARCHAR(100),agt_notes VARCHAR(500),agt_AppplnNo  VARCHAR(100),agt_AstCost  VARCHAR(100),
		agt_Regchg  VARCHAR(100),agt_stmpchg  VARCHAR(100),agt_agtval  VARCHAR(100),agt_lftEst VARCHAR(100),
		agt_lftWst VARCHAR(100),agt_lftNor VARCHAR(100),agt_lftSou VARCHAR(100),agt_lftRefno VARCHAR(100),agt_lftmgtval VARCHAR(100),
		agt_amenAmt VARCHAR(100),agt_RptPath VARCHAR(100)
	)
	CREATE TABLE #DocDtls(id BIGINT,DocRef BIGINT, DocSts TINYINT, DocRmks VARCHAR(100), DPk BIGINT)
	CREATE TABLE #SavedDoc(Pk BIGINT, DocFk BIGINT)
	
	CREATE TABLE #RptDtls(id BIGINT,RptPath VARCHAR(MAX), RptDocFk BIGINT, RptPk BIGINT)
	CREATE TABLE #RptDocDtls(TRptDocFk BIGINT, TRptPk BIGINT)
	CREATE TABLE #Temptbl(Reftyp BIGINT,RowNo BIGINT IDENTITY(1,1))
	CREATE TABLE #PopupTempTbl(LfjFk BIGINT,LpvFk BIGINT)
	
	IF @GlobalJson != '[]' AND @GlobalJson != ''
	BEGIN	
		INSERT INTO #GlobalDtls
		EXEC PrcParseJSON @GlobalJson,'LeadPk,GeoFk,UsrPk,UsrDispNm,LeadId,PrdFk,LajFk,RefPk,LajAgtFK,ServiceType'

		SELECT	@LeadPk = LeadPk, @UsrDispNm = UsrDispNm,@AgtFk = agt_AgtFk, 
				@RefFk = agt_RefFk,  @LajServType = agt_LajServType ,@LajFk = agt_LajFk ,@PrdFk = PrdFk, @GeoFk = GeoFk
		FROM	#GlobalDtls
			
	END

	IF @HdrJson != '[]' AND @HdrJson != ''
		BEGIN			
			INSERT INTO #HDTLS
			EXEC PrcParseJSON @HdrJson,'agt_rptdt,agt_rptstatus,agt_notes,agt_AppplnNo ,agt_AstCost,agt_Regchg ,agt_stmpchg ,agt_agtval ,agt_lftEst,agt_lftWst,agt_lftNor,agt_lftSou,agt_lftRefno,agt_lftmgtval,agt_amenAmt,agt_RptPath'			
			
			SELECT @Sts = ISNULL(agt_rptstatus,0), @Notes = ISNULL(agt_notes ,'') FROM #HDTLS
		END

	IF @DtlsJson != '[]' AND @DtlsJson != ''
		BEGIN			
			INSERT INTO #DocDtls
			EXEC PrcParseJSON @DtlsJson,'agt_DocFk,agt_DocSts,agt_DocRmks,DPk'
		END
	
	IF @RptJson != '[]' AND @RptJson != ''
		BEGIN
			INSERT INTO #RptDtls
			EXEC PrcParseJSON @RptJson,'RptPath,RptDocFk,RptPk'
		END
	IF @editmd != ''
		BEGIN 	
		
			INSERT INTO #Temptbl
			SELECT CONVERT(BIGINT,items) FROM dbo.split(@editmd,'~','T') 
		
			SET @FLAG = 1
			SELECT	@LapFk = Reftyp
			FROM	#Temptbl WHERE RowNo = 1

			SELECT	 @LajServType = Reftyp 
			FROM	#Temptbl WHERE RowNo = 2
	
	   END
				
	SELECT @CurDt = GETDATE(), @RowId = NEWID()

	BEGIN TRY
	
		IF @@TRANCOUNT = 0
			SET @TranCount = 1

		IF @TranCount = 1
			BEGIN TRAN

				IF @Action = 'Save'
					BEGIN
						SELECT @MaxJobNo = (CONVERT(BIGINT,RIGHT(MAX(LfjJobNo),5)) + 1) FROM LosAgentFBJob(NOLOCK)
						IF ISNULL(@MaxJobNo,0) = 0 SET @MaxJobNo = 1;


						INSERT INTO  LosAgentFBJob
						(
							LfjRptDt,LfjRptSts,LfjNotes,LfjAgtRefNo,LfjLajFk,LfjLavFk,LfjLpvFk,LfjLslFk,LfjAgtFk,LfjSrvTyp,LfjJobNo,LfjJobDt,LfjRowId,
							LfjCreatedBy,LfjCreatedDt,LfjModifiedBy,LfjModifiedDt,LfjDelFlg,LfjDelId,LfjJobSts
						)
						SELECT	dbo.gefgchar2date(agt_rptdt),agt_rptstatus,agt_notes,ISNULL(agt_lftRefno,''),@LajFk,
								CASE WHEN @LajServType IN (0,1,2,3) THEN @RefFk END,
								CASE WHEN @LajServType IN (4,5) THEN @RefFk END,
								CASE WHEN @LajServType IN (6) THEN @RefFk END,
								@AgtFk,@LajServType,
								'FBJOB_' + dbo.gefgGetPadZero(5,(ISNULL(@MaxJobNo,0))),
								@CurDt,@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,NULL,0,ISNULL(@JobSts,0)
						FROM	#HDTLS	
											
						SELECT	@LfjFk = SCOPE_IDENTITY(),@Error = @@ERROR, @RowCount = @@ROWCOUNT

						IF @Error > 0
							BEGIN
								RAISERROR('%s',16,1,'Error : Agt Fb Job Insert')
								RETURN
							END
						IF @RowCount = 0
							BEGIN
								RAISERROR('%s',16,1,'Error : No Rows Found for Agt Fb Job Insert')
								RETURN
							END

						IF @LajServType IN (2)
						BEGIN
							INSERT INTO  LosAgentFBDocs
							(
								LfdLfjFk,LfdDocFk,LfdNotes,LfdSts,LfdRowId,LfdCreatedBy,LfdCreatedDt,LfdModifiedBy,LfdModifiedDt,LfdDelFlg,LfdDelId
							)
							OUTPUT INSERTED.LfdPk, INSERTED.LfdDocFk INTO #SavedDoc
							SELECT	@LfjFk,DocRef,ISNULL(DocRmks,''),ISNULL(DocSts ,0),@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,NULL,0
							FROM	#DocDtls

							SELECT	@Error = @@ERROR, @RowCount = @@ROWCOUNT

							IF @Error > 0
								BEGIN
									RAISERROR('%s',16,1,'Error : Agt Fb Docs Insert')
									RETURN
								END
						END	

						IF @LajServType IN (4)
							BEGIN
								INSERT INTO  LosAgentFBLegal
								(
									LflLfjFk,LflEast,LflWest,LflNorth,LflSouth,LflRefNo,LflAppPlnNo,LflAstCost,LflRegChg,LflStmpChg,LflAgrmtVal,
									LflRowId,LflCreatedBy,LflCreatedDt,LflModifiedBy,LflModifiedDt,LflDelFlg,LflDelId
								)
								SELECT	@LfjFk,ISNULL(agt_lftEst,''),ISNULL(agt_lftWst,''),ISNULL(agt_lftNor,''),ISNULL(agt_lftSou,''),ISNULL(agt_lftRefno,''),
										ISNULL(agt_AppplnNo,''),ISNULL(agt_AstCost,0), ISNULL(agt_Regchg,0),ISNULL(agt_stmpchg,0),ISNULL(agt_agtval,0),
										@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,NULL,0
								FROM	#HDTLS

								SELECT	@DtlFk = SCOPE_IDENTITY(),@Error = @@ERROR, @RowCount = @@ROWCOUNT

								IF @Error > 0
									BEGIN
										RAISERROR('%s',16,1,'Error : Agt Fb Legal Insert')
										RETURN
									END

								IF @RowCount = 0
									BEGIN
										RAISERROR('%s',16,1,'Error : No Rows Found for Agt Fb Legal Insert')
										RETURN
									END
							END

						IF @LajServType IN(5)
							BEGIN
								INSERT INTO  LosAgentFBTechnical
								(
									LftLfjFk,LftEast,LftWest,LftNorth,LftSouth,LftRefNo,LftMktVal,LftAmenAmt,LftRowId,
									LftCreatedBy,LftCreatedDt,LftModifiedBy,LftModifiedDt,LftDelFlg,LftDelId
								)
								SELECT	@LfjFk,ISNULL(agt_lftEst,''),ISNULL(agt_lftWst,''),ISNULL(agt_lftNor,''),ISNULL(agt_lftSou,''),ISNULL(agt_lftRefno,''),
										ISNULL(agt_lftmgtval,0),ISNULL(agt_amenAmt,0),@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,NULL,0
								FROM	#HDTLS

								SELECT	@DtlFk = SCOPE_IDENTITY(),@Error = @@ERROR, @RowCount = @@ROWCOUNT
					
								IF @Error > 0
									BEGIN
										RAISERROR('%s',16,1,'Error : Agt Fb Technical Insert')
										RETURN
									END

								IF @RowCount = 0
									BEGIN
										RAISERROR('%s',16,1,'Error : No Rows Found for Agt Fb Technical Insert')
										RETURN
									END
							END
					END
					
				IF @Action = 'Edit'
				 BEGIN	
				
					 UPDATE LosAgentFBJob
					 SET	LfjRptDt = dbo.gefgChar2Date(agt_rptdt),LfjRptSts = ISNULL(agt_rptstatus,0) ,LfjNotes = ISNULL(agt_notes,''),LfjAgtRefNo = ISNULL(agt_lftRefno,''),
							LfjJobSts = ISNULL(@JobSts,0),LfjRowId=@RowId,LfjModifiedBy = @UsrDispNm,LfjModifiedDt = @CurDt
					 FROM	#HDTLS
					 WHERE  LfjPk = @LfjFk AND LfjDelId = 0
					
					
					 IF @LajServType = 2
						BEGIN
							 UPDATE LosAgentFBDocs
							 SET	LfdDocFk = DocRef,LfdNotes = DocRmks,LfdSts = DocSts,
									LfdRowId=@RowId, LfdModifiedBy=@UsrDispNm, LfdModifiedDt=@CurDt
							 FROM	#DocDtls
							 WHERE  LfdPk = DPk AND LfdDelId = 0
						END
						
					IF @LajServType = 4
						BEGIN
							 UPDATE LosAgentFBLegal
							 SET	LflEast=ISNULL(agt_lftEst,''),LflWest=ISNULL(agt_lftWst,''),
									LflNorth=ISNULL(agt_lftNor,''),LflSouth=ISNULL(agt_lftSou,''),
									LflRefNo=ISNULL(agt_lftRefno,''),LflAppPlnNo=ISNULL(agt_AppplnNo,''),
									LflAstCost=ISNULL(agt_AstCost,0),LflRegChg=ISNULL(agt_Regchg,0),
									LflStmpChg=ISNULL(agt_stmpchg,0),LflAgrmtVal=ISNULL(agt_agtval,0),
									LflRowId=@RowId,LflModifiedBy=@UsrDispNm,LflModifiedDt=@CurDt
							 FROM	#HDTLS
							 WHERE  LflPk = @DtlFk AND LflDelId = 0
						END																											

					IF @LajServType = 5
						BEGIN
						 UPDATE LosAgentFBTechnical
						 SET	LftEast=ISNULL(agt_lftEst,''),LftWest=ISNULL(agt_lftWst,''),LftNorth=ISNULL(agt_lftNor,''),LftSouth=ISNULL(agt_lftSou,''),
								LftRefNo=ISNULL(agt_lftRefno,''),LftMktVal=ISNULL(agt_lftmgtval,0),LftAmenAmt=ISNULL(agt_amenAmt,0),
								LftRowId=@RowId,LftModifiedBy=@UsrDispNm,LftModifiedDt=@CurDt
						 FROM	#HDTLS
						 WHERE  LftPk = @DtlFk AND LftDelId = 0
						END
				 END

			IF @Action IN ('Save','Edit')
				BEGIN
					
					IF EXISTS(SELECT 'X' FROM #RptDtls)
						BEGIN
							
							INSERT	INTO #RptDocDtls(TRptDocFk,TRptPk)
							SELECT	LfdDocFk, LfdPk
							FROM	LosAgentFBDocs(NOLOCK)
							JOIN	LosDocument (NOLOCK) ON DocPk = LfdDocFk AND DocCat = 'RPT' AND DocDelId = 0
							WHERE	LfdLfjFk = @LfjFk AND LfdDelid = 0
							
							IF EXISTS(SELECT 'X' FROM #RptDocDtls)
								BEGIN
									UPDATE	LosDocument
									SET		DocDelid = 1, DocDelFlg = dbo.gefggetDelFlg(@CurDt), DocModifiedBy = @UsrDispNm, 
											DocModifiedDt = @CurDt, DocRowId = @RowId
									FROM	#RptDocDtls 
									WHERE	TRptDocFk = DocPk AND DocDelid = 0
									
									UPDATE	LosAgentFBDocs
									SET		LfdDelId = 1, LfdDelFlg = dbo.gefggetDelFlg(@CurDt),LfdRowId = @RowId,
											LfdModifiedBy = @UsrDispNm, LfdModifiedDt = @CurDt
									FROM	#RptDocDtls
									WHERE	TRptPk = LfdPk
									
									DELETE FROM #RptDocDtls
								END
							
							INSERT INTO LosDocument
							(
								DocLedFk,DocBGeoFk,DocPrdFk,DocActor,DocCat,DocSubCat,DocNm,DocPath,
								DocRowId,DocCreatedBy,DocCreatedDt,DocModifiedBy,DocModifiedDt,DocDelFlg,DocDelId,DocAgtFk,DocSubActor
							)
							OUTPUT  INSERTED.DocPk,0 INTO #RptDocDtls
							SELECT	@LeadPk , @GeoFk , @PrdFk, 0, 'RPT', 'RPT', 'Report',  RptPath,
									@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,NULL,0, @AgtFk, 1
							FROM	#RptDtls
							
							INSERT INTO  LosAgentFBDocs
							(
								LfdLfjFk,LfdDocFk,LfdNotes,LfdSts,LfdRowId,LfdCreatedBy,LfdCreatedDt,LfdModifiedBy,LfdModifiedDt,
								LfdDelFlg,LfdDelId
							)
							SELECT	@LfjFk, TRptDocFk,@Notes,@Sts,@RowId,@UsrDispNm,@CurDt,
									@UsrDispNm,@CurDt,NULL,0
							FROM	#RptDocDtls, #HDTLS
						END
								
					IF @JobSts = 1 
						BEGIN
							INSERT INTO #LajDtls
							SELECT  LajPk FROM LosAgentJob(NOLOCK) 
							JOIN	LosAgentVerf(NOLOCK) ON LavLajFk = LajPk AND LavDelid = 0
							WHERE	LajLedFk = @LeadPk AND LajSrvTyp = @LajServType AND LajDelid = 0
							AND		@LajServType IN (0,1,2,3)
							
							INSERT INTO #LajDtls
							SELECT  LajPk FROM LosAgentJob(NOLOCK) 
							JOIN	LosAgentPrpVerf(NOLOCK) ON LpvLajFk = LajPk AND LpvDelid = 0
							WHERE	LajLedFk = @LeadPk AND LajSrvTyp = @LajServType AND LajDelid = 0
							AND		@LajServType IN (4,5)

							INSERT INTO #LajDtls
							SELECT  LajPk FROM	LosAgentJob(NOLOCK) 
							JOIN	LosSeller (NOLOCK) ON LajLedFk = LslLedFk AND LslAgtFk = LajAgtFk 
														AND ISNULL(LslSelTrig,'') = 'Y' AND LslDelId = 0
							WHERE	LajLedFk = @LeadPk AND LajSrvTyp = @LajServType AND LajDelid = 0
							AND		@LajServType IN (6)
							
							SELECT	@InCount = COUNT(*) FROM #LajDtls
							
							SELECT	@OutCount = COUNT(*) FROM LosAgentFBJob(NOLOCK) 
							WHERE	EXISTS(SELECT 'X' FROM #LajDtls WHERE LajPk = LfjLajFk) AND LfjJobSts = 1 AND LfjDelid = 0

							IF @InCount = @OutCount
								SET @IsNext = 1;
						END
						
					SELECT	@LfjFk 'HdrFk' , ISNULL(@DtlFk,0) 'DtlFk', @IsNext 'IsNext'
					
					IF @Action = 'Save'
						SELECT	ISNULL(Pk,0) 'DPk', DocSts 'agt_DocSts', DocRmks 'agt_DocRmks',DocRef 'agt_DocFk'
						FROM	#SavedDoc
						JOIN	#DocDtls ON DocRef = DocFk
					ELSE
						SELECT	DPk 'DPk', DocSts 'agt_DocSts', DocRmks 'agt_DocRmks',DocRef 'agt_DocFk'
						FROM	#DocDtls
				END			
						
			IF @Action = 'Select'
				BEGIN
				 	
				IF @FLAG = 1

				BEGIN 
					
					INSERT INTO #PopupTempTbl(LfjFk,LpvFk)
					SELECT	LfjPk ,LavPk 
					FROM	LosAgentJob(NOLOCK)
					JOIN	LosAgentVerf(NOLOCK) ON  LavLajFk = LajPk AND LavLapFk = @LapFk AND LavDelId = 0
					JOIN	LosAgentFBJob(NOLOCK) ON LajPk = LfjLajFk AND LfjLavFk = LavPk AND LfjDelId = 0 
					WHERE	LajLedFk = @LeadPk AND LajSrvTyp = @LajServType AND LajDelId = 0

					SELECT @LfjFk = LfjFk ,@RefFk = LpvFk FROM #PopupTempTbl

				END

				 SELECT	DocPath 'RptPath', DocPk 'RptDocFk', LfdPk 'RptPk'
				 FROM	LosAgentFBDocs(NOLOCK)
				 JOIN	LosDocument(NOLOCK) ON DocPk = LfdDocFk AND DocCat = 'RPT' AND DocDelid = 0
				 WHERE	LfdLfjFk = @LfjFk AND LfdDelid = 0
				 
				 IF @LajServType  IN(0,1,2,3)
					BEGIN
						SELECT	LavLajFk 'LajFk',LapActor 'ActorType',LapFstNm + ' ' + LapMdNm + ' ' + LapLstNm 'AppNm',LavMobNo 'Contact',LavAddTyp 'AddTyp',LavDoorNo 'DoorNo',
								LavBuilding 'Building',LavPlotNo 'PlotNo',LavStreet 'Street',LavLandmark 'LandMark',LavArea 'Area',LavDistrict 'District',
								LavState 'State',LavCountry 'Country',LavPin 'Pincode',LavPk 'LavPk', LajSrvTyp 'ServiceType',
								CASE	WHEN LapGender = 0 THEN 'Male' WHEN LapGender = 1 THEN 'Female' END 'Gender',
								CASE	WHEN LajSrvTyp IN(0,2,3) THEN 'Residence Address' ELSE 'Office Address' END 'AddrType' ,
								dbo.gefgDMY(LfjRptDt) 'agt_rptdt', LfjRptSts 'agt_rptstatus', LfjNotes 'agt_notes',								
								ISNULL(AgtFName,'') + ' ' + ISNULL(AgtMName,'') + ' ' + ISNULL(AgtLName,'') 'AgentName','' 'SellerNm','none' 'slrnmdisp'
						FROM	LosAgentVerf (NOLOCK)
						JOIN	LosAgentJob (NOLOCK) ON LajPk = LavLajFk AND LavDelId = 0
						JOIN	GenAgents (NOLOCK) ON AgtPk = LajAgtFk AND AgtDelId = 0
						JOIN	LosAppProfile(NOLOCK) ON LapPk = LavLapFk AND LapDelid = 0
						JOIN	LosAgentFBJob (NOLOCK) ON LfjPk = @LfjFk AND LfjLavFk = LavPk AND LfjDelid = 0
						WHERE 	LavPk = @RefFk
					END
				ELSE IF @LajServType IN(4)
					BEGIN
						IF NOT EXISTS(SELECT 'X' FROM LosQde(NOLOCK) WHERE QdeLedFk = @LeadPk AND QdeDelid = 0)
							SET @IsExist = 0
						
						IF @IsExist = 0
							BEGIN
								SELECT 	LedNm 'AppNm',0 'ActorType', LpvDoorNo 'DoorNo',LpvBuilding 'Building',
										LpvPlotNo 'PlotNo',LpvStreet 'Street',LpvLandmark 'LandMark',LpvArea 'Area',LpvDistrict 'District',
										LpvState 'State',LpvCountry 'Country',LpvPin 'Pincode' ,LedMobNo 'Contact',LajSrvTyp 'ServiceType',LpvPk 'LpvPk',
										'' 'Gender' ,LajPk 'LajFk','Property Address' 'AddrType',dbo.gefgDMY(LfjRptDt) 'agt_rptdt', LfjRptSts 'agt_rptstatus', LfjNotes 'agt_notes', 
										LflEast 'agt_lftEst',LflWest 'agt_lftWst',LflNorth 'agt_lftNor',LflSouth 'agt_lftSou',LfjAgtRefNo 'agt_lftRefno',
										LflAppPlnNo 'agt_AppplnNo',LflAstCost 'agt_AstCost',LflRegChg 'agt_Regchg', LflStmpChg 'agt_stmpchg',
										LflAgrmtVal 'agt_agtval',LflPk 'DtlFk',ISNULL(AgtFName,'') + ' ' + ISNULL(AgtMName,'') + ' ' + ISNULL(AgtLName,'') 'AgentName','' 'SellerNm','none' 'slrnmdisp'
 								FROM	LosAgentPrpVerf(NOLOCK)
								JOIN	LosAgentJob (NOLOCK) ON LajPk = LpvLajFk AND LajDelId = 0
								JOIN	GenAgents (NOLOCK) ON AgtPk = LajAgtFk AND AgtDelId = 0
								JOIN	LosLead(NOLOCK) ON LedPk = LajLedFk AND LedDelid = 0
								JOIN	LosAgentFBJob (NOLOCK) ON LfjPk = @LfjFk AND LfjLpvFk = LpvPk AND LfjDelid = 0
								JOIN	LosAgentFBLegal(NOLOCK) ON LflLfjFk = LfjPk
								WHERE	LpvPk = @RefFk
							END
						ELSE
							BEGIN
								SELECT 	QDEFstNm + ' ' + QDEMdNm + ' ' + QDELstNm 'AppNm',0 'ActorType', LpvDoorNo 'DoorNo',LpvBuilding 'Building',
										LpvPlotNo 'PlotNo',LpvStreet 'Street',LpvLandmark 'LandMark',LpvArea 'Area',LpvDistrict 'District',
										LpvState 'State',LpvCountry 'Country',LpvPin 'Pincode' ,QDAContact 'Contact',LajSrvTyp 'ServiceType',LpvPk 'LpvPk',
										CASE	WHEN QDEGender = 0 THEN 'Male' WHEN QDEGender = 1 THEN 'Female' END 'Gender' ,LajPk 'LajFk',
										'Property Address' 'AddrType',dbo.gefgDMY(LfjRptDt) 'agt_rptdt', LfjRptSts 'agt_rptstatus', LfjNotes 'agt_notes', 
										LflEast 'agt_lftEst',LflWest 'agt_lftWst',LflNorth 'agt_lftNor',LflSouth 'agt_lftSou',LfjAgtRefNo 'agt_lftRefno',
										LflAppPlnNo 'agt_AppplnNo',LflAstCost 'agt_AstCost',LflRegChg 'agt_Regchg', LflStmpChg 'agt_stmpchg',
										LflAgrmtVal 'agt_agtval',LflPk 'DtlFk',ISNULL(AgtFName,'') + ' ' + ISNULL(AgtMName,'') + ' ' + ISNULL(AgtLName,'') 'AgentName','' 'SellerNm','none' 'slrnmdisp'
 								FROM	LosAgentPrpVerf(NOLOCK)
								JOIN	LosAgentJob (NOLOCK) ON LajPk = LpvLajFk AND LajDelId = 0
								JOIN	GenAgents (NOLOCK) ON AgtPk = LajAgtFk AND AgtDelId = 0
								JOIN	LosQDE (NOLOCK) ON QDEActor = 0 AND QdeLedFk =  LajLedFk AND QDEDelid = 0
								JOIN	LosQdeAddress(NOLOCK) ON QdaQdeFk = QdePk AND QdaDelid = 0
								JOIN	LosAgentFBJob (NOLOCK) ON LfjPk = @LfjFk AND LfjLpvFk = LpvPk AND LfjDelid = 0
								JOIN	LosAgentFBLegal(NOLOCK) ON LflLfjFk = LfjPk
								WHERE	LpvPk = @RefFk
							END
					END
				ELSE IF @LajServType IN(5)
					BEGIN
						IF NOT EXISTS(SELECT 'X' FROM LosQde(NOLOCK) WHERE QdeLedFk = @LeadPk AND QdeDelid = 0)
							SET @IsExist = 0
						
						IF @IsExist = 0
							BEGIN
								SELECT 	LedNm 'AppNm', 0 'ActorType', LpvDoorNo 'DoorNo',LpvBuilding 'Building',
										LpvPlotNo 'PlotNo',LpvStreet 'Street',LpvLandmark 'LandMark',LpvArea 'Area',LpvDistrict 'District',
										LpvState 'State',LpvCountry 'Country',LpvPin 'Pincode' ,LedMobNo 'Contact',LajSrvTyp 'ServiceType',LpvPk 'LpvPk',
										'' 'Gender' ,LajPk 'LajFk','Property Address' 'AddrType',dbo.gefgDMY(LfjRptDt) 'agt_rptdt', LfjRptSts 'agt_rptstatus', LfjNotes 'agt_notes',
										LftEast 'agt_lftEst',LftWest 'agt_lftWst',LftNorth 'agt_lftNor',LftSouth 'agt_lftSou',LfjAgtRefNo 'agt_lftRefno',
										LftMktVal 'agt_lftmgtval',LftAmenAmt 'agt_amenAmt', LftPk 'DtlFk',ISNULL(AgtFName,'') + ' ' + ISNULL(AgtMName,'') + ' ' + ISNULL(AgtLName,'') 'AgentName','' 'SellerNm','none' 'slrnmdisp'
 								FROM	LosAgentPrpVerf(NOLOCK) 
								JOIN	LosAgentJob (NOLOCK) ON LajPk = LpvLajFk AND LajDelId = 0
								JOIN	GenAgents (NOLOCK) ON AgtPk = LajAgtFk AND AgtDelId = 0
								JOIN	LosLead(NOLOCK) ON LedPk = LajLedFk AND LedDelid = 0
								JOIN	LosAgentFBJob (NOLOCK) ON LfjPk = @LfjFk AND LfjLpvFk = LpvPk AND LfjDelid = 0
								JOIN	LosAgentFBTechnical(NOLOCK) ON LftLfjFk = LfjPk AND LftDelid = 0
								WHERE	LpvPk = @RefFk
							END
						ELSE
							BEGIN
								SELECT 	QDEFstNm + '' + QDEMdNm + '' + QDELstNm 'AppNm', 0 'ActorType', LpvDoorNo 'DoorNo',LpvBuilding 'Building',
										LpvPlotNo 'PlotNo',LpvStreet 'Street',LpvLandmark 'LandMark',LpvArea 'Area',LpvDistrict 'District',
										LpvState 'State',LpvCountry 'Country',LpvPin 'Pincode' ,QDAContact 'Contact',LajSrvTyp 'ServiceType',LpvPk 'LpvPk',
										CASE	WHEN QDEGender = 0 THEN 'Male' WHEN QDEGender = 1 THEN 'Female' END 'Gender' ,LajPk 'LajFk',
										'Property Address' 'AddrType',dbo.gefgDMY(LfjRptDt) 'agt_rptdt', LfjRptSts 'agt_rptstatus', LfjNotes 'agt_notes',
										LftEast 'agt_lftEst',LftWest 'agt_lftWst',LftNorth 'agt_lftNor',LftSouth 'agt_lftSou',LfjAgtRefNo 'agt_lftRefno',
										LftMktVal 'agt_lftmgtval',LftAmenAmt 'agt_amenAmt', LftPk 'DtlFk',ISNULL(AgtFName,'') + ' ' + ISNULL(AgtMName,'') + ' ' + ISNULL(AgtLName,'') 'AgentName','' 'SellerNm','none' 'slrnmdisp'
 								FROM	LosAgentPrpVerf(NOLOCK) 
								JOIN	LosAgentJob (NOLOCK) ON LajPk = LpvLajFk AND LajDelId = 0
								JOIN	LosQDE (NOLOCK) ON QDEActor = 0 AND QdeLedFk =  LajLedFk AND QDEDelid = 0
								JOIN	GenAgents (NOLOCK) ON AgtPk = LajAgtFk AND AgtDelId = 0
								JOIN	LosQdeAddress(NOLOCK) ON QdaQdeFk = QdePk AND QdaDelid = 0
								JOIN	LosAgentFBJob (NOLOCK) ON LfjPk = @LfjFk AND LfjLpvFk = LpvPk AND LfjDelid = 0
								JOIN	LosAgentFBTechnical(NOLOCK) ON LftLfjFk = LfjPk AND LftDelid = 0
								WHERE	LpvPk = @RefFk
							END
					END
				ELSE IF @LajServType IN(6)
					BEGIN
						SELECT 	LslNm 'AppNm',0 'ActorType', LslDoorNo 'DoorNo',LslBuilding 'Building',
								LslPlotNo 'PlotNo',LslStreet 'Street',LslLandmark 'LandMark',LslArea 'Area',LslDistrict 'District',
								LslState 'State',LslCountry 'Country',LslPin 'Pincode' ,QDAContact 'Contact',LajSrvTyp 'ServiceType',LslPk 'LslPk',
								CASE	WHEN QDEGender = 0 THEN 'Male' WHEN QDEGender = 1 THEN 'Female' END 'Gender' ,LajPk 'LajFk',
								'Seller Details' 'AddrType',dbo.gefgDMY(LfjRptDt) 'agt_rptdt', LfjRptSts 'agt_rptstatus', LfjNotes 'agt_notes',ISNULL(AgtFName,'') + ' ' + ISNULL(AgtMName,'') + ' ' + ISNULL(AgtLName,'') 'AgentName',LslNm 'SellerNm','block' 'slrnmdisp'
 						FROM	LosSeller(NOLOCK) 
						JOIN	LosAgentJob (NOLOCK) ON LslLedFk = LajLedFk AND LajSrvTyp = 6 AND LslAgtFk = LajAgtFk AND ISNULL(LslSelTrig,'') = 'Y'
													 AND LslDelId = 0 
						JOIN	GenAgents (NOLOCK) ON AgtPk = LajAgtFk AND AgtDelId = 0
						JOIN	LosQDE (NOLOCK) ON QDEActor = 0 AND QdeLedFk =  LajLedFk AND QDEDelid = 0
						JOIN	LosQdeAddress(NOLOCK) ON QdaQdeFk = QdePk AND QdaDelid = 0
						JOIN	LosAgentFBJob (NOLOCK) ON LfjPk = @LfjFk AND LfjLslFk = LslPk AND LfjDelid = 0
						WHERE	LslPk = @RefFk AND AgtPk = LajAgtFK
					END
				IF @LajServType IN(2)
					BEGIN
						SELECT	ISNULL(LfdPk,0) 'DPk', LfdDocFk 'agt_DocFk',LfdSts 'agt_DocSts', LfdNotes 'agt_DocRmks',
								DocCat 'DocCategory',DocSubCat 'DocSubCategory',DocNm 'DocNm',DocPath 'DocPath',ISNULL(AgtFName,'') + ' ' + ISNULL(AgtMName,'') + ' ' + ISNULL(AgtLName,'') 'AgentName'
						FROM	LosAgentFBDocs(NOLOCK)
						JOIN	LosDocument A(NOLOCK) ON A.DocPk = LfdDocFk AND A.DocDelid = 0 
						JOIN	GenAgents (NOLOCK) ON AgtPk = DocAgtFk AND AgtDelId = 0
						WHERE	LfdLfjFk = @LfjFk AND LfdDelid = 0
						AND		NOT EXISTS(SELECT 'X' FROM LosDocument B(NOLOCK) WHERE B.DocPk = LfdDocFk AND B.DocCat = 'RPT' AND b.DocDelid = 0)
					END	
				
			END
			
			
		IF @Trancount = 1 AND @@TRANCOUNT = 1
			COMMIT TRAN

	END TRY
	BEGIN CATCH
		IF @Trancount = 1 AND @@TRANCOUNT = 1
			ROLLBACK TRAN

		SELECT	@ErrMsg = ERROR_MESSAGE() + ',' + ERROR_PROCEDURE() + ':' + Rtrim(ERROR_LINE()), @ErrSeverity = ERROR_SEVERITY()
		RAISERROR('%s', @ErrSeverity, 1,@ErrMsg)
		RETURN

	END CATCH

END