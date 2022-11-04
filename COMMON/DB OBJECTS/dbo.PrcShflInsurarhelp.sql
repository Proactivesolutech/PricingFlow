IF OBJECT_ID('PrcShflInsurarhelp','P') IS NOT NULL
DROP PROC PrcShflInsurarhelp
GO
CREATE PROCEDURE PrcShflInsurarhelp
(
@insurarname VARCHAR(MAX)	= NULL,
@insurar VARCHAR(MAX)	= NULL
)
AS
BEGIN 
    IF ISNULL(@insurarname,'0') = '0'
	BEGIN
	SELECT	InsNm  'InsurerDescription', InsDispNm 'ShortDescription' ,InsPk 'InPk' 
	FROM	GenInsCmp (NOLOCK) 
	WHERE	InsDelId = 0 
	END
	ELSE
	BEGIN
	SELECT	InsNm  'InsurerDescription', InsDispNm 'ShortDescription' ,InsPk 'InPk' 
	FROM	GenInsCmp (NOLOCK) 
	WHERE	InsDelId = 0  AND InsDispNm LIKE  '%' + @insurarname + '%' 
	END
END
