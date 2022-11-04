ALTER PROCEDURE PrcShflScanBankhelp
(
@Bankname VARCHAR(MAX)	= NULL,
@bnk VARCHAR(MAX)	= NULL
)
AS
BEGIN 
	IF ISNULL(@Bankname,'') <> ''
	BEGIN
		SELECT	BnkCd 'BankCd', BnkNm 'BankName',BnkPk 'Bankpk' 
		FROM GenBnkMas(NOLOCK)
		WHERE	BnkDelId = 0  AND BnkNm LIKE  '%' + @Bankname + '%'
	END
	ELSE
	BEGIN
		SELECT	BnkCd 'BankCd', BnkNm 'BankName',BnkPk 'Bankpk' 
		FROM GenBnkMas(NOLOCK)
		WHERE	BnkDelId = 0 
	END
END


