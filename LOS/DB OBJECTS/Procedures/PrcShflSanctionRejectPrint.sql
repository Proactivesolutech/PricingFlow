IF OBJECT_ID('PrcShflSanctionRejectPrint','P') IS NOT NULL
	DROP PROCEDURE PrcShflSanctionRejectPrint
GO
CREATE PROCEDURE PrcShflSanctionRejectPrint
(
@LeadPk		BIGINT	=	NULL
)
AS
BEGIN


SELECT CONVERT(VARCHAR,GETDATE(),107) 'date'

 
SELECT		ISNULL(LaaDoorNo,'') + ' , <br>' +
			ISNULL(LaaBuilding,'') + ' , ' + ISNULL(LaaPlotNo,' ') + ', <br>' +
			ISNULL(LaaStreet,'') + ISNULL(LaaLandmark,'') +', <br> '+
			ISNULL(LaaArea,'') + ',' + ISNULL(LaaDistrict,'') + ' <br>'+
			ISNULL(LaaState,'') + ' '+ISNULL(LaaPin,'') +' <br>' 'Addr'  

FROM     LosAppAddress(NOLOCK) 
JOIN     LosAppProfile(NOLOCK)  ON LaaLedFk=LapLedFk
WHERE     LapActor=0 AND LaaDelId=0 AND LaaAddTyp=0 AND  LaaLedFk=@LeadPk


SELECT   LsnSancNo 'SancNo',CONVERT(VARCHAR,LsnSancDt,107) 'SancDt' 
FROM	 LosSanction 
WHERE    LsnLedFk=@LeadPk AND LsnDelId=0

SELECT   ISNULL(PrdNm,' ')'PrdNM'
FROM     GenPrdMas 
JOIN     Loslead ON PrdPk=LedPrdFk  
WHERE	 LedPk=@LeadPk

SELECT   '<strong> RejectionRemarks : </strong> ' + ISNULL(LanNotes,'') 'Notes'
FROM     LosAppNotes(NOLOCK) 
WHERE    LanLedFk =@LeadPk AND LanDelId=0 AND LanTyp='R'


END