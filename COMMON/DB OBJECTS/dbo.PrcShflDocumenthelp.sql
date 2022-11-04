IF OBJECT_ID('PrcShflDocumenthhelp','P') IS NOT NULL
	DROP PROCEDURE PrcShflDocumenthhelp
GO
CREATE PROCEDURE PrcShflDocumenthhelp
(
@Docname VARCHAR(MAX)	= NULL,
@Help  VARCHAR(MAX)	= NULL
)
AS
BEGIN 
					IF ISNULL(@Docname,'0') = '0'
					BEGIN
					  SELECT GdmName 'DocumentName',GdmPk 'DocPk' FROM GenDocuments WHERE
					  GdmKYC  = 'N' AND GdmStatFlg = 'L' AND GdmDelid = 0
					  END
					ELSE
					BEGIN	
					 SELECT GdmName 'DocumentName',GdmPk 'DocPk' FROM GenDocuments WHERE
				     GdmKYC  = 'N' AND GdmStatFlg = 'L' AND GdmDelid = 0 AND GdmName LIKE  '%' + @Docname + '%'
				    END				
END



