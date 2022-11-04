IF OBJECT_ID('PrcShflQDEEntry','P') IS NOT NULL
	DROP PROCEDURE PrcShflQDEEntry
GO
CREATE PROCEDURE PrcShflQDEEntry
(
	@Action			VARCHAR(100)		=	NULL,
	@GlobalJson		VARCHAR(MAX)		=	NULL,
	@HdrJson		VARCHAR(MAX)		=	NULL,
	@AppJson		VARCHAR(MAX)		=	NULL,
	@LogDtls		VARCHAR(MAX)		=	NULL

)
AS
BEGIN

	SET NOCOUNT ON
	SET ANSI_WARNINGS ON
	
	DECLARE @CurDt DATETIME, @TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT,
			@RowId VARCHAR(40), @prdGfk BIGINT, @PrdGrpFk BIGINT;
			
	DECLARE	@DocPk BIGINT, @LeadPk BIGINT, @GeoFk BIGINT, @UsrPk BIGINT, @UsrDispNm VARCHAR(100), @UsrNm VARCHAR(100),@PrdFk BIGINT,
			@selActor TINYINT, @SubActor TINYINT, @Query VARCHAR(MAX), @ActorNm VARCHAR(100);
	
	CREATE TABLE #GlobalDtls
	(
		id BIGINT, LeadPk BIGINT, GeoFk BIGINT, UsrPk BIGINT, UsrDispNm VARCHAR(100),UsrNm VARCHAR(100), PCd VARCHAR(100),PrdGroupFk BIGINT
	)
	CREATE TABLE #HdrDtls
	(
		id BIGINT, selActor TINYINT, subactor TINYINT, DocPk BIGINT, ActorNm VARCHAR(100), grpprdfk BIGINT
	)
	CREATE TABLE #AppDtls
	(
		id BIGINT, qde_txt_FirstNm VARCHAR(100),qde_txt_MiddleNm VARCHAR(100),qde_txt_LastNm VARCHAR(100),qde_dt_dob VARCHAR(20),
		qde_txt_mob VARCHAR(20),qde_txt_email VARCHAR(100),qde_txt_fthr1stNm VARCHAR(100),qde_txt_fthrMidNm VARCHAR(100),qde_txt_fthrLastNm VARCHAR(100),
		qde_txt_aadhar VARCHAR(20),qde_txt_pan VARCHAR(20),qde_txt_drv_lic VARCHAR(20),qde_txt_VotId VARCHAR(20),qde_txt_passNum VARCHAR(100),
		qde_txt_DoorNo VARCHAR(10),qde_txt_BuildNo VARCHAR(150),qde_txt_PlotNo VARCHAR(20),qde_txt_Street VARCHAR(150),qde_txt_LandMark VARCHAR(250),
		qde_txt_TownVil VARCHAR(150),qde_txt_DisCity VARCHAR(100),qde_txt_State VARCHAR(100),qde_txt_Pin VARCHAR(6),qde_sel_Gender TINYINT,qde_txt_cibil SMALLINT,
		qde_txt_pappno VARCHAR(100),qde_chk_doc VARCHAR(20)
	)
	
	SELECT @CurDt = GETDATE(), @RowId = NEWID()
	
	SET @Query =  'EXEC PrcShflQDEEntry ''' + ISNULL(@Action,'') + ''''
	
	IF @GlobalJson != '[]' AND @GlobalJson != ''
		BEGIN
			SET @Query =  @Query + ',''' + @GlobalJson + ''''
			
			INSERT INTO #GlobalDtls
			EXEC PrcParseJSON @GlobalJson,'LeadPk,GeoFk,UsrPk,UsrDispNm,UsrNm,PrdCd,PrdGrpFk'
			
			SELECT	@LeadPk = LeadPk, @GeoFk = GeoFk, @UsrPk = UsrPk, @UsrDispNm = UsrDispNm, @UsrNm = UsrNm
			FROM	#GlobalDtls
			
			SELECT	@PrdFk = PrdPk
			FROM	#GlobalDtls
			JOIN	GenPrdMas(NOLOCK) ON PrdCd = PCd AND PrdDelid = 0
			
		END
	
	IF @HdrJson != '[]' AND @HdrJson != ''
		BEGIN
			SET @Query =  @Query + ',''' + @HdrJson + ''''
			
			INSERT INTO #HdrDtls
			EXEC PrcParseJSON @HdrJson,'selActor,subactor,DocPk,ActorNm , grpprdfk'
			
			SELECT @selActor = selActor, @SubActor = subactor,@DocPk = DocPk,@ActorNm = ActorNm ,@PrdGrpFk = grpprdfk FROM #HdrDtls
		END
		
	IF @AppJson != '[]' AND @AppJson != ''
		BEGIN
			SET @Query =  @Query + ',''' + @AppJson + ''''
			
			INSERT INTO #AppDtls
			EXEC PrcParseJSON @AppJson,'qde_txt_FirstNm,qde_txt_MiddleNm,qde_txt_LastNm,qde_dt_dob,qde_txt_mob,qde_txt_email,qde_txt_fthr1stNm,qde_txt_fthrMidNm,qde_txt_fthrLastNm,qde_txt_aadhar,qde_txt_pan,qde_txt_drv_lic,qde_txt_VotId,qde_txt_passNum,qde_txt_DoorNo,qde_txt_BuildNo,qde_txt_PlotNo,qde_txt_Street,qde_txt_LandMark,qde_txt_TownVil,qde_txt_DisCity,qde_txt_State,qde_txt_Pin,qde_sel_Gender,qde_txt_cibil,qde_txt_pappno,qde_chk_doc'
			
		END

	BEGIN TRY
	 
	IF @@TRANCOUNT = 0
		SET @TranCount = 1
	
	IF @TranCount = 1
		BEGIN TRAN	
		
		
		--IF @Action = 'PrdPkUpdate'
		--		  BEGIN
		--			UPDATE LOSQDE SET QDEPGrpFk = @prdGfk WHERE QDELedFk = @LeadPk
		--		  END	
			
			IF @Action = 'LdDtls'
				BEGIN 

					SELECT	LedNm 'Nm',GrpPk 'productpk', GrpCd 'PCd'
					FROM	GenLvlDefn(NOLOCK)
					JOIN    LosLead(NOLOCK) ON LedPGrpFk=GrpPk
					WHERE   GrpDelId = 0 AND LedPk = @LeadPk		
										
					SELECT	QDePk 'Pk', ISNULL(QDEActor,0) 'Actor',ISNULL(QDESubActor,1) 'SubActor',
							ISNULL(QDEActorNm,'') 'ActorNm', 
							((ROW_NUMBER() OVER(ORDER BY QDePk)) - 1) 'TabNo'
					FROM	LosQDE(NOLOCK)
					WHERE	QDELedFk = @LeadPk AND QDEDelId = 0
										
					SELECT	DocLedFk 'LeadFk',ISNULL(AgtFName,'') + ' ' +  ISNULL(AgtMName,'') + ' ' + ISNULL(AgtLName,'') 'AgentNm',
							DocBGeoFk 'GeoFk',DocPrdFk 'PrdFk',DocActor 'Actor',DocCat	'Catogory',
							DocSubCat 'SubCatogory',DocNm 'DocName',DocPath 'DocPath',DocPk 'Pk'
					FROM	LosDocument(NOLOCK)
					JOIN	GenAgents(NOLOCK) ON AgtPk = DocAgtFk AND AgtDelid = 0
					WHERE	DocLedFk = @LeadPk AND DocDelid = 0 AND DocCat != 'RPT'

					SELECT	LedNm 'Nm',LedPGrpFk 'prdgrpfk',LedCIBILScr 'CIBIL',LedMobNo 'MOBNO',CONVERT (varchar(10),LedDOB,103) 'DOB'
					FROM	LosLead(NOLOCK)
					WHERE	LedPk = @LeadPk AND LedDelid = 0

				END
		  --IF @Action = 'SEL_PRD'
		  --BEGIN
		  --             SELECT  GrpNm 'productnm', GrpPk 'productpk', GrpCd 'ProductCode',GrpIconCls 'classnm'
				--		FROM	GenLvlDefn(NOLOCK)
				--		WHERE	GrpDelId = 0
		  --END
								
			ELSE IF @Action = 'A'
				BEGIN
					INSERT INTO LosQDE 
					(
						QDELedFk,QDEBGeoFk,QDEPrdFk,QDEActor,QDESubActor,QDEActorNm,QDEFstNm,QDEMdNm,QDELstNm,QDEGender,QDEFthFstNm,QDEFthMdNm,QDEFthLstNm,QDEDOB,QDEAadhar,
						QDEPAN,QDEDrvLic,QDEVoterId,QDEPassNum,QDeCibil,QDEPAplnNo,QDERowId,QDECreatedBy,QDECreatedDt,QDEModifiedBy,QDEModifiedDt,QDEDelFlg,QDEDelId,QDEPGrpFk,QdeOthDocAvl
					)
					SELECT	@LeadPk,@GeoFk,@PrdFk,@selActor,ISNULL(@SubActor,1),@ActorNm,qde_txt_FirstNm,qde_txt_MiddleNm,qde_txt_LastNm,qde_sel_Gender,qde_txt_fthr1stNm,qde_txt_fthrMidNm,qde_txt_fthrLastNm,
							ISNULL(dbo.gefgChar2Date(qde_dt_dob),@CurDt),qde_txt_aadhar,qde_txt_pan,
							qde_txt_drv_lic,qde_txt_VotId,qde_txt_passNum,qde_txt_cibil,qde_txt_pappno,@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0,@PrdGrpFk,
							CASE WHEN qde_chk_doc = '0' THEN 'Y' ELSE 'N' END
					FROM	#AppDtls
					
					SELECT	@DocPk = SCOPE_IDENTITY(), @Error = @@ERROR, @RowCount = @@ROWCOUNT

					--UPDATE	LosLead
					--SET		LedPGrpFk = @PrdGrpFk,LedModifiedBy = @UsrDispNm, LedModifiedDt = @CurDt, LedRowID = @RowId 
					--WHERE	LedPk = @LeadPk
					
					IF @Error > 0
						BEGIN
							RAISERROR('%s',16,1,'Error : QDE Header Insert')
							RETURN
						END
					
					IF @RowCount = 0
						BEGIN
							RAISERROR('%s',16,1,'Error : No Rows Found for QDE Header Insert')
							RETURN
						END
					
					INSERT INTO LosQDEAddress
					(
						QDAQDEFK,QDAAddTyp,QDADoorNo,QDABuilding,QDAPlotNo,QDAStreet,QDALandmark,QDAArea,QDADistrict,QDAState,
						QDACountry,QDAPin,QDAContact,QDAEmail,QDARowId,QDACreatedBy,QDACreatedDt,QDAModifiedBy,QDAModifiedDt,QDADelFlg,QDADelId
					)
					SELECT	@DocPk,0,qde_txt_DoorNo,qde_txt_BuildNo,qde_txt_PlotNo,qde_txt_Street,
							qde_txt_LandMark,qde_txt_TownVil,qde_txt_DisCity,qde_txt_State,'INDIA',CONVERT(NUMERIC(10),ISNULL(NULLIF(qde_txt_Pin,''),'0')),
							CONVERT(NUMERIC(15),ISNULL(NULLIF(qde_txt_mob,''),'0')),qde_txt_email,
							@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0
					FROM	#AppDtls
					
					SELECT	@Error = @@ERROR, @RowCount = @@ROWCOUNT
					
					IF @Error > 0
						BEGIN
							RAISERROR('%s',16,1,'Error : QDE Address Insert')
							RETURN
						END
					
					IF @RowCount = 0
						BEGIN
							RAISERROR('%s',16,1,'Error : No Rows Found for QDE Address Insert')
							RETURN
						END
					
					SELECT @DocPk 'Pk'
				END
			
			ELSE IF @Action = 'E'
				BEGIN
					UPDATE	LosQDE
					SET		QDEFstNm = qde_txt_FirstNm,QDEMdNm = qde_txt_MiddleNm,QDELstNm = qde_txt_LastNm,
							QDEGender = qde_sel_Gender,QDEFthFstNm = qde_txt_fthr1stNm,QDEFthMdNm = qde_txt_fthrMidNm,QDEFthLstNm = qde_txt_fthrLastNm,QDEDOB = ISNULL(dbo.gefgChar2Date(qde_dt_dob),@CurDt),
							QDEAadhar = qde_txt_aadhar,	QDEPAN = qde_txt_pan,QDEDrvLic = qde_txt_drv_lic,
							QDEVoterId = qde_txt_VotId,QDEPassNum = qde_txt_passNum,QDeCibil = qde_txt_cibil,QDERowId = @RowId, QDEModifiedBy = @UsrDispNm, 
							QDEModifiedDt =  @CurDt, QDEPAplnNo = qde_txt_pappno,QDEPGrpFk = @PrdGrpFk,
							QdeOthDocAvl = CASE WHEN qde_chk_doc = '0' THEN 'Y' ELSE  'N' END
					FROM	#AppDtls
					WHERE	QDEPk = @DocPk AND QDEDelid = 0

					--UPDATE	LosLead
					--SET		LedPGrpFk = @PrdGrpFk,LedModifiedBy = @UsrDispNm, LedModifiedDt = @CurDt, LedRowID = @RowId 
					--WHERE	LedPk = @LeadPk
					
					SELECT	@Error = @@ERROR
					
					IF @Error > 0
						BEGIN
							RAISERROR('%s',16,1,'Error : QDE Header Update')
							RETURN
						END
					
					UPDATE	LosQDEAddress
					SET		QDAAddTyp = 0,QDADoorNo = qde_txt_DoorNo,QDABuilding = qde_txt_BuildNo,QDAPlotNo = qde_txt_PlotNo,
							QDAStreet = qde_txt_Street,QDALandmark = qde_txt_LandMark,QDAArea = qde_txt_TownVil,QDADistrict = qde_txt_DisCity,
							QDAState = qde_txt_State,QDACountry = 'INDIA',QDAPin = CONVERT(NUMERIC(10),ISNULL(NULLIF(qde_txt_Pin,''),'0')),
							QDAContact = CONVERT(NUMERIC(15),ISNULL(NULLIF(qde_txt_mob,''),'0')),QDAEmail = qde_txt_email,
							QDARowId = @RowId,QDAModifiedBy = @UsrDispNm,QDAModifiedDt = @CurDt
					FROM	#AppDtls
					WHERE	QDAQDEFK = @DocPk AND QDADelId = 0
					
					SELECT	@Error = @@ERROR
					
					IF @Error > 0
						BEGIN
							RAISERROR('%s',16,1,'Error : QDE Address Update')
							RETURN
						END
					
					SELECT @DocPk 'Pk'	
				END
			
			ELSE IF @Action = 'D'
				BEGIN
					UPDATE	LosQDE
					SET		QDEDelId = 1, QDEDelFlg = dbo.gefgGetDelFlg(@CurDt),
							QDERowId = @RowId, QDEModifiedBy = @UsrDispNm, QDEModifiedDt =  @CurDt
					WHERE	QDEPk = @DocPk AND QDEDelid = 0
					
					SELECT	@Error = @@ERROR
					
					IF @Error > 0
						BEGIN
							RAISERROR('%s',16,1,'Error : QDE Header Delete')
							RETURN
						END
					
					UPDATE	LosQDEAddress
					SET		QDADelId = 1, QDADelFlg = dbo.gefgGetDelFlg(@CurDt),
							QDARowId = @RowId,QDAModifiedBy = @UsrDispNm,QDAModifiedDt = @CurDt
					WHERE	QDAQDEFK = @DocPk AND QDADelId = 0
					
					SELECT	@Error = @@ERROR
					
					IF @Error > 0
						BEGIN
							RAISERROR('%s',16,1,'Error : QDE Address Delete')
							RETURN
						END
				END
				
			ELSE IF @Action ='S'
				BEGIN
					SELECT	QDEFstNm 'qde_txt_FirstNm',QDEMdNm 'qde_txt_MiddleNm',QDELstNm 'qde_txt_LastNm',
							ISNULL(QDEGender,-1)'qde_sel_Gender',QDEFthFstNm 'qde_txt_fthr1stNm',QDEFthMdNm'qde_txt_fthrMidNm',
							QDEFthLstNm'qde_txt_fthrLastNm',dbo.gefgDMY(QDEDOB) 'qde_dt_dob',QDAContact 'qde_txt_mob',QDAEmail 'qde_txt_email',
							QDEAadhar 'qde_txt_aadhar',QDEPAN 'qde_txt_pan',QDEDrvLic 'qde_txt_drv_lic',QDEVoterId 'qde_txt_VotId',
							QDEPassNum'qde_txt_passNum',QDAAddTyp 'qde_addTyp',QDADoorNo 'qde_txt_DoorNo',QDABuilding 'qde_txt_BuildNo',
							QDAPlotNo 'qde_txt_PlotNo',	QDAStreet 'qde_txt_Street',QDALandmark 'qde_txt_LandMark',QDAArea 'qde_txt_TownVil',
							QDADistrict 'qde_txt_DisCity',QDAState 'qde_txt_State',QDACountry 'qde_txt_Country',QDAPin 'qde_txt_Pin',
							QDeCibil 'qde_txt_cibil',QDEPAplnNo 'qde_txt_pappno',QDEPGrpFk 'lead_prdPk',GrpCd 'prdcode',
							CASE WHEN QdeOthDocAvl = 'Y' THEN '0' ELSE '1' END 'qde_chk_doc'

					FROM	LosQDE(NOLOCK)
					JOIN	LosQDEAddress(NOLOCK) ON QDAQdeFk = QDEPk AND QDADelId = 0
					JOIN	GenLvlDefn(NOLOCK) ON GrpPk = QDEPGrpFk
					WHERE	QDEPk = @DocPk AND QDEDelid = 0
				END
		
		EXEC PrcShflGenLog @LogDtls,1001,@DocPk,@Query,0

		
	IF @Trancount = 1 AND @@TRANCOUNT = 1
		COMMIT TRAN
			
	END TRY
	BEGIN CATCH
		
		IF @Trancount = 1 AND @@TRANCOUNT = 1
			ROLLBACK TRAN	
		
		SELECT	@ErrMsg = ERROR_MESSAGE() + ',' + ERROR_PROCEDURE() + ':' + RTRIM(ERROR_LINE()),
				@ErrSeverity = ERROR_SEVERITY()
				
		EXEC PrcShflGenLog @LogDtls,1001,@DocPk,@Query,1,@ErrMsg
		
		RAISERROR('%s', @ErrSeverity, 1,@ErrMsg) 		
		RETURN
			
	END CATCH
		
END

