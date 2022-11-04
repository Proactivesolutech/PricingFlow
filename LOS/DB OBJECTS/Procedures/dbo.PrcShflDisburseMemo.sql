--EXEC PrcShflDisburseMemo 5041,2191
IF OBJECT_ID('PrcShflDisburseMemo','P') IS NOT NULL
	DROP PROCEDURE PrcShflDisburseMemo
GO
CREATE PROCEDURE PrcShflDisburseMemo
(	
	@LeadPk BIGINT = NULL,
	@SancPk	BIGINT = NULL
) 
AS
BEGIN	
	DECLARE @AppPrd VARCHAR(100), @CoAppNm VARCHAR(500), @NoofDisburse BIGINT

	CREATE TABLE #LnDisburseDet
	(
		ID BIGINT,LeadFK BIGINT, SancFK BIGINT, SancNo VARCHAR(50), LOAN_AMT NUMERIC(27, 7), TENUR NUMERIC(27, 7),ROI NUMERIC(27, 7),
		EMI NUMERIC(27, 7),LI NUMERIC(27, 7),GI NUMERIC(27, 7),BT_AMT NUMERIC(27, 7),BT_ROI NUMERIC(27, 7),BT_EMI NUMERIC(27, 7),
		BT_LI NUMERIC(27, 7),BT_GI NUMERIC(27, 7),TOPUP_AMT NUMERIC(27, 7),TOPUP_ROI NUMERIC(27, 7),TOPUP_EMI NUMERIC(27, 7),
		TOPUP_LI NUMERIC(27, 7),TOPUP_GI NUMERIC(27, 7),LTV NUMERIC(27, 7),ACT_LTV NUMERIC(27, 7),BT_LTV_A NUMERIC(27, 7),
		TOPUP_LTV_A NUMERIC(27, 7),BT_LTV_M NUMERIC(27, 7),TOPUP_LTV_M NUMERIC(27, 7), TotalPF NUMERIC(27, 7), BTPF NUMERIC(27, 7),
		TopupPF NUMERIC(27, 7),TotalPFCollected NUMERIC(27, 7), BTPFCollected NUMERIC(27, 7),
		TopupPFCollected NUMERIC(27, 7),BalPF NUMERIC(27, 7), BTPFBal NUMERIC(27, 7),
		TopupPFBal NUMERIC(27, 7), Spread NUMERIC(27, 7),TENUR_TOP NUMERIC(27,7), Waiver_ROI NUMERIC(27, 7),
		PrdCd VARCHAR(50), PrdFK BIGINT
	)

	INSERT INTO #LnDisburseDet
	EXEC PrcShflLoanDetail @LeadPk

	SELECT @AppPrd = B.PrdCd FROM LosApp A JOIN GenPrdMas B ON A.AppPrdFk = B.PrdPk WHERE A.AppLedFk = @LeadPk

	SELECT LapActor 'Actor', LapFstNm + ' ' + LapMdNm + ' ' + LapLstNm + '<br/>' 'Name'
	INTO #ApplicantDet
	FROM LosAppProfile
	WHERE LapLedFk = @LeadPk

	--Applicant Details
	SELECT Name 'ApplNm' FROM #ApplicantDet WHERE Actor = 0

	SELECT @CoAppNm = Name
	FROM #ApplicantDet 
	WHERE Actor <> 0

	IF(ISNULL(@CoAppNm,'') <> '')
	BEGIN
		SELECT @CoAppNm 'CoAppNm'
	END
	ELSE
	BEGIN
		SELECT 'NA' 'CoAppNm'
	END

	--Loan Details
	SELECT Ln.LlnLoanNo 'LoanNo',CAST(CAST(A.LpsLnAmt AS NUMERIC(27,2)) AS VARCHAR) 'SancAmt', CAST(CAST(A.LpsFinalLnAmt AS NUMERIC(27,2)) AS VARCHAR) 'FinLnAmt', 
		   CAST(CAST(A.LpsEMI AS NUMERIC(27,2)) AS VARCHAR) 'EMI', B.PrdNm 'LnType', C.GeoNm 'Branch',CAST(CAST(L.Spread AS NUMERIC(27,2)) AS VARCHAR) 'Spread', 
		   CASE	WHEN B.PrdCd IN ('HLBT','LAPBT')	   AND @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN CAST(CAST(L.BT_ROI AS NUMERIC(27,2)) AS VARCHAR)
				WHEN B.PrdCd IN ('HLTopup','LAPTopup') AND @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN CAST(CAST(L.TOPUP_ROI AS NUMERIC(27,2)) AS VARCHAR)
				ELSE CAST(CAST(L.ROI AS NUMERIC(27,2)) AS VARCHAR) 
			END + CAST(CAST(ISNULL(Waiver_ROI,0) AS NUMERIC(27,2)) AS VARCHAR) + '%' 'ROI', 
			CASE	WHEN B.PrdCd IN ('HLBT','LAPBT')	   AND @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN CAST(CAST(L.BTPF AS NUMERIC(27,2)) AS VARCHAR)
					WHEN B.PrdCd IN ('HLTopup','LAPTopup') AND @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN CAST(CAST(L.TopupPF AS NUMERIC(27,2)) AS VARCHAR)
					ELSE CAST(CAST(L.TotalPF AS NUMERIC(27,2)) AS VARCHAR) 
			END 'PFAmt', 
			CASE	WHEN B.PrdCd IN ('HLTopup','LAPTopup') AND @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN CAST(CAST(L.TENUR_TOP AS NUMERIC(27,0)) AS VARCHAR)
							ELSE CAST(CAST(L.TENUR AS NUMERIC(27,0)) AS VARCHAR)  
			END 'FinTenure',	
		   '15%' 'Shplr', CONVERT(VARCHAR,Ln.LlnCreatedDt,103) 'LnDate',  CAST(CAST(Ld.LedTenure AS NUMERIC(27,0)) AS VARCHAR) 'ReqTenure'
	FROM dbo.LosPostSanction A
	JOIN #LnDisburseDet L ON A.LpsLedFk = L.LeadFK AND A.LpsLsnFk = L.SancFK
	JOIN dbo.GenPrdMas B ON A.LpsPrdFk = B.PrdPk
	JOIN dbo.GenGeoMas C ON A.LpsBGeoFk = C.GeoPk
	JOIN dbo.LosLoan Ln ON A.LpsLedFk = Ln.LlnLedFk AND A.LpsLsnFk = Ln.LlnLsnFk
	JOIN dbo.LosLead Ld ON A.LpsLedFk = Ld.LedPk
	WHERE A.LpsLedFk = @LeadPk AND A.LpsLsnFk = @SancPk AND A.LpsDelId = 0

	--InFavour Details
	SELECT ROW_NUMBER() Over(Order by LpdCreatedDt) 'Sno',LpdInFav 'InFavour', CAST(CAST(LpdAmt AS NUMERIC(27,2)) AS VARCHAR) 'PayAmt',
		   CASE LpdInsTyp WHEN 'C' THEN 'Cheque'
						  WHEN 'D' THEN 'DD'
						  WHEN 'N' THEN 'NEFT'
						  WHEN 'R' THEN 'RTGS' 
		   END 'IntrtType'
	INTO #PayDtls
	FROM LosPayDtls
	WHERE LpdLsnFk = @SancPk AND LpdDelId = 0 
	

	SELECT @NoofDisburse = COUNT(*) FROM #PayDtls

	IF EXISTS(SELECT TOP 1 'X' FROM LosPostSanction WHERE LpsLedFk = @LeadPk AND LpsLsnFk = @SancPk AND LpsPFAdjFrmLn = 0 AND LpsDelId = 0)
	BEGIN
		INSERT INTO #PayDtls
		SELECT @NoofDisburse+1,'Processing fee (Subject to Adjustment)',CAST(CAST(LpsPFAdjAmt AS NUMERIC(27,2)) AS VARCHAR) 'PayAmt', '-' 'IntrtType'
		FROM LosPostSanction 
		WHERE LpsLedFk = @LeadPk AND LpsLsnFk = @SancPk AND LpsPFAdjFrmLn = 0 AND LpsDelId = 0

		SET @NoofDisburse += 1
	END

	SELECT @NoofDisburse 'NoofDisburse'

	SELECT * FROM #PayDtls

	SELECT TOP 1 CASE LcqPayMode WHEN 'P' THEN 'PDC'
								 WHEN 'E' THEN 'ECS'
								 WHEN 'N' THEN 'NACH'
				 END 'RepaymentMode'
	FROM LosAppCheque
	WHERE LcqLsnFk = @SancPk
	ORDER BY LcqCreatedDt
END

