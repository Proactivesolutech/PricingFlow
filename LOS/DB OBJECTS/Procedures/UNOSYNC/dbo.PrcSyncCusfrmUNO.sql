IF EXISTS(SELECT NULL FROM sysobjects WHERE name='PrcSyncCusfrmUNO' AND [type]='P')
	DROP PROC PrcSyncCusfrmUNO
GO
CREATE PROCEDURE PrcSyncCusfrmUNO
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CurDt DATETIME, @RowId VARCHAR(40), @UsrNm VARCHAR(100),@TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), 
			@Error INT, @RowCount INT
	
	DECLARE @entity_pkid INT,@entity_descr  VARCHAR(50)
	DECLARE @title_mr_pk_id INT,@title_mr_descr  VARCHAR(50)
	DECLARE @title_mrs_pk_id INT,@title_mrs_descr  VARCHAR(50)
	DECLARE @title_ms_pk_id INT,@title_ms_descr  VARCHAR(50)

	CREATE TABLE #LosCus_NewDtls(ModCusFk BIGINT, ModCusCd VARCHAR(50))
	CREATE TABLE #CusRefNo(CustFk VARCHAR(100), Drv VARCHAR(100), Vot VARCHAR(100))
	CREATE TABLE #igen_PINCODE(PINCODE INT, pk_id BIGINT)

	SELECT	@UsrNm = 'UNOSYNC', @CurDt = GETDATE(), @RowId = NEWID();
		
	BEGIN TRY
	
	IF @@TRANCOUNT = 0
		SET @Trancount = 1
					
		IF @Trancount = 1
			BEGIN TRAN

				SELECT * INTO #IGen_CustInfo_h FROM [SHFL_LOS_ACC]..IGen_CustInfo_h (NOLOCK)
				
				INSERT INTO #CusRefNo
				SELECT Cust_Fk,D,V FROM
				(
					SELECT  CASE WHEN B.DocName LIKE '%Voter%' THEN 'V' ELSE 'D' END 'DocNm',ISNULL(DocRefNo,'') 'RefNo', Cust_Fk 'Cust_Fk'
					FROM	#IGen_CustInfo_h C
					JOIN	[SHFL_LOS_ACC]..Lgen_KYCApprvlDoc(NOLOCK) A ON A.Cust_Fk = C.PK_id
					JOIN	[SHFL_LOS_ACC]..LGen_Documents(NOLOCK) B ON B.Pk_Id = A.Doc_Fk 
					AND		(B.DocName LIKE '%Voter%' OR B.DocName LIKE '%Driving%') AND B.StatFlag = 'L'
				)SRC PIVOT(MAX(RefNo) FOR DocNm IN ([D],[V])) PIV ORDER BY Cust_Fk;
				
				
				 IF OBJECT_ID('tempdb..#IGen_CustInfo_h') IS NOT NULL
					BEGIN
						UPDATE		LosCustomer
						SET			CusAadhar = RTRIM(LTRIM(UPPER(ISNULL(AadhaarNo,'')))), 
									CusPAN = RTRIM(LTRIM(UPPER(ISNULL(PANRefNo,'')))), 
									CusVoterId = ISNULL(Vot,''), CusDrvLic = ISNULL(Drv,''),
									CusModifiedDt = @CurDt
						FROM		#IGen_CustInfo_h A
						LEFT JOIN	#CusRefNo ON CustFk = Pk_id
						WHERE		Code = CusCd
						
						SELECT 'Update UNO-LosCustomer Header' 'Completed', @@ROWCOUNT 'Rows_Affected'
						
						UPDATE	Addr
						SET		CadBuilding = RTRIM(LTRIM(UPPER(ISNULL(CorrAdd1,'')))),CadStreet = RTRIM(LTRIM(UPPER(ISNULL(CorrAdd2,'')))),
								CadArea = RTRIM(LTRIM(UPPER(ISNULL(CorrArea,'')))),CadDistrict = RTRIM(LTRIM(UPPER(ISNULL(CorrCity,'')))),
								CadState = RTRIM(LTRIM(UPPER(ISNULL(CorrState,'')))),CadCountry = RTRIM(LTRIM(UPPER(ISNULL(CorrCountry,'')))),
								CadPin = RTRIM(LTRIM(ISNULL(CAST(CorrPinCode AS VARCHAR),''))),CadModifiedDt = @CurDt,
								CadEmail = RTRIM(LTRIM(UPPER(ISNULL(CorrEMail,'')))),CadContact = RTRIM(LTRIM(UPPER(ISNULL(CorrPhone,''))))
						FROM	LosCustomerAddress Addr
						JOIN	LosCustomer B(NOLOCK) ON Addr.CadCusFk = B.CusPk
						JOIN	#IGen_CustInfo_h A ON  B.CusCd = A.Code
						
						SELECT 'Update UNO-LosCustomerAddress Details' 'Completed', @@ROWCOUNT 'Rows_Affected'
						
						INSERT INTO LosCustomer
						(
							CusFstNm,CusMdNm,CusLstNm,CusGender,CusDOB,CusAadhar,CusPAN,CusDrvLic,CusVoterId,
							CusRowId,CusCreatedBy,CusCreatedDt,CusModifiedBy,CusModifiedDt,CusDelFlg,CusDelId,
							CusFthFstNm,CusFthMdNm,CusFthLstNm,CusCd
						)
						OUTPUT INSERTED.CusPk, INSERTED.CusCd INTO #LosCus_NewDtls
						SELECT		RTRIM(LTRIM(UPPER(ISNULL(FName,'')))), 	RTRIM(LTRIM(UPPER(ISNULL(MName,'')))),
									RTRIM(LTRIM(UPPER(ISNULL(LName,'')))),  
									CASE RTRIM(LTRIM(UPPER(ISNULL(Gender,'')))) WHEN 'U' THEN 2 WHEN 'F' THEN 1 ELSE 0 END,
									ISNULL(DOB,''),RTRIM(LTRIM(UPPER(ISNULL(AadhaarNo,'')))),RTRIM(LTRIM(UPPER(ISNULL(PANRefNo,'')))), 
									ISNULL(Drv,''), ISNULL(Vot,''), @RowId, @UsrNm, @CurDt, @UsrNm, @CurDt, NULL, 0,
									RTRIM(LTRIM(UPPER(ISNULL(FHFName,'')))), 	RTRIM(LTRIM(UPPER(ISNULL(FHMName,'')))),
									RTRIM(LTRIM(UPPER(ISNULL(FHLName,'')))), RTRIM(LTRIM(UPPER(ISNULL(code,''))))
						FROM		#IGen_CustInfo_h A
						LEFT JOIN	#CusRefNo ON CustFk = Pk_id
						WHERE		NOT EXISTS(SELECT 'X' FROM LosCustomer(NOLOCK) WHERE Code = CusCd)
						
						SELECT 'Insert UNO-LosCustomer Header' 'Completed', @@ROWCOUNT 'Rows_Affected'
						
						INSERT INTO LosCustomerAddress
						(
							CadCusFk,CadDoorNo,CadBuilding,CadPlotNo,CadStreet,CadLandmark,CadArea,CadDistrict,CadState,CadCountry,CadPin,
							CadRowId,CadCreatedBy,CadCreatedDt,CadModifiedBy,CadModifiedDt,CadDelFlg,CadDelId,CadEmail,CadContact
						)
						SELECT	ModCusFk,'',RTRIM(LTRIM(UPPER(ISNULL(CorrAdd1,'')))),'',RTRIM(LTRIM(UPPER(ISNULL(CorrAdd2,'')))),'', 
								RTRIM(LTRIM(UPPER(ISNULL(CorrArea,'')))), RTRIM(LTRIM(UPPER(ISNULL(CorrCity,'')))), 
								RTRIM(LTRIM(UPPER(ISNULL(CorrState,'')))), 	RTRIM(LTRIM(UPPER(ISNULL(CorrCountry,'')))), 
								RTRIM(LTRIM(ISNULL(CAST(CorrPinCode AS VARCHAR),''))), @RowId, @UsrNm, @CurDt, @UsrNm, @CurDt, NULL, 0,
								RTRIM(LTRIM(UPPER(ISNULL(CorrEMail,'')))),RTRIM(LTRIM(UPPER(ISNULL(CorrPhone,''))))
						FROM	#IGen_CustInfo_h
						JOIN	#LosCus_NewDtls	ON	ModCusCd = code
		
						SELECT 'Insert UNO-LosCustomerAddress Details' 'Completed', @@ROWCOUNT 'Rows_Affected'
		
						SELECT  @entity_pkid = pk_id , @entity_descr = LTRIM(RTRIM(descr))  
						FROM	[SHFL_LOS_ACC]..IGen_CustEntity WHERE LTRIM(RTRIM(descr)) ='Individual'
						
						SELECT  @title_mr_pk_id =PK_Id, @title_mr_descr = LTRIM(RTRIM(TopicName)) 
						FROM	[SHFL_LOS_ACC]..igen_genapplto 
						WHERE	LTRIM(RTRIM(TopicType))='TIT' AND LTRIM(RTRIM(EntityDescr)) ='Individual'AND LTRIM(RTRIM(topicname)) ='MR'
						
						SELECT  @title_mrs_pk_id =PK_Id, @title_mrs_descr = LTRIM(RTRIM(TopicName)) 
						FROM	[SHFL_LOS_ACC]..igen_genapplto WHERE LTRIM(RTRIM(TopicType))='TIT'
						AND		LTRIM(RTRIM(EntityDescr)) ='Individual'AND LTRIM(RTRIM(topicname)) = 'MRS'
						
						SELECT  @title_ms_pk_id =PK_Id, @title_ms_descr = LTRIM(RTRIM(TopicName)) 
						FROM	[SHFL_LOS_ACC]..igen_genapplto WHERE LTRIM(RTRIM(TopicType))='TIT'
						AND		LTRIM(RTRIM(EntityDescr)) ='Individual'AND LTRIM(RTRIM(topicname)) ='MS'

						INSERT INTO #igen_PINCODE
						SELECT	PINCODE 'PINCODE', MAX(Pk_Id) 'pk_id' FROM [SHFL_LOS_ACC]..igen_PINCODE pin(NOLOCK) 
						WHERE	StatFlag = 'L' GROUP BY PINCODE
						

						INSERT INTO [SHFL_LOS_ACC]..IGen_CustInfo_h
						(
							Code,CustEntity_FK,CustEntityDescr,Titl_FK,TitleShrtDescr,Initial,FName,MName,LName,FHFName,FHMName,FHLName,
							CorrAdd1,CorrAdd2,CorrArea,CorrCity,CorrState,CorrCountry,CorrPinCode,CorrPincode_FK,
							CorrMobile,CorrEMail,PerAdd1,PerAdd2,PerArea,PerCity,PerState,PerCountry,PerPinCode,
							PerPincode_FK,PerMobile,PerEmail,PANRefNo,ParntUnitShrtDescr,CurrUnitShrtDescr,Gender,DOB,
							StatFlag,SameAddrFlag,Locked,CrtdDt,CrtdBy,LstModDt,LstModBy,FullName,MFName,MMName,MLName,Marital,
							CorrLandMark,PerLandMark,PreferredName,CustManDtls_Entered,CommunicationAddrs,AadhaarNo
						)
						SELECT		CusCd, @entity_pkid, @entity_descr, 
									CASE ISNULL(CusGender,0) WHEN 2 THEN @title_ms_pk_id WHEN 1 THEN @title_mrs_pk_id ELSE @title_mr_pk_id END,
									CASE ISNULL(CusGender,0) WHEN 2 THEN @title_ms_descr WHEN 1 THEN @title_mrs_descr ELSE @title_mr_descr END,'',
									RTRIM(LTRIM(UPPER(ISNULL(CusFstNm,'')))),RTRIM(LTRIM(UPPER(ISNULL(CusMdNm,'')))),
									RTRIM(LTRIM(UPPER(ISNULL(CusLstNm,'')))),RTRIM(LTRIM(UPPER(ISNULL(CusFthFstNm,'')))),
									RTRIM(LTRIM(UPPER(ISNULL(CusFthMdNm,'')))),RTRIM(LTRIM(UPPER(ISNULL(CusFthLstNm,'')))),
									RTRIM(LTRIM(UPPER(ISNULL(CadBuilding,'')))),RTRIM(LTRIM(UPPER(ISNULL(CadStreet,'')))),
									RTRIM(LTRIM(UPPER(ISNULL(CadArea,'')))), RTRIM(LTRIM(UPPER(ISNULL(CadDistrict,'')))),
									RTRIM(LTRIM(UPPER(ISNULL(CadState,'')))), RTRIM(LTRIM(UPPER(ISNULL(CadCountry,'')))),
									CAST(RTRIM(LTRIM(ISNULL(CadPin,0)))AS NUMERIC),pin.pk_id,RTRIM(LTRIM(ISNULL(CadContact,''))), RTRIM(LTRIM(ISNULL(CadEmail,''))),
									RTRIM(LTRIM(UPPER(ISNULL(LaaBuilding,'')))),RTRIM(LTRIM(UPPER(ISNULL(LaaStreet,'')))),
									RTRIM(LTRIM(UPPER(ISNULL(LaaArea,'')))), RTRIM(LTRIM(UPPER(ISNULL(LaaDistrict,'')))),
									RTRIM(LTRIM(UPPER(ISNULL(LaaState,'')))), RTRIM(LTRIM(UPPER(ISNULL(LaaCountry,'')))),
									CAST(RTRIM(LTRIM(ISNULL(LaaPin,0))) AS NUMERIC),A.pk_id, RTRIM(LTRIM(ISNULL(LapMobile,''))),
									RTRIM(LTRIM(ISNULL(LapEmail,''))), RTRIM(LTRIM(UPPER(ISNULL(CusPAN,'')))),
									RTRIM(LTRIM(UPPER(ISNULL(B.GeoCd,'')))),RTRIM(LTRIM(UPPER(ISNULL(B.GeoCd,'')))),
									CASE ISNULL(CusGender,0) WHEN 2 THEN 'U' WHEN 1 THEN 'F' ELSE 'M' END,
									CusDOB, 'L', 'N', '', CusCreatedDt, SUBSTRING(CusCreatedBy,1,10), CusModifiedDt, SUBSTRING(CusModifiedBy,1,10), 
									RTRIM(LTRIM(UPPER(ISNULL(CusFstNm,'')))) + ' ' + RTRIM(LTRIM(UPPER(ISNULL(CusMdNm,'')))) + ' ' + RTRIM(LTRIM(UPPER(ISNULL(CusLstNm,'')))),
									RTRIM(LTRIM(UPPER(ISNULL(LapMotherFNm,'')))),RTRIM(LTRIM(UPPER(ISNULL(LapMotherMNm,'')))),RTRIM(LTRIM(UPPER(ISNULL(LapMotherLNm,'')))),
									MarSts,'',SUBSTRING(RTRIM(LTRIM(UPPER(ISNULL(LaaLandmark,'')))),1,50),RTRIM(LTRIM(UPPER(ISNULL(LapPrefNm,'')))),
									'Y', 'C', RTRIM(LTRIM(ISNULL(CusAadhar,'')))
						FROM		LosCustomer Cus(NOLOCK)
						JOIN		LosCustomerAddress Adr(NOLOCK) ON Cus.CusPk = Adr.CadCusFk AND Adr.CadDelid = 0
						JOIN		#igen_PINCODE pin(NOLOCK) ON pin.PINCODE = RTRIM(LTRIM(ISNULL(CAST(CadPin AS INT),'')))
						LEFT JOIN	
						(
							SELECT	Lap.LapCusFk 'LapCusFk', LapAd.LaaBuilding 'LaaBuilding', LapAd.LaaStreet 'LaaStreet', LapAd.LaaPin 'LaaPin', 
									LapAd.LaaArea 'LaaArea', LapAd.LaaState 'LaaState', LapAd.LaaCountry 'LaaCountry', 
									LapAd.LaaLandmark 'LaaLandmark',perpin.pk_id 'pk_id',Lap.LapMobile 'LapMobile',
									Lap.LapEMail 'LapEMail', Lap.LapMotherFNm 'LapMotherFNm', Lap.LapMotherMNm 'LapMotherMNm', 
									Lap.LapMotherLNm 'LapMotherLNm',Lap.LapPrefNm 'LapPrefNm',LapAd.LaaDistrict 'LaaDistrict',
									CASE Lap.LapMaritalSts WHEN 1 THEN 'S' WHEN 2 THEN 'D' WHEN 3 THEN 'W' ELSE 'M' END 'MarSts'
							FROM	LosAppProfile Lap(NOLOCK) 
							JOIN	LosAppAddress LapAd(NOLOCK) ON Lap.LapPk = LapAd.LaaLapFk AND LapAd.LaaAddTyp = 1 AND LapAd.LaaDelid = 0
							JOIN	#igen_PINCODE perpin(NOLOCK) ON perpin.PINCODE = CAST(RTRIM(LTRIM(ISNULL(LapAd.LaaPin ,'')))AS INT)
							WHERE	Lap.LapDelid = 0
						)A ON Cus.CusPk = A.LapCusFk
						JOIN
						(
							SELECT 	Geo.GeoCd 'GeoCd', Qde.QdeCusFk 'QdeCusFk'
							FROM	LosQde Qde(NOLOCK)
							JOIN	GenGeoMas Geo(NOLOCK) ON Qde.QdeBGeoFk = Geo.GeoPk AND Geo.GeoDelid = 0
							WHERE	Qde.QdeDelid = 0
						)B ON Cus.CusPk = B.QdeCusFk
						WHERE		Cus.CusDelid = 0
						AND NOT EXISTS(SELECT 'X' FROM [SHFL_LOS_ACC]..IGen_CustInfo_h WHERE Code = CusCd)
						ORDER BY CusCd
						
						SELECT 'Insert LOS-UNO Customer' 'Completed', @@ROWCOUNT 'Rows_Affected'
					END
				
			IF @Trancount = 1 AND @@TRANCOUNT = 1
			COMMIT TRAN
			
	END TRY
	BEGIN CATCH

		IF @Trancount = 1 AND @@TRANCOUNT = 1
			ROLLBACK TRAN	
		
		SELECT	@ErrMsg = ERROR_MESSAGE() + ',' + ERROR_PROCEDURE() + ':' + RTRIM(ERROR_LINE()),
				@ErrSeverity = ERROR_SEVERITY()
		
		RAISERROR('%s', @ErrSeverity, 1,@ErrMsg) 		
		RETURN
			
	END CATCH
	
END
