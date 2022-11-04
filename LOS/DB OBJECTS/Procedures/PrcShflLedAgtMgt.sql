IF EXISTS(SELECT NULL FROM sysobjects WHERE name='PrcShflLedAgtMgt' AND [type]='P')
	DROP PROC PrcShflLedAgtMgt
GO
CREATE PROCEDURE PrcShflLedAgtMgt
(
	@Action VARCHAR(50)			=NULL,
	@GlobalJson VARCHAR(MAX)	=NULL
)
AS
	SET NOCOUNT ON
	SET ANSI_WARNINGS ON
	
	DECLARE @CurDt DATETIME, @TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT,
			@RowId VARCHAR(40);

	DECLARE @LajFk BIGINT, @RefPk BIGINT, @LeadPk BIGINT, @srvTyp TINYINT, @IsExist BIT = 1
	
	CREATE TABLE #GlobalDtls
	(
		xx_id BIGINT,ServiceType BIGINT,LajFk BIGINT, RefFk BIGINT, LajAgtFK BIGINT, LeadPk BIGINT
	)	
	
	CREATE TABLE #AgtJobDtls
	(
		LajPk BIGINT,ServiceType TINYINT,LeadId VARCHAR(50),
		LajLedFk BIGINT,LajAgtFK BIGINT,AgentName VARCHAR(100),AgentJob VARCHAR(100),AgtPk BIGINT,
		AgtJobDt BIGINT
	)

	SELECT @CurDt = GETDATE(), @RowId = NEWID()	
	
	IF @GlobalJson != '[]' AND @GlobalJson != ''
	BEGIN					
		INSERT INTO #GlobalDtls
		EXEC PrcParseJSON @GlobalJson,'ServiceType,LajFk,RefPk,LajAgtFK,LeadPk'

		SELECT @LajFk = LajFk, @RefPk = RefFk,@srvTyp = ServiceType,@LeadPk = LeadPk FROM #GlobalDtls
	END
	
	BEGIN
		/*
		IF @Action IN('S','Dash')
		BEGIN
				IF @Action = 'S'
				BEGIN
					SELECT ISNULL(LeadId,'') 'LeadId',ISNULL(PrdFk,'') 'ProductFk', ISNULL(AppNo,'') 'ApplicationNo', 
							ISNULL(PrdNm,'') 'ProductName',ISNULL(GeoFk,'') 'BranchFk',ISNULL(BranchNm,'') 'BranchNm',
							ISNULL(AgtFk,'') 'AgtFk',ISNULL(AgtNm, '') 'AgentName'				
					FROM	#GlobalDtls
					WHERE	LeadPk = @LeadPk
				END

				INSERT INTO #AgtJobDtls(LajPk,ServiceType,LeadId,LajLedFk,LajAgtFK,AgentName,AgentJob,AgtPk,AgtJobDt)
				SELECT	LajPk 'LajPk', LajSrvTyp 'ServiceType', LedId 'LeadId',LajLedFk, LajAgtFK,
						ISNULL(AgtFName,'') + ' ' + ISNULL(AgtMName,'') + ' ' + ISNULL(AgtLName,'') 'AgentName',
						CASE	WHEN LajSrvTyp = 0 THEN 'FI' WHEN LajSrvTyp = 1 THEN 'FI'
								WHEN LajSrvTyp = 2 THEN 'DV'WHEN LajSrvTyp = 3 THEN 'CF'
								WHEN LajSrvTyp = 4 THEN 'LV' WHEN LajSrvTyp = 5 THEN 'TV' END 'AgentJob',AgtPk 'AgtPk',
						DATEDIFF(DAY,@CurDt,LajJobDt)
				FROM	LosAgentJob(NOLOCK)
				JOIN	GenAgents (NOLOCK) ON AgtPk = LajAgtFk	AND AgtDelId = 0
				JOIN	LosLead (NOLOCK) ON LedPk = LajLedFk AND LedDelId = 0	
				WHERE	LajLedFk = ISNULL(@LeadPk,LajLedFk) AND LajDelId = 0
				
				IF @Action = 'S'
					BEGIN
						SELECT	LajPk,ServiceType, LeadId, LajLedFk,AgtPk, AgentName, AgentJob, AgtPk, 
								LapActor 'ActorType',LapFstNm + '' + LapMdNm + '' + LapLstNm 'AppName',LavPk 'Pk',AgtJobDt 'AgtJobDt'
						FROM	#AgtJobDtls
						JOIN	LosAgentVerf (NOLOCK)	ON LavLajFk = LajPk	AND LavDelId = 0
						JOIN	LosAppProfile(NOLOCK) ON LapPk = LavLapFk AND LapDelid = 0
						WHERE	ServiceType IN(0,1,2,3)
							UNION	ALL
						SELECT	LajPk,ServiceType, LeadId, LajLedFk,AgtPk, AgentName, AgentJob, AgtPk,
								0 'ActorType',QDEFstNm 'AppName',LpvPk 'Pk',AgtJobDt 'AgtJobDt'
						FROM	#AgtJobDtls (NOLOCK)
						JOIN	LosQDE (NOLOCK) ON QDEActor = 0 AND	QDELedFk = LajLedFk AND QDEDelId  = 0
						JOIN	LosAgentPrpVerf (NOLOCK) ON LpvLajFk = LajPk AND LpvDelId = 0
						WHERE	ServiceType IN(4,5)
					END
				ELSE
					BEGIN
						SELECT  LajPk,ServiceType,LeadId,LajLedFk,LajAgtFK,AgentName,AgentJob,AgtPk,
								ActorType,AppName,Pk,AgtJobDt
						FROM
						(
							SELECT  LajPk,ServiceType,LeadId,LajLedFk,LajAgtFK,AgentName,AgentJob,AgtPk,
									LapActor 'ActorType',LapFstNm + '' + LapMdNm + '' + LapLstNm  'AppName',LavPk 'Pk',AgtJobDt 'AgtJobDt'
							FROM	#AgtJobDtls
							JOIN	LosAgentVerf (NOLOCK)	ON LavLajFk = LajPk	AND LavDelId = 0	
							JOIN	LosAppProfile(NOLOCK) ON LapPk = LavLapFk AND LapDelid = 0
							WHERE	ServiceType IN(0,1,2,3)
								UNION	ALL
							SELECT	LajPk,ServiceType, LeadId, LajLedFk,AgtPk, AgentName, AgentJob, AgtPk,
									0 'ActorType',QDEFstNm + '' + QDEMdNm + '' + QDELstNm 'AppName',LpvPk 'Pk',AgtJobDt 'AgtJobDt'
							FROM	#AgtJobDtls (NOLOCK)
							JOIN	LosQDE (NOLOCK) ON 	QDEActor = 0 AND QDELedFk = LajLedFk AND QDEDelId  = 0
							JOIN	LosAgentPrpVerf (NOLOCK) ON LpvLajFk = LajPk AND LpvDelId = 0
							WHERE	ServiceType IN(4,5)
						)A
						WHERE NOT EXISTS
						(
							SELECT 'X' FROM LosAgentFBJob(NOLOCK) WHERE LfjSrvTyp = ServiceType 
							AND LfjDpdFk = Pk AND LfjDelId = 0
						)

					END
		END
		*/
		IF @Action = 'SelDetails'
		BEGIN
				IF @srvTyp  IN(0,1,2,3)
					BEGIN
						SELECT	LavLajFk 'LajFk',LapActor 'ActorType',LapFstNm + ' ' + LapMdNm + ' ' + LapLstNm 'AppNm',LavMobNo 'Contact',LavAddTyp 'AddTyp',LavDoorNo 'DoorNo',
								LavBuilding 'Building',LavPlotNo 'PlotNo',LavStreet 'Street',LavLandmark 'LandMark',LavArea 'Area',LavDistrict 'District',
								LavState 'State',LavCountry 'Country',LavPin 'Pincode',LavPk 'LavPk', LajSrvTyp 'ServiceType',
						CASE	WHEN LapGender = 0 THEN 'Male' WHEN LapGender = 1 THEN 'Female' END 'Gender',
						CASE	WHEN LajSrvTyp IN(0,2,3) THEN 'Residence Address' ELSE 'Office Address' END 'AddrType',2 'agt_rptstatus','' 'SellerNm','none' 'slrnmdisp',
								ISNULL(AgtFName,'') + ' ' + ISNULL(AgtMName,'') + ' ' + ISNULL(AgtLName,'') 'AgentName'
						FROM	LosAgentVerf (NOLOCK)
						JOIN	LosAgentJob (NOLOCK) ON LajPk = LavLajFk AND LavDelId = 0
						JOIN	GenAgents (NOLOCK) ON AgtPk = LajAgtFk AND AgtDelId = 0
						JOIN	LosAppProfile(NOLOCK) ON LapPk = LavLapFk AND LapDelid = 0
						WHERE 	LavPk = @RefPk  
					
						IF @srvTyp IN(2)
							BEGIN
								SELECT	LadDocCt 'DocCategory',LadDocSubCt 'DocSubCategory', LadDocFk 'agt_DocFk',
										'' 'agt_DocRmks',2 'agt_DocSts', 0 'DPk',DocNm 'DocNm',DocPath 'DocPath',
										ISNULL(AgtFName,'') + ' ' + ISNULL(AgtMName,'') + ' ' + ISNULL(AgtLName,'') 'AgentName'
								FROM	LosAgentDocs (NOLOCK) 
								JOIN	LosAgentJob (NOLOCK) ON LajPk = LadLajFk AND LajDelId = 0
								JOIN	GenAgents (NOLOCK) ON AgtPk = LajAgtFk AND AgtDelId = 0
								JOIN	LosDocument (NOLOCK) ON DocLedFk = LajLedFk AND DocDelId = 0 AND DocPk=LadDocFk
								WHERE	LadLajFk = @LajFk AND LadSrvTyp = 2 AND LadDpdFk = @RefPk AND LadDelId = 0
							END
						
					END
				ELSE IF @srvTyp IN(4,5)
					BEGIN
						IF NOT EXISTS(SELECT 'X' FROM LosQde(NOLOCK) WHERE QdeLedFk = @LeadPk AND QdeDelid = 0)
							SET @IsExist = 0
						
						IF @IsExist = 0
							BEGIN
								SELECT 	LedNm 'AppNm',0 'ActorType', LpvDoorNo 'DoorNo',LpvBuilding 'Building',
										LpvPlotNo 'PlotNo',LpvStreet 'Street',LpvLandmark 'LandMark',LpvArea 'Area',LpvDistrict 'District',
										LpvState 'State',LpvCountry 'Country',LpvPin 'Pincode' ,LedMobNo 'Contact',LajSrvTyp 'ServiceType',LpvPk 'LpvPk',
										'' 'Gender' ,LajPk 'LajFk',
										'Property Address' 'AddrType',2 'agt_rptstatus','' 'SellerNm','none' 'slrnmdisp',
										ISNULL(AgtFName,'') + ' ' + ISNULL(AgtMName,'') + ' ' + ISNULL(AgtLName,'') 'AgentName'
 								FROM	LosAgentPrpVerf(NOLOCK)
								JOIN	LosAgentJob (NOLOCK) ON LajPk = LpvLajFk AND LajDelId = 0
								JOIN	GenAgents (NOLOCK) ON AgtPk = LajAgtFk AND AgtDelId = 0
								JOIN	LosLead(NOLOCK) ON LedPk = LajLedFk AND LedDelid = 0
								WHERE	LpvPk = @RefPk
							END
						ELSE
							BEGIN
								SELECT 	QDEFstNm + ' ' + QDEMdNm + ' ' + QDELstNm 'AppNm',0 'ActorType', LpvDoorNo 'DoorNo',LpvBuilding 'Building',
										LpvPlotNo 'PlotNo',LpvStreet 'Street',LpvLandmark 'LandMark',LpvArea 'Area',LpvDistrict 'District',
										LpvState 'State',LpvCountry 'Country',LpvPin 'Pincode' ,QDAContact 'Contact',LajSrvTyp 'ServiceType',LpvPk 'LpvPk',
										CASE WHEN QDEGender = 0 THEN 'Male' WHEN QDEGender = 1 THEN 'Female' END 'Gender' ,LajPk 'LajFk',
										'Property Address' 'AddrType',2 'agt_rptstatus','' 'SellerNm','none' 'slrnmdisp',
										ISNULL(AgtFName,'') + ' ' + ISNULL(AgtMName,'') + ' ' + ISNULL(AgtLName,'') 'AgentName'
 								FROM	LosAgentPrpVerf(NOLOCK)
								JOIN	LosAgentJob (NOLOCK) ON LajPk = LpvLajFk AND LajDelId = 0
								JOIN	GenAgents (NOLOCK) ON AgtPk = LajAgtFk AND AgtDelId = 0
								JOIN	LosQDE (NOLOCK) ON QDEActor = 0 AND QdeLedFk =  LajLedFk AND QDEDelid = 0
								JOIN	LosQdeAddress(NOLOCK) ON QdaQdeFk = QdePk AND QdaDelid = 0
								WHERE	LpvPk = @RefPk
							END
					END
				ELSE IF @srvTyp IN(6)
					BEGIN
						SELECT 	QDEFstNm + ' ' + QDEMdNm + ' ' + QDELstNm 'AppNm',0 'ActorType',  LavDoorNo 'DoorNo',LavBuilding 'Building',
								LavPlotNo 'PlotNo',LavStreet 'Street',LavLandmark 'LandMark',LavArea 'Area',LavDistrict 'District',
								LavState 'State',LavCountry 'Country',LavPin 'Pincode' ,QDAContact 'Contact',LajSrvTyp 'ServiceType',LslPk 'LslPk',
								CASE WHEN QDEGender = 0 THEN 'Male' WHEN QDEGender = 1 THEN 'Female' END 'Gender' ,LajPk 'LajFk',
								CASE WHEN LslTyp = 'S' THEN 'Seller Details' ELSE 'Builder Details' END 'AddrType',2 'agt_rptstatus', LavNm 'SellerNm','block' 'slrnmdisp',
								ISNULL(AgtFName,'') + ' ' + ISNULL(AgtMName,'') + ' ' + ISNULL(AgtLName,'') 'AgentName'
 						FROM	LosAgentVerf (NOLOCK)
						JOIN	LosSeller(NOLOCK) ON LslPk = LavLslFk AND LavDelId = 0
						JOIN	LosAgentJob (NOLOCK) ON LslLedFk = LajLedFk AND LajSrvTyp = 6  AND LslAgtFk = LajAgtFk 
													  AND ISNULL(LslSelTrig,'') = 'Y' AND LslDelId = 0
						JOIN	GenAgents (NOLOCK) ON AgtPk = LajAgtFk AND AgtDelId = 0
						JOIN	LosQDE (NOLOCK) ON QDEActor = 0 AND QdeLedFk =  LajLedFk AND QDEDelid = 0
						JOIN	LosQdeAddress(NOLOCK) ON QdaQdeFk = QdePk AND QdaDelid = 0
						WHERE	LslPk = @RefPk AND AgtPk = LajAgtFK
					END

		END
END

