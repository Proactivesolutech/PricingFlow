IF OBJECT_ID('PrcShflDepositebankhelp','P') IS NOT NULL
	DROP PROCEDURE PrcShflDepositebankhelp
GO

CREATE PROCEDURE PrcShflDepositebankhelp
(
@Bankname VARCHAR(MAX)	= NULL,
@Bank BIGINT				= NULL
)
AS
BEGIN 

					IF ISNULL(@Bankname,'0') = '0'
					BEGIN
				    SELECT  GabCd 'Code',GabNm 'BankName',GabAccNo 'AccountNo',GabPk 'Gblpk'
					FROM    GABnkMas(NOLOCK)
					WHERE	GabDelId = 0    
					END
					ELSE
					BEGIN
					SELECT	GabCd 'Code',GabNm 'BankName',GabAccNo 'AccountNo',GabPk 'Gblpk'
					FROM    GABnkMas(NOLOCK)
					WHERE	GabDelId = 0  AND GabCd LIKE  '%' + @Bankname + '%'
					END
END
