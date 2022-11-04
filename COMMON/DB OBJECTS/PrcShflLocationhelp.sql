IF EXISTS(SELECT NULL FROM sysobjects WHERE name='PrcShflLocationhelp' AND [type]='P')
	DROP PROC PrcShflLocationhelp
GO
CREATE PROCEDURE PrcShflLocationhelp
(
@LocCd VARCHAR(MAX)	= NULL,
@LocPk VARCHAR(MAX)	= NULL
)
AS
BEGIN 

		IF ISNULL(@LocCd,'0') = '0'					
			BEGIN
				SELECT NlmCd 'LocCd', NlmNm 'LocNm' , NlmPk 'LocPk' 
				FROM LosNHBLocMas(NOLOCK)
				WHERE NlmDelId = 0
			END
					
		ELSE
			BEGIN
				SELECT NlmCd 'LocCd', NlmNm 'LocNm' , NlmPk 'LocPk' 
				FROM LosNHBLocMas(NOLOCK)
				WHERE NlmDelId = 0 AND NlmCd LIKE  '%' + @LocCd + '%'
			END
END




