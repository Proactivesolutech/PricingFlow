IF OBJECT_ID('PrcShflAgtTrig','P') IS NOT NULL
DROP PROC PrcShflAgtTrig
GO
CREATE PROCEDURE PrcShflAgtTrig
(
	@Action		VARCHAR(100)	=	NULL,
	@GlobalJSON	VARCHAR(MAX)	=	NULL,
	@HdrJson    VARCHAR(MAX)	=	NULL,
	@AgtJson	VARCHAR(MAX)	=	NULL,	
	@AddJson	VARCHAR(MAX)	=	NULL,
	@propFK		BIGINT			=	NULL,
	@prdGfk     BIGINT			=	NULL,
	@IsLapPrd	BIT				=	0	
)
AS
BEGIN

--RAISERROR('Wait',16,1)
--RETURN

	SET NOCOUNT ON
	DECLARE @TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT, @Count INT
	DECLARE @CurDt DATETIME ,@RowId VARCHAR(MAX), @UsrDispNm VARCHAR(100)
	DECLARE @LeadPk BIGINT, @LeadID VARCHAR(100), @AppPk BIGINT, @BrnchFk BIGINT, @PrdFk BIGINT;
	DECLARE @Seller VARCHAR(250), @prpPrj VARCHAR(250), @prpTyp TINYINT
	DECLARE @lpvDoorNo VARCHAR(100), @lpvBuilding VARCHAR(100)
	DECLARE @lpvPlotNo VARCHAR(100), @lpvStreet VARCHAR(150), @lpvLandmark VARCHAR(250)
	DECLARE @lpvArea VARCHAR(150), @lpvDistrict VARCHAR(100), @lpvState VARCHAR(100)
	DECLARE @lpvCountry VARCHAR(100), @lpvPin VARCHAR(100), @MaxJobNo VARCHAR(100), @IsPropIden BIT = 0;
	DECLARE @AgtRefs TABLE(AgtFk BIGINT, AgtSrvTyp TINYINT, JobNo VARCHAR(100), LeadFk BIGINT, OrdNo INT)
	DECLARE @Prps TABLE(PrpFk BIGINT, Rowno INT IDENTITY(1,1))
	
	CREATE TABLE #globaldtls
	(
		xx_id BIGINT,FwdDataPk BIGINT,LeadID VARCHAR(MAX),UsrDispNm VARCHAR(100),BrnchFk BIGINT,PrdFk BIGINT,BranchNm VARCHAR(100),LeadNm VARCHAR(100),AppNo VARCHAR(100)
	)

	CREATE TABLE #HdrJson
	(
		xx_id BIGINT,Seller VARCHAR(100),prpPrj VARCHAR(100),prpTyp VARCHAR(100),
		lpvDoorNo VARCHAR(100), lpvBuilding VARCHAR(100),
		lpvPlotNo VARCHAR(100), lpvStreet VARCHAR(150), lpvLandmark VARCHAR(250),
		lpvArea VARCHAR(150), lpvDistrict VARCHAR(100), lpvState VARCHAR(100),
		lpvCountry VARCHAR(100), lvpqdaPin VARCHAR(6),prppk BIGINT
	)

	CREATE TABLE #AdrDtls
	(
		xx_id BIGINT,agt_app_Typ INT,agt_app_AppFk BIGINT,agt_app_LapFk BIGINT,agt_app_DoorNo VARCHAR(20), agt_app_Building VARCHAR(100),
		agt_app_PlotNo VARCHAR(20), agt_app_Street VARCHAR(150), agt_app_Landmark VARCHAR(250),
		agt_app_Area VARCHAR(150), agt_app_District VARCHAR(100), agt_app_State VARCHAR(100),
		agt_app_Country VARCHAR(100), agt_app_Pin VARCHAR(6)
	)
	CREATE TABLE #AgtDtls
	(
		xx_id BIGINT, AgtSrvTyp TINYINT, AgtFk BIGINT, LedFk BIGINT, PrpOrdNo INT
	)
	CREATE TABLE #InsertedAgtJob
	(
		LajFk BIGINT, SrvTyp TINYINT, AgtRef BIGINT,AgtLeadFk BIGINT,  AgtJobNo VARCHAR(50)
	)
	CREATE TABLE #LosAddTemp
	(
		xx_id BIGINT,laaAppPk BIGINT,Laaledfk BIGINT,qdeactor INT,qdename VARCHAR(100),qdemobNo VARCHAR(20),qdaaddtyp INT,
		qdaDoorNo VARCHAR(100),qdaBuilding VARCHAR(100),qdaPlotNo VARCHAR(100),qdaStreet VARCHAR(150),
		qdaLandmark VARCHAR(250),qdaArea VARCHAR(150),qdaDistrict VARCHAR(100),qdaState VARCHAR(100),
		qdaCountry VARCHAR(100),qdaPin VARCHAR(100), LapFk BIGINT, qdeSubActor TINYINT
	)
	--CREATE TABLE #PropFkUpdate
	--(
	--	PrpFk BIGINT,PrpLeadFk BIGINT,Typ INT
	--)

	IF  @GlobalJSON !='[]' AND @GlobalJSON !=''
		BEGIN
			INSERT INTO #globaldtls
			EXEC PrcParseJSON @GlobalJSON,'FwdDataPk,LeadID,UsrDispNm,BrnchFk,PrdFk,BranchNm,LeadNm,AppNo'

			SELECT @LeadPk = FwdDataPk, @LeadID = LeadID, @UsrDispNm = UsrDispNm, @BrnchFk = BrnchFk, @PrdFk = PrdFk FROM #globaldtls
		END
	IF @HdrJson != '[]' AND @HdrJson != ''
		BEGIN
			
			INSERT INTO #HdrJson
			EXEC PrcParseJSON @HdrJson,'agt_seller,agt_project,agt_prtytyp,agt_flno,agt_buildg,agt_plotno,agt_str,agt_lnmrk,agt_town,agt_city,agt_state,lpvCountry,agt_pin,agt_prppk'
			SET @IsPropIden = 1;	
					
		END
	
	IF @AddJson != '[]' AND @AddJson != ''
		BEGIN
			INSERT INTO #AdrDtls
			EXEC PrcParseJSON @AddJson,'agt_app_Typ,agt_app_AppFk,agt_app_LapFk,agt_app_DoorNo,agt_app_Building,agt_app_PlotNo,agt_app_Street,agt_app_Landmark,agt_app_Area,agt_app_District,agt_app_State,agt_app_Country,agt_app_Pin'
		END
		
	IF @AgtJson != '[]' AND @AgtJson != ''
		BEGIN
			INSERT INTO #AgtDtls(xx_id,AgtSrvTyp,AgtFk,PrpOrdNo)
			EXEC PrcParseJSON @AgtJson,'agt_SrvTyp,agt_AgtFk,agt_PrpKey'

			SELECT @MaxJobNo = CONVERT(BIGINT,RIGHT(MAX(LajJobNo),5)) FROM LosAgentJob(NOLOCK)

			INSERT INTO @AgtRefs(AgtFk,LeadFk,AgtSrvTyp,JobNo,OrdNo)
			SELECT AgtFk, @LeadPk, AgtSrvTyp, 'JOB_' + dbo.gefgGetPadZero(5,(ISNULL(@MaxJobNo,0) + ROW_NUMBER() OVER(ORDER BY AgtFk,AgtSrvTyp))),PrpOrdNo
			FROM   #AgtDtls
		END

	SELECT @CurDt = GETDATE(), @RowId = NEWID()

	BEGIN TRY

		IF @@TRANCOUNT = 0
			SET @TranCount = 1

		IF @TranCount = 1
			BEGIN TRAN
			    IF @Action='SEL_PRD'
				BEGIN

						SELECT	LedNm 'nm',GrpPk 'productpk', GrpCd 'PCd',GrpIconCls 'icon_class',GrpNm 'prdname'
				        FROM	GenLvlDefn(NOLOCK)
				        JOIN    LosLead ON LedPGrpFk=GrpPk
				        WHERE   GrpDelId = 0 AND LedPk = @LeadPk
				 
				END

				IF @Action='SELECT_AGT'
					BEGIN
						SELECT	AgtCd,AgtTitle,AgtFName,AgtMName,AgtLName,AgtDoorNo,AgtBuilding,AgtPlotNo,AgtStreet,
								AgtLandmark,AgtArea,AgtDistrict,AgtState,AgtCountry,AgtPin,AgtPk
						FROM	genagents(NOLOCK) WHERE AgtDelid = 0
					END

				IF @Action ='SEL_LEAD'
					BEGIN
						SELECT	LedId 'LeadID',BranchNm,LedNm 'LeadNm',AppNo , ISNULL(LedLnAmt,0) 'LnAmt'
						FROM	LosLead (NOLOCK)
						JOIN	#globaldtls ON FwdDataPk = LedPk
						WHERE	LedPk = @LeadPk
					END	

				IF @Action='SELECT'
					BEGIN
						SELECT @Count = COUNT(*) FROM Losprop(NOLOCK) WHERE PrpLedFk= @LeadPk

						SELECT	PrpSeller 'agt_seller',PrpPrj 'agt_project',PrpTyp 'agt_prtytyp',PrpDoorNo 'agt_flno',PrpBuilding 'agt_buildg',
								PrpPlotNo 'agt_plotno',PrpStreet 'agt_str',PrpLandmark 'agt_lnmrk',PrpArea 'agt_town',PrpDistrict 'agt_city',PrpState 'agt_state',
								PrpPin 'agt_pin',PrpPk 'agt_prpPk'
						FROM	Losprop(NOLOCK)
						WHERE	PrpLedFk= @LeadPk AND PrpDelid = 0

						SELECT @RowCount = @@ROWCOUNT;

						IF @Count > 0
						BEGIN
							IF @RowCount > 0
								SELECT 0 'PrpIden','UPDATE' 'Action';
							ELSE
								SELECT 1 'PrpIden','UPDATE' 'Action';
							END
						ELSE
							SELECT 0 'PrpIden','INSERT' 'Action';

						SELECT LajAgtFk 'agt_AgtFk',LajSrvTyp 'agt_SrvTyp',LajPk
						FROM   LosAgentJob (NOLOCK)
						WHERE  LajLedFk = @LeadPk AND LajDelid = 0
						
						SELECT		@AppPk = AppPk FROM LosApp(NOLOCK) WHERE AppLedFk = @LeadPk AND AppDelId = 0
						
						SELECT		CASE LapActor WHEN 2 THEN 'Guarnator' WHEN 1 THEN 'CoApplicant' ELSE 'Applicant' END 'ActorTyp',
									LapAppFk 'agt_app_AppFk',LapPk 'agt_app_LapFk',ISNULL(LaaAddTyp,-1) 'agt_app_Typ',
									ISNULL(LaaDoorNo,'') 'agt_app_DoorNo',ISNULL(LaaBuilding,'') 'agt_app_Building',
									ISNULL(LaaPlotNo,'') 'agt_app_PlotNo',ISNULL(LaaStreet,'') 'agt_app_Street',
									ISNULL(LaaLandmark,'') 'agt_app_Landmark',ISNULL(LaaArea,'') 'agt_app_Area',
									ISNULL(LaaDistrict,'') 'agt_app_District',ISNULL(LaaState,'') 'agt_app_State',
									RTRIM(LTRIM(ISNULL(LaaPin,''))) 'agt_app_pin',LapEmpTyp 'agt_Addr_Type'
						FROM		LosAppProfile(NOLOCK)
						LEFT JOIN	LosAppAddress(NOLOCK) ON LaaAppFk = @AppPk AND LaaAddTyp IN (2,3,4,-1) AND LaaLapFk = LapPk AND LaaDelid = 0
						WHERE		LapAppFk = @AppPk AND LapDelid = 0
				
					END

				IF @Action IN ('INSERT_ADR','INSERT','UPDATE','INSERT_AGT') 
					BEGIN
					
						SELECT @AppPk = AppPk FROM LosApp(NOLOCK) WHERE AppLedFk = @LeadPk AND AppDelId = 0

						UPDATE	LosAppAddress
						SET		LaaDoorNo = agt_app_DoorNo,LaaBuilding = agt_app_Building,LaaPlotNo =agt_app_PlotNo,
								LaaStreet = agt_app_Street,LaaLandmark = agt_app_Landmark,LaaArea = agt_app_Area,
								LaaDistrict = agt_app_District,LaaState = agt_app_State,LaaCountry = 'INDIA',LaaPin = agt_app_pin,
								LaaRowId = @RowId,LaaModifiedBy = @UsrDispNm,LaaModifiedDt = @CurDt
						FROM	#AdrDtls
						WHERE	LaaLedFk = @LeadPk AND LaaAppFk = agt_app_AppFk AND LaaAddTyp IN (2,3,4,-1) AND LaaLapFk = agt_app_LapFk AND LaaDelid = 0
	
						INSERT INTO LosAppAddress
						(
							LaaLedFk,LaaAppFk,LaaLapFk,LaaAddTyp,LaaDoorNo,LaaBuilding,LaaPlotNo,LaaStreet,LaaLandmark,LaaArea,
							LaaDistrict,LaaState,LaaCountry,LaaPin,LaaRowId,LaaCreatedBy,LaaCreatedDt,LaaModifiedBy,LaaModifiedDt,LaaDelFlg,
							LaaDelId,LaaAcmTyp,LaaComAdd,LaaYrsResi
						)
						SELECT	@LeadPk,agt_app_AppFk,agt_app_LapFk,agt_app_Typ,agt_app_DoorNo,agt_app_Building,agt_app_PlotNo,agt_app_Street,
								agt_app_Landmark,agt_app_Area,agt_app_District,agt_app_State,'INDIA',agt_app_Pin,
								@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,NULL,0,0,0,0
						FROM	#AdrDtls
						WHERE	NOT EXISTS
						(
							SELECT 'X' FROM  LosAppAddress(NOLOCK) 
							WHERE	LaaLedFk = @LeadPk AND LaaAppFk = agt_app_AppFk AND LaaAddTyp IN (2,3,4,-1) AND LaaLapFk = agt_app_LapFk AND LaaDelid = 0
						) 
						
					END
					
				IF @Action IN('INSERT','UPDATE','INSERT_AGT') 
					BEGIN
					
						INSERT INTO #LosAddTemp
						(
							Laaledfk,laaAppPk,qdeactor,qdename,qdemobNo,qdaaddtyp,qdaDoorNo,qdaBuilding,qdaPlotNo,qdaStreet,qdaLandmark,
							qdaArea,qdaDistrict,qdaState,qdaCountry,qdaPin, LapFk, qdeSubActor
						)
						SELECT		@LeadPk,@AppPk,QDEActor,QDEFstNm,QDAContact,QDAAddTyp,ISNULL(QDADoorNo,''),ISNULL(QDABuilding,''),
									ISNULL(QDAPlotNo,''),ISNULL(QDAStreet,''),
									ISNULL(QDALandmark,''),ISNULL(QDAArea,''),ISNULL(QDADistrict,''),ISNULL(QDAState,''),
									ISNULL(QDACountry,''),ISNULL(QDAPin,''), LapPk, ISNULL(QDESubActor,1)
						FROM		LosQDEAddress(NOLOCK)
						JOIN 		LosQDE(NOLOCK) ON QDEPk = QDAQDEFK AND QDELedFk = @LeadPk AND QdeDelid = 0
						JOIN		LosAppProfile(NOLOCK) ON LapLedFk = QdeLedFk AND LapCusFk = QdeCusFk AND LapDelid = 0
						WHERE		QDADelId = 0

						IF @IsPropIden = 0 
								BEGIN
									UPDATE Losprop SET PrpDelid = 1, PrpRowId=@RowId, PrpModifiedBy=@UsrDispNm,PrpModifiedDt=@CurDt, 
									PrpDelFlg= dbo.gefgGetDelFlg(@curDt)
									WHERE PrpLedFk = @LeadPk AND PrpDelid = 0
								END
						ELSE
							BEGIN
								UPDATE  A 	SET						       											            
											A.PrpSeller = B.Seller, A.PrpPrj = B.prpPrj, A.PrpTyp = ISNULL(B.prpTyp,0), PrpAppFk = @AppPk,
											A.PrpDoorNo = B.lpvDoorNo, A.PrpBuilding = B.lpvBuilding, A.PrpPlotNo = B.lpvPlotNo, A.PrpStreet = B.lpvStreet,
											A.PrpLandmark = B.lpvLandmark, A.PrpArea = B.lpvArea, A.PrpDistrict = B.lpvDistrict,A.PrpState = B.lpvState,
											A.PrpPin = B.lvpqdaPin ,A.PrpRowId = @RowId, A.PrpCreatedBy = @UsrDispNm ,A.PrpCreatedDt = @CurDt,
											A.PrpModifiedBy = @UsrDispNm, A.PrpModifiedDt = @CurDt										
								FROM LosProp A JOIN #HdrJson B ON B.prppk = A.PrpPk
								WHERE A.PrpPk = B.prppk AND B.prppk <> 0 AND PrpDelId = 0							
							END

						INSERT INTO Losprop      
							(             
								PrpSeller,PrpPrj,PrpTyp,PrpLedFk,PrpAppFk,PrpDoorNo,PrpBuilding,PrpPlotNo,PrpStreet,
								PrpLandmark,PrpArea,PrpDistrict,PrpState,PrpCountry,PrpPin,PrpRowId,PrpCreatedBy,
								PrpCreatedDt,PrpModifiedBy,PrpModifiedDt,PrpDelFlg,PrpDelId
							)
						--OUTPUT	INSERTED.*
						SELECT  Seller ,prpPrj ,prpTyp ,@LeadPk,@AppPk,lpvDoorNo , lpvBuilding ,lpvPlotNo , lpvStreet , lpvLandmark ,
								lpvArea , lpvDistrict , lpvState ,'India',lvpqdaPin,@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,NULL,0
						FROM	#HdrJson WHERE  prppk = 0				

					END												
					IF @Action = 'INSERT_AGT' 					
						BEGIN	
							IF @IsPropIden = 1				
							BEGIN 

								INSERT INTO LosAgentJob
								(              
									LajAgtFk,LajSrvTyp,LajJobNo,LajJobDt,LajLedFk,LajLedNo,LajBGeoFk, LajPrdFk,
									LajRowId,LajCreatedBy,LajCreatedDt,LajModifiedBy,LajModifiedDt,LajDelFlg,LajDelId,LajPGrpFk
								)
								OUTPUT	INSERTED.LajPk, INSERTED.LajSrvTyp, inserted.LajAgtfk,inserted.LajLedFk,inserted.LajJobNo INTO #InsertedAgtJob
								SELECT	AgtFk,AgtSrvTyp,JobNo,@CurDt, @LeadPk, @LeadID,@BrnchFk,@PrdFk,@RowId,@UsrDispNm,@CurDt,@UsrDispNm,
										@CurDt,NULL,0,@prdGfk
								FROM	@AgtRefs WHERE AgtSrvTyp IN(4,5)
								AND		AgtFk > 0
								
								SELECT	@Error = @@ERROR, @RowCount = @@ROWCOUNT

								IF @Error > 0
									BEGIN
										RAISERROR('%s',16,1,'Error : Agent Job Table')
										RETURN
									END
								IF @RowCount = 0
									BEGIN
										RAISERROR('%s',16,1,'Error : No Records Found for Inserting Agent Job Table')
										RETURN
									END
							END	
							
						INSERT INTO LosAgentJob
						(              
							LajAgtFk,LajSrvTyp,LajJobNo,LajJobDt,LajLedFk,LajLedNo,LajBGeoFk, LajPrdFk,
							LajRowId,LajCreatedBy,LajCreatedDt,LajModifiedBy,LajModifiedDt,LajDelFlg,LajDelId,LajPGrpFk
						)
						OUTPUT	INSERTED.LajPk, INSERTED.LajSrvTyp, inserted.LajAgtfk,inserted.LajLedFk,inserted.LajJobNo INTO #InsertedAgtJob
						SELECT	AgtFk,AgtSrvTyp,JobNo,@CurDt, @LeadPk, @LeadID, @BrnchFk,@PrdFk,@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,NULL,0,@prdGfk
						FROM	@AgtRefs WHERE AgtSrvTyp IN(0,1,2,3)
						AND		AgtFk > 0
						
						SELECT	@Error = @@ERROR, @RowCount = @@ROWCOUNT

						IF @Error > 0
							BEGIN
								RAISERROR('%s',16,1,'Error : Agent Job Table')
								RETURN
							END
						IF @RowCount = 0
							BEGIN
								RAISERROR('%s',16,1,'Error : No Records Found for Inserting Agent Job Table')
								RETURN
							END							
		
						
						INSERT INTO LosAgentVerf 
						(              
							LavLajFk,LavLapFk,LavNm,LavMobNo,LavAddTyp,LavDoorNo,LavBuilding,LavPlotNo,
							LavStreet,LavLandmark,LavArea,LavDistrict,LavState,LavCountry,LavPin,
							LavRowId,LavCreatedBy,LavCreatedDt,LavModifiedBy,LavModifiedDt,LavDelFlg,LavDelId
						)
						--OUTPUT	INSERTED. *
						SELECT	LajFK,LapFk,qdename,qdemobNo,qdaaddtyp,qdaDoorNo,qdaBuilding,qdaPlotNo,
								qdaStreet,qdaLandmark,qdaArea,qdaDistrict,qdaState,'India',qdaPin,@RowId,
								@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,NULL,0
						FROM	@AgtRefs 
						JOIN	#InsertedAgtJob ON AgtFk = AgtRef AND AgtSrvTyp = SrvTyp
						JOIN	#LosAddTemp ON LeadFk = Laaledfk
						WHERE	AgtSrvTyp IN (0,2)
						AND		AgtFk > 0
							
						SELECT	@Error = @@ERROR

						IF @Error > 0
							BEGIN
								RAISERROR('%s',16,1,'Error : Agent Job Verification Table')
								RETURN
							END
						
						INSERT INTO LosAgentVerf 
						(              
							LavLajFk,LavLapFk,LavNm,LavMobNo,LavAddTyp,LavDoorNo,LavBuilding,LavPlotNo,
							LavStreet,LavLandmark,LavArea,LavDistrict,LavState,LavCountry,LavPin,
							LavRowId,LavCreatedBy,LavCreatedDt,LavModifiedBy,LavModifiedDt,LavDelFlg,LavDelId
						)
						SELECT	LajFK,LapFk,qdename,qdemobNo,qdaaddtyp,qdaDoorNo,qdaBuilding,qdaPlotNo,
								qdaStreet,qdaLandmark,qdaArea,qdaDistrict,qdaState,'India',qdaPin,@RowId,
								@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,NULL,0
						FROM	@AgtRefs 
						JOIN	#InsertedAgtJob ON AgtFk = AgtRef AND AgtSrvTyp = SrvTyp
						JOIN	#LosAddTemp ON LeadFk = Laaledfk AND qdeactor = 0
						WHERE	AgtSrvTyp = 3
						AND		AgtFk > 0
						
						IF @Error > 0
							BEGIN
								RAISERROR('%s',16,1,'Error : Agent Job Collection Feedback Verification Table')
								RETURN
							END
							
						INSERT INTO LosAgentVerf
						(              
								LavLajFk,LavLapFk,LavNm,LavMobNo,LavAddTyp,LavDoorNo,LavBuilding,LavPlotNo,
								LavStreet,LavLandmark,LavArea,LavDistrict,LavState,LavCountry,LavPin,
								LavRowId,LavCreatedBy,LavCreatedDt,LavModifiedBy,LavModifiedDt,LavDelFlg,LavDelId
						)
						--OUTPUT	INSERTED. *
						SELECT      LajFK,LapFk,qdename,qdemobNo,Laaaddtyp,LaaDoorNo,LaaBuilding,LaaPlotNo,
									LaaStreet,LaaLandmark,LaaArea,LaaDistrict,LaaState,'India',LaaPin,
									@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,NULL,0
						FROM		@AgtRefs
						JOIN		#InsertedAgtJob ON AgtFk = AgtRef AND AgtSrvTyp = SrvTyp
						JOIN		#LosAddTemp ON LeadFk = Laaledfk
						JOIN		LosAppAddress (NOLOCK) ON LaaLapFk = LapFk AND LaaAddTyp IN (2,3,4,-1) AND LaaDelid =0
						WHERE		AgtSrvTyp = 1
						AND			AgtFk > 0
						
						SELECT	@Error = @@ERROR

						IF @Error > 0
							BEGIN
								RAISERROR('%s',16,1,'Error : Agent Job FI (Office) Verification Table')
								RETURN
							END
						
						/*
						INSERT INTO	LosAgentDocs
						(
							LadLajFk,LadDocFk,LadSrvTyp,LadDpdFk,LadDocCt,LadDocSubCt,LadRowId,LadCreatedBy,LadCreatedDt,LadModifiedBy,LadModifiedDt,LadDelFlg,LadDelId
						)
						--OUTPUT	INSERTED. *
						SELECT  LajFK,DocPk,SrvTyp,LavPk,DocCat,DocSubCat,@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,0,0 
						FROM	LosAgentVerf (NOLOCK)
						JOIN	#InsertedAgtJob ON LavLajFk = LajFk
						JOIN	#LosAddTemp ON LapFk = LavLapFk
						JOIN	LosDocument(NOLOCK) ON DocCat NOT IN ('RPT') AND DocLedFk = @LeadPk AND DocActor = qdeactor 
						AND		DocSubActor = qdeSubActor AND DocDelId = 0
						WHERE	SrvTyp IN (2)
						
						SELECT	@Error = @@ERROR

						IF @Error > 0
							BEGIN
								RAISERROR('%s',16,1,'Error : Agent Job Document Verification Table')
								RETURN
							END
						*/
						
						IF @IsPropIden = 1
							BEGIN
								IF @IsLapPrd = 1
									BEGIN
										INSERT INTO  LosAgentPrpVerf
										(              
											LpvLajFk,LpvPrpSeller,LpvPrpPrj,LpvPrpTyp,LpvBuyNm,LpvDoorNo,LpvBuilding,LpvPlotNo,LpvStreet,LpvLandmark,
											LpvArea,LpvDistrict,LpvState,LpvCountry,LpvPin,LpvRowId,LpvCreatedBy,LpvCreatedDt,LpvModifiedBy,
											LpvModifiedDt,LpvDelFlg,LpvDelId, LpvPrpFk
										)
										--OUTPUT	INSERTED. *
										SELECT      LajFK,PrpSeller,prpPrj,prpTyp,'',PrpDoorNo,PrpBuilding,PrpPlotNo,
													PrpStreet,PrpLandmark,PrpArea,PrpDistrict,PrpState,'India',PrpPin,@RowId,
													@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,NULL,0, PrpPk
										FROM     	#InsertedAgtJob 						
										JOIN		LosProp(NOLOCK) ON PrpLedFk = AgtLeadFk
										WHERE		SrvTyp IN (4)
						
										SELECT	@Error = @@ERROR

										IF @Error > 0
											BEGIN
												RAISERROR('%s',16,1,'Error : Agent Job TV/LV Verification Table')
												RETURN
											END
										
										INSERT INTO @Prps
										SELECT PrpPk FROM LosProp(NOLOCK) WHERE PrpLedFk = @LeadPk AND PrpDelid = 0

										INSERT INTO  LosAgentPrpVerf
										(              
											LpvLajFk,LpvPrpSeller,LpvPrpPrj,LpvPrpTyp,LpvBuyNm,LpvDoorNo,LpvBuilding,LpvPlotNo,LpvStreet,LpvLandmark,
											LpvArea,LpvDistrict,LpvState,LpvCountry,LpvPin,LpvRowId,LpvCreatedBy,LpvCreatedDt,LpvModifiedBy,
											LpvModifiedDt,LpvDelFlg,LpvDelId, LpvPrpFk
										)
										SELECT      LajFK,PrpSeller,prpPrj,prpTyp,'',PrpDoorNo,PrpBuilding,PrpPlotNo,
													PrpStreet,PrpLandmark,PrpArea,PrpDistrict,PrpState,'India',PrpPin,@RowId,
													@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,NULL,0, PrpPk
										FROM     	#InsertedAgtJob
										JOIN		@AgtRefs ON AgtFk = AgtRef AND AgtSrvTyp = 5 AND LeadFk = AgtLeadFk AND AgtJobNo = JobNo
										JOIN		LosProp(NOLOCK) ON PrpLedFk = AgtLeadFk
										AND			EXISTS(SELECT 'X' FROM @Prps WHERE PrpFk = PrpPk AND Rowno = OrdNo) AND PrpDelid = 0
										WHERE		SrvTyp IN (5)
										AND			AgtFk > 0
						
										SELECT	@Error = @@ERROR

										IF @Error > 0
											BEGIN
												RAISERROR('%s',16,1,'Error : Agent Job TV/LV Verification Table')
												RETURN
											END
									END
								ELSE
									BEGIN
										INSERT INTO  LosAgentPrpVerf
										(              
											LpvLajFk,LpvPrpSeller,LpvPrpPrj,LpvPrpTyp,LpvBuyNm,LpvDoorNo,LpvBuilding,LpvPlotNo,LpvStreet,LpvLandmark,
											LpvArea,LpvDistrict,LpvState,LpvCountry,LpvPin,LpvRowId,LpvCreatedBy,LpvCreatedDt,LpvModifiedBy,
											LpvModifiedDt,LpvDelFlg,LpvDelId, LpvPrpFk
										)
										--OUTPUT	INSERTED. *
										SELECT      LajFK,PrpSeller,prpPrj,prpTyp,'',PrpDoorNo,PrpBuilding,PrpPlotNo,
													PrpStreet,PrpLandmark,PrpArea,PrpDistrict,PrpState,'India',PrpPin,@RowId,
													@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,NULL,0, PrpPk
										FROM     	#InsertedAgtJob 						
										JOIN		LosProp(NOLOCK) ON PrpLedFk = AgtLeadFk
										WHERE		SrvTyp IN (4,5)
						
										SELECT	@Error = @@ERROR

										IF @Error > 0
											BEGIN
												RAISERROR('%s',16,1,'Error : Agent Job TV/LV Verification Table')
												RETURN
											END
									END
							END
				END
				IF @Action = 'DOCUMENT'
				BEGIN
				SELECT	DocCat	'Catogory',	DocSubCat 'SubCatogory',DocNm 'DocName',DocPath 'DocPath',DocPk 'Pk',DocLedFk 'LeadFk',
						ISNULL(AgtFName,'') + ' ' +  ISNULL(AgtMName,'') + ' ' + ISNULL(AgtLName,'') 'AgentNm',DocBGeoFk 'GeoFk',DocPrdFk 'PrdFk',
						CASE WHEN DocActor = 0 THEN 'Applicant' WHEN DocActor = 1  THEN 'Co-Applicant' WHEN DocActor = 2  THEN 'Guarantor' END 'Actor'
						FROM LosDocument(NOLOCK)
						JOIN GenAgents(NOLOCK) ON AgtPk = DocAgtFk AND AgtDelid = 0
						JOIN #globaldtls ON FwdDataPk = DocLedFk			
						WHERE DocDelId=0 AND DocCat !='RPT'
				END

				IF @Action = 'DELETE'
				BEGIN
					UPDATE	Losprop SET PrpDelid = 1, PrpRowId=@RowId, PrpModifiedBy=@UsrDispNm,PrpModifiedDt=@CurDt, 
							PrpDelFlg= dbo.gefgGetDelFlg(@curDt)
					WHERE	PrpPk = @propFK AND PrpDelid = 0
				END
			IF @Trancount = 1 AND @@TRANCOUNT = 1
				COMMIT TRAN

	END TRY
	BEGIN CATCH

	IF @Trancount = 1 AND @@TRANCOUNT = 1
		ROLLBACK TRAN	

	SELECT	@ErrMsg = ERROR_MESSAGE(),-- + ',' + ERROR_PROCEDURE() + ':' + RTRIM(ERROR_LINE()),
			@ErrSeverity = ERROR_SEVERITY()

	RAISERROR('%s', @ErrSeverity, 1,@ErrMsg) 		
	RETURN

	END CATCH	
END


	





	
