IF OBJECT_ID('PrcShflsaleOfzhelp','P') IS NOT NULL
	DROP PROCEDURE PrcShflsaleOfzhelp
GO

CREATE PROCEDURE PrcShflsaleOfzhelp
(
@Ofzname VARCHAR(MAX)	= NULL,
@OFZ BIGINT				= NULL,
@BranchFk	BIGINT			= NULL
)
AS
BEGIN 

					IF ISNULL(@Ofzname,'0') = '0'
					BEGIN
				    SELECT	GblBGeoFk 'BGeoPk', GblNm 'Location',GblCd 'Code',GblPk 'Gblpk'
					FROM    GenBusiLocation(NOLOCK)
					WHERE	GblDelId = 0 AND GblBGeoFk=@BranchFk   
					END
					ELSE
					BEGIN
					SELECT	GblBGeoFk 'BGeoPk', GblNm 'Location',GblCd 'Code',GblPk 'Gblpk'
					FROM    GenBusiLocation(NOLOCK)
					WHERE	GblDelId = 0  AND GblBGeoFk=@BranchFk AND GblNm LIKE  '%' + @Ofzname + '%'   
					END
END
