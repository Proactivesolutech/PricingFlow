IF OBJECT_ID('PrcShflCusDedupe','P') IS NOT NULL
	DROP PROCEDURE PrcShflCusDedupe
GO
CREATE PROCEDURE PrcShflCusDedupe
(
	@Action			VARCHAR(100)		=	NULL,
	@GlobalJson		VARCHAR(MAX)		=	NULL,
	@HdrJson		VARCHAR(MAX)		=	NULL,
	@AppJson		VARCHAR(MAX)		=	NULL,
	@LogDtls		VARCHAR(MAX)		=	NULL,
	@json_dedupeMatch VARCHAR(MAX)		=	NULL,
	@CusQdePk	BIGINT					=	NULL,
	@matfk		BIGINT					=	NULL
)
AS
BEGIN
	--RAISERROR('%s',16,1,'Error : DDE Header Delete')
	--RETURN
	SET NOCOUNT ON
	SET ANSI_WARNINGS ON
	
	DECLARE @CurDt DATETIME, @TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT,
			@RowId VARCHAR(40), @Query VARCHAR(MAX), @QryString VARCHAR(MAX),@oldlapfk VARCHAR(MAX),@newlapfk VARCHAR(MAX);
	DECLARE	@DocPk BIGINT, @LeadPk BIGINT, @GeoFk BIGINT, @UsrPk BIGINT, @UsrDispNm VARCHAR(100), @UsrNm VARCHAR(100),@GrpFk BIGINT,
			@MinFk BIGINT, @MaxFk BIGINT, @AgtFk BIGINT, @AppNo VARCHAR(100),@APPPk BIGINT, @LapFk BIGINT,@CusFkId BIGINT, @MaxAppNo BIGINT,
			@NumGenUNODB VARCHAR(100), @CusCd VARCHAR(20), @FstLetter CHAR(1);

	CREATE TABLE #LosCustemp
	(
		xx_id BIGINT,qdeFstNm VARCHAR(100),qdeMdNm VARCHAR(100),qdeLstNm VARCHAR(100),qdeGender VARCHAR(100),
		qdeDOB DATETIME,qdeAadhar VARCHAR(100),qdePAN VARCHAR(100),qdeDrvLic VARCHAR(100),qdeVoterId VARCHAR(100),
		qdeFthFstNm VARCHAR(100),qdeFthMdNm VARCHAR(100),qdeFthLstNm VARCHAR(100),prdFk BIGINT,actor TINYINT
	)

	CREATE TABLE #LosCusAddTemp
	(
		xx_id BIGINT,qdaDoorNo VARCHAR(100),qdaBuilding VARCHAR(100),qdaPlotNo VARCHAR(100),qdaStreet VARCHAR(100),
		qdaLandmark VARCHAR(100),qdaArea VARCHAR(100),qdaDistrict VARCHAR(100),qdaState VARCHAR(100),
		qdaCountry VARCHAR(100),qdaPin VARCHAR(100),qdaContact VARCHAR(100),qdaEmail VARCHAR(100)
	)

	CREATE TABLE #RuleCheck
	(
		xx_id BIGINT, SNo BIGINT, RuleNm VARCHAR(500), CusFk BIGINT,QdeFk BIGINT,Operator VARCHAR(100)
	)		

	CREATE TABLE #GlobalDtls
	(
		id BIGINT, LeadPk BIGINT, GeoFk BIGINT, UsrPk BIGINT, UsrDispNm VARCHAR(100), PCd VARCHAR(100),AgtFk BIGINT,AppNo VARCHAR(100)
	)

	CREATE TABLE #RtnResult
	(
		SNo BIGINT IDENTITY(1,1), RuleNm VARCHAR(500), QdeFk BIGINT, CusFk BIGINT, Operator VARCHAR(100)
	)
	CREATE TABLE #CusCdQuery
	(
		CusCode VARCHAR(100)
	)
	IF @Action = 'LoadLdDtls'
		BEGIN
			CREATE TABLE #QdeDtls
			(
				Actor TINYINT, qdeFk BIGINT, qdaFk BIGINT, PrdFk BIGINT, qdeFstNm VARCHAR(100), qdeMidNm VARCHAR(100), qdeLstNm VARCHAR(100), 
				qdeDob DATETIME, qdeGender TINYINT, qdemob VARCHAR(15), qdePin VARCHAR(6), qdepan VARCHAR(10),
				qdedrvlic VARCHAR(100), qdeVotId VARCHAR(100), qdeAdhar VARCHAR(20)
			)
		END
		
	SELECT @CurDt = GETDATE(), @RowId = NEWID()
	
	SET @Query =  'EXEC PrcShflCusDedupe ''' + ISNULL(@Action,'') + ''''
	
	IF @GlobalJson != '[]' AND @GlobalJson != ''
		BEGIN
			SET @Query =  @Query + ',''' + @GlobalJson + ''''
			
			INSERT INTO #GlobalDtls
			EXEC PrcParseJSON @GlobalJson,'LeadPk,GeoFk,UsrPk,UsrDispNm,PrdCd,AgtFk,AppNo'
			

			SELECT	@LeadPk = LeadPk, @GeoFk = GeoFk, @UsrPk = UsrPk, @UsrDispNm = UsrDispNm,
					@GrpFk = GrpPk, @AgtFk = AgtFk, @AppNo = AppNo
			FROM	#GlobalDtls
			LEFT OUTER JOIN	GenlvlDefn(NOLOCK) ON GrpCd = PCd AND GrpDelid = 0
		END

	IF @json_dedupeMatch != '[]' AND @json_dedupeMatch != ''
		BEGIN			
				INSERT INTO #RuleCheck
				EXEC PrcParseJSON @json_dedupeMatch,'SNo,RuleNm,CusFk,QdeFk,Operator'
	
		END

	BEGIN TRY
	 
	IF @@TRANCOUNT = 0
		SET @TranCount = 1
	
	IF @TranCount = 1
		BEGIN TRAN
			
			IF @Action = 'SELECT_LEAD_DATA'
			BEGIN
				SELECT	ISNULL(QdeActor,0) 'Actor', QdePk 'qdeFk' , QdaPk 'qdaFk', QdePrdFk 'PrdFk',
						ISNULL(QDEFstNm,'') 'qdeFstNm', ISNULL(QDEMdNm,'') 'qdeMidNm', ISNULL(QDELstNm,'') 'qdeLstNm', 
						CONVERT(VARCHAR(100),QDEDOB,103) 'qdeDob',
						CASE WHEN QDEGender = 0 THEN 'Male' WHEN QDEGender = 1 THEN 'Female' END 'qdeGender',
						QDAContact 'qdemob', QDAPin 'qdePin', QDEPAN 'qdepan',
						QDEDrvLic 'qdedrvlic',QDEVoterId 'qdeVotId', QDEAadhar 'qdeAdhar',QdeCusFk 'cusfk',
						QDEFthFstNm+' '+ISNULL(QDEFthMdNm,'')+' '+ISNULL(QDEFthLstNm,' ') 'FatherName',QDEActorNm 'qdeactornm',LedId 'Leadid'
				FROM	LosQDE(NOLOCK)
				JOIN	LosLead(NOLOCK) ON LedPk = QDELedFk AND LedDelId = 0
				JOIN	LosQdeAddress(NOLOCK) ON QDAQDEFk = QDEPk AND QDADelid = 0
				WHERE	QDELedFk = @LeadPk  AND QdeDelid = 0

				SELECT	@QryString = ISNULL(@QryString,'') + 'EXEC PrcShflRuleCheck ' + CAST(QDEPk  AS VARCHAR)+ ',' + CAST(ISNULL(QdeCusFk,0)  AS VARCHAR)+ ';'
				FROM	LosQDE(NOLOCK) WHERE QDELedFk = @LeadPk  AND QdeDelid = 0
				
				EXEC(@QryString);

				SELECT SNo,RuleNm,QdeFk,CusFk,Operator FROM #RtnResult
			END

		IF @Action = 'INSERT_MATCH'
			BEGIN
			
			SELECT DISTINCT CusFk 'CusFk',RuleNm 'RuleName',Operator 'Operator',SNo 'SNo',CusFstNm 'FirstName',CusMdNm 'MiddleName',CusLstNm 'LastName',
					CONVERT(VARCHAR(100),CusDOB,103) 'DOB',CadContact 'MobileNo',
					CusFthFstNm +' '+ISNULL(CusFthMdNm,'')+' '+ISNULL(CusFthLstNm,'') 'FatherName',CadEmail 'EmailId',CusAadhar 'AadharNo',
					CusPAN 'PAN',CusDrvLic 'DrvLic',CusVoterId 'VoterId',CadPin 'Pincode',
					CASE WHEN CusGender = 0 THEN 'Male' WHEN CusGender = 1  THEN 'Female' END 'Gender' 
			FROM	#RuleCheck  
					JOIN LosCustomer(NOLOCK) ON CusPk=CusFk AND CusDelId = 0
					JOIN LosCustomerAddress(NOLOCK) ON CadCusFk=CusPk AND CadDelId = 0
			WHERE	CusPk=CusFk ORDER BY Operator ASC

			
			END

		IF @Action  IN ('CREATE_CUSDATA','UPDATE_CUSFK')
			BEGIN				
						
						INSERT INTO #LosCustemp( qdeFstNm,qdeMdNm ,qdeLstNm ,qdeGender,qdeDOB,qdeAadhar,
												qdePAN,qdeDrvLic,qdeVoterId,qdeFthFstNm,qdeFthMdNm,qdeFthLstNm,prdFk,actor)
						SELECT		ISNULL(QDEFstNm,''),ISNULL(QDEMdNm,''),ISNULL(QDELstNm,''),ISNULL(QDEGender,0),ISNULL(QDEDOB,''),
									ISNULL(QDEAadhar,''),ISNULL(QDEPAN,''),ISNULL(QDEDrvLic,''),
									ISNULL(QDEVoterId,''),ISNULL(QDEFthFstNm,''),ISNULL(QDEFthMdNm,''),ISNULL(QDEFthLstNm,''),LedPrdFk,
									ISNULL(QDEActor,0)
						FROM		LosQDE(NOLOCK) 
						JOIN		LosLead (NOLOCK) ON LedPk = QDELedFk AND LedDelId = 0
						JOIN		LosQdeAddress (NOLOCK) ON QDAQDEFK = QDEPk AND QDADelid = 0 
						WHERE		QDEPk = @CusQdePk AND QDEDelId = 0 

						INSERT INTO #LosCusAddTemp(qdaDoorNo,qdaBuilding,qdaPlotNo,qdaStreet,qdaLandmark,qdaArea,qdaDistrict,qdaState,
													qdaCountry,qdaPin,qdaContact,qdaEmail)
						SELECT		ISNULL(QDADoorNo,''),ISNULL(QDABuilding,''),ISNULL(QDAPlotNo,''),ISNULL(QDAStreet,''),
									ISNULL(QDALandmark,''),ISNULL(QDAArea,''),ISNULL(QDADistrict,''),ISNULL(QDAState,''),
									ISNULL(QDACountry,''),ISNULL(QDAPin,''), ISNULL(QDAContact,''),ISNULL(QDAEmail,'')
						FROM		LosQDEAddress(NOLOCK) 
						WHERE		QDAQDEFK =  @CusQdePk AND QDADelId = 0

						IF @Action  IN ('CREATE_CUSDATA')
							BEGIN
															
								SELECT	@NumGenUNODB = CmpUNODB + '.dbo.GetGenNumForLOS'
								FROM	GenCmpMas(NOLOCK)

								SELECT @FstLetter =  SUBSTRING (qdeFstNm, 1, 1)  from #LosCustemp

								INSERT INTO #CusCdQuery(CusCode)
								EXEC @NumGenUNODB 'Customer',NULL,'ADMIN',null,@FstLetter,'P'

								SELECT @CusCd = CusCode FROM #CusCdQuery

								INSERT INTO LosCustomer(CusFstNm,CusMdNm,CusLstNm,CusGender,CusDOB,CusAadhar,CusPAN,CusDrvLic,CusVoterId,
											CusRowId,CusCreatedBy,CusCreatedDt,CusModifiedBy,CusModifiedDt,CusDelFlg,CusDelId,
											CusFthFstNm,CusFthMdNm,CusFthLstNm, CusCd)
								SELECT		qdeFstNm,qdeMdNm ,qdeLstNm ,qdeGender,qdeDOB,qdeAadhar,
											qdePAN,qdeDrvLic,qdeVoterId,@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,0,0,qdeFthFstNm,
											qdeFthMdNm,qdeFthLstNm,@CusCd
								FROM		#LosCustemp

								SET			@CusFkId = SCOPE_IDENTITY() ;
				
								INSERT INTO LosCustomerAddress(CadCusFk,CadDoorNo,CadBuilding,CadPlotNo,CadStreet,CadLandmark,CadArea,CadDistrict,
											CadState,CadCountry,CadPin,CadContact,CadEmail,CadRowId,CadCreatedBy,CadCreatedDt,CadModifiedBy,CadModifiedDt,CadDelFlg,CadDelId)
								SELECT		@CusFkId,qdaDoorNo,qdaBuilding,qdaPlotNo,qdaStreet,qdaLandmark,qdaArea,qdaDistrict,qdaState,
											qdaCountry,qdaPin,qdaContact,qdaEmail,@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,0,0 
								FROM		#LosCusAddTemp 
							END
						ELSE
							SET @CusFkId = @matfk
			
						UPDATE	LosQDE SET QdeCusFk = @CusFkId, QDEModifiedDt = @CurDt, QDEModifiedBy = @UsrDispNm, QdeRowId = @RowId 
						WHERE	QDEPk = @CusQdePk AND QdeDelid = 0
					
						IF NOT EXISTS(SELECT 'X' FROM LosApp(NOLOCK) WHERE AppLedFk = @LeadPk AND AppDelid = 0)
							BEGIN
								SELECT @MaxAppNo = (CONVERT(BIGINT,RIGHT(MAX(AppAppNo),6)) + 1) FROM LosApp(NOLOCK)

								IF ISNULL(@MaxAppNo,0) = 0 SET @MaxAppNo =  1;
									SELECT @AppNo = 'SHFLAPLN' + dbo.gefgGetPadZero(6,(ISNULL(@MaxAppNo,0)))

								INSERT INTO LosApp(AppLedFk,AppAgtFk,AppBGeoFk,AppApplNm,AppAppNo,AppLnPur,AppBuiLoc,AppPAppNo,
											AppRowId,AppCreatedBy,AppCreatedDt,AppModifiedBy,AppModifiedDt,AppDelFlg,AppDelId,AppPGrpFk)
								SELECT		@LeadPk,@AgtFk,@GeoFk, qdeFstNm, @AppNo, '',0, '',@RowId, @UsrDispNm, @CurDt, 
											@UsrDispNm, @CurDt, NULL, 0,@GrpFk
								FROM		#LosCustemp
						
								SELECT	@APPPk = SCOPE_IDENTITY()
							END
								SELECT @APPPk = AppPk FROM LosApp(NOLOCK) WHERE AppLedFk = @LeadPk AND AppDelid = 0

							
							SELECT	LapPk 'LapFk', LapActor 'Actor', ROW_NUMBER() OVER(PARTITION BY LapActor ORDER BY LapActor) 'SubActor'
							INTO	#LapDtls
							FROM	LosAppProfile(NOLOCK)
							WHERE	LapLedFk = @LeadPk AND LapDelid = 0

							IF NOT EXISTS(SELECT 'X' FROM #LapDtls, LosQDE(NOLOCK) WHERE QdePk = @CusQdePk AND QDEActor = Actor AND QDESubActor = SubActor)
								BEGIN
							
									INSERT INTO LosAppProfile(LapLedFK,LapAppFk,LapCusFk,LapCibil,LapActor,LapPrefNm,LapFstNm,LapMdNm,LapLstNm,LapGender,LapDOB,
											LapRelation,LapMaritalSts,LapNationality,LapReligion,LapCommunity,LapDpdCnt,LapMobile,LapResi,LapEMail,LapRowId,
											LapCreatedBy,LapCreatedDt,LapModifiedBy,LapModifiedDt,LapDelFlg,LapDelId,LapFatherFNm,LapFatherMNm,
											LapFatherLNm,LapMotherFNm,LapMotherMNm,LapMotherLNm,LapEducation,LapInsorUniv,LapAadhar,LapPAN,LapDrvLic,
											LapVotId,LapPassport,LapTitle, LapActorNm, LapEmpTyp,LapCusExs,LapOthDocAvl)
									SELECT		@LeadPk,@APPPk,QdeCusFk,ISNULL(QDeCibil ,0),QDEActor,'',QDEFstNm,QDEMdNm,QDELstNm,QDEGender,
												QDEDOB,'',-1,'INDIAN','',-1,0,QDAContact,'',QDAEmail,@RowId, @UsrDispNm, @CurDt, 
												@UsrDispNm, @CurDt, NULL,0,QDEFthFstNm,QDEFthMdNm,QDEFthLstNm,'','','',-1,'',QDEAadhar ,QDEPAN,QDEDrvLic,QDEVoterId,
												QDEPassNum,-1 ,QDEActorNm,-1, CASE @Action WHEN 'UPDATE_CUSFK' THEN 1 ELSE 0 END,QdeOthDocAvl
									FROM		LosQDE(NOLOCK)
									JOIN		LosQDEAddress(NOLOCK) ON QDAQDEFK = QDEPk AND QDADelId = 0
									WHERE		QdePk = @CusQdePk AND QDEDelId = 0
				
									SET @LapFk = SCOPE_IDENTITY()
			
									INSERT	INTO LosAppAddress
									(
										LaaLedFk,LaaAppFk,LaaLapFk,LaaAddTyp,LaaDoorNo,LaaBuilding,LaaPlotNo,LaaStreet,LaaLandmark,LaaArea,
										LaaDistrict,LaaState,LaaCountry,LaaPin,LaaRowId,LaaCreatedBy,LaaCreatedDt,LaaModifiedBy,LaaModifiedDt,LaaDelFlg,
										LaaDelId,LaaAcmTyp,LaaComAdd,LaaYrsResi
									)
									SELECT	@LeadPk,@APPPk,@LapFk,0,QDADoorNo,QDABuilding,QDAPlotNo,QDAStreet,QDALandmark,
											QDAArea,QDADistrict,QDAState,QDACountry,QDAPin,@RowId, @UsrDispNm, @CurDt, 
											@UsrDispNm, @CurDt, NULL,0,-1,0,0
									FROM	LosQDEAddress(NOLOCK) 
									WHERE	QDAQDEFK = @CusQdePk AND QDADelId = 0

								IF EXISTS(SELECT 'X' FROM LosAppProfile(NOLOCK) WHERE LapCusFk = @CusFkId AND LapPk <> @LapFk AND LapDelId = 0)
								BEGIN 
									SELECT @oldlapfk = LapPk from LosAppProfile WHERE LapCusFk = @CusFkId AND LapPk <> @LapFk AND LapDelId = 0

								--BANK INSERT
									IF EXISTS(SELECT 'X' FROM LosAppBank(NOLOCK) WHERE LbkLapFk=@oldlapfk  AND LbkDelId = 0)
									BEGIN
										INSERT INTO  LosAppBank
									   (
										LbkLedFk,LbkAppFk,LbkLapFk,LbkNm,LbkAccTyp,LbkAccNo,LbkBnkFk,LbkBbmFk,LbkIFSC,LbkBank,LbkBranch,
										LbkRowId,LbkCreatedBy,LbkCreatedDt,LbkModifiedBy,LbkModifiedDt,LbkDelFlg,LbkDelId
									   )
									   SELECT	@LeadPk,@APPPk,@LapFk,LbkNm,LbkAccTyp,LbkAccNo,LbkBnkFk,LbkBbmFk,0,
											   LbkBank,LbkBranch, @RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0
									   FROM	 LosAppBank WHERE LbkLapFk=@oldlapfk AND LbkDelId = 0
									END

                               	--ASSET INSERT
									IF EXISTS(SELECT 'X' FROM LosAppAst(NOLOCK) WHERE LasLapFk=@oldlapfk  AND LasDelId = 0)
									BEGIN
										INSERT INTO  LosAppAst
										(
										LasLedFk,LasAppFk,LasLapFk,LasTyp,LasDesc,LasAmt,LasRowId,LasCreatedBy,LasCreatedDt,
										LasModifiedBy,LasModifiedDt,LasDelFlg,LasDelId
										)
										SELECT	@LeadPk,@APPPk,@LapFk,LasTyp,LasDesc,LasAmt, @RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0
										FROM	 LosAppAst WHERE LasLapFk=@oldlapfk AND LasDelId = 0
									END

								--ASSET NOTES
									IF EXISTS(SELECT 'X' FROM LosAppNotes(NOLOCK) WHERE LanLapFk=@oldlapfk AND LanTyp='A' AND LanDelId = 0)
									BEGIN
										INSERT INTO  LosAppNotes
										(
										LanLedFk,LanAppFk,LanLapFk,LanTyp,LanNotes,
										LanRowId,LanCreatedBy,LanCreatedDt,LanModifiedBy,LanModifiedDt,LanDelFlg,LanDelId
										)
										SELECT	@LeadPk,@APPPk,@LapFk,LanTyp,LanNotes,@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0
										FROM	 LosAppNotes WHERE LanLapFk=@oldlapfk AND LanTyp='A' AND LanDelId = 0
									END

								--OBLIGATION INSERT
									IF EXISTS(SELECT 'X' FROM LosAppObl(NOLOCK) WHERE LaoLapFk=@oldlapfk  AND LaoDelId = 0)
									BEGIN
										INSERT INTO LosAppObl
										(
										LaoLedFk,LaoAppFk,LaoLapFk,LoaIsIncl,LaoTyp,LaoIsShri,LaoSrc,LaoRefNo,LaoEMI,LaoOutstanding,LaoTenure,LaoNotes,
										LaoRowId,LaoCreatedBy,LaoCreatedDt,LaoModifiedBy,LaoModifiedDt,LaoDelFlg,LaoDelId
										)
										SELECT	@LeadPk,@APPPk,@LapFk,LoaIsIncl,LaoTyp,LaoIsShri,LaoSrc,LaoRefNo,LaoEMI,LaoOutstanding,LaoTenure,
										        LaoNotes, @RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0
										FROM    LosAppObl WHERE LaoLapFk=@oldlapfk  AND LaoDelId = 0
									END

								--OBLIGATION NOTES
									IF EXISTS(SELECT 'X' FROM LosAppNotes(NOLOCK) WHERE LanLapFk=@oldlapfk AND LanTyp='O' AND LanDelId = 0)
									BEGIN
										INSERT INTO  LosAppNotes
										(
										LanLedFk,LanAppFk,LanLapFk,LanTyp,LanNotes,
										LanRowId,LanCreatedBy,LanCreatedDt,LanModifiedBy,LanModifiedDt,LanDelFlg,LanDelId
										)
									   SELECT	@LeadPk,@APPPk,@LapFk,LanTyp,LanNotes,@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0
									   FROM	 LosAppNotes WHERE LanLapFk=@oldlapfk AND LanTyp='O' AND LanDelId = 0
									END

								--CREDIT CARD INSERT
									IF EXISTS(SELECT 'X' FROM LosAppCreditCrd(NOLOCK) WHERE LacLapFk=@oldlapfk  AND LacDelId = 0)
									BEGIN
										INSERT INTO LosAppCreditCrd
										(
										LacLedFk,LacAppFk,LacLapFk,LacTyp,LacIsuBnk,LacBnkFk,LacLimit,LacCrdNo,LacRowId,LacCreatedBy,LacCreatedDt,LacModifiedBy,LacModifiedDt,
										LacDelFlg,LacDelId
										)
										SELECT	@LeadPk,@APPPk,@LapFk,LacTyp,LacIsuBnk,LacBnkFk,LacLimit,LacCrdNo,
										        @RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0
										FROM    LosAppCreditCrd WHERE LacLapFk=@oldlapfk  AND LacDelId = 0
									END

								--CREDI CARD NOTES
									IF EXISTS(SELECT 'X' FROM LosAppNotes(NOLOCK) WHERE LanLapFk=@oldlapfk AND LanTyp='C' AND LanDelId = 0)
									BEGIN
										INSERT INTO  LosAppNotes
										(
										LanLedFk,LanAppFk,LanLapFk,LanTyp,LanNotes,
										LanRowId,LanCreatedBy,LanCreatedDt,LanModifiedBy,LanModifiedDt,LanDelFlg,LanDelId
										)
									   SELECT	@LeadPk,@APPPk,@LapFk,LanTyp,LanNotes,@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0
									   FROM	 LosAppNotes WHERE LanLapFk=@oldlapfk AND LanTyp='C' AND LanDelId = 0
									END

                                  --SELF EMPLOYED
								  IF EXISTS(SELECT 'X' FROM LosAppBusiProfile(NOLOCK) WHERE LabLapFk=@oldlapfk AND LabDelId = 0)
									BEGIN
									INSERT INTO LosAppBusiProfile
									(
									LabLedFk,LabAppFk,LabLapFk,LabBusiTyp,LabOrgTyp,LabNm,LabNat,LabOwnShip,LabIncYr,LabBusiPrd,LabCIN,LabOffNo,LabEMail,
									LabRowId,LabCreatedBy,LabCreatedDt,LabModifiedBy,LabModifiedDt,LabDelFlg,LabDelId,LabCurBusiPrd,LabMSME
									)
									 SELECT	@LeadPk,@APPPk,@LapFk,LabBusiTyp,LabOrgTyp,LabNm,LabNat,LabOwnShip,LabIncYr,LabBusiPrd,LabCIN,LabOffNo,LabEMail,
									        @RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0,LabCurBusiPrd,LabMSME
									 FROM	LosAppBusiProfile WHERE LabLapFk=@oldlapfk AND LabDelId = 0

									UPDATE	LosAppProfile
								    SET 	LapEmpTyp = 1, LapDelFlg = dbo.gefgGetDelFlg(@CurDt),LapRowId=@RowId,LapModifiedBy=@UsrDispNm,LapModifiedDt=@CurDt
								    WHERE	LapPk = @LapFk AND LapCusFk=@CusFkId AND LapDelId = 0

			
								  
                                  END

								   --SALARIED
								  IF EXISTS(SELECT 'X' FROM LosAppOffProfile(NOLOCK) WHERE LaeLapFk=@oldlapfk AND LaeDelId = 0)
									BEGIN
									INSERT INTO LosAppOffProfile
									(
									LaeLedFk,LaeAppFk,LaeLapFk,LaeNm,LaeTyp,LaeNat,LaeDesig,LaeExp,LaeTotExp,LaeOffNo,LaeEMail,LaeRowId,LaeCreatedBy,LaeCreatedDt,LaeModifiedBy,LaeModifiedDt,LaeDelFlg,LaeDelId,LaeEmpId,
									LapMonIncAmt,LapOthIncAmt
									)
									 SELECT	@LeadPk,@APPPk,@LapFk,LaeNm,LaeTyp,LaeNat,LaeDesig,LaeExp,LaeTotExp,LaeOffNo,LaeEMail,
									        @RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0,LaeEmpId,
									        LapMonIncAmt,LapOthIncAmt
									 FROM	LosAppOffProfile WHERE LaeLapFk=@oldlapfk AND LaeDelId = 0

							
								 	UPDATE	LosAppProfile
								    SET 	LapEmpTyp = 0, LapDelFlg = dbo.gefgGetDelFlg(@CurDt),LapRowId=@RowId,LapModifiedBy=@UsrDispNm,LapModifiedDt=@CurDt
								    WHERE  LapPk = @LapFk AND LapCusFk=@CusFkId AND LapDelId = 0

                                  END

                             
									--PERMANENT ADDRESS
									IF EXISTS(SELECT 'X' FROM LosAppAddress(NOLOCK) WHERE LaaLapFk=@oldlapfk AND LaaAddTyp=1 AND LaaDelId = 0)
									BEGIN
										INSERT INTO  LosAppAddress
										(
										LaaLedFK,LaaAppFk,LaaLapFk,LaaAddTyp,LaaComAdd,LaaAcmTyp,LaaYrsResi,LaaDoorNo,LaaBuilding,LaaPlotNo,LaaStreet,LaaLandmark,
										LaaArea,LaaDistrict,LaaState,LaaCountry,LaaPin,LaaRowId,LaaCreatedBy,LaaCreatedDt,LaaModifiedBy,LaaModifiedDt,
										LaaDelFlg,LaaDelId,LaaRentAmt 
										)
									   SELECT	@LeadPk,@APPPk,@LapFk,LaaAddTyp,LaaComAdd,LaaAcmTyp,LaaYrsResi,LaaDoorNo,LaaBuilding,LaaPlotNo,LaaStreet,LaaLandmark,
										        LaaArea,LaaDistrict,LaaState,LaaCountry,LaaPin,@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0,LaaRentAmt
									   FROM	    LosAppAddress WHERE LaaLapFk=@oldlapfk AND LaaAddTyp=1 AND LaaDelId = 0
									END

									--BUSINESS ADDRESS
									IF EXISTS(SELECT 'X' FROM LosAppAddress(NOLOCK) WHERE LaaLapFk=@oldlapfk AND LaaAddTyp=2 AND LaaDelId = 0)
									BEGIN
									
										INSERT INTO  LosAppAddress
										(
										LaaLedFK,LaaAppFk,LaaLapFk,LaaAddTyp,LaaComAdd,LaaAcmTyp,LaaYrsResi,LaaDoorNo,LaaBuilding,LaaPlotNo,LaaStreet,LaaLandmark,
										LaaArea,LaaDistrict,LaaState,LaaCountry,LaaPin,LaaRowId,LaaCreatedBy,LaaCreatedDt,LaaModifiedBy,LaaModifiedDt,
										LaaDelFlg,LaaDelId,LaaRentAmt 
										)
									   SELECT	@LeadPk,@APPPk,@LapFk,LaaAddTyp,LaaComAdd,LaaAcmTyp,LaaYrsResi,LaaDoorNo,LaaBuilding,LaaPlotNo,LaaStreet,LaaLandmark,
										        LaaArea,LaaDistrict,LaaState,LaaCountry,LaaPin,@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0,LaaRentAmt
									   FROM	    LosAppAddress WHERE LaaLapFk=@oldlapfk AND LaaAddTyp=2 AND LaaDelId = 0
									END

									--OFFICE ADDRESS
									IF EXISTS(SELECT 'X' FROM LosAppAddress(NOLOCK) WHERE LaaLapFk=@oldlapfk AND LaaAddTyp=3 AND LaaDelId = 0)
									BEGIN
										INSERT INTO  LosAppAddress
										(
										LaaLedFK,LaaAppFk,LaaLapFk,LaaAddTyp,LaaComAdd,LaaAcmTyp,LaaYrsResi,LaaDoorNo,LaaBuilding,LaaPlotNo,LaaStreet,LaaLandmark,
										LaaArea,LaaDistrict,LaaState,LaaCountry,LaaPin,LaaRowId,LaaCreatedBy,LaaCreatedDt,LaaModifiedBy,LaaModifiedDt,
										LaaDelFlg,LaaDelId,LaaRentAmt 
										)
									   SELECT	@LeadPk,@APPPk,@LapFk,LaaAddTyp,LaaComAdd,LaaAcmTyp,LaaYrsResi,LaaDoorNo,LaaBuilding,LaaPlotNo,LaaStreet,LaaLandmark,
										        LaaArea,LaaDistrict,LaaState,LaaCountry,LaaPin,@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0,LaaRentAmt
									   FROM	    LosAppAddress WHERE LaaLapFk=@oldlapfk AND LaaAddTyp=3 AND LaaDelId = 0
									END

									--STUDENT ADDRESS
									IF EXISTS(SELECT 'X' FROM LosAppAddress(NOLOCK) WHERE LaaLapFk=@oldlapfk AND LaaAddTyp=4 AND LaaDelId = 0)
									BEGIN
										INSERT INTO  LosAppAddress
										(
										LaaLedFK,LaaAppFk,LaaLapFk,LaaAddTyp,LaaComAdd,LaaAcmTyp,LaaYrsResi,LaaDoorNo,LaaBuilding,LaaPlotNo,LaaStreet,LaaLandmark,
										LaaArea,LaaDistrict,LaaState,LaaCountry,LaaPin,LaaRowId,LaaCreatedBy,LaaCreatedDt,LaaModifiedBy,LaaModifiedDt,
										LaaDelFlg,LaaDelId,LaaRentAmt 
										)
									   SELECT	@LeadPk,@APPPk,@LapFk,LaaAddTyp,LaaComAdd,LaaAcmTyp,LaaYrsResi,LaaDoorNo,LaaBuilding,LaaPlotNo,LaaStreet,LaaLandmark,
										        LaaArea,LaaDistrict,LaaState,LaaCountry,LaaPin,@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0,LaaRentAmt
									   FROM	    LosAppAddress WHERE LaaLapFk=@oldlapfk AND LaaAddTyp=4 AND LaaDelId = 0
									END

									--Kyc Document
									IF EXISTS(SELECT 'X' FROM LosAppKYCDocuments(NOLOCK) WHERE KYCLapFk=@oldlapfk AND KYCDelId = 0)
									BEGIN

								    INSERT INTO LosAppKYCDocuments
						              (
									   KYCLedFk,KYCAppFk,KYCLapFk,KYCDocTyp,KYCGdmFk,KYCDocVal,KYCValidUpto,
						               KYCRowId,KYCCreatedBy,KYCCreatedDt,KYCModifiedBy,KYCModifiedDt,KYCDelFlg,KYCDelId,
									   KycRefDt,KYCRmks
									  )
								
								    SELECT	@LeadPk,@APPPk,@LapFk,KYCDocTyp,KYCGdmFk,KYCDocVal,KYCValidUpto,@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0,
								            KycRefDt,KYCRmks
								    FROM	LosAppKYCDocuments WHERE KYCLapFk=@oldlapfk AND KYCDelId = 0

								    END
									

								END
								END
							ELSE
								BEGIN 						
									SELECT @LapFk = LapFk FROM #LapDtls, LosQDE(NOLOCK) WHERE QdePk = @CusQdePk AND QDEActor = Actor AND QDESubActor = SubActor

									UPDATE LosAppProfile SET LapCusFk = @CusFkId, LapCusExs = CASE @Action WHEN 'UPDATE_CUSFK' THEN 1 ELSE 0 END
									WHERE  LapPk = @LapFk

								   --BANK UPDATE
									UPDATE	LosAppBank
									SET 	LbkDelId = 1, LbkDelFlg = dbo.gefgGetDelFlg(@CurDt),LbkRowId=@RowId,LbkModifiedBy=@UsrDispNm,LbkModifiedDt=@CurDt
									WHERE	LbkAppFk = @APPPk AND LbkLapFk = @LapFk AND LbkDelId = 0 

						    		--ASSET INSERT
									UPDATE	LosAppAst
									SET 	LasDelId = 1, LasDelFlg = dbo.gefgGetDelFlg(@CurDt),LasRowId=@RowId,LasModifiedBy=@UsrDispNm,LasModifiedDt=@CurDt
									WHERE	LasAppFk = @APPPk AND LasLapFk = @LapFk AND LasDelId = 0
									
									 --ASSET NOTES
									UPDATE	LosAppNotes
									SET 	LanDelId = 1, LanDelFlg = dbo.gefgGetDelFlg(@CurDt),LanRowId=@RowId,LanModifiedBy=@UsrDispNm,LanModifiedDt=@CurDt
									WHERE	LanAppFk = @APPPk AND LanLapFk = @LapFk AND LanTyp='A' AND LanDelId = 0

									--OBLIGATION INSERT
									UPDATE	LosAppObl
									SET 	LaoDelId = 1, LaoDelFlg = dbo.gefgGetDelFlg(@CurDt),LaoRowId=@RowId,LaoModifiedBy=@UsrDispNm,LaoModifiedDt=@CurDt
									WHERE	LaoAppFk = @APPPk AND LaoLapFk = @LapFk AND LaoDelId = 0

									--OBLIGATION NOTES
									UPDATE	LosAppNotes
									SET 	LanDelId = 1, LanDelFlg = dbo.gefgGetDelFlg(@CurDt),LanRowId=@RowId,LanModifiedBy=@UsrDispNm,LanModifiedDt=@CurDt
									WHERE	LanAppFk = @APPPk AND LanLapFk = @LapFk AND LanTyp='O' AND LanDelId = 0


									--CREDIT CARD INSERT
									UPDATE	LosAppCreditCrd
									SET 	LacDelId = 1, LacDelFlg = dbo.gefgGetDelFlg(@CurDt),LacRowId=@RowId,LacModifiedBy=@UsrDispNm,LacModifiedDt=@CurDt
									WHERE	LacAppFk = @APPPk AND LacLapFk = @LapFk AND LacDelId = 0	

									--CREDI CARD NOTES
									UPDATE	LosAppNotes
									SET 	LanDelId = 1, LanDelFlg = dbo.gefgGetDelFlg(@CurDt),LanRowId=@RowId,LanModifiedBy=@UsrDispNm,LanModifiedDt=@CurDt
									WHERE	LanAppFk = @APPPk AND LanLapFk = @LapFk AND LanTyp='C' AND LanDelId = 0

									  --SELF EMPLOYED
									UPDATE	LosAppBusiProfile
									SET 	LabDelId = 1, LabDelFlg = dbo.gefgGetDelFlg(@CurDt),LabRowId=@RowId,LabModifiedBy=@UsrDispNm,LabModifiedDt=@CurDt
									WHERE	LabAppFk = @APPPk AND LabLapFk = @LapFk AND LabDelId = 0

				
									   --SALARIED
									UPDATE	LosAppOffProfile
									SET 	LaeDelId = 1, LaeDelFlg = dbo.gefgGetDelFlg(@CurDt),LaeRowId=@RowId,LaeModifiedBy=@UsrDispNm,LaeModifiedDt=@CurDt
									WHERE	LaeAppFk = @APPPk AND LaeLapFk = @LapFk AND LaeDelId = 0


									--PERMANENT ADDRESS
									UPDATE	LosAppAddress
									SET 	LaaDelId = 1, LaaDelFlg = dbo.gefgGetDelFlg(@CurDt),LaaRowId=@RowId,LaaModifiedBy=@UsrDispNm,LaaModifiedDt=@CurDt
									WHERE	LaaAppFk = @APPPk AND LaaLapFk = @LapFk AND LaaAddTyp=1 AND LaaDelId = 0

										--BUSINESS ADDRESS
									UPDATE	LosAppAddress
									SET 	LaaDelId = 1, LaaDelFlg = dbo.gefgGetDelFlg(@CurDt),LaaRowId=@RowId,LaaModifiedBy=@UsrDispNm,LaaModifiedDt=@CurDt
									WHERE	LaaAppFk = @APPPk AND LaaLapFk = @LapFk AND LaaAddTyp=2 AND LaaDelId = 0

										--OFFICE ADDRESS
									UPDATE	LosAppAddress
									SET 	LaaDelId = 1, LaaDelFlg = dbo.gefgGetDelFlg(@CurDt),LaaRowId=@RowId,LaaModifiedBy=@UsrDispNm,LaaModifiedDt=@CurDt
									WHERE	LaaAppFk = @APPPk AND LaaLapFk = @LapFk AND LaaAddTyp=3 AND LaaDelId = 0

										--STUDENT ADDRESS
									UPDATE	LosAppAddress
									SET 	LaaDelId = 1, LaaDelFlg = dbo.gefgGetDelFlg(@CurDt),LaaRowId=@RowId,LaaModifiedBy=@UsrDispNm,LaaModifiedDt=@CurDt
									WHERE	LaaAppFk = @APPPk AND LaaLapFk = @LapFk AND LaaAddTyp=4 AND LaaDelId = 0

									--Kyc Document
									  UPDATE LosAppKYCDocuments
								      SET 	 KYCDelId = 1, KYCDelFlg = dbo.gefgGetDelFlg(@CurDt),KYCRowId=@RowId,KYCModifiedBy=@UsrDispNm,KYCModifiedDt=@CurDt
								      FROM	 LosAppKYCDocuments
								      WHERE	 KYCAppFk = @APPPk AND KYCLapFk = @LapFk AND KYCDelId = 0


										IF EXISTS(SELECT 'X' FROM LosAppProfile(NOLOCK) WHERE LapCusFk = @CusFkId AND LapPk <> @LapFk AND LapDelId = 0)
									BEGIN 
									SELECT @oldlapfk = LapPk from LosAppProfile WHERE LapCusFk = @CusFkId AND LapPk <> @LapFk AND LapDelId = 0

									--BANK INSERT
										IF EXISTS(SELECT 'X' FROM LosAppBank(NOLOCK) WHERE LbkLapFk=@oldlapfk  AND LbkDelId = 0)
										BEGIN
											INSERT INTO  LosAppBank
										   (
											LbkLedFk,LbkAppFk,LbkLapFk,LbkNm,LbkAccTyp,LbkAccNo,LbkBnkFk,LbkBbmFk,LbkIFSC,LbkBank,LbkBranch,
											LbkRowId,LbkCreatedBy,LbkCreatedDt,LbkModifiedBy,LbkModifiedDt,LbkDelFlg,LbkDelId
										   )
										   
										   SELECT	@LeadPk,@APPPk,@LapFk,LbkNm,LbkAccTyp,LbkAccNo,LbkBnkFk,LbkBbmFk,0,
												   LbkBank,LbkBranch, @RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0
										   FROM	 LosAppBank WHERE LbkLapFk=@oldlapfk AND LbkDelId = 0
										 

										END

                               		--ASSET INSERT
										IF EXISTS(SELECT 'X' FROM LosAppAst(NOLOCK) WHERE LasLapFk=@oldlapfk  AND LasDelId = 0)
										BEGIN
											INSERT INTO  LosAppAst
											(
											LasLedFk,LasAppFk,LasLapFk,LasTyp,LasDesc,LasAmt,LasRowId,LasCreatedBy,LasCreatedDt,
											LasModifiedBy,LasModifiedDt,LasDelFlg,LasDelId
											)
											SELECT	@LeadPk,@APPPk,@LapFk,LasTyp,LasDesc,LasAmt, @RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0
											FROM	 LosAppAst WHERE LasLapFk=@oldlapfk AND LasDelId = 0
										END

									--ASSET NOTES
										IF EXISTS(SELECT 'X' FROM LosAppNotes(NOLOCK) WHERE LanLapFk=@oldlapfk AND LanTyp='A' AND LanDelId = 0)
										BEGIN
											INSERT INTO  LosAppNotes
											(
											LanLedFk,LanAppFk,LanLapFk,LanTyp,LanNotes,
											LanRowId,LanCreatedBy,LanCreatedDt,LanModifiedBy,LanModifiedDt,LanDelFlg,LanDelId
											)
											SELECT	@LeadPk,@APPPk,@LapFk,LanTyp,LanNotes,@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0
											FROM	 LosAppNotes WHERE LanLapFk=@oldlapfk AND LanTyp='A' AND LanDelId = 0
										END

									--OBLIGATION INSERT
										IF EXISTS(SELECT 'X' FROM LosAppObl(NOLOCK) WHERE LaoLapFk=@oldlapfk  AND LaoDelId = 0)
										BEGIN
											INSERT INTO LosAppObl
											(
											LaoLedFk,LaoAppFk,LaoLapFk,LoaIsIncl,LaoTyp,LaoIsShri,LaoSrc,LaoRefNo,LaoEMI,LaoOutstanding,LaoTenure,LaoNotes,
											LaoRowId,LaoCreatedBy,LaoCreatedDt,LaoModifiedBy,LaoModifiedDt,LaoDelFlg,LaoDelId
											)
											SELECT	@LeadPk,@APPPk,@LapFk,LoaIsIncl,LaoTyp,LaoIsShri,LaoSrc,LaoRefNo,LaoEMI,LaoOutstanding,LaoTenure,
													LaoNotes, @RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0
											FROM    LosAppObl WHERE LaoLapFk=@oldlapfk  AND LaoDelId = 0
										END

									--OBLIGATION NOTES
										IF EXISTS(SELECT 'X' FROM LosAppNotes(NOLOCK) WHERE LanLapFk=@oldlapfk AND LanTyp='O' AND LanDelId = 0)
										BEGIN
											INSERT INTO  LosAppNotes
											(
											LanLedFk,LanAppFk,LanLapFk,LanTyp,LanNotes,
											LanRowId,LanCreatedBy,LanCreatedDt,LanModifiedBy,LanModifiedDt,LanDelFlg,LanDelId
											)
										   SELECT	@LeadPk,@APPPk,@LapFk,LanTyp,LanNotes,@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0
										   FROM	 LosAppNotes WHERE LanLapFk=@oldlapfk AND LanTyp='O' AND LanDelId = 0
										END

									--CREDIT CARD INSERT
										IF EXISTS(SELECT 'X' FROM LosAppCreditCrd(NOLOCK) WHERE LacLapFk=@oldlapfk  AND LacDelId = 0)
										BEGIN
											INSERT INTO LosAppCreditCrd
											(
											LacLedFk,LacAppFk,LacLapFk,LacTyp,LacIsuBnk,LacBnkFk,LacLimit,LacCrdNo,LacRowId,LacCreatedBy,LacCreatedDt,LacModifiedBy,LacModifiedDt,
											LacDelFlg,LacDelId
											)
											SELECT	@LeadPk,@APPPk,@LapFk,LacTyp,LacIsuBnk,LacBnkFk,LacLimit,LacCrdNo,
													@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0
											FROM    LosAppCreditCrd WHERE LacLapFk=@oldlapfk  AND LacDelId = 0
										END

									--CREDI CARD NOTES
										IF EXISTS(SELECT 'X' FROM LosAppNotes(NOLOCK) WHERE LanLapFk=@oldlapfk AND LanTyp='C' AND LanDelId = 0)
										BEGIN
											INSERT INTO  LosAppNotes
											(
											LanLedFk,LanAppFk,LanLapFk,LanTyp,LanNotes,
											LanRowId,LanCreatedBy,LanCreatedDt,LanModifiedBy,LanModifiedDt,LanDelFlg,LanDelId
											)
										   SELECT	@LeadPk,@APPPk,@LapFk,LanTyp,LanNotes,@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0
										   FROM	 LosAppNotes WHERE LanLapFk=@oldlapfk AND LanTyp='C' AND LanDelId = 0
										END

									  --SELF EMPLOYED
									  IF EXISTS(SELECT 'X' FROM LosAppBusiProfile(NOLOCK) WHERE LabLapFk=@oldlapfk AND LabDelId = 0)
										BEGIN
										INSERT INTO LosAppBusiProfile
										(
										LabLedFk,LabAppFk,LabLapFk,LabBusiTyp,LabOrgTyp,LabNm,LabNat,LabOwnShip,LabIncYr,LabBusiPrd,LabCIN,LabOffNo,LabEMail,
										LabRowId,LabCreatedBy,LabCreatedDt,LabModifiedBy,LabModifiedDt,LabDelFlg,LabDelId,LabCurBusiPrd,LabMSME
										)
										 SELECT	@LeadPk,@APPPk,@LapFk,LabBusiTyp,LabOrgTyp,LabNm,LabNat,LabOwnShip,LabIncYr,LabBusiPrd,LabCIN,LabOffNo,LabEMail,
												@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0,LabCurBusiPrd,LabMSME
										 FROM	LosAppBusiProfile WHERE LabLapFk=@oldlapfk AND LabDelId = 0

										UPDATE	LosAppProfile
										SET 	LapEmpTyp = 1, LapDelFlg = dbo.gefgGetDelFlg(@CurDt),LapRowId=@RowId,LapModifiedBy=@UsrDispNm,LapModifiedDt=@CurDt
										WHERE	 LapPk = @LapFk AND LapCusFk=@CusFkId AND LapDelId = 0
									  END

									   --SALARIED
									  IF EXISTS(SELECT 'X' FROM LosAppOffProfile(NOLOCK) WHERE LaeLapFk=@oldlapfk AND LaeDelId = 0)
										BEGIN
										INSERT INTO LosAppOffProfile
										(
										LaeLedFk,LaeAppFk,LaeLapFk,LaeNm,LaeTyp,LaeNat,LaeDesig,LaeExp,LaeTotExp,LaeOffNo,LaeEMail,LaeRowId,LaeCreatedBy,LaeCreatedDt,LaeModifiedBy,LaeModifiedDt,LaeDelFlg,LaeDelId,LaeEmpId,
										LapMonIncAmt,LapOthIncAmt
										)
										 SELECT	@LeadPk,@APPPk,@LapFk,LaeNm,LaeTyp,LaeNat,LaeDesig,LaeExp,LaeTotExp,LaeOffNo,LaeEMail,
												@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0,LaeEmpId,
												LapMonIncAmt,LapOthIncAmt
										 FROM	LosAppOffProfile WHERE LaeLapFk=@oldlapfk AND LaeDelId = 0

										 UPDATE	LosAppProfile
										 SET 	LapEmpTyp = 0, LapDelFlg = dbo.gefgGetDelFlg(@CurDt),LapRowId=@RowId,LapModifiedBy=@UsrDispNm,LapModifiedDt=@CurDt
										 WHERE	 LapPk = @LapFk AND LapCusFk=@CusFkId AND LapDelId = 0
										
									  END

	                                

										--PERMANENT ADDRESS
										IF EXISTS(SELECT 'X' FROM LosAppAddress(NOLOCK) WHERE LaaLapFk=@oldlapfk AND LaaAddTyp=1 AND LaaDelId = 0)
										BEGIN
											INSERT INTO  LosAppAddress
											(
											LaaLedFK,LaaAppFk,LaaLapFk,LaaAddTyp,LaaComAdd,LaaAcmTyp,LaaYrsResi,LaaDoorNo,LaaBuilding,LaaPlotNo,LaaStreet,LaaLandmark,
											LaaArea,LaaDistrict,LaaState,LaaCountry,LaaPin,LaaRowId,LaaCreatedBy,LaaCreatedDt,LaaModifiedBy,LaaModifiedDt,
											LaaDelFlg,LaaDelId,LaaRentAmt 
											)
										   SELECT	@LeadPk,@APPPk,@LapFk,LaaAddTyp,LaaComAdd,LaaAcmTyp,LaaYrsResi,LaaDoorNo,LaaBuilding,LaaPlotNo,LaaStreet,LaaLandmark,
													LaaArea,LaaDistrict,LaaState,LaaCountry,LaaPin,@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0,LaaRentAmt
										   FROM	    LosAppAddress WHERE LaaLapFk=@oldlapfk AND LaaAddTyp=1 AND LaaDelId = 0
										END

										--BUSINESS ADDRESS
										IF EXISTS(SELECT 'X' FROM LosAppAddress(NOLOCK) WHERE LaaLapFk=@oldlapfk AND LaaAddTyp=2 AND LaaDelId = 0)
										BEGIN
											INSERT INTO LosAppAddress
											(
											LaaLedFK,LaaAppFk,LaaLapFk,LaaAddTyp,LaaComAdd,LaaAcmTyp,LaaYrsResi,LaaDoorNo,LaaBuilding,LaaPlotNo,LaaStreet,LaaLandmark,
											LaaArea,LaaDistrict,LaaState,LaaCountry,LaaPin,LaaRowId,LaaCreatedBy,LaaCreatedDt,LaaModifiedBy,LaaModifiedDt,
											LaaDelFlg,LaaDelId,LaaRentAmt 
											)
										   SELECT	@LeadPk,@APPPk,@LapFk,LaaAddTyp,LaaComAdd,LaaAcmTyp,LaaYrsResi,LaaDoorNo,LaaBuilding,LaaPlotNo,LaaStreet,LaaLandmark,
													LaaArea,LaaDistrict,LaaState,LaaCountry,LaaPin,@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0,LaaRentAmt
										   FROM	    LosAppAddress WHERE LaaLapFk=@oldlapfk AND LaaAddTyp=2 AND LaaDelId = 0
										END

										--OFFICE ADDRESS
										IF EXISTS(SELECT 'X' FROM LosAppAddress(NOLOCK) WHERE LaaLapFk=@oldlapfk AND LaaAddTyp=3 AND LaaDelId = 0)
										BEGIN
											INSERT INTO LosAppAddress
											(
											LaaLedFK,LaaAppFk,LaaLapFk,LaaAddTyp,LaaComAdd,LaaAcmTyp,LaaYrsResi,LaaDoorNo,LaaBuilding,LaaPlotNo,LaaStreet,LaaLandmark,
											LaaArea,LaaDistrict,LaaState,LaaCountry,LaaPin,LaaRowId,LaaCreatedBy,LaaCreatedDt,LaaModifiedBy,LaaModifiedDt,
											LaaDelFlg,LaaDelId,LaaRentAmt 
											)
										   SELECT	@LeadPk,@APPPk,@LapFk,LaaAddTyp,LaaComAdd,LaaAcmTyp,LaaYrsResi,LaaDoorNo,LaaBuilding,LaaPlotNo,LaaStreet,LaaLandmark,
													LaaArea,LaaDistrict,LaaState,LaaCountry,LaaPin,@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0,LaaRentAmt
										   FROM	    LosAppAddress WHERE LaaLapFk=@oldlapfk AND LaaAddTyp=3 AND LaaDelId = 0
										END

										--STUDENT ADDRESS
										IF EXISTS(SELECT 'X' FROM LosAppAddress(NOLOCK) WHERE LaaLapFk=@oldlapfk AND LaaAddTyp=4 AND LaaDelId = 0)
										BEGIN
											INSERT INTO  LosAppAddress
											(
											LaaLedFK,LaaAppFk,LaaLapFk,LaaAddTyp,LaaComAdd,LaaAcmTyp,LaaYrsResi,LaaDoorNo,LaaBuilding,LaaPlotNo,LaaStreet,LaaLandmark,
											LaaArea,LaaDistrict,LaaState,LaaCountry,LaaPin,LaaRowId,LaaCreatedBy,LaaCreatedDt,LaaModifiedBy,LaaModifiedDt,
											LaaDelFlg,LaaDelId,LaaRentAmt 
											)
										   SELECT	@LeadPk,@APPPk,@LapFk,LaaAddTyp,LaaComAdd,LaaAcmTyp,LaaYrsResi,LaaDoorNo,LaaBuilding,LaaPlotNo,LaaStreet,LaaLandmark,
													LaaArea,LaaDistrict,LaaState,LaaCountry,LaaPin,@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0,LaaRentAmt
										   FROM	    LosAppAddress WHERE LaaLapFk=@oldlapfk AND LaaAddTyp=4 AND LaaDelId = 0
										END

										--Kyc Document
									IF EXISTS(SELECT 'X' FROM LosAppKYCDocuments(NOLOCK) WHERE KYCLapFk=@oldlapfk AND KYCDelId = 0)
									BEGIN

								    INSERT INTO LosAppKYCDocuments
						              (
									   KYCLedFk,KYCAppFk,KYCLapFk,KYCDocTyp,KYCGdmFk,KYCDocVal,KYCValidUpto,
						               KYCRowId,KYCCreatedBy,KYCCreatedDt,KYCModifiedBy,KYCModifiedDt,KYCDelFlg,KYCDelId,
									   KycRefDt,KYCRmks
									  )
								
								    SELECT	@LeadPk,@APPPk,@LapFk,KYCDocTyp,KYCGdmFk,KYCDocVal,DBO.gefgChar2Date(KYCValidUpto),@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0,
								            DBO.gefgChar2Date(KycRefDt),KYCRmks
								    FROM	LosAppKYCDocuments WHERE KYCLapFk=@oldlapfk AND KYCDelId = 0

								    END

									END
							END						
			END

--	EXEC PrcShflGenLog @LogDtls,1001,@DocPk,@Query,0
	
	IF @Trancount = 1 AND @@TRANCOUNT = 1
		COMMIT TRAN
			
	END TRY
	BEGIN CATCH
		
		IF @Trancount = 1 AND @@TRANCOUNT = 1
			ROLLBACK TRAN	
		
		SELECT	@ErrMsg = ERROR_MESSAGE() + ',' + ERROR_PROCEDURE() + ':' + RTRIM(ERROR_LINE()),
				@ErrSeverity = ERROR_SEVERITY()
				
		--EXEC PrcShflGenLog @LogDtls,1001,@DocPk,@Query,1,@ErrMsg
		
		RAISERROR('%s', @ErrSeverity, 1,@ErrMsg) 		
		RETURN
			
	END CATCH			
				
END