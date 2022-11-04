IF OBJECT_ID('PrcShflleadagenthelp','P') IS NOT NULL
DROP PROC PrcShflleadagenthelp
GO
CREATE PROCEDURE PrcShflleadagenthelp
(
@Agntname VARCHAR(MAX)	= NULL,
@agnt VARCHAR(MAX)	= NULL
)
AS
BEGIN 
    IF ISNULL(@Agntname,'0') = '0'
	BEGIN
	SELECT	AgtFName + '' + AgtMName + '' + AgtLName 'AgentName',AgtPk 'AgtPk' 
	FROM	GenAgents (NOLOCK) 
	WHERE	AgtDelId = 0 
	END
	ELSE
	BEGIN
	SELECT	AgtFName + '' + AgtMName + '' + AgtLName 'AgentName',AgtPk 'AgtPk' 
	FROM	GenAgents (NOLOCK) 
	WHERE	AgtDelId = 0 AND AgtFName LIKE  '%' + @Agntname + '%' 
	END
END


 