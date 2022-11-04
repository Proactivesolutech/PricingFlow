ALTER PROCEDURE PrcShflbuildermas
(
	@Action			VARCHAR(100) = NULL,
	@DtlsJson		VARCHAR(MAX) = NULL,
	@GbaGbmFk		BIGINT		 = NULL
)
AS
BEGIN 

DECLARE @GbmPk BIGINT
DECLARE @GbmCd VARCHAR(50),@GbmName VARCHAR(100),@GbmContactPerson VARCHAR(100),@GbmLandNo VARCHAR(50),@GbmMobileNo VARCHAR(50),@GbmPANNo VARCHAR(50),
        @GbmCINNo VARCHAR(50),@GbmEmail VARCHAR(50),@GbaDoorNo VARCHAR(10),@GbaBuilding VARCHAR(150),@GbaPlotNo VARCHAR(20),@GbaStreet VARCHAR(150),
		@GbaLandmark VARCHAR(250),@GbaArea VARCHAR(150),@GbaDistrict VARCHAR(100),@GbaState VARCHAR(100),@GbaCountry VARCHAR(100),@GbaPin VARCHAR(6)

CREATE TABLE #TEMPDtls
(
XX_ID BIGINT,BuiGbmCd VARCHAR(50),BuiGbmName VARCHAR(100),BuiGbmContactPerson VARCHAR(100),BuiGbmLandNo VARCHAR(50),
BuiGbmMobileNo VARCHAR(50),BuiGbmPANNo VARCHAR(50),BuiGbmCINNo VARCHAR(50),BuiGbmEmail VARCHAR(50),BuiGbaDoorNo VARCHAR(10),BuiGbaBuilding VARCHAR(150),
BuiGbaPlotNo VARCHAR(20),BuiGbaStreet VARCHAR(150),BuiGbaLandmark VARCHAR(250),BuiGbaArea VARCHAR(150),BuiGbaDistrict VARCHAR(100),BuiGbaState VARCHAR(100),
BuiGbaCountry VARCHAR(100),buiGbaPin VARCHAR(6)
)
	
IF @DtlsJson != '[]' AND @DtlsJson !='' 
BEGIN 
INSERT INTO #TEMPDtls
EXEC PrcParseJSON @DtlsJson,'GbmCd,GbmName,GbmContactPerson,GbmLandNo,GbmMobileNo,GbmPANNo,GbmCINNo,GbmEmail,GbaDoorNo,GbaBuilding,GbaPlotNo,GbaStreet,GbaLandmark,GbaArea,GbaDistrict,GbaState,GbaCountry,GbaPin'

SELECT   @GbmCd=BuiGbmCd,@GbmName=BuiGbmName,@GbmContactPerson=BuiGbmContactPerson,@GbmLandNo=BuiGbmLandNo,@GbmMobileNo=BuiGbmMobileNo,
         @GbmPANNo=BuiGbmPANNo,@GbmCINNo=BuiGbmCINNo,@GbmEmail=BuiGbmEmail,@GbaDoorNo=BuiGbaDoorNo,@GbaBuilding=BuiGbaBuilding,@GbaPlotNo=BuiGbaPlotNo,
		 @GbaStreet=BuiGbaStreet,@GbaLandmark=BuiGbaLandmark,@GbaArea=BuiGbaArea,@GbaDistrict=BuiGbaDistrict,@GbaState=BuiGbaState,@GbaCountry=BuiGbaCountry,
		 @GbaPin=buiGbaPin
FROM     #TEMPDtls
END
IF @Action='LOAD'
BEGIN	
	SELECT   GbmCd 'GbmCd',GbmName 'GbmName',GbmContactPerson 'GbmContactPerson',GbmLandNo 'GbmLandNo',GbmMobileNo 'GbmMobileNo',GbmPANNo 'GbmPANNo',
	         GbmCINNo 'GbmCINNo',GbmEmail 'GbmEmail',GbaDoorNo 'GbaDoorNo',GbaBuilding 'GbaBuilding',GbaPlotNo 'GbaPlotNo',GbaStreet 'GbaStreet',
			 GbaLandmark 'GbaLandmark',GbaArea 'GbaArea',GbaDistrict 'GbaDistrict',GbaState 'GbaState',GbaCountry 'GbaCountry',GbaPin 'GbaPin',GbaGbmFk 'GbaGbmFk'
	FROM     GenBuilder 
	JOIN     GenBuilderAddress ON GbmPk=GbaGbmFk  
	WHERE    GbmDelId=0 AND GbaDelId=0	
END
IF @Action='SAVE'
BEGIN
INSERT INTO    GenBuilder
(
               GbmCd,GbmName,GbmContactPerson,GbmLandNo,GbmMobileNo,GbmPANNo,GbmCINNo,GbmEmail,GbmRowId,GbmCreatedBy,
               GbmCreatedDt,GbmModifiedBy,GbmModifiedDt,GbmDelFlg,GbmDelId
)
    SELECT     BuiGbmCd,BuiGbmName,BuiGbmContactPerson,BuiGbmLandNo,BuiGbmMobileNo,BuiGbmPANNo,BuiGbmCINNo,BuiGbmEmail,
               NEWID(),'ADMIN',GETDATE(),'ADMIN',GETDATE(),NULL,0 
      FROM     #TEMPDtls


	SELECT	@GbmPk = SCOPE_IDENTITY()



INSERT INTO  GenBuilderAddress
(
             GbaGbmFk,GbaDoorNo,GbaBuilding,GbaPlotNo,GbaStreet,GbaLandmark,GbaArea,GbaDistrict,GbaState,GbaCountry,GbaPin,
             GbaRowId,GbaCreatedBy,GbaCreatedDt,GbaModifiedBy,GbaModifiedDt,GbaDelFlg,GbaDelId
)
	SELECT   @GbmPk,BuiGbaDoorNo,BuiGbaBuilding,BuiGbaPlotNo,BuiGbaStreet,BuiGbaLandmark,BuiGbaArea,BuiGbaDistrict,BuiGbaState,BuiGbaCountry,buiGbaPin,
	         NEWID(),'ADMIN',GETDATE(),'ADMIN',GETDATE(),NULL,0
    FROM     #TEMPDtls

END

IF @Action='SELECT'

BEGIN
    SELECT   GbmCd 'GbmCd',GbmName 'GbmName',GbmContactPerson 'GbmContactPerson',GbmLandNo 'GbmLandNo',GbmMobileNo 'GbmMobileNo',GbmPANNo 'GbmPANNo',
	         GbmCINNo 'GbmCINNo',GbmEmail 'GbmEmail',GbaDoorNo 'GbaDoorNo',GbaBuilding 'GbaBuilding',GbaPlotNo 'GbaPlotNo',GbaStreet 'GbaStreet',
			 GbaLandmark 'GbaLandmark',GbaArea 'GbaArea',GbaDistrict 'GbaDistrict',GbaState 'GbaState',GbaCountry 'GbaCountry',GbaPin 'GbaPin'
	FROM     GenBuilder 
	JOIN     GenBuilderAddress ON GbmPk=GbaGbmFk  
	WHERE    GbmPk=@GbaGbmFk
END


IF @Action='UPDATE'
BEGIN
 UPDATE  GenBuilder
   SET   GbmCd=@GbmCd,GbmName=@GbmName,GbmContactPerson=@GbmContactPerson,GbmLandNo=@GbmLandNo,GbmMobileNo=@GbmMobileNo,GbmPANNo=@GbmPANNo,GbmCINNo=GbmCINNo,
         GbmEmail=@GbmEmail
  FROM   #TEMPDtls
  WHERE  GbmPk=@GbaGbmFk AND GbmDelId=0
		  
 UPDATE  GenBuilderAddress
 SET     GbaDoorNo=@GbaDoorNo,GbaBuilding=@GbaBuilding,GbaPlotNo=@GbaPlotNo,GbaStreet=@GbaStreet,GbaLandmark=@GbaLandmark,GbaArea=@GbaArea,
		 GbaDistrict=@GbaDistrict,GbaState=@GbaState,GbaCountry=@GbaCountry,GbaPin=@GbaPin
 FROM     #TEMPDtls
 WHERE    GbaGbmFk=@GbaGbmFk AND GbaDelId=0  

END
END
