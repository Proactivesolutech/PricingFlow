USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[BPMIMPORT]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BPMIMPORT]
(
@Action		VARCHAR(20)	=	NULL,
@FlowFk		BIGINT		=	NULL,
@Bfwfk		BIGINT		=	NULL
)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @BioFk BIGINT,@KeyFk BIGINT,@KeyNm VARCHAR(30),@Lane VARCHAR(100),@UsrRoleFk BIGINT,@UsrRoleNm VARCHAR(50),@UsrNm VARCHAR(100),@UsrFk BIGINT

	CREATE TABLE #FlowTbl
	(
	TBioBfwFk BIGINT,TBioId VARCHAR(100),TBioInBfwFk BIGINT,TBioInId VARCHAR(100),
	TBioOutBfwFk BIGINT,TBioOutId VARCHAR(100),TBioPk BIGINT,TLabel VARCHAR(100),TLane VARCHAR(100)
	)
	CREATE TABLE #BpmFlowKeyTable
	(
	BKeyNm VARCHAR(100),BKeyBrnchFk BIGINT,BKeyPk BIGINT,BKeyDelId INT
	) 
	CREATE TABLE #BpmExec
	(
	BBexKeyFk BIGINT,BBexBvmFk BIGINT,BBexBioFk BIGINT,BBexBrnchFk BIGINT,BBexUsrFk BIGINT,BBexRtnBfwFk BIGINT,BBexAutoPass INT,BBexRoundNo INT,
	BBexRowId VARCHAR(100),BBexCreatedBy VARCHAR(30),BBexCreatedDt DATETIME DEFAULT GETDATE(),BBexDelFlg VARCHAR(10),BBexDelId INT
	)

	INSERT INTO #BpmFlowKeyTable
	SELECT * FROM BpmFlowKeyTable

	SELECT @KeyFk = MAX(KeyPk)+1 FROM BpmFlowKeyTable

	SELECT @keyNm = BpmNm  
	FROM BpmMas(NOLOCK)
	JOIN BpmVersions(NOLOCK) ON BpmPk = BvmBpmFk AND BvmPk = @FlowFk

	IF  ISNULL(@Bfwfk,0) = 0
	BEGIN
		SET @Action = 'E'
	END
	
	DECLARE @Pk BIGINT,@BioPk BIGINT,@Start BIGINT,@End BIGINT,@MinFk BIGINT,
			@BrnchFk BIGINT,@RowId VARCHAR(100),@CurDt DATETIME
			

	SELECT @CurDt = GETDATE(),@RowId = NEWID(),@UsrNm = 'IMPORT'

	SELECT @Start = BioPk FROM BpmObjInOut WHERE BioBvmFk = @FlowFk AND BioId LIKE '%Start%'
	SELECT @End = BioPk FROM BpmObjInOut WHERE BioBvmFk = @FlowFk AND BioId LIKE '%END%'
	
	IF @Action = 'E'
	BEGIN
		SELECT @BioPk = BioPk FROM BpmObjInOut WHERE BioBvmFk = @FlowFk AND BioId LIKE '%Start%'
		SELECT @Bfwfk = BioOutBfwFk FROM BpmObjInOut WHERE BioPk = @BioPk
		SET @Action = 'A'
	END
		
	IF @Action = 'A'
	BEGIN
		
		--SELECT * FROM BpmFlow(NOLOCK) WHERE BfwLabel = 'Start' AND BfwBvmFk = 2404

		INSERT INTO #FlowTbl
		SELECT BioBfwFk,BioId,BioInBfwFk,BioInId,BioOutBfwFk,BioOutId,BioPk,BfwLabel,BfwLaneRef  
		FROM BpmObjInOut(NOLOCK) 
		JOIN BpmFlow(NOLOCK) ON BfwPk = BioBfwFk
		WHERE BioBvmFk = @FlowFk AND BioId LIKE '%Start%'

		SELECT @BioFk = TBioPk FROM #FlowTbl
		SELECT @Lane = TLane FROM #FlowTbl WHERE  TBioPk = @BioFk

--SELECT * FROM BpmFlow(NOLOCK) WHERE  BfwLaneRef = @Lane AND BfwBvmFk = @FlowFk
SELECT @UsrRoleNm = BfwLabel FROM BpmFlow(NOLOCK) WHERE  BfwId = @Lane AND BfwBvmFk = @FlowFk
SELECT @UsrRoleFk = RolPk FROM GenRole(NOLOCK) WHERE RolNm = @UsrRoleNm AND RolDelId = 0
SELECT @UsrFk = MAX(UrdUsrFk) FROM GenUsrRoleDtls(NOLOCK) WHERE UrdRolFk = @UsrRoleFk AND UrdDelId = 0
SELECT @BrnchFk = UbdGeoFk FROM GenUsrBrnDtls(NOLOCK) WHERE UbdDelId = 0 AND UbdUsrFk = @UsrFk AND UbdDelId = 0

		INSERT INTO #BpmFlowKeyTable(BKeyNm,BKeyBrnchFk,BKeyPk,BkeyDelid)
		--OUTPUT INSERTED.*
		SELECT @keyNm,@BrnchFk ,@KeyFk,0

		SELECT @MinFk = @KeyFk

		INSERT	INTO #BpmExec
		(
			BBexKeyFk,BBexBvmFk,BBexBioFk,BBexBrnchFk,BBexUsrFk,BBexRtnBfwFk,BBexAutoPass,BBexRoundNo,
			BBexRowId,BBexCreatedBy,BBexCreatedDt,BBexDelFlg,BBexDelId
		)
		--OUTPUT INSERTED.*
		SELECT	@MinFk,@FlowFk,@BioFk,@BrnchFk,@UsrFk,NULL,0,1,@RowId,@UsrNm,@CurDt,NULL,0
		
		IF EXISTS(SELECT * FROM BpmObjInOut WHERE BioId LIKE '%END%' AND BioPk = @Bfwfk)
		BEGIN
			RETURN
		END
		
		WHILE @End <> @Bfwfk
		BEGIN
			SELECT @BioPk = BioOutBfwFk FROM BpmObjInOut 
			JOIN BpmFlow(NOLOCK) ON BfwPk = BioBfwFk
			WHERE BioBfwFk = @Bfwfk 
			
			SELECT @Bfwfk = @BioPk 

			--SELECT * FROM BpmFlow(NOLOCK) WHERE BfwLabel IN ('Reason','Quote to Customer','Stock Availability in Respective Branch')
			--SELECT * FROM BpmFlow WHERE BfwBvmFk = 2404 AND BfwLabel IN ('Reason','Quote to Customer','Stock Availability in Respective Branch')
			INSERT INTO #FlowTbl
			SELECT BioBfwFk,BioId,BioInBfwFk,BioInId,BioOutBfwFk,BioOutId,BioPk,BfwLabel,BfwLaneRef  
			FROM BpmObjInOut 
			JOIN BpmFlow(NOLOCK) ON BfwPk = BioBfwFk
			WHERE BioOutBfwFk = @Bfwfk --AND BioId LIKE '%Task%' 

			SELECT @BioFk = TBioPk FROM #FlowTbl
			SELECT @Lane = TLane FROM #FlowTbl WHERE  TBioPk = @BioFk
			SELECT @UsrRoleNm = BfwLabel FROM BpmFlow(NOLOCK) WHERE  BfwId = @Lane AND BfwBvmFk = @FlowFk
			SELECT @UsrRoleFk = RolPk FROM GenRole(NOLOCK) WHERE RolNm = @UsrRoleNm AND RolDelId = 0
			SELECT @UsrFk = MAX(UrdUsrFk) FROM GenUsrRoleDtls(NOLOCK) WHERE UrdRolFk = @UsrRoleFk AND UrdDelId = 0
			SELECT @BrnchFk = UbdGeoFk FROM GenUsrBrnDtls(NOLOCK) WHERE UbdDelId = 0 AND UbdUsrFk = @UsrFk AND UbdDelId = 0
			
			INSERT	INTO #BpmExec
			(
				BBexKeyFk,BBexBvmFk,BBexBioFk,BBexBrnchFk,BBexUsrFk,BBexRtnBfwFk,BBexAutoPass,BBexRoundNo,
				BBexRowId,BBexCreatedBy,BBexCreatedDt,BBexDelFlg,BBexDelId
			)
			--OUTPUT INSERTED.*
			SELECT	@MinFk,@FlowFk,@BioFk,@BrnchFk,@UsrFk,NULL,0,1,@RowId,@UsrNm,@CurDt,NULL,0
			
			--SELECT @Lane = BfwLaneRef FROM BpmFlow(NOLOCK) WHERE  BfwBvmFk = @FlowFk
			--SELECT @BioFk
			
		END
		
		INSERT INTO #FlowTbl
		SELECT BioBfwFk,BioId,BioInBfwFk,BioInId,BioOutBfwFk,BioOutId,BioPk,BfwLabel,BfwLaneRef
		FROM BpmObjInOut (NOLOCK)
		JOIN BpmFlow(NOLOCK) ON BfwPk = BioBfwFk 
		WHERE BioBvmFk = @FlowFk AND BioId LIKE '%End%'
		
		SELECT * FROM #FlowTbl
		SELECT * FROM #BpmExec
		--SELECT * FROM #FlowTbl WHERE TBioBfwFk > 21944 AND TBioBfwFk < 21947
		--SELECT * FROM #FlowTbl WHERE TBioBfwFk > 21944
		--SELECT * FROM #FlowTbl WHERE TBioBfwFk < 21947
		--SELECT * FROM #FlowTbl WHERE TBioBfwFk > 21947
	END
END
--SELECT * FROM GenUsrMas WHERE UsrDelId = 0
--SELECT * FROM GenRole
--SELECT * FROM GenUsrRoleDtls WHERE UrdDelId = 0
--SELECT * FROM GenUsrBrnDtls WHERE UbdDelId = 0
--SELECT * FROM BpmFlow(NOLOCK) WHERE BfwLabel IN ('yes','no') AND BfwBvmFk >= 2399 
--SELECT * FROM BpmFlow(NOLOCK) WHERE BfwBvmFk = 2399 AND BfwId LIKE '%1w%'

--SELECT * FROM BpmObjInOut(NOLOCK) WHERE BioBvmFk = 2399
--objsearch Usr
--EXEC BPMIMPORT 'E',2404
--EXEC BPMIMPORT 'E',2405
--EXEC BPMIMPORT 'E',2399
--ExclusiveGateway_1wvsn9f_zx0v



GO
