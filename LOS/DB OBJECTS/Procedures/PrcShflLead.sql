IF EXISTS(SELECT NULL FROM sysobjects WHERE name='PrcShflLead' AND [type]='P')
	DROP PROC PrcShflLead
GO
CREATE PROCEDURE PrcShflLead
(
    @Action		  VARCHAR(100)		=	NULL,
    @GlobalJson	  VARCHAR(100)		=	NULL,
	@HdrJson	  VARCHAR(MAX)		=	NULL,
	@LeadPk		  BIGINT			=	NULL,
	
)
AS
BEGIN
	SET NOCOUNT ON
	--RETURN
	DECLARE	@TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT,
			@UsrPk BIGINT, @UsrDispNm VARCHAR(100), @UsrNm VARCHAR(100);
			
	DECLARE	@CurDt DATETIME ,@RowId VARCHAR(40),@MaxLedNo BIGINT,@ledpk BIGINT,@LedFk BIGINT,@IsExs BIT = 0
	
	CREATE TABLE #GlobalDtls
	(
		id BIGINT, UsrPk BIGINT, UsrDispNm VARCHAR(100),UsrNm VARCHAR(100)
	)
	CREATE TABLE #HdlTbl
	(
		xx_id BIGINT,lead_pk BIGINT,lead_id VARCHAR(50),lead_Branch BIGINT,lead_ApplicantNm VARCHAR(100),lead_mobile VARCHAR(100),lead_dob VARCHAR(40),
		lead_incometyp BIGINT,lead_roi VARCHAR(15),lead_mktval VARCHAR(100),lead_loanamt VARCHAR(100),lead_tenure BIGINT,lead_mnthInc VARCHAR(100),
		lead_obl VARCHAR(100),lead_prvloanRcard TINYINT,lead_defloanRcard TINYINT,lead_proof TINYINT,lead_cibil BIGINT,lead_Agent BIGINT,
		LeadPrdPk BIGINT,ld_loanpurpose VARCHAR(10)
	)
			
	IF @GlobalJson != '[]' AND @GlobalJson != ''
		BEGIN
			INSERT INTO #GlobalDtls
			EXEC PrcParseJSON @GlobalJson,'UsrPk,UsrDispNm,UsrNm'
			
			SELECT	@UsrPk = UsrPk, @UsrDispNm = UsrDispNm, @UsrNm = UsrNm
			FROM	#GlobalDtls
			
		END		
	IF @HdrJson != '[]' AND @HdrJson != ''
		BEGIN	
			INSERT INTO #HdlTbl
			EXEC PrcParseJSON @HdrJson,'lead_pk,lead_id,lead_Branch,lead_ApplicantNm,lead_mobile,lead_dob,lead_incometyp,lead_roi,lead_mktval,lead_loanamt,lead_tenure,lead_mnthInc,lead_obl,lead_prvloanRcard,lead_defloanRcard,lead_proof,lead_cibil,lead_Agent,lead_prdPk,ld_loanpurpose'
			
			SELECT @ledpk = lead_pk FROM #HdlTbl
		END

		
	SELECT @CurDt = GETDATE(), @RowId = NEWID()	
	
	BEGIN TRY
	 
		IF @@TRANCOUNT = 0
			SET @TranCount = 1
		
		IF @TranCount = 1
			BEGIN TRAN			

				IF @Action = 'Insert-Lead'
					BEGIN
						SELECT @MaxLedNo = (CONVERT(BIGINT,RIGHT(MAX(LedId),5)) + 1) FROM LosLead(NOLOCK) WHERE LEN(LedId) = 9
						IF ISNULL(@MaxLedNo,0) = 0 SET @MaxLedNo =  1;
						
						IF EXISTS(SELECT 'X' FROM LosLead(NOLOCK),#HdlTbl WHERE LedId = lead_id)
							BEGIN
								RAISERROR('%s',16,1,'Lead ID Already Exists!!')
								RETURN
							END
							
						INSERT INTO LosLead (LedId,LedBGeoFk,LedNm,LedDOB,LedPrdFk,LedEmpCat,LedMrktVal,LedPrvLnCrd,LedLnAmt,LedTenure,LedDflt,
									LedMonInc,LedIncPrf,LedMonObli,LedCIBILScr,LedEMI,LedROI,LedRowId,LedCreatedBy,LedCreatedDt,LedModifiedBy,
									LedModifiedDt,LedDelFlg,LedDelId,LedAgtFk,LedMobNo,LedPGrpFk,LedPNI,LedBT)
						SELECT		ISNULL(lead_id,'SHFL' + dbo.gefgGetPadZero(5,(ISNULL(@MaxLedNo,0)))),lead_Branch,lead_ApplicantNm,
									ISNULL(DBO.gefgChar2Date(lead_dob),@CurDt), NULL,lead_incometyp,
									CAST(ISNULL(NULLIF(lead_mktval,''),0) AS NUMERIC (27,7)),lead_prvloanRcard,
									CAST(ISNULL(NULLIF(lead_loanamt,''),0) AS NUMERIC (27,7)),lead_tenure,lead_defloanRcard,
									CAST(ISNULL(NULLIF(lead_mnthInc,''),0) AS NUMERIC (27,7)),lead_proof,
									CAST(ISNULL(NULLIF(lead_obl,''),0) AS NUMERIC (27,7)),lead_cibil,0,
									ISNULL(lead_roi,0),@RowId,@UsrDispNm, @CurDt,@UsrDispNm, @CurDt, NULL,0,lead_Agent,lead_mobile,LeadPrdPk,
									CASE WHEN ld_loanpurpose = '0' THEN 'N' 
									WHEN  ld_loanpurpose = '1' THEN 'N' 
									WHEN  ld_loanpurpose = '2' THEN 'Y' END ,
									CASE WHEN ld_loanpurpose = '0' THEN 'N'  
									WHEN ld_loanpurpose = '1' then 'Y'
									WHEN  ld_loanpurpose = '2' THEN 'N' END
						FROM		#HdlTbl		
					
						SELECT		@LedFk = SCOPE_IDENTITY()

						SELECT		@LedFk 'leadpk', LedPNI 'lead_pni',LedBT 'lead_bt' FROM LosLead WHERE LedPk = @LedFk
					END																								
							
				IF @Action = 'Sel-Branch'
					BEGIN						
						SELECT	GeoNm 'BranchNm',GeoPk 'BranchPk' 
						FROM	GenGeoMas (NOLOCK) 
						WHERE	GeoLvlNo = 1 AND GeoDelid = 0
										
						SELECT	AgtFName 'firstnm', AgtMName 'midnm' ,  AgtLName  'lname',AgtPk 'AgtPk' 
						FROM	GenAgents (NOLOCK) 
						WHERE	AgtDelId = 0
	
						SELECT @MaxLedNo = (CONVERT(BIGINT,RIGHT(MAX(LedId),5)) + 1) FROM LosLead(NOLOCK)WHERE LEN(LedId) = 9
						IF ISNULL(@MaxLedNo,0) = 0 SET @MaxLedNo =  1;
							SELECT 'SHFL' + dbo.gefgGetPadZero(5,(ISNULL(@MaxLedNo,0))) 'Leadid'			
						
						SELECT	GrpPk 'productpk', GrpCd 'PCd'
						FROM	GenLvlDefn(NOLOCK)
						WHERE	GrpCd = 'HL' AND GrpDelId = 0
					END

				IF @Action = 'sel_prd'
					BEGIN
						SELECT  GrpNm 'productnm', GrpPk 'productpk', GrpCd 'ProductCode'
						FROM	GenLvlDefn(NOLOCK)
						WHERE	GrpDelId = 0
						
					END
				
				IF @Action = 'Search-Lead'
					BEGIN
						SELECT		LedId 'LeadId',LedNm 'LeadNm',LedPk 'LeadPk',GeoPk 'GeoPk',GeoNm 'BranchNm',
									GrpCd 'PCd',GrpPk 'PrdPk',GrpNm 'ProductNm'
						FROM		LosLead(NOLOCK)	
						JOIN		GenGeoMas(NOLOCK) ON GeoPk = LedBGeoFk AND GeoDelId = 0
						JOIN		GenLvlDefn(NOLOCK) ON GrpPk = LedPGrpFk AND GrpDelId = 0
						WHERE		LedDelid = 0
						ORDER BY	LedPk DESC
					END

				IF @Action = 'S'
					BEGIN
						IF EXISTS(SELECT 'X' FROM LosProcChrg(NOLOCK) WHERE LpcLedFk = @LeadPk AND LpcDelid = 0)
							SET @IsExs = 1;
							
						SELECT		LedId 'lead_id' ,LedBGeoFk 'lead_Branch',LedNm 'lead_ApplicantNm',DBO.gefgDMY(LedDOB) 'lead_dob',LedEmpCat 'lead_incometyp',
									LedMrktVal 'lead_mktval',LedPrvLnCrd 'lead_prvloanRcard',LedMobNo 'lead_mobile',
									LedLnAmt 'lead_loanamt',LedTenure 'lead_tenure',LedDflt 'lead_defloanRcard',
									LedMonInc 'lead_mnthInc',LedIncPrf 'lead_proof',LedMonObli 'lead_obl',LedCIBILScr 'lead_cibil',
									LedROI 'lead_roi',LedAgtFk 'lead_Agent' ,Ledpk 'lead_pk',LedPNI 'lead_pni',LedBT 'lead_bt',
									GeoPk 'lead_Branch',GeoNm 'BranchNm',AgtPk 'lead_Agent',AgtFName + '' + AgtMName + '' + AgtLName 'AgentName',
									@IsExs 'IsExists'
						FROM		LosLead(NOLOCK)	
						JOIN		GenGeoMas(NOLOCK) ON GeoPk = LedBGeoFk AND GeoDelId = 0
						LEFT JOIN	GenAgents(NOLOCK) ON AgtPk = LedAgtFk  AND AgtDelId = 0
						WHERE		LedPk = @LeadPk AND LedDelid = 0

					END

				IF @Action = 'UPDATE'
					BEGIN
						UPDATE	LosLead SET
								LedPGrpFk = ISNULL(LeadPrdPk,2),LedBGeoFk = lead_Branch ,LedNm = lead_ApplicantNm,LedDOB = ISNULL(DBO.gefgChar2Date(lead_dob),@CurDt),
								LedEmpCat =lead_incometyp ,LedMrktVal = lead_mktval,LedPrvLnCrd = lead_prvloanRcard,LedLnAmt =lead_loanamt ,LedTenure = lead_tenure,
								LedDflt = lead_defloanRcard,LedMonInc = lead_mnthInc,LedIncPrf = lead_proof,LedMonObli =lead_obl ,
								LedCIBILScr = lead_cibil,LedEMI = 0, LedAgtFk = lead_Agent,LedROI = lead_roi, LedMobNo = lead_mobile,
								LedModifiedBy = @UsrDispNm, LedModifiedDt = @CurDt, LedRowID = @RowId, 
								LedPNI = CASE WHEN ld_loanpurpose = '0' THEN 'N' 
									WHEN  ld_loanpurpose = '1' THEN 'N' 
									WHEN  ld_loanpurpose = '2' THEN 'Y' END ,

								LedBT= 	CASE WHEN ld_loanpurpose = '0' THEN 'N'  
									WHEN ld_loanpurpose = '1' then 'Y'
									WHEN  ld_loanpurpose = '2' THEN 'N' END
						FROM	#HdlTbl 
						WHERE	LedPk = @ledpk


						SELECT		@ledpk 'leadpk', LedPNI 'lead_pni',LedBT 'lead_bt' FROM LosLead WHERE LedPk = @ledpk
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
