IF EXISTS(SELECT NULL FROM sysobjects WHERE name='PrcSyncAgtfrmUNO' AND [type]='P')
	DROP PROC PrcSyncAgtfrmUNO
GO
CREATE PROCEDURE PrcSyncAgtfrmUNO
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @CurDt DATETIME, @RowId VARCHAR(40), @UsrNm VARCHAR(100),@TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), 
			@Error INT, @RowCount INT

	CREATE TABLE #Agts(Tmp_AgtCd VARCHAR(50), AgtPk BIGINT, OldFk BIGINT)
	CREATE TABLE #AgtInsert
	(
		AgtCd VARCHAR(100), Initial CHAR(10), FName VARCHAR(100), MName  VARCHAR(100), LName VARCHAR(100), 
		Address1 VARCHAR(MAX), Address2 VARCHAR(MAX), Area VARCHAR(100),City VARCHAR(100), 
		State VARCHAR(100), Country VARCHAR(100), 
		Pincode VARCHAR(10), MobileNo VARCHAR(25), StatFlag CHAR(1), Typ INT, Pk BIGINT,UnitShrtDescr VARCHAR(100)
	)
	
	SELECT	@UsrNm = 'UNOSYNC', @CurDt = GETDATE(), @RowId = NEWID();

	BEGIN TRY
	
	IF @@TRANCOUNT = 0
		SET @Trancount = 1
					
		IF @Trancount = 1
			BEGIN TRAN
			
				INSERT INTO #AgtInsert
				SELECT	MktngAgentCode, Initial, FName, MName, LName, Address1, Address2, Area, City, State, Country, Pincode, MobileNo , 
						StatFlag, 0, PK_ID, UnitShrtDescr
				FROM	[SHFL_LOS_ACC].dbo.LGen_MktngAgent WHERE  FI = 'Y'
					UNION ALL
				SELECT	MktngAgentCode, Initial, FName, MName, LName, Address1, Address2, Area, City, State, Country, Pincode, MobileNo , 
						StatFlag, 3, PK_ID, UnitShrtDescr
				FROM	[SHFL_LOS_ACC].dbo.LGen_MktngAgent WHERE  TypeShrtDescr IN ('CLAGT','COLAG')
					UNION ALL
				SELECT	MktngAgentCode, Initial, FName, MName, LName, Address1, Address2, Area, City, State, Country, Pincode, MobileNo , 
						StatFlag, 5, PK_ID, UnitShrtDescr
				FROM	[SHFL_LOS_ACC].dbo.LGen_MktngAgent WHERE  TypeShrtDescr IN ('TECH','ETEE','itee')
					UNION ALL	
				SELECT	MktngAgentCode, Initial, FName, MName, LName, Address1, Address2, Area, City, State, Country, Pincode, MobileNo , 
						StatFlag, 4, PK_ID, UnitShrtDescr
				FROM	[SHFL_LOS_ACC].dbo.LGen_MktngAgent WHERE  TypeShrtDescr IN ('fculw')
					UNION ALL	
				SELECT	MktngAgentCode, Initial, FName, MName, LName, Address1, Address2, Area, City, State, Country, Pincode, MobileNo , 
						StatFlag, 7, PK_ID, UnitShrtDescr
				FROM	[SHFL_LOS_ACC].dbo.LGen_MktngAgent WHERE  DSA = 'Y'
		
				INSERT INTO GenAgents
				(
					AgtCd,AgtTitle,AgtFName,AgtMName,AgtLName,AgtDoorNo,AgtBuilding,AgtPlotNo,AgtStreet,AgtLandmark,AgtArea,AgtDistrict,AgtState,AgtCountry,AgtPin,
					AgtRowId,AgtCreatedBy,AgtCreatedDt,AgtModifiedBy,AgtModifiedDt,AgtDelFlg,AgtDelId,AgtContact,AgtStsFlg
				)
				OUTPUT INSERTED.AgtCd , INSERTED.AgtPk, 0  INTO #Agts
				SELECT		AgtCd, Initial, FName, MName, LName, '',Address1, '', Address2, '', Area, City, State, Country, Pincode, 
							@RowID,@UsrNm, @CurDt,@UsrNm, @CurDt,NULL, 0,MobileNo , StatFlag
				FROM		#AgtInsert 
				WHERE		NOT EXISTS(SELECT 'X' FROM GenAgents A(NOLOCK) WHERE #AgtInsert.AgtCd = A.AgtCd)
				GROUP BY	AgtCd,Initial, FName, MName, LName,Address1, Address2, Area, City, State, Country, Pincode,MobileNo, StatFlag
				
				SELECT 'Insert UNO-Agents Header' 'Completed', @@ROWCOUNT 'Rows_Affected'
				
				IF EXISTS(SELECT 'X' FROM #Agts)
					BEGIN
						UPDATE #Agts SET OldFk = Pk FROM #AgtInsert WHERE Tmp_AgtCd = AgtCd
			
						INSERT INTO GenAgentUnit
						(
							AguAgtFk,AguBGeoFk,AguDoorNo,AguBuilding,AguPlotNo,AguStreet,AguLandmark,AguArea,AguDistrict,AguState,AguCountry,AguPin,AugContact,
							AguRowId,AguCreatedBy,AguCreatedDt,AguModifiedBy,AguModifiedDt,AguDelFlg,AguDelId
						)
						SELECT	AgtPk, GeoPk,'', A.Address1,'', A.Address2,'', ISNULL(A.Area,''),ISNULL(A.City,''), ISNULL(A.State,''), 
								ISNULL(A.Country,''), ISNULL(A.Pincode,'') , A.MobileNo ,
								@RowID,@UsrNm, @CurDt,@UsrNm, @CurDt,NULL, 0
						FROM	[SHFL_LOS_ACC].dbo.LGen_MktngAgent_d A
						JOIN	GenGeoMas ON GeoCd = UnitShrtdescr AND GeoDelid = 0
						JOIN	#Agts ON Hdr_Fk = OldFk
						GROUP BY AgtPk,GeoPk, A.Address1,A.Address2,ISNULL(A.Area,''),ISNULL(A.City,''),ISNULL(A.State,''), ISNULL(A.Country,''), ISNULL(A.Pincode,'') , A.MobileNo 
						ORDER BY AgtPk
						
						SELECT 'Insert UNO-Agents Unit Details' 'Completed', @@ROWCOUNT 'Rows_Affected'
						
						INSERT INTO GenAgentUnit
						(
							AguAgtFk,AguBGeoFk,AguDoorNo,AguBuilding,AguPlotNo,AguStreet,AguLandmark,AguArea,AguDistrict,AguState,AguCountry,AguPin,AugContact,
							AguRowId,AguCreatedBy,AguCreatedDt,AguModifiedBy,AguModifiedDt,AguDelFlg,AguDelId
						)
						SELECT	AgtPk, GeoPk,'', A.Address1,'', A.Address2,'', ISNULL(A.Area,''),ISNULL(A.City,''), ISNULL(A.State,''), 
								ISNULL(A.Country,''), ISNULL(A.Pincode,'') , A.MobileNo ,
								@RowID,@UsrNm, @CurDt,@UsrNm, @CurDt,NULL, 0
						FROM	#AgtInsert A
						JOIN	GenGeoMas ON GeoCd = UnitShrtdescr AND GeoDelid = 0
						JOIN	#Agts ON Tmp_AgtCd = AgtCd
						GROUP BY AgtPk,GeoPk, A.Address1,A.Address2,ISNULL(A.Area,''),ISNULL(A.City,''),ISNULL(A.State,''), ISNULL(A.Country,''), ISNULL(A.Pincode,'') , A.MobileNo 
						ORDER BY AgtPk
						
						SELECT 'Insert UNO-Agents Unit Details in Header' 'Completed', @@ROWCOUNT 'Rows_Affected'
						
						INSERT INTO GenAgentServ
						(
							AgsAgtFk,AgsSvrTyp,AgsIsAct,AgsRowId,AgsCreatedBy,AgsCreatedDt,AgsModifiedBy,AgsModifiedDt,AgsDelFlg,AgsDelId
						)
						SELECT	AgtPk, TYP, 1, @RowID,@UsrNm, @CurDt,@UsrNm, @CurDt,NULL, 0
						FROM	#Agts
						JOIN	#AgtInsert ON Tmp_AgtCd = AgtCd
						GROUP BY AgtPk, TYP
						ORDER BY AgtPk
						
						SELECT 'Insert UNO-Agents Service Type Details' 'Completed', @@ROWCOUNT 'Rows_Affected'
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