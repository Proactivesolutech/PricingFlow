IF OBJECT_ID('PrcShflKychhelp','P') IS NOT NULL
	DROP PROCEDURE PrcShflKychhelp
GO
CREATE PROCEDURE PrcShflKychhelp
(
@Docname VARCHAR(MAX)	= NULL,
@Help  VARCHAR(MAX)	= NULL
)
AS
BEGIN 
					IF ISNULL(@Docname,'0') = '0'
					BEGIN
					  IF ISNULL(@Help,'0') <> '0'
					  BEGIN

					  --ADDRESS PROOF
					    IF @Help = 'A'
					    BEGIN
						 SELECT GdmValidity 'Docvalidpk',GdmName 'DocumentName',GdmPk 'DocPk' FROM GenDocuments WHERE
						 GdmAddrProof = 'Y' AND GdmStatFlg = 'L' AND GdmDelid = 0
					    END

					    --ID PROOF
					    ELSE IF @Help = 'I'
					    BEGIN
						 SELECT GdmValidity 'Docvalidpk',GdmName 'DocumentName',GdmPk 'DocPk' FROM GenDocuments WHERE
						 GdmIDProof  = 'Y' AND GdmStatFlg = 'L' AND GdmDelid = 0
					    END   

						--DOB PROOF
					   ELSE IF @Help = 'D'
					    BEGIN
						 SELECT GdmValidity 'Docvalidpk',GdmName 'DocumentName',GdmPk 'DocPk' FROM GenDocuments WHERE
						 GdmAgeProof = 'Y' AND GdmStatFlg = 'L' AND GdmDelid = 0
					    END
						 
						 --SIGNATURE PROOF
					   ELSE IF @Help = 'S'
					    BEGIN
						 SELECT GdmValidity 'Docvalidpk',GdmName 'DocumentName',GdmPk 'DocPk' FROM GenDocuments WHERE
						 GdmSignProof  = 'Y' AND GdmStatFlg = 'L' AND GdmDelid = 0
					    END

						ELSE IF @help = '1'
						BEGIN 
						 SELECT GdmValidity 'Docvalidpk',GdmName 'DocumentName',GdmPk 'DocPk' FROM GenDocuments WHERE
						 GdmStatFlg = 'L' AND GdmDelid = 0
						END
					  END
					END
					ELSE
					BEGIN
				
					 IF ISNULL(@Help,'0') <> '0'
					  BEGIN

					  --ADDRESS PROOF
					    IF @Help = 'A'
					    BEGIN
						 SELECT GdmValidity 'Docvalidpk',GdmName 'DocumentName',GdmPk 'DocPk' FROM GenDocuments WHERE
						 GdmAddrProof = 'Y' AND GdmStatFlg = 'L' AND GdmDelid = 0 AND GdmName LIKE  '%' + @Docname + '%'
					    END

					    --ID PROOF
					    ELSE IF @Help = 'I'
					    BEGIN
						 SELECT GdmValidity 'Docvalidpk',GdmName 'DocumentName',GdmPk 'DocPk' FROM GenDocuments WHERE
						 GdmIDProof  = 'Y' AND GdmStatFlg = 'L' AND GdmDelid = 0 AND GdmName LIKE  '%' + @Docname + '%'
					    END   

						--DOB PROOF
					    ELSE IF @Help = 'D'
					    BEGIN
						 SELECT GdmValidity 'Docvalidpk',GdmName 'DocumentName',GdmPk 'DocPk' FROM GenDocuments WHERE
						 GdmAgeProof = 'Y' AND GdmStatFlg = 'L' AND GdmDelid = 0 AND GdmName LIKE  '%' + @Docname + '%'
					    END
						 
						 --SIGNATURE PROOF
					   ELSE IF @Help = 'S'
					    BEGIN
						 SELECT GdmValidity 'Docvalidpk',GdmName 'DocumentName',GdmPk 'DocPk' FROM GenDocuments WHERE
						 GdmSignProof  = 'Y' AND GdmStatFlg = 'L' AND GdmDelid = 0 AND GdmName LIKE  '%' + @Docname + '%'
					    END

						ELSE IF @help = '1'
						BEGIN 
						 SELECT GdmValidity 'Docvalidpk',GdmName 'DocumentName',GdmPk 'DocPk' FROM GenDocuments WHERE
						 GdmStatFlg = 'L' AND GdmDelid = 0 AND GdmName LIKE  '%' + @Docname + '%'
						END
					  END
					END		
END



