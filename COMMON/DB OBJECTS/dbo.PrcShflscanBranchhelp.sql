IF OBJECT_ID('PrcShflscanBranchhelp','P') IS NOT NULL
DROP PROC PrcShflscanBranchhelp
GO
CREATE PROCEDURE PrcShflscanBranchhelp
(
@Branchname VARCHAR(MAX)	= NULL,
@Brnchfk BIGINT
)
AS
BEGIN 
					IF ISNULL(@Branchname,'0') = '0'
					BEGIN
					SELECT	BbmLoc 'Location', BbmMICR 'Micr',BbmIFSC 'Ifsc',BbmCentre 'Centre',BbmAddress 'Address',BbmState 'State',BbmPk 'Brnchpk'
	                FROM    GenBnkBrnchMas(NOLOCK)
					WHERE	BbmDelId = 0  AND BbmBnkFk = @Brnchfk
					END
					ELSE
					BEGIN
					SELECT	BbmLoc 'Location', BbmMICR 'Micr',BbmIFSC 'Ifsc',BbmCentre 'Centre',BbmAddress 'Address',BbmState 'State',BbmPk 'Brnchpk'
	                FROM    GenBnkBrnchMas(NOLOCK)
					WHERE	BbmDelId = 0  AND BbmBnkFk = @Brnchfk AND BbmLoc LIKE  '%' + @Branchname + '%'
					END		
END

