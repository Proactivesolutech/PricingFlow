IF OBJECT_ID('PrcShflScanBankhelp','P') IS NOT NULL
DROP PROC PrcShflScanBankhelp
GO
CREATE PROCEDURE PrcShflScanBankhelp
(
@Bankname VARCHAR(MAX)	= NULL,
@bnk VARCHAR(MAX)	= NULL
)
AS
BEGIN 

					IF ISNULL(@Bankname,'0') = '0'
					BEGIN
					SELECT	BnkCd 'BankCd', BnkNm 'BankName',BnkPk 'Bankpk' 
					FROM GenBnkMas(NOLOCK)
					WHERE	BnkDelId = 0  
					END
					ELSE
					BEGIN
					SELECT	BnkCd 'BankCd', BnkNm 'BankName',BnkPk 'Bankpk' 
					FROM GenBnkMas(NOLOCK)
					WHERE	BnkDelId = 0  AND BnkNm LIKE  '%' + @Bankname + '%'
					END
END

