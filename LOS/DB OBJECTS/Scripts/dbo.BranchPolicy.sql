BEGIN TRAN


	SELECT		GbpBGeoFk, GbpccfFk, GbpPrdFk, GbpVal, GbpGrpFk, ccfobjname INTO #BrnchPolicy
	FROM		GenBrnchPolicy(NOLOCK)
	JOIN		GenCmpConfigHdr(NOLOCK) ON GbpccfFk = ccfpk AND ccfobjname IN ('gAgtTchTrig','gIMC') AND GbpDelid = 0
	WHERE		ccfDelId = 0
	GROUP BY	GbpBGeoFk, GbpccfFk, GbpPrdFk, GbpVal, GbpGrpFk, ccfobjname
	
	INSERT INTO GenBrnchPolicy
	SELECT		GeoPk, NULL, GbpccfFk, GbpVal, NEWID(),'ADMIN', GETDATE(),'ADMIN', GETDATE(),NULL,0, GbpGrpFk
	FROM		GenGeoMas Geo(NOLOCK), #BrnchPolicy T1 WHERE Geo.GeoLvlNo = 1 AND Geo.GeoDelid = 0 AND  T1.ccfobjname = 'gAgtTchTrig' AND T1.GbpBGeoFk = 52
	AND			NOT EXISTS(SELECT 'X' FROM #BrnchPolicy T2 WHERE T2.GbpBGeoFk = Geo.GeoPk)
	
	INSERT INTO GenBrnchPolicy
	SELECT		GeoPk, GbpPrdFk, GbpccfFk, GbpVal, NEWID(),'ADMIN', GETDATE(),'ADMIN', GETDATE(),NULL,0, NULL
	FROM		GenGeoMas Geo(NOLOCK), #BrnchPolicy T1 WHERE Geo.GeoLvlNo = 1 AND Geo.GeoDelid = 0 AND  T1.ccfobjname = 'gIMC' AND T1.GbpBGeoFk = 52
	AND			NOT EXISTS(SELECT 'X' FROM #BrnchPolicy T2 WHERE T2.GbpBGeoFk = Geo.GeoPk)
	
ROLLBACK TRAN