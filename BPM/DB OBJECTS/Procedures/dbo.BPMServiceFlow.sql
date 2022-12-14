USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[BPMServiceFlow]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC BPMServiceFlow N'EnqRej',N''
CREATE PROCEDURE [dbo].[BPMServiceFlow]
(
	@FLAG    	VARCHAR(100),
	@XMLDoc		TEXT	=	NULL,
	@LOCID		BIGINT	=	NULL
)
 AS
 BEGIN
  SET NOCOUNT ON; 
	DECLARE @FlowFk BIGINT,@DcdPk BIGINT,@RejFk BIGINT,@EndFk BIGINT,@AcptFk BIGINT,@RejFk1 BIGINT,@QcAprv BIGINT,@QcAcpt BIGINT,@FlowFk2 BIGINT
	SELECT @FlowFk = 2404--,@FlowFk2 = 2275
	
	DECLARE	@XMLID INT, @PERD VARCHAR(10), @LvlNo int, @CNT1 int, @CNT2 INT, @CNT3 INT,@RolNm VARCHAR(100),
			@YEAR VARCHAR(10), @MONTH VARCHAR(10), @ACC_TYP VARCHAR(10), @TOGGLE VARCHAR(200), @selection varchar(200),
			@Location VARCHAR(100),@GeoFk BIGINT
	 
	 CREATE TABLE #ResultTbl(Location VARCHAR(100),Task VARCHAR(100),Total VARCHAR(20),nxtlvl VARCHAR(10))

	 CREATE TABLE #GeoMas(Branch VARCHAR(100),Zone VARCHAR(100),State VARCHAR(100),Center VARCHAR(100),BPk BIGINT,ZPk BIGINT,SPk BIGINT,CPk BIGINT)
			
			INSERT INTO #GeoMas
			SELECT B.GeoNm 'Branch',Z.GeoNm 'Zone',S.GeoNm 'State',C.GeoNm 'Center',B.GeoPk 'BPk',Z.GeoPk 'ZPk',S.GeoPk 'SPk',C.GeoPk 'CPk' FROM GenGeoMap
				JOIN GenGeoMas B ON GemGeoBfk = B.GeoPk AND B.GeoDelId = 0 AND GemDelId = 0
				JOIN GenGeoMas Z ON GemGeoZfk = Z.GeoPk AND Z.GeoDelId = 0
				JOIN GenGeoMas S ON GemGeoSfk = S.GeoPk AND S.GeoDelId = 0
				JOIN GenGeoMas C ON GemGeoCfk = C.GeoPk AND C.GeoDelId = 0

	 IF @XMLDoc IS NOT NULL and nullif(cast(@XMLDoc as varchar(1000)),'') is not null
		BEGIN
		EXEC SP_XML_PREPAREDOCUMENT @XMLID OUTPUT, @XMLDoc
		
			SELECT @PERD = MAX(PERIOD)
			FROM OPENXML (@XMLID, '/input/item',2)
			WITH (PERIOD  varchar(10),sel VARCHAR(20)
			   ) WHERE sel = 'true' ;

			SELECT @CNT1 = count(*)
		    FROM OPENXML (@XMLID, '/input/item',2)
		    WITH (fieldName  varchar(100),fieldValue VARCHAR(100)
			) WHERE fieldName = 'Location'
           
		IF @FLAG = 'Task'
		BEGIN
		   SELECT @CNT1 = count(*)
		    FROM OPENXML (@XMLID, '/input/item',2)
		    WITH (fieldName  varchar(20),fieldValue VARCHAR(20)
			) WHERE fieldName = 'RolNm'

			IF @CNT1 > 0
			BEGIN
				SELECT @RolNm = fieldValue FROM OPENXML (@XmlId, '/input/item',2)
				WITH (fieldName  varchar(100),fieldValue VARCHAR(100)
					) WHERE fieldName = 'RolNm'
			END
		END
			IF @CNT1 > 0
			BEGIN
				SELECT @LvlNo = fieldValue FROM OPENXML (@XmlId, '/input/item',2)
				WITH (fieldName  varchar(20),fieldValue VARCHAR(20)
					) WHERE fieldName = 'nxtLvl'

				SELECT @Location = fieldValue FROM OPENXML (@XmlId, '/input/item',2)
				WITH (fieldName  varchar(100),fieldValue VARCHAR(100)
					) WHERE fieldName = 'Location'

				SELECT @GeoFk = fieldValue FROM OPENXML (@XmlId, '/input/item',2)
				WITH (fieldName  varchar(20),fieldValue VARCHAR(20)
					) WHERE fieldName = 'GeoPk'

				SELECT @selection = fieldValue FROM OPENXML (@XmlId, '/input/item',2)
				WITH (fieldName  varchar(20),fieldValue VARCHAR(20)
					) WHERE fieldName = 'Id'
			END    

		EXEC SP_XML_REMOVEDOCUMENT @XMLID
		
		
		END

	IF @FLAG = 'TotalCnt'
	BEGIN

		IF ISNULL(@LvlNo,0) > 4
		SELECT @LvlNo = 0 , @GeoFk = NULL

			
			--SELECT	CASE ISNULL(@LvlNo,1) WHEN 1 THEN GeoNm ELSE BfwLabel END AS 'Location',CASE ISNULL(@LvlNo,1) WHEN 1 THEN '' ELSE BfwLabel END AS 'Task',
			--		COUNT(GeoNm) 'Total',ISNULL(@LvlNo,0)+1 'nxtLvl' 
			--	FROM	BpmNextOpUsr(NOLOCK)
			--	JOIN	BpmExec (NOLOCK) ON BnoBexFk = BexPk AND BexDelid = 0	
			--	JOIN	GenUsrMas(NOLOCK) ON UsrPk = BexUsrFk AND UsrDelId = 0	
			--	JOIN	BpmUiDefn(NOLOCK) ON BudPk = BnoBudFk AND BudDelid = 0
			--	JOIN	BpmFlow(NOLOCK) ON BnoBfwFk = BfwPk AND BfwDelId = 0
			--	JOIN	GenGeoMas(NOLOCK) ON GeoPk = BexBrnchFk
			--	WHERE	NOT EXISTS (SELECT NULL FROM BpmExecStatus(NOLOCK) WHERE BesBexFk = BnoBexFk AND BesDelId = 0)
			--	AND		BnoBvmFk > 2399 AND  ((ISNULL(@LvlNo,1) = 1  ) OR (ISNULL(@LvlNo,1) = 2 AND GeoNm = @Location  ))
			--	GROUP BY  CASE ISNULL(@LvlNo,1) WHEN 1 THEN GeoNm ELSE BfwLabel END,CASE ISNULL(@LvlNo,1) WHEN 1 THEN '' ELSE BfwLabel END
--SELECT @GeoFk

--SELECT * FROM #GeoMas

				--SELECT	CASE ISNULL(@LvlNo,0) WHEN 0 THEN Center WHEN 1 THEN State WHEN 2 THEN Zone WHEN 3 THEN Branch WHEN 4 THEN Branch END 'Location' ,
				--		CASE WHEN ISNULL(@LvlNo,0)> 3 THEN BfwLabel ELSE '' END AS 'Task',
				--		CASE ISNULL(@LvlNo,0) WHEN 0 THEN COUNT(Center) WHEN 1 THEN COUNT(State) 
				--							  WHEN 2 THEN COUNT(Zone) WHEN 3 THEN COUNT(Branch) 
				--							  WHEN 4 THEN COUNT(Branch) END 'Total',ISNULL(@LvlNo,0)+1 'nxtLvl' ,
				--		CASE ISNULL(@LvlNo,0) WHEN 0 THEN CPk WHEN 1 THEN SPk WHEN 2 THEN ZPk WHEN 3 THEN BPk WHEN 4 THEN BPk END 'GeoPk'
				--FROM	BpmNextOpUsr(NOLOCK)
				--JOIN	BpmExec (NOLOCK) ON BnoBexFk = BexPk AND BexDelid = 0	
				--JOIN	GenUsrMas(NOLOCK) ON UsrPk = BexUsrFk AND UsrDelId = 0	
				--JOIN	BpmUiDefn(NOLOCK) ON BudPk = BnoBudFk AND BudDelid = 0
				--JOIN	BpmFlow(NOLOCK) ON BnoBfwFk = BfwPk AND BfwDelId = 0
				--JOIN	#GeoMas ON  ISNULL(@GeoFk,BexBrnchFk) = CASE ISNULL(@LvlNo,0) WHEN 0 THEN BPk WHEN 1 THEN CPk WHEN 2 THEN SPk 
				--																	  WHEN 3 THEN ZPk WHEN 4 THEN BPk END AND BexBrnchFk = BPk 
				--WHERE	NOT EXISTS (SELECT NULL FROM BpmExecStatus(NOLOCK) WHERE BesBexFk = BnoBexFk AND BesDelId = 0)
				--AND		BnoBvmFk > 2399 AND ((ISNULL(@LvlNo,0) = 0)
				--         OR (ISNULL(@LvlNo,0) = 1 AND CPk = @GeoFk  ) OR (ISNULL(@LvlNo,0) = 2 AND SPk = @GeoFk  )
				--		 OR (ISNULL(@LvlNo,0) = 3 AND ZPk = @GeoFk  ) OR (ISNULL(@LvlNo,0) = 4 AND BPk = @GeoFk  ))
				--GROUP BY  CASE ISNULL(@LvlNo,0) WHEN 0 THEN Center WHEN 1 THEN State WHEN 2 THEN Zone WHEN 3 THEN Branch WHEN 4 THEN Branch END,
				--		  CASE WHEN ISNULL(@LvlNo,0)> 3 THEN BfwLabel ELSE '' END,
				--		  CASE ISNULL(@LvlNo,0) WHEN 0 THEN CPk WHEN 1 THEN SPk WHEN 2 THEN ZPk WHEN 3 THEN BPk WHEN 4 THEN BPk END

				SELECT	CASE ISNULL(@LvlNo,0) WHEN 0 THEN Center WHEN 1 THEN State WHEN 2 THEN Zone WHEN 3 THEN Branch WHEN 4 THEN Branch END 'Location' ,
						CASE WHEN ISNULL(@LvlNo,0)> 3 THEN BfwLabel ELSE '' END AS 'Task',
						CASE ISNULL(@LvlNo,0) WHEN 0 THEN COUNT(Center) WHEN 1 THEN COUNT(State) 
											  WHEN 2 THEN COUNT(Zone) WHEN 3 THEN COUNT(Branch) 
											  WHEN 4 THEN COUNT(Branch) END 'Total',ISNULL(@LvlNo,0)+1 'nxtLvl' ,
						CASE ISNULL(@LvlNo,0) WHEN 0 THEN CPk WHEN 1 THEN SPk WHEN 2 THEN ZPk WHEN 3 THEN BPk WHEN 4 THEN BPk END 'GeoPk'
				FROM	BpmNextOpUsr(NOLOCK)
				JOIN	BpmExec (NOLOCK) ON BnoBexFk = BexPk AND BexDelid = 0	
				JOIN	GenUsrMas(NOLOCK) ON UsrPk = BexUsrFk AND UsrDelId = 0	
				JOIN	GenUsrRoleDtls(NOLOCK) ON UrdUsrFk = UsrPk AND UrdDelId = 0
				JOIN	GenRole(NOLOCK) ON RolPk = UrdRolFk AND UrdDelId = 0
				JOIN	BpmUiDefn(NOLOCK) ON BudPk = BnoBudFk AND BudDelid = 0
				JOIN	BpmFlow(NOLOCK) ON BnoBfwFk = BfwPk AND BfwDelId = 0
				JOIN	#GeoMas ON  ISNULL(@GeoFk,BexBrnchFk) = CASE ISNULL(@LvlNo,0) WHEN 0 THEN BPk WHEN 1 THEN CPk WHEN 2 THEN SPk 
																					  WHEN 3 THEN ZPk WHEN 4 THEN BPk END AND BexBrnchFk = BPk 
				WHERE	NOT EXISTS (SELECT NULL FROM BpmExecStatus(NOLOCK) WHERE BesBexFk = BnoBexFk AND BesDelId = 0)
				AND		BnoBvmFk > 2399 AND ((ISNULL(@LvlNo,0) = 0)
				         OR (ISNULL(@LvlNo,0) = 1 AND CPk = @GeoFk  ) OR (ISNULL(@LvlNo,0) = 2 AND SPk = @GeoFk  )
						 OR (ISNULL(@LvlNo,0) = 3 AND ZPk = @GeoFk  ) OR (ISNULL(@LvlNo,0) = 4 AND BPk = @GeoFk  ))
				GROUP BY  CASE ISNULL(@LvlNo,0) WHEN 0 THEN Center WHEN 1 THEN State WHEN 2 THEN Zone WHEN 3 THEN Branch WHEN 4 THEN Branch END,
						  CASE WHEN ISNULL(@LvlNo,0)> 3 THEN BfwLabel ELSE '' END,
						  CASE ISNULL(@LvlNo,0) WHEN 0 THEN CPk WHEN 1 THEN SPk WHEN 2 THEN ZPk WHEN 3 THEN BPk WHEN 4 THEN BPk END

	END
	IF @FLAG = 'GRID'
	BEGIN
	IF ISNULL(@LvlNo,0) > 4
		SELECT @LvlNo = 0 , @GeoFk = NULL

	IF ISNULL(@LvlNo,0)<>0
				SELECT	CASE ISNULL(@LvlNo,0) WHEN 0 THEN '' ELSE RolNm END 'RolNm',
						CASE ISNULL(@LvlNo,0) WHEN 0 THEN COUNT(Center) WHEN 1 THEN COUNT(State) 
											  WHEN 2 THEN COUNT(Zone) WHEN 3 THEN COUNT(Branch) 
											  WHEN 4 THEN COUNT(Branch) END 'Total',ISNULL(@LvlNo,0) 'nxtLvl' ,@GeoFk 'GeoPk'
						--CASE ISNULL(@LvlNo,0) WHEN 0 THEN CPk WHEN 1 THEN SPk WHEN 2 THEN ZPk WHEN 3 THEN BPk WHEN 4 THEN BPk END 'GeoPk',
				FROM	BpmNextOpUsr(NOLOCK)
				JOIN	BpmExec (NOLOCK) ON BnoBexFk = BexPk AND BexDelid = 0	
				JOIN	GenUsrMas(NOLOCK) ON UsrPk = BexUsrFk AND UsrDelId = 0	
				JOIN	GenUsrRoleDtls(NOLOCK) ON UrdUsrFk = UsrPk AND UrdDelId = 0
				JOIN	GenRole(NOLOCK) ON RolPk = UrdRolFk AND UrdDelId = 0
				JOIN	BpmUiDefn(NOLOCK) ON BudPk = BnoBudFk AND BudDelid = 0
				JOIN	BpmFlow(NOLOCK) ON BnoBfwFk = BfwPk AND BfwDelId = 0
				JOIN	#GeoMas ON  ISNULL(@GeoFk,BexBrnchFk) = CASE ISNULL(@LvlNo,0) WHEN 0 THEN BPk WHEN 1 THEN CPk WHEN 2 THEN SPk 
																					  WHEN 3 THEN ZPk WHEN 4 THEN BPk END AND BexBrnchFk = BPk 
				WHERE	NOT EXISTS (SELECT NULL FROM BpmExecStatus(NOLOCK) WHERE BesBexFk = BnoBexFk AND BesDelId = 0)
				AND		BnoBvmFk > 2399 AND ((ISNULL(@LvlNo,0) = 0)
				         OR (ISNULL(@LvlNo,0) = 1 AND CPk = @GeoFk  ) OR (ISNULL(@LvlNo,0) = 2 AND SPk = @GeoFk  )
						 OR (ISNULL(@LvlNo,0) = 3 AND ZPk = @GeoFk  ) OR (ISNULL(@LvlNo,0) = 4 AND BPk = @GeoFk  ))
				GROUP BY  --CASE ISNULL(@LvlNo,0) WHEN 0 THEN Center WHEN 1 THEN State WHEN 2 THEN Zone WHEN 3 THEN Branch WHEN 4 THEN Branch END,
						  --CASE WHEN ISNULL(@LvlNo,0)> 3 THEN BfwLabel ELSE '' END,
						  --CASE ISNULL(@LvlNo,0) WHEN 0 THEN CPk WHEN 1 THEN SPk WHEN 2 THEN ZPk WHEN 3 THEN BPk WHEN 4 THEN BPk END,
						  CASE ISNULL(@LvlNo,0) WHEN 0 THEN '' ELSE RolNm END

	END
	IF @FLAG = 'Task'
	BEGIN
	IF ISNULL(@LvlNo,0)<>0
				SELECT	CASE ISNULL(@LvlNo,0) WHEN 0 THEN Center WHEN 1 THEN State WHEN 2 THEN Zone WHEN 3 THEN Branch WHEN 4 THEN Branch END 'Location' , BfwLabel  'Task',
						CASE ISNULL(@LvlNo,0) WHEN 0 THEN COUNT(Center) WHEN 1 THEN COUNT(State) 
											  WHEN 2 THEN COUNT(Zone) WHEN 3 THEN COUNT(Branch) 
											  WHEN 4 THEN COUNT(Branch) END 'Total',ISNULL(@LvlNo,0) 'nxtLvl' ,
						CASE ISNULL(@LvlNo,0) WHEN 0 THEN CPk WHEN 1 THEN SPk WHEN 2 THEN ZPk WHEN 3 THEN BPk WHEN 4 THEN BPk END 'GeoPk'
						--CASE ISNULL(@LvlNo,0) WHEN 0 THEN '' ELSE RolNm END 'RolNm'
				FROM	BpmNextOpUsr(NOLOCK)
				JOIN	BpmExec (NOLOCK) ON BnoBexFk = BexPk AND BexDelid = 0	
				JOIN	GenUsrMas(NOLOCK) ON UsrPk = BexUsrFk AND UsrDelId = 0	
				JOIN	GenUsrRoleDtls(NOLOCK) ON UrdUsrFk = UsrPk AND UrdDelId = 0
				JOIN	GenRole(NOLOCK) ON RolPk = UrdRolFk AND UrdDelId = 0
				JOIN	BpmUiDefn(NOLOCK) ON BudPk = BnoBudFk AND BudDelid = 0
				JOIN	BpmFlow(NOLOCK) ON BnoBfwFk = BfwPk AND BfwDelId = 0
				JOIN	#GeoMas ON  ISNULL(@GeoFk,BexBrnchFk) = CASE ISNULL(@LvlNo,0) WHEN 0 THEN BPk WHEN 1 THEN CPk WHEN 2 THEN SPk 
																					  WHEN 3 THEN ZPk WHEN 4 THEN BPk END AND BexBrnchFk = BPk 
				WHERE	NOT EXISTS (SELECT NULL FROM BpmExecStatus(NOLOCK) WHERE BesBexFk = BnoBexFk AND BesDelId = 0)
				AND		BnoBvmFk > 2399 AND ((ISNULL(@LvlNo,0) = 0)
				         OR (ISNULL(@LvlNo,0) = 1 AND CPk = @GeoFk  ) OR (ISNULL(@LvlNo,0) = 2 AND SPk = @GeoFk  )
						 OR (ISNULL(@LvlNo,0) = 3 AND ZPk = @GeoFk  ) OR (ISNULL(@LvlNo,0) = 4 AND BPk = @GeoFk  )) AND RolNm = @RolNm
				GROUP BY  CASE ISNULL(@LvlNo,0) WHEN 0 THEN Center WHEN 1 THEN State WHEN 2 THEN Zone WHEN 3 THEN Branch WHEN 4 THEN Branch END,
						  BfwLabel,
						  CASE ISNULL(@LvlNo,0) WHEN 0 THEN CPk WHEN 1 THEN SPk WHEN 2 THEN ZPk WHEN 3 THEN BPk WHEN 4 THEN BPk END
						 -- CASE ISNULL(@LvlNo,0) WHEN 0 THEN '' ELSE RolNm END

					
	END
END
--exec BPMServiceFlow N'GRID',NULL,N'86566'
GO
