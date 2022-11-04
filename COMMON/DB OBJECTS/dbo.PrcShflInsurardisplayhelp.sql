ALTER PROCEDURE PrcShflInsurardisplayhelp
(
@Insname VARCHAR(MAX)	= NULL,
@ins BIGINT				= NULL
)
AS
BEGIN 

					IF ISNULL(@Insname,'0') = '0'
					BEGIN
				    SELECT	InsCd 'Insurer',InsNm 'InsurerName', InsDispNm 'ShortDescription',InsPk 'InPk'
					FROM    GenInsCmp(NOLOCK)
					WHERE	InsDelId = 0    
					END
					ELSE
					BEGIN
				    SELECT	InsCd 'Insurer',InsNm 'InsurerName', InsDispNm 'ShortDescription',InsPk 'InPk'
					FROM    GenInsCmp(NOLOCK)
					WHERE	InsDelId = 0   AND InsNm LIKE  '%' + @Insname + '%'
					END
END
