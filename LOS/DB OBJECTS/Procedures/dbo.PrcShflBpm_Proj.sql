IF OBJECT_ID('PrcShflBpm_Proj','P') IS NOT NULL
DROP PROCEDURE PrcShflBpm_Proj
GO
CREATE PROCEDURE PrcShflBpm_Proj
(
	@Action			VARCHAR(100)		=	NULL,
	@ProcessJSON	VARCHAR(MAX)		=	NULL,
	@ConfigCd		VARCHAR(50)			=	NULL,
	@LdDtls			VARCHAR(MAX)		=	NULL
)
AS
BEGIN
	SET NOCOUNT ON
	SET ANSI_WARNINGS ON
	
	DECLARE @UsrNm VARCHAR(200),@UsrPwd VARCHAR(200),@UsrPk BIGINT, @CmpFk BIGINT;
	DECLARE @CurDt DATETIME, @TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT
	DECLARE	@IsRoleQc TINYINT, @FwdDataPk BIGINT, @BrnchFk BIGINT, @PrdFk VARCHAR(50), @GrpFk VARCHAR(50)
	SET @CurDt = GETDATE()
	
	CREATE TABLE #GlobalDetails
	( 
		xx_id BIGINT, TempFlowFk BIGINT, TempFlowXml VARCHAR(MAX),TempElemId VARCHAR(200),CurPage BIGINT,FwdDataPk BIGINT,
		CreatePageType TINYINT,TgtPageID VARCHAR(200),UsrNm VARCHAR(200),UsrPwd VARCHAR(200),UsrPk BIGINT,VerFlowPk BIGINT,CurVerFlowPk BIGINT,
		HisPK BIGINT, DblEntry INT, CurBfwFk  BIGINT, IsRoleQc TINYINT, BrnchFk BIGINT, PrdFk BIGINT,GrpFk BIGINT
	)
	CREATE TABLE #PendingProcess
	(
		xx_id BIGINT,DataPk BIGINT, Cd VARCHAR(50), KeyDpdFk BIGINT, HisPk BIGINT
	)
	CREATE TABLE #DashDtls
	(
		LedFk BIGINT,BfwFk BIGINT, LeadNm VARCHAR(100), BpmBranchFk BIGINT, PCd VARCHAR(100), PrdNm VARCHAR(100), 
		LeadID VARCHAR(100), Roles VARCHAR(100),PrdFk BIGINT,AgtNm VARCHAR(100),AgtFk BIGINT, Branch VARCHAR(100),
		AppNo VARCHAR(100), ServerDt VARCHAR(20), Cd VARCHAR(50), PrdGrpFk BIGINT,
		PrdIcon Varchar(50), DpdFk BIGINT, HisPk BIGINT, GrpCd VARCHAR(50)
	)
	CREATE TABLE #AgtJobDtls
	( 
		LajPk BIGINT,ServiceType TINYINT,LeadId VARCHAR(50),
		LajLedFk BIGINT,LajAgtFK BIGINT,AgentName VARCHAR(100),AgentJob VARCHAR(100),AgtPk BIGINT,
		AgtJobDt BIGINT
	)
	CREATE TABLE #Agtjobrefdtls
	(
		LedFk BIGINT, LeadNm VARCHAR(200), PCd VARCHAR(100), PrdNm VARCHAR(100), LeadID VARCHAR(100), PrdFk BIGINT,AgtNm VARCHAR(100), AgtFk BIGINT,Branch VARCHAR(100),
		AppNo VARCHAR(100), ServerDt VARCHAR(100),LajFk BIGINT,ServiceType TINYINT,AgtLeadId VARCHAR(50),
		LajLedFk BIGINT,LajAgtFK BIGINT,JobAgentName VARCHAR(100),AgentJob VARCHAR(100),AppName VARCHAR(100),Pk BIGINT, 
		DueDys VARCHAR(200),bg VARCHAR(20),LfjPk BIGINT, HisPk BIGINT, GrpCd VARCHAR(50),DpdFk BIGINT
	)
	
	IF @ProcessJSON !='[]' AND @ProcessJSON != ''
		BEGIN
			INSERT INTO #GlobalDetails
			EXEC PrcParseJSON @ProcessJSON,'FlowFk,FlowXml,ElemId,CurPage,FwdDataPk,CreatePageType,TgtPageID,UsrNm,UsrPwd,UsrPk,VerFlowPk,CurVerFlowPk,HisPK,DblEntry,CurProcFk,IsRoleQc,BrnchFk,PrdFk,GrpFk'
			
			SELECT @IsRoleQc = IsRoleQc,@FwdDataPk = FwdDataPk, @BrnchFk = BrnchFk, @PrdFk = PrdFk, @GrpFk = GrpFk FROM #GlobalDetails
		END
	IF @LdDtls != '[]' AND @LdDtls != ''
		BEGIN
			--UsrFk,PcPk,FlowNm,FlowPk,SbsdFk,PagePk,Pg_status,DataPk,BfwFk,BpmBranchFk,ExecUsr,ExecDt,ExecTm,Cd,KeyDpdFk
			INSERT INTO #PendingProcess
			EXEC PrcParseJSON @LdDtls,'DataPk,Cd,KeyDpdFk,HisPk'
		END
		
	BEGIN TRY
		IF @@TRANCOUNT = 0
			SET @TranCount = 1
			
	IF @TranCount = 1
		  BEGIN TRAN	
		  	
			IF @Action = 'USR_LOGIN'
				BEGIN
					SELECT @UsrNm = UsrNm FROM #GlobalDetails
					SELECT @UsrPwd = UsrPwd FROM #GlobalDetails
					
					SELECT	@UsrPk =  UsrPk 
					FROM	GenUsrMas(NOLOCK) 
					WHERE	UsrNm = @UsrNm AND dbo.gefgGetDecPass(UsrPwd) = @UsrPwd AND UsrDelid = 0
					
					
					IF ISNULL(@UsrPk,0) > 0
						BEGIN
							SELECT	UsrDispNm, UsrPk  FROM GenUsrMas(NOLOCK) 
							WHERE	UsrPk = @UsrPk
							
							SELECT		RolLvlNo 'Role'
							FROM		GenUsrRoleDtls (NOLOCK) 
							JOIN		GenRole(NOLOCK) ON RolPk = UrdRolFk AND RolDelid = 0
							WHERE		UrdUsrFk = @UsrPk AND UrdDelid = 0
							GROUP BY	RolLvlNo
						END
				END	
			
			IF @Action = 'LEAD_DTLS'
				BEGIN
					SELECT	LedPk 'LeadPk', LedBGeoFk 'BrnchFk', GeoNm 'Branch'
					FROM	LosLead(NOLOCK)
					JOIN	GenGeoMas(NOLOCK) ON GeoPk = LedBGeoFk AND GeoDelid = 0
					WHERE	LedPk = ISNULL(@FwdDataPk,LedPk)
				END
			
			IF @Action = 'GETLEAD'
				BEGIN
					SELECT		A.LedPk 'LedPk', A.LedId 'LedId', A.LedNm 'LedNm',  C.GeoNm 'Branch',
								CASE ISNULL(LedPrdFk, 0) WHEN 0 THEN GrpNm ELSE PrdNm END 'PrdNm', 
								CASE ISNULL(LedPrdFk, 0) WHEN 0 THEN GrpIconCls ELSE PrdIcon END 'PrdIcon'
					FROM		LosLead A(NOLOCK)
					LEFT JOIN	GenPrdMas B(NOLOCK) ON A.LedPrdFk = ISNULL(B.PrdPk,0) AND A.LedDelId = 0
					LEFT JOIN	GenLvlDefn D(NOLOCK) ON D.GrpPk = CASE ISNULL(A.LedPrdFk,0) WHEN 0 THEN A.LedPGrpFk ELSE B.PrdGrpFk END AND GrpDelId = 0
					JOIN		GenGeoMas C(NOLOCK) ON A.LedBGeoFk = C.GeoPk AND C.GeoDelid = 0
					WHERE		LedDelid = 0
				END
			
			IF @Action = 'CMP_CONFIG'
				BEGIN
					SELECT @CmpFk = CmpPk FROM GenCmpMas(NOLOCK)
					
					SELECT	ISNULL(ccfobjname,'') 'ConfigCd', dbo.gefgGetCmpCnfgVal(ccfobjname,@CmpFk) 'ConfigVal'
					FROM	GenCmpConfigHdr(NOLOCK)
					WHERE	ccfDelid = 0
				END

			IF @Action = 'CMP_CONFIG_POLICY'
				BEGIN
					SELECT @CmpFk = CmpPk FROM GenCmpMas(NOLOCK)
					
					SELECT	ISNULL(ccfobjname,'') 'ConfigCd', GbpVal 'ConfigVal'
					FROM	GenCmpConfigHdr(NOLOCK)
					JOIN	GenBrnchPolicy(NOLOCK) ON GbpccfFk = ccfPk AND GbpBGeoFk = ISNULL(@BrnchFk,0) 
					AND		(GbpPrdFk IS NULL OR GbpPrdFk = ISNULL(@PrdFk,0))
					AND		(GbpGrpFk IS NULL OR GbpGrpFk = ISNULL(@GrpFk,0)) AND GbpDelid = 0
					WHERE	ccfObjname = @ConfigCd AND ccfDelid = 0
				END
				
			IF @Action IN('PENDING_LD_DTLS','PENDING_LD_DTLS_ADM')
				BEGIN
						
					INSERT INTO #DashDtls
					(
					  LedFk, LeadNm , LeadID,  PCd, PrdNm, PrdFk,AgtNm,  AgtFk,Branch , AppNo, ServerDt,
					  PrdGrpFk,PrdIcon,DpdFk,Cd, HisPk ,GrpCd
					)
					SELECT	DISTINCT DataPk, LedNm 'LeadNm' , LedId + CASE ISNULL(LsnSancNo,'') WHEN '' THEN '' ELSE '<br/>' + LsnSancNo END 'LeadID',
								CASE ISNULL(LedPrdFk, 0) WHEN 0 THEN GrpCd ELSE PrdCd END 'PrdCd', 
								CASE ISNULL(LedPrdFk, 0) WHEN 0 THEN GrpNm ELSE PrdNm END 'PrdNm',  
								CASE ISNULL(LedPrdFk, 0) WHEN 0 THEN GrpPk ELSE PrdPk END 'PrdFk',
								ISNULL(AgtFName,'') + ' ' +  ISNULL(AgtMName,'') + ' ' + ISNULL(AgtLName,'') 'AgtNm', AgtPk 'AgtFk',
								GeoNm 'Branch', ISNULL(AppAppNo,LedId) 'AppNo', dbo.gefgDMY(@CurDt) 'ServerDt',
								GrpPk 'GrpFk',CASE ISNULL(LedPrdFk, 0) WHEN 0 THEN GrpIconCls ELSE PrdIcon END 'PrdIcon',ISNULL(KeyDpdFk,0),Cd,
								HisPk,GrpCd
					FROM		#PendingProcess
					JOIN		LosLead(NOLOCK) ON LedPk = DataPk
					LEFT JOIN	LosSanction(NOLOCK) ON LsnPk = KeyDpdFk AND LsnDelid = 0
					JOIN		GenAgents(NOLOCK) ON AgtPk = LedAgtFk AND AgtDelid = 0
					LEFT JOIN	GenPrdMas(NOLOCK) ON PrdPk = ISNULL(LsnPrdFk,LedPrdFk) AND PrdDelId=0
					LEFT JOIN	GenLvlDefn (NOLOCK) ON GrpPk = CASE ISNULL(LedPrdFk,0) WHEN 0 THEN LedPGrpFk ELSE PrdGrpFk END AND GrpDelId = 0
					JOIN		GenGeoMas(NOLOCK) ON LedBGeoFk = GeoPk AND GeoDelid = 0
					LEFt JOIN	LosApp(NOLOCK) ON LedPk = AppLedFk 

					-- Dashboard Select
					SELECT		LedFk, LeadNm, PCd, PrdNm, LeadID, PrdFk,AgtNm,  AgtFk,Branch , AppNo, ServerDt,
								PrdGrpFk,PrdIcon,HisPk,DpdFk,GrpCd
					FROM		#DashDtls
					WHERE		Cd NOT IN ('FIR','FIO','DV','CF','LV','TV','FIS')

					IF @IsRoleQc = 1
						BEGIN
							INSERT INTO #AgtJobDtls(LajPk,ServiceType,LeadId,LajLedFk,LajAgtFK,AgentName,AgentJob,AgtPk,AgtJobDt)
							SELECT	LajPk 'LajPk', LajSrvTyp 'ServiceType', LedId 'LeadId',LajLedFk, LajAgtFK,
									ISNULL(AgtFName,'') + ' ' + ISNULL(AgtMName,'') + ' ' + ISNULL(AgtLName,'') 'AgentName',
									CASE	WHEN LajSrvTyp = 0 THEN 'FIR' WHEN LajSrvTyp = 1 THEN 'FIO'
											WHEN LajSrvTyp = 2 THEN 'DV'WHEN LajSrvTyp = 3 THEN 'CF'
											WHEN LajSrvTyp = 4 THEN 'LV' WHEN LajSrvTyp = 5 THEN 'TV' 
											WHEN LajSrvTyp = 6 THEN 'FIS' END 'AgentJob',AgtPk 'AgtPk',
											DATEDIFF(DAY,@CurDt,LajJobDt)
							FROM	LosAgentJob(NOLOCK)
							JOIN	GenAgents (NOLOCK) ON AgtPk = LajAgtFk	AND AgtDelId = 0
							JOIN	LosLead (NOLOCK) ON LedPk = LajLedFk AND LedDelid = 0
							WHERE	EXISTS(SELECT 'X' FROM #DashDtls WHERE LajLedFk = LedFk AND Cd IN ('FIS','FIR','FIO','DV','CF','LV','TV'))
							AND		LajDelid = 0
							
						-- Agent Select
							INSERT INTO #Agtjobrefdtls
							( 
								LedFk,LeadNm,PCd,PrdNm,LeadID,PrdFk,AgtNm,AgtFk,Branch,AppNo,ServerDt,
								LajFk,ServiceType,AgtLeadId,LajLedFk,LajAgtFK,JobAgentName,AgentJob,AppName,
								Pk,DueDys,bg,LfjPk,HisPk,GrpCd,DpdFk
							)
							SELECT  LedFk, LeadNm,PCd, PrdNm, LeadID, PrdFk,AgtNm, AgtFk,Branch,AppNo, ServerDt,
									LajPk 'LajFk',ServiceType,AgtLeadId,LajLedFk,LajAgtFK,AgentName,AgentJob,AppName,Pk, 
									CASE WHEN AgtJobDt >=0 THEN 'Due ' + CAST(ABS(AgtJobDt) AS VARCHAR) + ' day(s)' 
										ELSE 'Overdue ' + CAST(ABS(AgtJobDt) AS VARCHAR) + ' day(s)' END 'DueDys',
									CASE WHEN AgtJobDt >= 0 THEN 'bg3' ELSE 'bg2' END 'bg', ISNULL(LfjPk,0) 'LfjFk',
									HisPk,GrpCd,DpdFk
							FROM	#DashDtls
							JOIN
							(    
								SELECT  LajPk,ServiceType,LeadId 'AgtLeadId',LajLedFk,LajAgtFK,AgentName,AgentJob,
										LavNm 'AppName',LavPk 'Pk',AgtJobDt 'AgtJobDt'
								FROM	#AgtJobDtls
								JOIN	LosAgentVerf (NOLOCK)	ON LavLajFk = LajPk	AND LavDelId = 0	
								WHERE	ServiceType IN(0,1,2,3)
									UNION	ALL
								SELECT	LajPk,ServiceType, LeadId 'AgtLeadId', LajLedFk,AgtPk, AgentName, AgentJob,
										LedNm 'AppName',LpvPk 'Pk',AgtJobDt 'AgtJobDt'
								FROM	#AgtJobDtls (NOLOCK)
								JOIN	LosLead (NOLOCK) ON LedPk = LajLedFk AND LedDelId  = 0
								JOIN	LosAgentPrpVerf (NOLOCK) ON LpvLajFk = LajPk AND LpvDelId = 0
								WHERE	ServiceType IN(4,5)
									UNION ALL
								SELECT	LajPk,ServiceType, LeadId 'AgtLeadId', LajLedFk,AgtPk, AgentName, AgentJob,
										QDEFstNm 'AppName',LslPk 'Pk',AgtJobDt 'AgtJobDt'
								FROM	#AgtJobDtls (NOLOCK)
								JOIN	LosQDE (NOLOCK) ON QDEActor = 0 AND QDELedFk = LajLedFk AND QDEDelId  = 0
								JOIN	LosSeller (NOLOCK) ON LslLedFk = LajLedFk AND LslDelId = 0 AND ISNULL(LslSelTrig,'') = 'Y' 
														   AND LajAgtFK = LslAgtFk  
								WHERE	ServiceType IN(6)
							)A ON LedFk = LajLedFk AND Cd = AgentJob
							LEFT JOIN	LosAgentFBJob(NOLOCK) ON LfjLajFk = LajPk 
							AND Pk = CASE WHEN ServiceType IN (0,1,2,3) THEN LfjLavFk 
										  WHEN ServiceType IN (4,5) THEN LfjLpvFk
										  WHEN ServiceType IN (6) THEN LfjLslFk
										  ELSE Pk END
							WHERE		ISNULL(LfjJobSts,0) = CASE @Action WHEN 'PENDING_LD_DTLS_ADM' THEN ISNULL(LfjJobSts,0) ELSE 0 END
							ORDER BY	LajLedFk DESC , ServiceType 
							
							SELECT * FROM #Agtjobrefdtls													
							SELECT	DISTINCT LeadID,LedFk,LeadNm,PrdNm,LajLedFk,PCd
							FROM	#Agtjobrefdtls
						END
						ELSE
							SELECT TOP 0 NULL
				END

	IF @Trancount = 1 AND @@TRANCOUNT = 1
		COMMIT TRAN
		
	END TRY
	BEGIN CATCH
		IF @Trancount = 1 AND @@TRANCOUNT = 1
			ROLLBACK TRAN	
		SELECT	@ErrMsg = ERROR_MESSAGE(),-- + ',' + ERROR_PROCEDURE() + ':' + RTRIM(ERROR_LINE()),

				@ErrSeverity = ERROR_SEVERITY()

		RAISERROR('%s', @ErrSeverity, 1,@ErrMsg) 		

		RETURN
	END CATCH
END
