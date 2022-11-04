IF EXISTS(SELECT NULL FROM sysobjects WHERE name='PrcShflRefNohelp' AND [type]='P')
	DROP PROC PrcShflRefNohelp
GO
CREATE PROCEDURE PrcShflRefNohelp
(
@RefNo VARCHAR(MAX)	= NULL,
@RefPk VARCHAR(MAX)	= NULL,
@LeadPk	BIGINT		= NULL
)
AS
BEGIN 

--DECLARE @LeadPk BIGINT =  95355
	DECLARE @CusDtls TABLE (CusFk BIGINT , LedPk BIGINT)

	INSERT INTO @CusDtls
	SELECT LapCusFk CusFk, LapLedFk FROM LosAppProfile WHERE LapLedFk = @LeadPk AND LapDelid = 0 GROUP BY LapCusFk, LapLedFk

	INSERT INTO @CusDtls
	SELECT LapCusFk, LapLedFk FROM LosAppProfile WHERE EXISTS(SELECT 'X' FROM @CusDtls WHERE CusFk = LapCusFk AND LedPk <> LapLedFk) AND LapDelid = 0

	IF ISNULL(@RefNo,'0') = '0'
	BEGIN		
		SELECT	LlnLoanNo 'RefLoanNo',LlnPk 'Loanpk' 
		FROM	LosLoan(NOLOCK)		
		WHERE	EXISTS(SELECT 'X' FROM @CusDtls WHERE LedPk = LlnLedFk) AND LlnDelId = 0							
	END
	ELSE
	BEGIN						
		SELECT	LlnLoanNo 'RefLoanNo',LlnPk 'Loanpk' 
		FROM	LosLoan(NOLOCK)		
		WHERE	EXISTS(SELECT 'X' FROM @CusDtls WHERE LedPk = LlnLedFk) AND LlnDelId = 0  AND LlnLoanNo LIKE  '%' + @RefNo + '%'
	END
END






