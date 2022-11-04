IF OBJECT_ID('PrcShflExceptionReport','P') IS NOT NULL
	DROP PROCEDURE PrcShflExceptionReport
GO
CREATE PROC PrcShflExceptionReport
(
	@Action		VARCHAR(50) = NULL,
	@FrmDt		VARCHAR(50) = NULL,
	@ToDt		VARCHAR(50) = NULL
)
AS
BEGIN
	IF (@Action = 'PFOverride')
	BEGIN
		SELECT	ROW_NUMBER() OVER(ORDER BY A.LlnLoanDt) 'S.No', C.LedId 'LeadId',  S.LsnSancNo 'Sanction No.',A.LlnLoanNo 'Loan No.', CONVERT(VARCHAR,A.LlnLoanDt,103) 'Loan Date'
		FROM	dbo.LosLoan (NOLOCK) A
		JOIN	dbo.LosPostSanction (NOLOCK) B ON A.LlnLpsFk = B.LpsPk AND B.LpsDelId = 0
		JOIN	dbo.LosSanction (NOLOCK) S ON B.LpsLsnFk = S.LsnPk AND S.LsnDelId = 0
		JOIN	dbo.LosLead (NOLOCK) C On A.LlnLedFk = C.LedPk AND C.LedDelId = 0		
		WHERE	CONVERT(DATE,A.LlnLoanDt,103) BETWEEN CONVERT(DATE,@FrmDt,103) AND CONVERT(DATE,@ToDt,103) 
		AND		ISNULL(B.LpsOvrride,'') = 'Y' AND A.LlnDelId = 0	
		ORDER BY A.LlnLoanDt
	END
END
