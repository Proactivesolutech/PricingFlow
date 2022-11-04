ALTER PROCEDURE PrcShflLegalVerification

(
    @Action		  VARCHAR(100)		=	NULL,
	@GlobalJson    VARCHAR(MAX)		=	NULL,
	@DtlsJson      VARCHAR(MAX)		=	NULL,
	@ownerarray    VARCHAR(MAX)		=	NULL,
	@DevJson	  VARCHAR(MAX)		=	NULL
)
    AS
	BEGIN
	--RAISERROR('%s',16,1,'Error :  TEST')
	--RETURN

	DECLARE	 @CurDt DATETIME,@TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), 
			 @Error INT, @RowCount INT,@RowId VARCHAR(40),@fbjobpk BIGINT,@Approver VARCHAR(20);	

	DECLARE @LeadPk BIGINT,@AgentNm VARCHAR(100),@LavFk BIGINT,@srvTyp BIGINT,@LajFk BIGINT,@AgtFk BIGINT,@UsrDispNm VARCHAR(100),@GeoFk BIGINT,@PrdFk BIGINT,
			@lplpk BIGINT, @PrpFk BIGINT,@lapfk VARCHAR(100),@LplRptDt  VARCHAR(100),@hiddenpk BIGINT,@lap VARCHAR(100),@UsrPk BIGINT, @AppFk BIGINT;

	CREATE TABLE #GlobalDtls
	(			
	    xx_id BIGINT,LeadPk BIGINT, GeoFk BIGINT, UsrPk BIGINT, UsrDispNm VARCHAR(100), PrdCd VARCHAR(100),
		AgtFk BIGINT,LeadId VARCHAR(100),AppNo VARCHAR(100),BranchNm VARCHAR(100),AgtNm VARCHAR(100),PrdFk BIGINT,Approver VARCHAR(20)
	 )		

	CREATE TABLE #Dtls
	(			
	    dd_id BIGINT,leg_Comments VARCHAR(500),leg_status VARCHAR(100),leg_buildername VARCHAR(100),leg_CINBuilder VARCHAR(100),
		leg_refno VARCHAR(100),leg_serachperiod VARCHAR(100),leg_clrAndMarket VARCHAR(100),leg_assetcst Numeric,leg_regChrges VARCHAR(100),
		leg_StmpdutyChrges VARCHAR(100), leg_aggreeValue VARCHAR(100),leg_avltv VARCHAR(100),hiddenkey BIGINT,
		leg_ownertype VARCHAR(100),leg_sarAct VARCHAR(100),leg_subreg VARCHAR(100),leg_lftEst VARCHAR(100),leg_lftWst VARCHAR(100),
		leg_lftNor VARCHAR(100),leg_lftSou VARCHAR(100),PrpPk BIGINT
	 )		

	 CREATE TABLE #OwnershipDtls
	(			
	    xx_id BIGINT,lapfk VARCHAR(100),prpFk BIGINT, LpoFk BIGINT				 
	 )	

	 CREATE TABLE #temptbl
	 (
		lplfk BIGINT,PrpFk BIGINT	 
	 )
	CREATE TABLE #ManualDev
	(
		xx_id BIGINT,DelLvl VARCHAR(100),DevRemarks VARCHAR(MAX)
	)
	SELECT @CurDt = Getdate(), @RowId = Newid()

	IF @GlobalJson != '[]' AND @GlobalJson != ''
	BEGIN					

		INSERT INTO #GlobalDtls
		EXEC PrcParseJSON @GlobalJson,'LeadPk,GeoFk,UsrPk,UsrDispNm,PrdCd,AgtFk,LeadId,AppNo,BranchNm,AgtNm,PrdFk,Approver'
		
		SELECT @LeadPk = LeadPk,@GeoFk=GeoFk, @AgentNm = AgtNm,@AgtFk=AgtFk,@UsrDispNm=UsrDispNm,@PrdFk=PrdFk, 
		       @UsrPk = UsrPk ,@Approver=Approver
		FROM #GlobalDtls
		
		SELECT	@AppFk = AppPk
		FROM	LosApp(NOLOCK) WHERE AppLedFk = @LeadPk
	END

	IF @DtlsJson != '[]' AND @DtlsJson != ''
	BEGIN					

		INSERT INTO #Dtls
		EXEC PrcParseJSON @DtlsJson,'leg_Comments,leg_status,leg_buildername,leg_CINBuilder,leg_refno,leg_serachperiod ,leg_clrAndMarket,leg_assetcst,leg_regChrges,leg_StmpdutyChrges, leg_aggreeValue,leg_avltv,hiddenkey,leg_ownertype,leg_sarAct,leg_subreg,Leg_lftEst,Leg_lftWst,Leg_lftNor,Leg_lftSou,PrpPk'
		--SELECT @hiddenpk = hiddenkey FROM #Dtls
	END

	IF @ownerarray != '[]' AND @ownerarray != ''

	BEGIN	
					
		INSERT INTO #OwnershipDtls
		EXEC PrcParseJSON @ownerarray,'pk,PrpPk,LpoPk'
	END

	IF @DevJson != '[]' AND @DevJson != ''
	BEGIN
			INSERT INTO #ManualDev
			EXEC PrcParseJSON @DevJson, 'leg_deviationLvl,leg_DeviationRmks'
	END

	BEGIN TRY

	IF @@TRANCOUNT = 0

		SET @TranCount = 1
	IF @TranCount = 1
		BEGIN TRAN
			IF @Action = 'Save'
			BEGIN
				UPDATE	LosPropLegal
				SET		LplNotes=leg_Comments,LplSts=leg_status,LplBuilderNm=leg_buildername,
						LplBuilderCIN=leg_CINBuilder,LplRefNo=leg_refno,LplSrchPer=leg_serachperiod,
						LplClrMrkt=leg_clrAndMarket,LplAstCost=ISNULL(leg_assetcst,0),LplRegChg=ISNULL(leg_regChrges,0),
						LplStmpChg=ISNULL(leg_StmpdutyChrges,0),
                        LplAgrmtVal=ISNULL(leg_aggreeValue,0),LplAvLtv=ISNULL(leg_avltv,0),
				        LplRowId=@RowId,LplModifiedBy=@UsrDispNm,LplModifiedDt=@CurDt,
						LplOwnTyp=leg_ownertype,LplSarfaesi=leg_sarAct,LplSubRegistrar=leg_subreg,
						LplEast = leg_lftEst,LplWest = leg_lftWst,LplNorth = leg_lftNor,LplSouth = leg_lftSou,
						LplDocSts=@Approver
				FROM	#DTLS A
				JOIN	LosPropLegal B ON B.LplPk = A.hiddenkey
				WHERE	A.hiddenkey <> 0 AND B.LplDelId = 0
				
				INSERT	INTO #temptbl (lplfk ,PrpFk)
				SELECT  LplPk, LplPrpFk FROM  LosPropLegal WHERE LplLedFk = @LeadPk
				 	 
				INSERT INTO  LosPropLegal
				(
						LplLedFk,LplAgtFk,LplBGeoFk,LplPrpFk,LplRptDt,LplNotes,LplSts,LplBuilderNm,
						LplBuilderCIN,LplRefNo,LplSrchPer,LplClrMrkt,LplAstCost,LplRegChg,LplStmpChg,
                        LplAgrmtVal,LplAvLtv,LplRowId,LplCreatedBy,LplCreatedDt,LplModifiedBy,LplModifiedDt,LplDelFlg,LplDelId,
						LplOwnTyp,LplSarfaesi,LplSubRegistrar,LplEast,LplWest,LplNorth,LplSouth,LplDocSts
				)
				OUTPUT	INSERTED.LplPk,INSERTED.LplPrpFk  INTO #temptbl 
				SELECT	@LeadPk,@AgtFk,@GeoFk,PrpPk,@CurDt,leg_Comments,leg_status,leg_buildername,leg_CINBuilder,
						leg_refno, leg_serachperiod,leg_clrAndMarket,ISNULL(leg_assetcst,0),
						ISNULL(leg_regChrges,0),ISNULL(leg_StmpdutyChrges,0), 
						ISNULL(leg_aggreeValue,0) ,CAST(ISNULL(NULLIF(leg_avltv,''),0) AS NUMERIC(27,7)),
						@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,NULL,0,leg_ownertype,leg_sarAct,leg_subreg,leg_lftEst,
						leg_lftWst,leg_lftNor,leg_lftSou,@Approver
				FROM	#Dtls
				WHERE   hiddenkey = 0
											
				SELECT	@lplpk= SCOPE_IDENTITY(),  @Error = @@ERROR, @RowCount = @@ROWCOUNT

				IF @Error > 0
					BEGIN
						RAISERROR('%s',16,1,'Error :  Legal Insert')
						RETURN
					END

				UPDATE	A
				SET		A.LpoDelid = 1, A.LpoDelFlg = dbo.gefgGetDelFlg(@CurDt), A.LpoRowId = @RowId, A.LpoModifiedBy = @UsrDispNm, A.LpoModifiedDt =  @CurDt					
				FROM	LosPropOwner A	(NOLOCK)
				JOIN	#temptbl B ON A.LpoLplFk = B.lplfk
				WHERE	NOT EXISTS(SELECT 'X' FROM #OwnershipDtls WHERE LpoFk = LpoPk)


				INSERT INTO LosPropOwner(LpoLplFk,LpoLapFk,LpoRowId,LpoCreatedBy,LpoCreatedDt,LpoModifiedBy,LpoModifiedDt,LpoDelFlg,LpoDelId)	
				--OUTPUT INSERTED.*			
				SELECT		lplfk,lapfk,@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,NULL,0
				FROM		#OwnershipDtls	A					 
				JOIN		#temptbl B ON  B.PrpFk = A.prpFk 
				JOIN		#Dtls C ON C.PrpPk = B.PrpFk
				WHERE		A.LpoFk = 0 			

				SELECT	@Error = @@ERROR, @RowCount = @@ROWCOUNT
				IF @Error > 0
					BEGIN
						RAISERROR('%s',16,1,'Error : Legal Insert')
						RETURN
					END							
			END
			
			 IF @Action = 'Load'
			 BEGIN			
					SELECT DISTINCT ISNULL(LeadId,'') 'Leg_leadid',  ISNULL(UsrDispNm,'') 'leg_applicant', ISNULL(AppNo,'') 'leg_appno', 
					ISNULL(BranchNm,'') 'leg_brnch',ISNULL(AgtNm, '') 'leg_agency',	LedLnAmt 'Loanamt',
					LedPGrpFk 'LedPGrpFk',GrpNm 'GrpNm',GrpIconCls 'GrpIconCls'
					FROM #GlobalDtls
					join LosLead on LedPk = LeadPk
					JOIN GenLvlDefn ON GrpPk = LedPGrpFk
					WHERE	LeadPk = @LeadPk

					SELECT	LpvDoorNo 'Leg_flatno',LpvBuilding 'Leg_build',LpvPlotNo 'Leg_plotno',LpvStreet 'Leg_street',LpvLandmark 'Leg_land',
							LpvArea 'Leg_town',LpvDistrict 'Leg_district',LpvState 'Leg_state',LpvPin 'Leg_pin', PrpPk 'PrpPk'
					FROM LosProp(NOLOCK)
					JOIN LosAgentPrpVerf(NOLOCK) ON PrpPk = LpvPrpFk 
					Join LosAgentJob(NOLOCK) ON LajPk = LpvLajFk AND LajLedFk=@LeadPk AND LajSrvTyp=4 AND LajDelId = 0 AND LpvDelID = 0 AND PrpDelId = 0
					ORDER BY PrpPk 

					SELECT  dbo.gefgDMY(LfjRptDt) 'rptdt', LfjRptSts 'leg_status',PrpPk 'PrpPk'
					FROM	LosProp(NOLOCK)				
					JOIN	LosAgentJob(NOLOCK) ON LajLedFk = PrpLedFk AND LajSrvTyp = 4 AND LajDelId = 0 
					JOIN	LosAgentPrpVerf C(NOLOCK) ON LajPk = C.LpvLajFk AND PrpPk = C.LpvPrpFk AND C.LpvDelId = 0
					JOIN	LosAgentFBjob(NOLOCK) ON LfjLajFk = LajPk AND C.LpvPk = LfjLpvFk AND LfjDelId = 0
					JOIN	LosAgentFBLegal(NOLOCK) ON LflLfjFk = LfjPk AND LfjDelId = 0
					WHERE	LajLedFk = @LeadPk AND PrpDelId = 0 
					ORDER BY PrpPk
					 
					SELECT   LapFstNm 'FirstName', LapMdNm 'MiddleName', LapLstNm 'LastName',LapPk 'pk'
					FROM     LosAppProfile(NOLOCK) 
					WHERE	 LapLedFk = @LeadPk AND LapDelId=0
 					
					SELECT	 LplPk 'hiddenkey', LplNotes 'leg_Comments', LplSts 'leg_status', LplBuilderNm 'leg_buildername',
							 LplBuilderCIN 'leg_CINBuilder' , LplRefNo 'leg_refno' , LplSrchPer 'leg_serachperiod',
							 LplClrMrkt 'leg_clrAndMarket', LplAstCost 'leg_assetcst', LplRegChg 'leg_regChrges',
							 LplStmpChg 'leg_StmpdutyChrges', LplAgrmtVal 'leg_aggreeValue', LplAvLtv 'leg_avltv',
							 LplOwnTyp 'leg_ownertype',LplSarfaesi 'leg_sarAct',LplSubRegistrar 'leg_subreg',
							 LplEast 'Leg_lftEst',LplWest 'Leg_lftWst',LplNorth 'Leg_lftNor' ,LplSouth 'Leg_lftSou',
							 LplPrpFk 'PrpPk'
					FROM	 LosPropLegal
					WHERE    LplLedFk = @LeadPk AND LplDelId = 0
					ORDER BY LplPrpFk

					SELECT	LpoLapFk 'pk',LpoLplFk 'LplPk',LplPrpFk 'PrpPk',LpoPk 'LpoPk'
					FROM	LosPropOwner
					JOIN	LosPropLegal ON LpoLplFk = LplPk
					JOIN	LosProp ON PrpPk = LplPrpFk
					WHERE   LplLedFk  = @LeadPk AND LpoDelId = 0  

					SELECT COUNT(*) 'PrpCnt' 
					FROM LosProp(NOLOCK) 
					WHERE PrpLedFk = @LeadPk AND PrpDelId = 0		

			   END

			   IF @Action = 'DOCUMENT'

			   BEGIN
						SELECT	DocCat	'Catogory',	DocSubCat 'SubCatogory',DocNm 'DocName',DocPath 'DocPath',DocPk 'Pk',DocLedFk 'LeadFk',
						ISNULL(AgtFName,'') + ' ' +  ISNULL(AgtMName,'') + ' ' + ISNULL(AgtLName,'') 'AgentNm',DocBGeoFk 'GeoFk',DocPrdFk 'PrdFk',
						CASE WHEN DocActor = 0 THEN 'Applicant' WHEN DocActor = 1  THEN 'Co-Applicant' WHEN DocActor = 2  THEN 'Guarantor' END 'Actor'
						FROM LosDocument(NOLOCK)
						JOIN GenAgents(NOLOCK) ON AgtPk = DocAgtFk AND AgtDelid = 0
						JOIN #GlobalDtls ON LeadPk = DocLedFk			
						WHERE DocDelId=0 AND DocCat !='RPT'
			   END
			   
				IF @Action ='Save_Deviation'
					BEGIN	
						
							DELETE T 
							FROM	LosDeviation T (NOLOCK)
							JOIN	LosLnAttributes (NOLOCK) ON LnaPk = LdvLnaFk AND LnaDelId = 0 
							WHERE	LdvStage = 'L' AND LdvLedFk = @LeadPk  AND LnaCd = 'MANUALDEV'
							
							INSERT INTO LosDeviation(LdvLedFk,LdvAppFk,LdvUsrFk,LdvStage,LdvLnaFk,LdvLapFk,LdvArrVal,LdvDevVal,LdvInpSts,LdvDevSts,LdvAppBy,LdvRmks,
										LdvRowId,LdvCreatedBy,LdvCreatedDt,LdvModifiedBy,LdvModifiedDt,LdvDelFlg,LdvDelId)	
										OUTPUT INSERTED.*					
							SELECT		@LeadPk,@AppFk, @UsrPk, 'L' , LnaPk , NULL , NULL, NULL , '',  'D', DelLvl , DevRemarks,
										@RowID , @UsrDispNm, GETDATE() , @UsrDispNm, GETDATE() , NULL, 0
							FROM		#ManualDev 
							JOIN		LosLnAttributes(NOLOCK) ON LnaCd = 'MANUALDEV'			
					END

				IF @Action ='Select_Dev'
					BEGIN	
																			
						SELECT	LdvAppBy 'leg_deviationLvl',LdvRmks 'leg_DeviationRmks'
						FROM	LosDeviation T (NOLOCK)
						JOIN	LosLnAttributes (NOLOCK) ON LnaPk = LdvLnaFk AND LnaDelId = 0 
						WHERE	LdvStage = 'L' AND LdvLedFk = @LeadPk  AND LnaCd = 'MANUALDEV' AND LdvDelId = 0 
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

