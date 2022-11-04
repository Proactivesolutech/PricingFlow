ALTER PROCEDURE PrcShfl_AgentMas_help
(
@AgentName VARCHAR(MAX)	= NULL,
@code BIGINT			= NULL,
@Extra VARCHAR(MAX)=NULL
)
AS
BEGIN 

-- Lead - 7
-- FIO,FIR,FIS - 0
-- DV - 2
-- CF - 3
-- TV - 5
-- LV - 4

	DECLARE @BrnchFk BIGINT; 
	 CREATE TABLE #TEMP(XX_ID BIGINT,BranchFk BIGINT)

	IF @Extra != '' AND @Extra != '[]'
	 BEGIN
           INSERT INTO  #TEMP
		   EXEC PrcParseJSON @Extra,'BrnchFk'
	 END
	 
	 
					IF ISNULL(@AgentName,'0') = '0'
					BEGIN
						SELECT  ISNULL(AgtFNAme,'') + 
								CASE ISNULL(AgtMNAme,'') WHEN '' THEN ' ' ELSE ' ' + ISNULL(AgtMNAme,'') END + 
								CASE ISNULL(AgtLNAme,'') WHEN '' THEN '' ELSE ' ' + ISNULL(AgtLNAme,'') END 'AgentName',
								AgtCd 'Code',AgtPk 'Agtpk'
						FROM    GenAgents(NOLOCK)
						JOIN	GenAgentSErv(NOLOCK) ON AgsAgtFk = AgtPk AND AgsSvrTyp = ISNULL(@code,'0') AND AgtDelid = 0 
						AND		EXISTS
						(
							SELECT 'X' FROM GenAgentUnit (NOLOCK) WHERE AguAgtFk = AgtPk AND AgtDelid = 0 
							AND EXISTS(SELECT 'X' FROM #TEMP WHERE BranchFk = AguBGeoFk)
						) 
						WHERE	AgtStsFlg = 'L' AND AgtDelId = 0    
					END
					ELSE
					BEGIN
					    SELECT	ISNULL(AgtFNAme,'') + 
								CASE ISNULL(AgtMNAme,'') WHEN '' THEN ' ' ELSE ' ' + ISNULL(AgtMNAme,'') END + 
								CASE ISNULL(AgtLNAme,'') WHEN '' THEN '' ELSE ' ' + ISNULL(AgtLNAme,'') END 'AgentName',
								AgtCd 'Code',AgtPk 'Agtpk'
			     	    FROM    GenAgents(NOLOCK)
						JOIN	GenAgentSErv(NOLOCK) ON AgsAgtFk = AgtPk AND AgsSvrTyp = ISNULL(@code,'0') 
						AND		(ISNULL(AgtFNAme,'') LIKE  '%' + @AgentName + '%' OR ISNULL(AgtMNAme,'') LIKE  '%' + @AgentName + '%' 
								OR ISNULL(AgtLNAme,'') LIKE  '%' + @AgentName + '%') AND AgtDelid = 0 
						AND		EXISTS
						(
							SELECT 'X' FROM GenAgentUnit (NOLOCK) WHERE AguAgtFk = AgtPk AND AgtDelid = 0 
							AND EXISTS(SELECT 'X' FROM #TEMP WHERE BranchFk = AguBGeoFk)
						) 
						WHERE	AgtStsFlg = 'L' AND AgtDelId = 0    
					END
END





