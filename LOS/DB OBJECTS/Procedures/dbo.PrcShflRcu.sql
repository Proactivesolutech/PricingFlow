IF OBJECT_ID('PrcShflRCU','P') IS NOT NULL
	DROP PROCEDURE PrcShflRCU
GO
    CREATE PROCEDURE PrcShflRCU
    (
           @Action VARCHAR(100) = NULL,
		   @GlobalJson VARCHAR(MAX) = NULL,
		   @AppJson  VARCHAR(MAX) = NULL,
		   @IsQcScreen	TINYINT = 0
    )
    AS
    BEGIN 
    DECLARE	 @CurDt DATETIME,@TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), 
			     @Error INT, @RowCount INT,@RowId VARCHAR(40),@loan VARCHAR(100)

    DECLARE     @LeadPk BIGINT,@AgentNm VARCHAR(100),@AgtFk BIGINT,@UsrDispNm VARCHAR(100),
	             @GeoFk BIGINT,@PrdFk BIGINT,@LruRptDt  VARCHAR(100),@lapfk BIGINT,@docfk BIGINT,@Approver VARCHAR(20)


    CREATE TABLE #RCUGlobalDtls
	(			
	             xx_id BIGINT,LeadPk BIGINT, GeoFk BIGINT, UsrPk BIGINT, UsrDispNm VARCHAR(100), 
			     LeadId VARCHAR(100),AppNo VARCHAR(100),BranchNm VARCHAR(100),Approver VARCHAR(20),rcu_int_dt VARCHAR(15)
	)		
	 CREATE TABLE #Dtls
     (
		dd_id BIGINT,rcu_lapFk BIGINT,rcu_screened VARCHAR(100),rcu_sample VARCHAR(100),rcu_status VARCHAR(100),
		rcu_cmnts VARCHAR(MAX), rcu_docpk BIGINT, rcu_pk BIGINT,rcu_date VARCHAR(40),rcu_nameofsup  VARCHAR(40),rcu_refId  VARCHAR(40)	
	 )
	 SELECT @CurDt = Getdate(), @RowId = Newid()

	 IF @GlobalJson != '[]' AND @GlobalJson != ''
	    BEGIN					
		INSERT INTO #RCUGlobalDtls
		EXEC PrcParseJSON @GlobalJson,'LeadPk,GeoFk,UsrPk,UsrDispNm,LeadId,AppNo,BranchNm,Approver,Rcu_date'
		SELECT @LeadPk = LeadPk,@GeoFk=GeoFk, @UsrDispNm=UsrDispNm,@Approver=Approver FROM #RCUGlobalDtls 
	  END

	IF @AppJson != '[]' AND @AppJson != ''
	BEGIN					
		INSERT INTO #Dtls
		EXEC PrcParseJSON @AppJson,'rcu_lapFk,rcu_screened,rcu_sample,rcu_status,rcu_cmnts,rcu_docpk,rcu_pk,rcu_date,rcu_nameofsup,rcu_refId'
	END



	BEGIN TRY
	IF @@TRANCOUNT = 0
		SET @TranCount = 1
	IF @TranCount = 1
		BEGIN TRAN
			IF @Action = 'Load'
		      BEGIN
				    SELECT		DocLedFk 'LeadFk', LapPk  'rcu_lapFk',
								DocBGeoFk 'GeoFk',DocPrdFk 'PrdFk',DocActor 'Actor',DocCat	'Catogory',
								DocSubCat 'SubCatogory',DocNm 'DocName',DocPath 'DocPath',DocPk 'Pk',
							    CONVERT(CHAR(1),ISNULL(LruScreen,0)) 'rcu_screened', CONVERT(CHAR(1),ISNULL(LruSample,'0')) 'rcu_sample',
								CONVERT(CHAR(1),ISNULL(LruRptSts,0)) 'rcu_status',DBO.gefgDMY(LruRptDt) 'rcu_date',
								CASE @IsQcScreen WHEN 1 THEN ISNULL(LruApprovalNt,'') ELSE ISNULL(LruNotes,'') END 'rcu_cmnts', 
								ISNULL(LruPk,'0') 'rcu_pk',
								CASE ISNULL(DocActor,0) WHEN 2 THEN 'Guarnator' WHEN 1 THEN 'CoApplicant' ELSE 'Applicant' END 'Applicant'
					FROM		LosAppProfile(NOLOCK)	
					JOIN		LosQDE (NOLOCK) ON LapLedFk = QdeLedFk AND QdeCusFk = LapCusFk AND QDEDelId = 0
					JOIN		LosDocument(NOLOCK) ON DocCat <> 'RPT' AND DocCat <> 'PD' AND DocLedFk = @LeadPk AND DocActor = QdeActor AND QDESubActor = DocSubActor AND DocDelid = 0
					JOIN		LosApp(NOLOCK) ON AppLedFk = @LeadPk AND AppPk = LapAppFk  AND AppDelId = 0
					LEFT JOIN	LosRCU(NOLOCK) ON LruLapFk = LapPk AND LruDocFk = DocPk AND LruDelid = 0
					WHERE		LapDelid = 0

				    SELECT		LedLnAmt 'LoanAmount',LedTenure 'Tenure',DBO.gefgDMY(LapDOB) 'DOB',LapGender 'Gender',LapActor 'Actor',LapFstNm + ' ' + LapMdNm + ' ' + LapLstNm 'FirstName',
								LapActorNm 'ActorNm',LapPk 'Lapfk',ISNULL(PrdNm,GrpNm) 'hdnPrdNm',ISNULL(PrdIcon,GrpIconCls) 'hdnPrdIcon'
					FROM		LosAppProfile(NOLOCK)
					JOIN        LosLead(NOLOCK) ON LedPk=LapLedFk AND LedDelId=0
					JOIN	    GenLvlDefn(NOLOCK) ON LedPGrpFk = GrpPk AND GrpDelid = 0
                    LEFT JOIN   GenPrdMas(NOLOCK) ON LedPrdFk = PrdPk AND PrdDelid = 0
					WHERE		LapLedFk=@LeadPk AND LapDelid = 0 ORDER BY LapActor

				    SELECT		LaaDoorNo 'doorno',LaaBuilding 'build',LaaPlotNo 'Plot',LaaStreet 'Street',LaaLandmark 'Land',
								LaaArea 'Area',LaaDistrict 'District',LaaState 'State',LaaCountry 'Country',LaaPin 'Pin',LaaAddTyp 'add',
								LaaLapFk 'lap',LaaAddTyp 'Addtyp'		
					FROM        LosAppAddress(NOLOCK)  
					WHERE       LaaLedFk =@LeadPk  AND LaaAddTyp IN (0,2,3)  AND LaaDelId=0 

				    SELECT		LruScreen 'rcu_screened',LruSample 'rcu_sample',LruRptSts 'rcu_status',DBO.gefgDMY(LruRptDt) 'rcu_date',LruNotes 'rcu_cmnts',LruPk 'rcu_pk'	,
								LruSupNm 'rcu_nameofsup',	LruRefNo 'rcu_refId'		
					FROM        LosRCU(NOLOCK)  
					WHERE       LruLedFk =@LeadPk AND LruDelId=0
					
					SELECT      LapPk 'RCU_lapPk' FROM LosAppProfile WHERE LapLedFk=@LeadPk


				
				    EXEC PrcShflLoanDetail @LeadPk

					SELECT  dbo.gefgDMY(AdtDt) 'Dt'
			        FROM    LosAppDates
			        WHERE   AdtLedFk=@LeadPk AND AdtTyp='U' AND AdtDelId=0 
		    END
			IF @Action = 'Save'
			BEGIN
                     INSERT INTO LosRCU(LruLedFk,LruLapFk,LruScreen,LruSample,LruRptSts,LruRptDt,LruNotes,
                                 LruRowId,LruCreatedBy,LruCreatedDt,LruModifiedBy,LruModifiedDt,LruDelFlg,LruDelId,
								 LruSupNm,LruRefNo,LruDocSts)

				     SELECT	     @LeadPk,rcu_lapFk,rcu_screened,rcu_sample,rcu_status,ISNULL(DBO.gefgChar2Date(rcu_date),@CurDt),
								 ISNULL(rcu_cmnts,''),@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,NULL,0,rcu_nameofsup,rcu_refId,@Approver
				     FROM		 #Dtls
					 WHERE	     ISNULL(rcu_pk,0) = 0


					 UPDATE LosAppDates SET AdtDelId=1 WHERE AdtLedFk=@LeadPk AND AdtTyp='U'

			         INSERT INTO LosAppDates
	                (
	                AdtLedFk,AdtTyp,AdtDt,AdtRowId,AdtCreatedBy,AdtCreatedDt,AdtModifiedBy,
					AdtModifiedDt,AdtDelFlg,AdtDelId
	                )
				    SELECT     @LeadPk,'U',dbo.gefgChar2Date(rcu_int_dt),@RowId,@UsrDispNm,@CurDt,@UsrDispNm,
				               @CurDt,NULL,0
                    FROM       #RCUGlobalDtls 

					 SELECT	     @Error = @@ERROR, @RowCount = @@ROWCOUNT

					 IF @Error > 0
								BEGIN
									RAISERROR('%s',16,1,'Error : Legal Insert')
									RETURN
								END

						UPDATE 	A
						SET		LruScreen = rcu_screened, LruSample = rcu_sample, LruRptSts = rcu_status, LruRptDt = ISNULL(DBO.gefgChar2Date(rcu_date),@CurDt), 
								LruNotes = CASE @IsQcScreen WHEN 1 THEN LruNotes ELSE ISNULL(rcu_cmnts,'') END,
								LruApprovalNt = CASE @IsQcScreen WHEN 1 THEN ISNULL(rcu_cmnts,'') ELSE LruApprovalNt END,
								LruRowId = @RowId, LruModifiedBy = @UsrDispNm, LruModifiedDt = @CurDt,LruSupNm=rcu_nameofsup,LruRefNo=rcu_refId,LruDocSts=@Approver
						FROM	LosRCU A 
						JOIN    #Dtls B ON A.LruPk = B.rcu_pk
						WHERE   B.rcu_pk > 0


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