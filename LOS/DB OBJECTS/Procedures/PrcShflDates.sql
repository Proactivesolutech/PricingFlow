IF OBJECT_ID('PrcShflDates','P') IS NOT NULL
	DROP PROCEDURE PrcShflDates
GO
CREATE PROCEDURE PrcShflDates
(
@Action			VARCHAR(100)	= NULL,
@GlobalJson		VARCHAR(MAX)	= NULL,
@DtlsJson       VARCHAR(MAX)	= NULL, 
@SancDivJson	VARCHAR(MAX)	= NULL,
@SellerJson		VARCHAR(MAX)	= NULL,
@selPk			BIGINT			= NULL
)

AS
BEGIN
		--RAISERROR('%s',16,1,'Error : QDE Header Insert')
		--					RETURN
	SET NOCOUNT ON
	DECLARE @CurDt DATETIME, @TranCount INT = 0,@RowId VARCHAR(40), @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT;
	DECLARE @IsTechExists CHAR(1),@LeadPk BIGINT, @GeoFk BIGINT, @UsrDispNm VARCHAR(100),@PrdFk BIGINT,@SancPk BIGINT,@AgtFk BIGINT,
			@LeadID VARCHAR(100),@PrdNm  VARCHAR(100),@PrdIcon VARCHAR(100),@SancHdrPk BIGINT,@UsrPk BIGINT,@Approver VARCHAR(20),
			@AppPK BIGINT,@SellerPk BIGINT,@confirm BIGINT,@MaxJobNo VARCHAR(100),@flag BIGINT



	CREATE TABLE #TEMP_DATE(xx_ID BIGINT,TYP VARCHAR(2),SHDATE VARCHAR(15))

	CREATE TABLE #InsDtls
	(
		Insrid BIGINT,psq_hdn_new BIGINT,psq_hdn_confirm BIGINT
	)
	--Seller Details 
	CREATE TABLE #SelDetails
	(
		SelID Bigint,psq_agnttype VARCHAR(20),LslNm varchar(250),LslTyp CHAR(2),LslDoorNo varchar(10),LslBuilding varchar(150),LslPlotNo varchar(20),LslStreet varchar(150),
		LslLandmark varchar(250),LslArea varchar(150),LslDistrict varchar(100),LslState varchar(100),LslPin CHAR(6), SellerPk BIGINT, BuilderCIN VARCHAR(100), PropFk BIGINT, LslSelTrig VARCHAR(10), BuilderPk BIGINT
	)
	CREATE TABLE #BOGlobalDtls
	(
		id BIGINT, LeadPk BIGINT, GeoFk BIGINT, UsrDispNm VARCHAR(100), PrdFk BIGINT,PCd VARCHAR(100),SancPk BIGINT,AgtFk BIGINT,LeadID  VARCHAR(100),
		PrdGrpFk BIGINT, SancHdrPk BIGINT, UsrPk BIGINT,Approver VARCHAR(20)
	)

	CREATE TABLE #TempVerf
	(
		VerLajFk BIGINT
	)
	SELECT @CurDt = GETDATE(), @RowId = NEWID()	
	  
	IF @GlobalJson != '[]' AND @GlobalJson != ''
	BEGIN
		INSERT INTO #BOGlobalDtls
		EXEC PrcParseJSON @GlobalJson,'LeadFk,GeoFk,UsrDispNm,PrdFk,PrdCd,SancPk,AgtFk,LeadID,PrdGrpFk,SancHdrPk,UsrPk,Approver'
			
		SELECT	@LeadPk = A.LeadPk, @GeoFk = A.GeoFk, @UsrDispNm = A.UsrDispNm, 
				@PrdFk = B.PrdPk, @SancPk = SancPk,@AgtFk=AgtFk,@LeadID=LeadID,
				@PrdNm = B.PrdNm, @PrdIcon = B.PrdIcon, @SancHdrPk = SancHdrPk,@UsrPk=UsrPk,@Approver=Approver
		FROM	#BOGlobalDtls A
		LEFT JOIN	GenPrdMas B(NOLOCK) ON B.PrdCd = A.PCd AND B.PrdDelid = 0			
	END

	IF @DtlsJson !='' AND @DtlsJson != '[]'
	BEGIN
		INSERT INTO  #TEMP_DATE
		Exec PrcParseJSON @DtlsJson,'Code,Date'
	END

	IF @SancDivJson != '[]' AND @SancDivJson != ''
	BEGIN	
		INSERT INTO #InsDtls
		EXEC PrcParseJSON @SancDivJson,'psq_hdn_new,psq_hdn_confirm'					
	END

	IF @SellerJson != '[]' AND @SellerJson != ''
	BEGIN				
		INSERT INTO #SelDetails
		EXEC PrcParseJSON @SellerJson,'psq_agnttype,psq_SellerName,psq_SellerType,psq_SellerFLatNo,psq_SellerBuild,psq_SellerPlotNo,psq_SellerSt,psq_SellerLndMrk,psq_SellerTown,psq_SellerDist,psq_SellerState,psq_SellerPin,psq_hdn_Sellerpk,psq_CIN,PropFk,psq_check_agt,psq_BuilderPk'			
	END


	BEGIN TRY

		IF @@TRANCOUNT = 0
			SET @TranCount = 1

		IF @TranCount = 1
			BEGIN TRAN	
 
    
		 IF @Action = 'SELECT_LEAD'
			BEGIN
				IF EXISTS(SELECT 'X' FROM LosAgentJob WHERE LajSrvTyp = 5 AND LajLedFk = @LeadPk AND LajDelid = 0)
					SET @IsTechExists = 'Y'
				ELSE
					SET @IsTechExists = 'N'
			
				SELECT  LedId 'ledid',LedNm 'Name',GeoNm 'branch',LedPrdFk 'product',PrdIcon 'ClasNm',LedPNI 'PNICASE',PrdNm 'productnm',
						@IsTechExists 'TYP'
				FROM    LosLead(NOLOCK)		  
				JOIN    GenPrdMas(NOLOCK) ON  LedPrdFk=PrdPk
				JOIN    GenGeoMas(NOLOCK) ON LedBGeoFk=GeoPk  
				WHERE   LedDelId=0 AND LedPk=@LeadPk
			END	

		IF @Action = 'INSERT'
			BEGIN

				SELECT  @AppPK = AppPk
				FROM	dbo.LosApp(NOLOCK)
				WHERE	AppLedFk = @LeadPk

				UPDATE LosAppDates SET AdtDelId=1 WHERE AdtLedFk=@LeadPk AND AdtTyp IN ('S','C') AND AdtSanFk=@SancPk
				INSERT INTO LosAppDates(AdtLedFk,AdtTyp,AdtDt,AdtRowId,AdtCreatedBy,AdtCreatedDt,AdtModifiedBy,AdtModifiedDt,AdtDelFlg,AdtDelId,AdtSanFk)
				SELECT  @LeadPk,TYP,dbo.gefgChar2Date(SHDATE),@RowId,'ADMIN',@CurDt,'ADMIN',@CurDt,NULL,0,@SancPk
				FROM    #TEMP_DATE


				INSERT INTO LosAppDates(AdtLedFk,AdtTyp,AdtDt,AdtRowId,AdtCreatedBy,AdtCreatedDt,AdtModifiedBy,AdtModifiedDt,AdtDelFlg,AdtDelId,AdtSanFk)
				SELECT  @LeadPk,TYP,dbo.gefgChar2Date(SHDATE),@RowId,'ADMIN',@CurDt,'ADMIN',@CurDt,NULL,0,@SancPk
				FROM    #TEMP_DATE

				SELECT SCOPE_IDENTITY() 'AdtFK'

			IF EXISTS(SELECT TOP 1 'X' FROM #SelDetails WHERE ISNULL(LslNm,'') <> '')
			BEGIN 			
				IF EXISTS(SELECT 'X' FROM #SelDetails WHERE ISNULL(SellerPk,0) = 0)
				BEGIN
					INSERT INTO LosSeller(LslLedFk,LslBGeoFk,LslPrdFk,LslAppFk,LslLsnFk,LslNm,LslTyp,LslBuilderCIN,LslDoorNo,
											LslBuilding,LslPlotNo,LslStreet,LslLandmark,LslArea,LslDistrict,LslState,LslAgtFk,
											LslCountry,LslPin, LslLpsFk, LslPrpFK, LslRowId,LslCreatedBy,LslCreatedDt,LslModifiedBy,LslModifiedDt,LslDelFlg,LslDelId,LslSelTrig,LslGbmFk)										
					SELECT		@LeadPk,@GeoFk,@PrdFk,@AppPK,@SancPk,LslNm,LslTyp,BuilderCIN,LslDoorNo,	LslBuilding,LslPlotNo,LslStreet,LslLandmark,
								LslArea,LslDistrict,LslState,psq_agnttype,'INDIA',LslPin,@SancHdrPk, PropFk, @RowId,@UsrDispNm,@CurDt,@UsrDispNm,
								@CurDt,0,0,LslSelTrig,ISNULL(BuilderPk,'')
					FROM		#SelDetails
					WHERE		ISNULL(SellerPk,0) = 0 AND ISNULL(LslNm,'') <> ''					
					
				END
				ELSE
					BEGIN
						UPDATE  LosSeller 
						SET		LslNm = A.LslNm,  LslTyp = A.LslTyp, LslBuilderCIN = BuilderCIN,
								LslDoorNo = A.LslDoorNo, LslBuilding = A.LslBuilding, LslPlotNo = A.LslPlotNo,
								LslStreet=A.LslStreet,LslLandmark=A.LslLandmark,LslArea=A.LslArea,LslDistrict=A.LslDistrict,LslState=A.LslState,
								LslCountry='INDIA',LslPin=A.LslPin,LslRowId = @RowId, LslModifiedBy = @UsrDispNm, LslModifiedDt = @CurDt,
								LslAgtFk = psq_agnttype, LslPrpFK = PropFk, LslSelTrig = A.LslSelTrig ,
								LslGbmFk = ISNULL(BuilderPk,'')
						FROM	#SelDetails A
						WHERE	LslPk = A.SellerPk  

						SELECT @SellerPk  = SellerPk FROM #SelDetails 
					END
					
				SELECT @confirm = psq_hdn_confirm, @flag =psq_hdn_new  FROM #InsDtls


				IF EXISTS (SELECT 'X' FROM LosSeller WHERE ISNULL(LslLedFk,0) = @LeadPk AND ISNULL(@confirm,0) = 1 AND @flag = 1)				
					BEGIN		
											
						SELECT @MaxJobNo = (CONVERT(BIGINT,RIGHT(MAX(LfjJobNo),5)) + 1) FROM LosAgentFBJob(NOLOCK)
						IF ISNULL(@MaxJobNo,0) = 0 SET @MaxJobNo = 1;

						IF NOT EXISTS (SELECT 'X' FROM LosAgentJob JOIN #SelDetails A ON A.psq_agnttype = LajAgtFk AND LajSrvTyp = 6 WHERE LajLedFk = @LeadPk)
						BEGIN
							INSERT INTO LosAgentJob
							(
								LajAgtFk,LajSrvTyp,LajJobNo,LajJobDt,LajLedFk,LajLedNo,LajRowId,
								LajCreatedBy,LajCreatedDt,LajModifiedBy,LajModifiedDt,LajDelFlg,LajDelId,LajBGeoFk,LajPrdFk
							) output inserted.LajPk INTO #TempVerf
							SELECT  psq_agnttype,6,'JOB_' + dbo.gefgGetPadZero(5,(ISNULL(@MaxJobNo,0))),@CurDt,@LeadPk,
									@LeadID,@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,NULL,0,@GeoFk,@PrdFk
							FROM	#SelDetails A	
							WHERE	A.LslSelTrig = 'Y'	OR A.LslSelTrig = '0' GROUP BY psq_agnttype

			

							INSERT INTO LosAgentVerf(LavLajFk,LavNm,LavMobNo,LavAddTyp,LavDoorNo,LavBuilding,LavPlotNo,LavStreet,LavLandmark,LavArea,LavDistrict,
										LavState,LavCountry,LavPin,LavRowId,LavCreatedBy,LavCreatedDt,LavModifiedBy,LavModifiedDt,LavDelFlg,LavDelId,LavLapFk,LavLslFk)									

							
							SELECT		VerLajFk, LslNm, LapMobile, 0, LslDoorNo, LslBuilding, LslPlotNo, LslStreet, LslLandmark, LslArea, LslDistrict,LslState, LslCountry,
										LslPin,@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, 0, 0, LslAppFk , LslPk
							FROM		LosSeller (NOLOCK)

							JOIN		LosAppProfile (NOLOCK) ON LapAppFk = LslAppFk AND LapDelId = 0 
							JOIN		LosAgentJob (NOLOCK) ON LajAgtFk = LslAgtFk AND LajSrvTyp = 6 AND LajLedFk = @LeadPk AND LajDelId = 0
							JOIN		#TempVerf ON	VerLajFk = LajPk
							WHERE		LslLedFk = @LeadPk AND LapActor = 0 AND LslSelTrig = 'Y' AND LslDelId = 0 AND LslTyp = 'S'
						
																		
							INSERT INTO LosAgentVerf(LavLajFk,LavNm,LavMobNo,LavAddTyp,LavDoorNo,LavBuilding,LavPlotNo,LavStreet,LavLandmark,LavArea,LavDistrict,
										LavState,LavCountry,LavPin,LavRowId,LavCreatedBy,LavCreatedDt,LavModifiedBy,LavModifiedDt,LavDelFlg,LavDelId,
										LavLapFk,LavLslFk)		
														
							SELECT		VerLajFk,GbmName, GbmMobileNo, 0, GbaDoorNo,GbaBuilding,GbaPlotNo,GbaStreet,GbaLandmark,GbaArea,GbaDistrict,GbaState,
										GbaCountry,GbaPin,@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, 0, 0, LslAppFk , LslPk
							FROM		GenBuilderAddress(NOLOCK)
							JOIN		LosSeller (NOLOCK) ON LslGbmFk = GbaGbmFk
							JOIN		GenBuilder (NOLOCK) ON GbmPk = LslGbmFk AND GbmDelId = 0 AND GbaDelId = 0
							JOIN		LosAgentJob (NOLOCK) ON LajAgtFk = LslAgtFk AND LajSrvTyp = 6 AND LajLedFk = @LeadPk AND LajDelId = 0
							JOIN		#TempVerf ON	VerLajFk = LajPk
							JOIN		LosAppProfile (NOLOCK) ON LapAppFk = LslAppFk AND LapDelId = 0 AND LapActor = 0 							
							WHERE		LslLedFk = @LeadPk  AND LslSelTrig = 'Y' AND LslDelId = 0	AND LslTyp = 'B'	

						END
					END											
			END
			END

		--IF @Action = 'UPDATE'
		--	BEGIN
		--		UPDATE LosAppDates SET AdtDelId=1 WHERE AdtLedFk=@LeadPk AND AdtTyp IN ('S','C') AND AdtSanFk=@SancPk
		--		INSERT INTO LosAppDates(AdtLedFk,AdtTyp,AdtDt,AdtRowId,AdtCreatedBy,AdtCreatedDt,AdtModifiedBy,AdtModifiedDt,AdtDelFlg,AdtDelId,AdtSanFk)
		--		SELECT  @LeadPk,TYP,dbo.gefgChar2Date(SHDATE),@RowId,'ADMIN',@CurDt,'ADMIN',@CurDt,NULL,0,@SancPk
		--		FROM    #TEMP_DATE

		--		SELECT SCOPE_IDENTITY() 'AdtFK'
		--	END

		IF @Action = 'LOAD'
			BEGIN		

			
				SELECT   AdtTyp 'CODE',dbo.gefgDMY(AdtDt) 'DATE',AdtPk 'AdtPk'
				FROM     LosAppDates(NOLOCK)
				WHERE    AdtLedFk=@LeadPk AND AdtSanFk = ISNULL(@SancPk,0) AND AdtTyp IN('S','C') AND AdtDelId=0

				SELECT	PrpTyp,PrpDoorNo 'sanc_doorno',PrpBuilding 'sanc_building',PrpPlotNo 'sanc_plotno',PrpStreet 'sanc_street',PrpLandmark 'sanc_landmark',
						PrpArea 'sanc_area',PrpDistrict 'sanc_district',PrpState 'sanc_state',PrpCountry 'sanc_country',PrpPin 'sanc_pincode',PrpPk 'sanc_prppk',
						CONVERT(VARCHAR,DENSE_RANK() OVER(ORDER BY PrpPk)) 'sanc_prop',
						CONVERT(VARCHAR,ROW_NUMBER() OVER(PARTITION BY PrpPk ORDER BY PrpPk)) 'sanc_valuation'
				FROM	LosProp(NOLOCK)								
				WHERE	PrpLedFk = @LeadPk AND PrpDelId = 0 
				ORDER BY PrpPk

				SELECT	CASE WHEN  PrdCd IN ('HLNew','HLResale','HLPltConst','PL') THEN 'N' ELSE 'Y' END 'SellerDetHide'
				FROM 	LosSanction(NOLOCK) 				
				JOIN	GenPrdMas(NOLOCK)  ON PrdPk = LsnPrdFk AND PrdDelId = 0
				WHERE	LsnLedFk = @LeadPk AND LsnPk = @SancPk AND LsnDelId = 0

				--Seller Details
				SELECT	A.LslNm 'psq_SellerName',A.LslTyp 'psq_SellerType',A.LslDoorNo 'psq_SellerFLatNo',A.LslBuilding 'psq_SellerBuild',
						A.LslPlotNo 'psq_SellerPlotNo',A.LslStreet 'psq_SellerSt',A.LslLandmark 'psq_SellerLndMrk',A.LslArea 'psq_SellerTown',
						A.LslDistrict 'psq_SellerDist',A.LslState 'psq_SellerState',A.LslPin 'psq_SellerPin',A.LslPk 'psq_hdn_Sellerpk', 
						A.LslAgtFk 'psq_agnttype', A.LslBuilderCIN 'psq_CIN', A.LslPrpFK 'PropFk', ISNULL(LslGbmFk,'') 'psq_BuilderPk' ,
						CASE WHEN A.LslSelTrig = 'Y' THEN '0'ELSE '1' END 'psq_check_agt', B.AgtFName + ' ' + B.AgtMName + ' ' + B.AgtLName 'AgtName'					
				FROM	dbo.LosSeller A(NOLOCK)	
				LEFT JOIN	GenAgents B(NOLOCK) ON B.AgtPk = A.LslAgtFk	AND AgtDelId = 0		
				WHERE	LslLedFk = @LeadPk AND LslDelId = 0 
				ORDER BY LslPrpFK , LslPk
				
			
			END


		IF @Action='Risk_mat'
			BEGIN 
				 SELECT  LrcParameter,LrcVal
				 FROM    LosRiskCalc(NOLOCK)
				 WHERE   LrcLedFk=@LeadPk AND LrcDelId = 0
			END

		IF @Action='CAM'
			BEGIN 
				 SELECT  LrcParameter,LrcVal
				 FROM    LosRiskCalc(NOLOCK)
				 WHERE   LrcLedFk=@LeadPk AND LrcDelId = 0
			END

		IF @Action = 'Delete_Seller'
			BEGIN
				UPDATE  LosSeller
				SET		LslDelId = 1,  
						LslRowId = @RowId, LslModifiedBy = @UsrDispNm, LslModifiedDt = @CurDt			
				WHERE	LslPk = @selPk AND LslDelId = 0
			END

		IF @Trancount = 1 AND @@TRANCOUNT = 1
		COMMIT TRAN

	END TRY
	BEGIN CATCH
			IF @Trancount = 1 AND @@TRANCOUNT = 1
				ROLLBACK TRAN	

			SELECT	@ErrMsg = ERROR_MESSAGE() ,
					@ErrSeverity = ERROR_SEVERITY()
	
			RAISERROR('%s', @ErrSeverity, 1,@ErrMsg) 		
			RETURN		
	END CATCH

	
END
