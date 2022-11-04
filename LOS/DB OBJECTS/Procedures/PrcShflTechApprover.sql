IF EXISTS(SELECT NULL FROM sysobjects WHERE name='PrcShflTechApprover' AND [type]='P')
	DROP PROC PrcShflTechApprover
GO
CREATE PROCEDURE PrcShflTechApprover
(
    @Action		  VARCHAR(100)		=	NULL,
	@GlobalJson   VARCHAR(MAX)		=	NULL,
	@DtlsJson	  VARCHAR(MAX)		=	NULL ,
	@DevJson	  VARCHAR(MAX)		=	NULL
)
AS
BEGIN
--RETURN
	SET NOCOUNT ON
	SET ANSI_WARNINGS ON
	
		DECLARE  @CurDt DATETIME,@RowId VARCHAR(40),@UsrDispNm VARCHAR(100),@LeadPk BIGINT,@TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), 
				 @Error INT, @RowCount INT, @agt_JobDt VARCHAR(100),@agt_DocFk VARCHAR(100),@RefFk BIGINT ,  @LajServType BIGINT,@AgtFk BIGINT,@MaxJobNo VARCHAR(100),
				 @LajFk BIGINT, @RptPath VARCHAR(MAX),@GeoFk BIGINT, @PrdFk BIGINT, @DocPk BIGINT,@PrpPk BIGINT,@PrpTechPk BIGINT, @UsrPk BIGINT, @AppFk BIGINT,
				 @Approver VARCHAR(20)

	
	CREATE TABLE #GlobalDtls
	(
		xx_id BIGINT,LeadPk BIGINT,LeadId VARCHAR(100),LeadNm VARCHAR(100),AppNo VARCHAR(100), GeoFk BIGINT, BranchNm VARCHAR(100),UsrDispNm VARCHAR(100),
		PrdFk BIGINT,PrdNm VARCHAR(100),AgtFk BIGINT,UsrPk BIGINT,Approver VARCHAR(20)
	)
	CREATE TABLE #DtlsTbl
	(
		xx_id BIGINT,MktVal VARCHAR(100),AmenAmt VARCHAR(100),PrpValRmks VARCHAR(500),PrpTyp VARCHAR(100),DemolishRsk VARCHAR(100),UdsArea VARCHAR(100),
		Udsmmt VARCHAR(100),UdsVal VARCHAR(100),SupBuldArea VARCHAR(100),SupBuldmmt VARCHAR(100),BuldArea VARCHAR(100),Buldmmt VARCHAR(100),CrpArea VARCHAR(100),
		Crpmmt VARCHAR(100),Estmt VARCHAR(100),OwnTyp VARCHAR(100),PossessTyp VARCHAR(100),SurvNo VARCHAR(100),LocTyp VARCHAR(100),ApprLandUse VARCHAR(100),
		ApprAuth VARCHAR(100),BuildApprAuth VARCHAR(100),PropDtRmks VARCHAR(500),BuldAge VARCHAR(100),EstmtBuldLife VARCHAR(100),StructTyp VARCHAR(100),FloorNo VARCHAR(100),
		ConstPer VARCHAR(100),ConstRmks VARCHAR(500),LandArea VARCHAR(100),LandVal VARCHAR(100),Landmmt VARCHAR(100),LeasePer VARCHAR(100),TechPrpPk BIGINT,
		DistressVal VARCHAR(25), Mumty VARCHAR(10), PropOccupancy VARCHAR(5),techEst VARCHAR(100), techWst VARCHAR(100), techNor VARCHAR(100),techSou VARCHAR(100),
		techRefno VARCHAR(100),techstatus BIGINT, PrpFK BIGINT,techAppplnNo VARCHAR(100),tech_agtFk BIGINT,techExsConsVal VARCHAR(100),techProposConstVal VARCHAR(100)
	)
	CREATE TABLE #ManualDev
	(
		xx_id BIGINT,DelLvl VARCHAR(100),DevRemarks VARCHAR(MAX)
	)

	SELECT @CurDt = GETDATE(), @RowId = NEWID()	

	IF @GlobalJson != '[]' AND @GlobalJson != ''
	BEGIN	
		
		INSERT INTO #GlobalDtls
		EXEC PrcParseJSON @GlobalJson,'LeadPk,LeadId,LeadNm,AppNo,GeoFk,BranchNm,UsrDispNm,PrdFk,PrdNm,AgtFk,UsrPk,Approver'

		SELECT	@LeadPk = LeadPk, @UsrDispNm = UsrDispNm, 
				@PrdFk = PrdFk, @GeoFk = GeoFk, @AgtFk = AgtFk, @GeoFk=GeoFk, @UsrPk = UsrPk, @Approver=Approver
		FROM	#GlobalDtls

		SELECT	@PrpPk = PrpPk
		FROM	LosProp(NOLOCK) WHERE PrpLedFk = @LeadPk

		SELECT	@AppFk = AppPk
		FROM	LosApp(NOLOCK) WHERE AppLedFk = @LeadPk
			
	END
	IF @DtlsJson != '[]' AND @DtlsJson != ''
	BEGIN	

		INSERT INTO #DtlsTbl
		EXEC PrcParseJSON @DtlsJson,'tech_mktval,tech_amenamt,tech_propremarks,tech_proptyp,tech_demolrisk,tech_UDSarea,tech_udsmmt,tech_UDSval,tech_supbuildarea,tech_supbuildmmt,tech_buildarea,tech_buildupmmt,tech_carpetarea,tech_carpetmmt,tech_estimate,tech_ownertype,tech_possessiontyp,tech_surveyno,tech_loctyp,tech_landuse,tech_apprauth,tech_buildapprauth,tech_prpdtlsremarks,tech_buildingage,tech_estimatebuilding,tech_structyp,tech_nooffloor,tech_construction,tech_constremarks,tech_landarea,tech_landvalue,tech_landmmt,tech_leasepriod,tech_prpPk,tech_distressval,tech_mumty,tech_propoccupy,tech_Est,tech_Wst,tech_Nor,tech_Sou,tech_Refno,tech_status,propfk,tech_AppplnNo,tech_agtFk,tech_ExsConsVal,tech_ProposConstVal'
		SELECT @PrpTechPk = TechPrpPk FROM	#DtlsTbl
	END
	IF @DevJson != '[]' AND @DevJson != ''
	BEGIN
			INSERT INTO #ManualDev
			EXEC PrcParseJSON @DevJson, 'tech_deviationLvl,tech_DeviationRmks'
	END
	

	BEGIN TRY
	
		IF @@TRANCOUNT = 0
			SET @TranCount = 1

		IF @TranCount = 1
			BEGIN TRAN		
				IF @Action = 'S'
					BEGIN
						SELECT	LeadPk 'LeadPk',LeadId 'LeadId',LeadNm 'LeadNm',AppNo 'AppNo',GeoFk 'GeoFk',BranchNm 'BranchNm',UsrDispNm 'UsrDispNm',
								PrdFk 'PrdFk',PrdNm 'PrdNm',LedPGrpFk 'LedPGrpFk',GrpNm 'GrpNm',GrpIconCls 'GrpIconCls'
						FROM	#GlobalDtls
						JOIN	LosLead(NOLOCK) ON LedPk = LeadPk
						JOIN	GenLvlDefn(NOLOCK) ON LedPGrpFk = GrpPk
						WHERE	LeadPk = @LeadPk	
					
								
						SELECT	PrpTyp,PrpDoorNo 'tech_doorno',PrpBuilding 'tech_building',PrpPlotNo 'tech_plotno',PrpStreet 'tech_street',PrpLandmark 'tech_landmark',
								PrpArea 'tech_area',PrpDistrict 'tech_district',PrpState 'tech_state',PrpCountry 'tech_country',PrpPin 'tech_pincode',PrpPk 'prp_pk',
								LftLfjFk,LftMktVal 'tech_mktval',ISNULL(LftAmenAmt,'') 'tech_amenamt',LftPk 'tech_lftpk',DBO.gefgDMY(LfjRptDt) 'tech_rptdt',LfjRptSts 'tech_rptsts',
								LfjNotes 'tech_notes',LfjSrvTyp 'tech_srvtyp',LfjRptSts 'tech_status', LfjAgtFk 'tech_agtFk',
								CONVERT(VARCHAR,DENSE_RANK() OVER(ORDER BY PrpPk)) 'tech_prop',
								CONVERT(VARCHAR,ROW_NUMBER() OVER(PARTITION BY PrpPk ORDER BY PrpPk)) 'tech_valuation'
						FROM	LosProp(NOLOCK)				
						JOIN	LosAgentJob(NOLOCK) ON LajLedFk = PrpLedFk AND LajSrvTyp = 5 AND LajDelId = 0 
						JOIN	LosAgentPrpVerf C(NOLOCK) ON LajPk = C.LpvLajFk AND PrpPk = C.LpvPrpFk AND C.LpvDelId = 0
						JOIN	LosAgentFBjob(NOLOCK) ON LfjLajFk = LajPk AND C.LpvPk = LfjLpvFk AND LfjDelId = 0
						JOIN	LosAgentFBTechnical(NOLOCK) ON LftLfjFk = LfjPk AND LftDelId = 0
						WHERE	LajLedFk = @LeadPk AND PrpDelId = 0 
						ORDER BY PrpPk

						SELECT	LptMktVal 'tech_mktval',ISNULL(LptAmenAmt,0) 'tech_amenamt',LptPrpValRmks 'tech_propremarks',LptPrpTyp 'tech_proptyp',
								LptDemolishRsk 'tech_demolrisk',LptUdsArea 'tech_UDSarea',ISNULL(LptUdsmmt,0) 'tech_udsmmt',ISNULL(LptUdsVal,0) 'tech_UDSval',
								LptSupBuldArea 'tech_supbuildarea',ISNULL(LptSupBuldmmt,0) 'tech_supbuildmmt',LptBuldArea 'tech_buildarea',ISNULL(LptBuldmmt,0) 'tech_buildupmmt',
								LptCrpArea 'tech_carpetarea',ISNULL(LptCrpmmt,0) 'tech_carpetmmt',ISNULL(LptEstmt,0) 'tech_estimate',LptOwnTyp 'tech_ownertype',
								LptPossessTyp 'tech_possessiontyp',LptSurvNo 'tech_surveyno',LptLocTyp 'tech_loctyp',LptApprLandUse 'tech_landuse',
								LptApprAuth 'tech_apprauth',LptBuildApprAuth 'tech_buildapprauth',LptPropDtRmks 'tech_prpdtlsremarks',LptBuldAge 'tech_buildingage',LptEstmtBuldLife 'tech_estimatebuilding',
								LptStructTyp 'tech_structyp',LptFloorNo 'tech_nooffloor',LptConstPer 'tech_construction',LptConstRmks 'tech_constremarks',
								LptLandArea 'tech_landarea',ISNULL(LptLandVal,0) 'tech_landvalue',ISNULL(LptLandmmt,0) 'tech_landmmt',LptLeasePer 'tech_leasepriod', LptPk 'tech_prpPk',
								LptDistressAmt 'tech_distressval', ISNULL(Convert(Varchar,LptMumty),'-1')'tech_mumty', LptOccupSts 'tech_propoccupy',
								LptRefNo 'tech_Refno',LptEast 'tech_Est',LptWest 'tech_Wst',LptNorth 'tech_Nor',LptSouth 'tech_Sou',LptSts 'tech_status',
								LptPrpFk 'PrpFk',LptAppPlnNo 'tech_AppplnNo', CONVERT(VARCHAR,ROW_NUMBER() OVER(PARTITION BY LptPrpFk ORDER BY LptPrpFk)) 'apr_valuation',
								LptPrpConsVal 'tech_ProposConstVal',LptExsConsVal 'tech_ExsConsVal'
						FROM	LosPropTechnical (NOLOCK)
						WHERE	LptLedFk = @LeadPk  AND LptDelId = 0
						ORDER BY LptPrpFk	
					
						SELECT COUNT(*) 'PrpCnt' 
						FROM LosProp(NOLOCK) 
						WHERE PrpLedFk = @LeadPk AND PrpDelId = 0
						
		
					END

					IF @Action ='DOCUMENT'
					BEGIN			
						SELECT	DocCat	'Catogory',	DocSubCat 'SubCatogory',DocNm 'DocName',DocPath 'DocPath',DocPk 'Pk',DocLedFk 'LeadFk',
								ISNULL(AgtFName,'') + ' ' +  ISNULL(AgtMName,'') + ' ' + ISNULL(AgtLName,'') 'AgentNm',DocBGeoFk 'GeoFk',DocPrdFk 'PrdFk',
								CASE WHEN DocActor = 0 THEN 'Applicant' WHEN DocActor = 1  THEN 'Co-Applicant' WHEN DocActor = 2  THEN 'Guarantor' END 'Actor'
								FROM LosDocument(NOLOCK)
								JOIN GenAgents(NOLOCK) ON AgtPk = DocAgtFk AND AgtDelid = 0
								JOIN #GlobalDtls ON LeadPk = DocLedFk			
								WHERE DocDelId=0 AND DocCat !='RPT'			
					END

					IF @Action = 'Save'
						BEGIN
							INSERT INTO LosPropTechnical(LptLedFk,LptAgtFk,LptBGeoFk,LptPrpFk,LptRptDt,LptSts,LptMktVal,LptPrpValRmks,LptPrpTyp,
										LptDemolishRsk,LptUdsArea,LptUdsmmt,LptUdsVal,LptSupBuldArea,LptSupBuldmmt,LptBuldArea,LptBuldmmt,LptCrpArea,
										LptCrpmmt,LptEstmt,LptOwnTyp,LptPossessTyp,LptSurvNo,LptLocTyp,LptApprLandUse,LptApprAuth,LptBuildApprAuth,LptPropDtRmks,LptBuldAge,
										LptEstmtBuldLife,LptStructTyp,LptFloorNo,LptConstPer,LptConstRmks,LptRowId,LptCreatedBy,LptCreatedDt,
										LptModifiedBy,LptModifiedDt,LptDelFlg,LptDelId,LptLandArea,LptLandVal,LptLandmmt,LptLeasePer,
										LptDistressAmt, LptMumty, LptOccupSts,LptRefNo,LptEast,LptWest,LptNorth,LptSouth,LptAppPlnNo,LptPrpConsVal,LptExsConsVal,LptAmenAmt,
										LptDocSts)
							--OUTPUT INSERTED.*

							SELECT		@LeadPk,tech_agtFk,@GeoFk,PrpFK,@CurDt,ISNULL(techstatus,2),CAST(ISNULL(NULLIF(MktVal,''),NULL) AS numeric (27,7)),
										ISNULL(PrpValRmks,''),ISNULL(PrpTyp,-1),ISNULL(DemolishRsk,-1),CAST(ISNULL(NULLIF(UdsArea,''),NULL) AS NUMERIC (27,7)),ISNULL(Udsmmt,-1),
										CAST(ISNULL(NULLIF(UdsVal,''),NULL) AS NUMERIC (27,7)),CAST(ISNULL(NULLIF(SupBuldArea,''),NULL) AS NUMERIC (27,7)),ISNULL(SupBuldmmt,-1),
										CAST(ISNULL(NULLIF(BuldArea,''),NULL) AS NUMERIC (27,7)),ISNULL(Buldmmt,-1),CAST(ISNULL(NULLIF(CrpArea,''),NULL) AS NUMERIC (27,7)) ,
										ISNULL(Crpmmt,-1),CAST(ISNULL(NULLIF(Estmt,''),NULL) AS NUMERIC (27,7)),ISNULL(OwnTyp,-1),ISNULL(PossessTyp,-1),ISNULL(SurvNo,''),
										ISNULL(LocTyp ,-1),ISNULL(ApprLandUse,-1),ISNULL(ApprAuth,''),ISNULL(BuildApprAuth,''),ISNULL(PropDtRmks,''),ISNULL(BuldAge,''),ISNULL(EstmtBuldLife,''),ISNULL(StructTyp,''),
										ISNULL(FloorNo,''),ISNULL(ConstPer,''),ISNULL(ConstRmks,''),@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,0,0,CAST(ISNULL(NULLIF(LandArea,''),NULL) AS NUMERIC (27,7)),
										CAST(ISNULL(NULLIF(LandVal,''),NULL) AS NUMERIC (27,7)),ISNULL(Landmmt,-1),ISNULL(LeasePer,''),
										CAST(ISNULL(NULLIF(DistressVal,''),NULL) AS NUMERIC (27,7)), CASE Mumty WHEN '-1' THEN NULL ELSE Mumty END, 
										CASE PropOccupancy WHEN '-1' THEN ' ' ELSE PropOccupancy END,
										techRefno,techEst, techWst, techNor,techSou,techAppplnNo,CAST(ISNULL(NULLIF(techProposConstVal,''),NULL) AS NUMERIC (27,7)),
										CAST(ISNULL(NULLIF(techExsConsVal,''),NULL) AS NUMERIC (27,7)),0,@Approver
							FROM		#DtlsTbl
							WHERE       ISNULL(TechPrpPk,0) = 0
						

							UPDATE	LosPropTechnical 
							SET		LptPrpValRmks = ISNULL(PrpValRmks,''),LptPrpTyp = ISNULL(PrpTyp, -1),LptDemolishRsk = ISNULL(DemolishRsk,-1),
									LptUdsmmt = ISNULL(Udsmmt,-1),LptSupBuldmmt = ISNULL(SupBuldmmt,-1),LptBuldmmt = ISNULL(Buldmmt ,-1),
									LptCrpmmt = ISNULL(Crpmmt,-1),LptOwnTyp = ISNULL(OwnTyp,-1),LptPossessTyp = ISNULL(PossessTyp ,-1),
									LptSurvNo = ISNULL(SurvNo,''),LptLocTyp = ISNULL(LocTyp ,-1),LptApprLandUse = ISNULL(ApprLandUse,-1),
									LptApprAuth = ISNULL(ApprAuth,''),LptBuildApprAuth = ISNULL(BuildApprAuth,''),
									LptPropDtRmks = ISNULL(PropDtRmks,''),LptBuldAge = ISNULL(BuldAge ,''),
									LptEstmtBuldLife = ISNULL(EstmtBuldLife,''),LptStructTyp = ISNULL(StructTyp,''),LptFloorNo = ISNULL(FloorNo ,''),
									LptConstPer = ISNULL(ConstPer,''),LptConstRmks = ISNULL(ConstRmks,''),LptLeasePer = ISNULL(LeasePer,''),LptLandmmt = ISNULL(Landmmt,-1),	
									LptMktVal = CAST(ISNULL(NULLIF(MktVal,''),NULL) AS NUMERIC (27,7)) ,														
									LptUdsArea = CAST(ISNULL(NULLIF(UdsArea,''),NULL) AS NUMERIC (27,7)),
									LptUdsVal = CAST(ISNULL(NULLIF(UdsVal,''),NULL) AS NUMERIC (27,7)),
									LptSupBuldArea = CAST(ISNULL(NULLIF(SupBuldArea,''),NULL) AS NUMERIC (27,7)),
									LptBuldArea = CAST(ISNULL(NULLIF(BuldArea,''),NULL) AS NUMERIC (27,7)),							
									LptCrpArea = CAST(ISNULL(NULLIF(CrpArea,''),NULL) AS NUMERIC (27,7)),
									LptEstmt = CAST(ISNULL(NULLIF(Estmt,''),NULL) AS NUMERIC (27,7)),
									LptLandArea = CAST(ISNULL(NULLIF(LandArea,''),NULL) AS NUMERIC (27,7)),
									LptLandVal = CAST(ISNULL(NULLIF(LandVal,''),NULL) AS NUMERIC (27,7)),
									LptDistressAmt = CAST(ISNULL(NULLIF(DistressVal,''),NULL) AS NUMERIC (27,7)),
									LptMumty = CASE Mumty WHEN '-1' Then NULL ELSE Mumty END,
									LptOccupSts = CASE PropOccupancy WHEN '-1' THEN ' ' ELSE PropOccupancy END	,
									LptRefNo = techRefno,LptEast = techEst, LptWest = techWst,LptNorth = techNor,LptSouth = techSou	,
									LptSts = ISNULL(techstatus,2),LptAppPlnNo = techAppplnNo,LptPrpConsVal = CAST(ISNULL(NULLIF(techProposConstVal,''),NULL) AS NUMERIC (27,7)),
									LptExsConsVal = CAST(ISNULL(NULLIF(techExsConsVal,''),NULL) AS NUMERIC (27,7)),LptDocSts=@Approver
							FROM	#DtlsTbl A 
							JOIN	LosPropTechnical B ON A.TechPrpPk = B.LptPk AND A.PrpFK = B.LptPrpFk
							WHERE	A.TechPrpPk <> 0 AND LptDelId = 0 					
						END

					IF @Action ='Save_Deviation'
						BEGIN	
						
								DELETE T 
								FROM	LosDeviation T (NOLOCK)
								JOIN	LosLnAttributes (NOLOCK) ON LnaPk = LdvLnaFk AND LnaDelId = 0 
								WHERE	LdvStage = 'T' AND LdvLedFk = @LeadPk  AND LnaCd = 'MANUALDEV'
							
								INSERT INTO LosDeviation(LdvLedFk,LdvAppFk,LdvUsrFk,LdvStage,LdvLnaFk,LdvLapFk,LdvArrVal,LdvDevVal,LdvInpSts,LdvDevSts,LdvAppBy,LdvRmks,
											LdvRowId,LdvCreatedBy,LdvCreatedDt,LdvModifiedBy,LdvModifiedDt,LdvDelFlg,LdvDelId)	
											OUTPUT INSERTED.*					
								SELECT		@LeadPk,@AppFk, @UsrPk, 'T' , LnaPk , NULL , NULL, NULL , '',  'D', DelLvl , DevRemarks,
											@RowID , @UsrDispNm, GETDATE() , @UsrDispNm, GETDATE() , NULL, 0
								FROM		#ManualDev 
								JOIN		LosLnAttributes(NOLOCK) ON LnaCd = 'MANUALDEV'			
						END

					IF @Action ='Select_Dev'
						BEGIN	
																			
							SELECT	LdvAppBy 'tech_deviationLvl',LdvRmks 'tech_DeviationRmks'
							FROM	LosDeviation T (NOLOCK)
							JOIN	LosLnAttributes (NOLOCK) ON LnaPk = LdvLnaFk AND LnaDelId = 0 
							WHERE	LdvStage = 'T' AND LdvLedFk = @LeadPk  AND LnaCd = 'MANUALDEV' AND LdvDelId = 0 
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
