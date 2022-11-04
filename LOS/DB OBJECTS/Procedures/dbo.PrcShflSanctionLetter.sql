IF OBJECT_ID('PrcShflSanctionLetter','P') IS NOT NULL
	DROP PROCEDURE PrcShflSanctionLetter
GO
CREATE PROCEDURE PrcShflSanctionLetter
(
	@Action			VARCHAR(100) ,
	@GlobalJson		VARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE @CurDt DATETIME, @TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT

	DECLARE @DBNAME VARCHAR(20) = db_name() , @LeadPk BIGINT


	DECLARE @GeoFk BIGINT, @UsrPk BIGINT, @UsrDispNm VARCHAR(100), @UsrNm VARCHAR(100),@PrdFk BIGINT,
		@AppFk BIGINT,@LapFk BIGINT, @CreditPk BIGINT,@RowId VARCHAR(MAX) , @RoleFk BIGINT , @SanctionNo VARCHAR(50) , @SanctionPk BIGINT,
		@MaxSanNo BIGINT , @AgtFk BIGINT , @PfPk BIGINT , @ApproverLvl TINYINT , @LoanNo VARCHAR(50) , @MaxLoanNo BIGINT;

	CREATE TABLE #GlobalDtls
	(
		xx_id BIGINT,LeadPk BIGINT,LeadId VARCHAR(100),LeadNm VARCHAR(100),AppNo VARCHAR(100), GeoFk BIGINT, BranchNm VARCHAR(100),UsrDispNm VARCHAR(100),
		PrdFk BIGINT,PrdNm VARCHAR(100),AgtFk BIGINT
	)
		
	IF @GlobalJson != '[]' AND @GlobalJson != ''
	BEGIN	
		
		INSERT INTO #GlobalDtls
		EXEC PrcParseJSON @GlobalJson,'FwdDataPk,LeadId,LeadNm,AppNo,GeoFk,BranchNm,UsrDispNm,PrdFk,PrdNm,AgtFk'

		SELECT	@LeadPk = LeadPk, @UsrDispNm = G.UsrDispNm, 
				@PrdFk = AppPrdFk, @AgtFk = G.AgtFk
		FROM	#GlobalDtls G
		JOIN	LosApp (NOLOCK) ON AppLedFk = LeadPk AND AppDelId = 0				
	END

	BEGIN TRY
	 
		IF @@TRANCOUNT = 0
			SET @TranCount = 1
		
		IF @TranCount = 1
			BEGIN TRAN
			
			IF @Action = 'PRINT_SCANCTION'
			BEGIN
				-- 1 Sanction Details
				SELECT	RTRIM(LedId) +' / ' + RTRIM(LsnSancNo) 'SancNo',CONVERT(VARCHAR,LsnSancDt,106) 'SancDate' , 
						LsnPk 'SanctionPk' , PrdCd 'ProductCode' , PrdPk 'Productpk',PrdNm 'ProductName'
				INTO	#SancTable
				FROM	LosSanction(NOLOCK) 
				JOIN	LosLead (NOLOCK) ON LedPk = LsnLedFk AND LedDelId = 0 
				JOIN	GenPrdMas (NOLOCK) ON  PrdPk = LsnPrdFk AND PrdDelId = 0
				WHERE	LsnLedFk = @LeadPk AND LsnDelId = 0 AND 
						LsnRvnNo = (SELECT MAX(Q.LsnRvnNo) FROM LosSanction Q(NOLOCK) WHERE Q.LsnLedFk = @LeadPk AND Q.LsnDelId = 0)		
								
				IF EXISTS(SELECT 'X' FROM #SancTable)
				BEGIN
					SELECT * FROM #SancTable
				END
				ELSE
				BEGIN
					SELECT 'Loan is not yet sanctioned for this Lead.' AS 'ERROR';
				END

				--2  Applicant, Product 
				SELECT	 AppApplNm  'AppName', PrdNm 'Product' , 
						CASE WHEN AppLnPur = 0 THEN 'Take over of existing Housing Loan' 
							WHEN AppLnPur = 1 THEN 'Extend Renovate Repair of House Flat' 
							WHEN AppLnPur = 2 THEN 'Construction' 
							WHEN AppLnPur = 3 THEN 'Plot And Construction' 
							WHEN AppLnPur = 4 THEN 'Flat New' 
							WHEN AppLnPur = 5 THEN 'Flat Resale' 
							WHEN AppLnPur = 6 THEN 'House New' 
							WHEN AppLnPur = 7 THEN 'House ReSale' 
							WHEN AppLnPur = 8 THEN 'Refinance' 
							WHEN AppLnPur = 9 THEN 'House Old' 
							WHEN AppLnPur = 10 THEN 'Additional Finance' 
							WHEN AppLnPur = 11 THEN 'House Extension' 
							END 'Purpose',
							PrdCd 'OrgProduct' 
				FROM	LosApp (NOLOCK) 
				JOIN	GenPrdMas (NOLOCK) ON PrdPk =  AppPrdFk AND PrdDelId = 0
				WHERE	AppLedFk = @LeadPk AND AppDelId = 0								


				-- 3 Credit Loan details
				--SELECT	LcaLcrFk 'CreditPk',LcaLnaFk 'LnAttrPk',LnaCd 'AttrCode',LcaVal 'Value',LcaPk 'AttrPK'
				--FROM	LosCreditAttr (NOLOCK) A
				--JOIN	LosLnAttributes (NOLOCK) L ON L.LnaPk = A.LcaLnaFk AND L.LnaDelId = 0
				--JOIN	LosCredit (NOLOCK) B ON B.LcrPk = A.LcaLcrFk AND B.LcrDelId = 0
				--WHERE	B.LcrLedFk = @LeadPk AND A.LcaDelId = 0  
				--		AND LcrDocRvsn = 2 
			
			SELECT OBL,IIR,NET_INC,FOIR,CBL,TENUR,LOAN_AMT,ROI,EMI,SPREAD,EST_PRP,ACT_PRP,LTV,
							ACT_LTV,LI,GI,TOPUP_AMT,BT_AMT,BT_ROI,BT_EMI,TOPUP_EMI,BT_LI,TOPUP_LI,BT_GI,TOPUP_GI,TOPUP_ROI FROM 
			(
				SELECT	LnaCd 'AttrCode',LsaVal 'Value'
				FROM	LosSanctionAttr (NOLOCK) A
				JOIN	LosSanction	S (NOLOCK) ON S.LsnPk = A.LsaLsnFk AND S.LsnDelId = 0
				JOIN	LosLnAttributes (NOLOCK) L ON L.LnaPk = A.LsaLnaFk AND L.LnaDelId = 0				
				WHERE	LsnRvnNo = (SELECT MAX(Q.LsnRvnNo) FROM LosSanction Q(NOLOCK) WHERE Q.LsnLedFk = @LeadPk AND Q.LsnDelId = 0)		
						AND S.LsnLedFk = @LeadPk AND LnaCd IN ('OBL','IIR','NET_INC','FOIR','CBL','TENUR','LOAN_AMT','ROI','EMI','SPREAD','EST_PRP','ACT_PRP','LTV',
							'ACT_LTV','LI','GI','TOPUP_AMT','BT_AMT','BT_ROI','BT_EMI','TOPUP_EMI','BT_LI','TOPUP_LI','BT_GI','TOPUP_GI','TOPUP_ROI')
			)
			PIVOTTABLE
			PIVOT (MAX(Value) FOR AttrCode IN (OBL,IIR,NET_INC,FOIR,CBL,TENUR,LOAN_AMT,ROI,EMI,SPREAD,EST_PRP,ACT_PRP,LTV,
							ACT_LTV,LI,GI,TOPUP_AMT,BT_AMT,BT_ROI,BT_EMI,TOPUP_EMI,BT_LI,TOPUP_LI,BT_GI,TOPUP_GI,TOPUP_ROI) )
			AS PIVOTTABLE

				-- 4 Subjective				
				SELECT	LscNote 'condition' FROM LosSubjCondtion(NOLOCK) 
				JOIN	LosSanction(NOLOCK) ON LsnPk = LscLsnFk  AND LsnDelId = 0
				WHERE	LsnLedFk = @LeadPk AND LscDelId = 0

				SELECT ISNULL(SUM(LpcChrg),0) 'PF'
				FROM	LosProcChrg(NOLOCK) 
				WHERE	LpcLedFk = @LeadPk AND LpcDelId = @LeadPk 

			END

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