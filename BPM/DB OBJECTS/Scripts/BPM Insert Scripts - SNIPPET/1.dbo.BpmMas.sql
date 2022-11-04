SELECT  N'IF NOT EXISTS(SELECT ''X'' FROM [BpmMas] WHERE BpmPk='+  CAST(BpmPk AS NVARCHAR(50)) 
        +N')BEGIN ' +  CHAR(5) + '
        SET IDENTITY_INSERT [dbo].[BpmMas] ON ' +  CHAR(5) + ' 

        INSERT INTO [dbo].[BpmMas]      ' +  CHAR(5) + '(
					[BpmNm], ' +   CHAR(5) + '
					[BpmFolderPath], ' +   CHAR(5) + '
					[BpmTrigFk], ' +   CHAR(5) + '
					[BpmPk], ' +   CHAR(5) + '
					[BpmRowId] ,' +   CHAR(5) + '
					[BpmCreatedBy], ' +   CHAR(5) + '
					[BpmCreatedDt], ' +   CHAR(5) + '
					[BpmModifiedBy], ' +   CHAR(5) + '
					[BpmModifiedDt], ' +   CHAR(5) + '
					[BpmDelFlg], ' +   CHAR(5) + '
					[BpmDelId] )' +   CHAR(5) + '
             VALUES' +  CHAR(5) + ' 
                   ( '''  + ISNULL(CAST(BpmNm AS NVARCHAR(1000)), 'NULL') + ''' ' +  CHAR(5) + ' 
                   ,''' + ISNULL(CAST(BpmFolderPath AS NVARCHAR(1000)), 'NULL') +''' ' +  CHAR(5) + ' 
                   ,' + ISNULL(CAST(BpmTrigFk AS NVARCHAR(1000)), 'NULL')  + ' ' +  CHAR(5) + ' 
				   ,' + ISNULL(CAST(BpmPk AS NVARCHAR(1000)), 'NULL')  + ' ' +  CHAR(5) + ' 
				   ,''' + ISNULL(CAST(BpmRowId AS NVARCHAR(1000)), 'NULL')  + ''' ' +  CHAR(5) + ' 
				   ,''' + ISNULL(CAST(BpmCreatedBy AS NVARCHAR(1000)), 'NULL')  + ''' ' +  CHAR(5) + ' 
				   ,dbo.gefgChar2Date(''' + dbo.gefgDMY(GETDATE()) + ''')' +  CHAR(5) + ' 
				   ,''' + ISNULL(CAST(BpmModifiedBy AS NVARCHAR(1000)), 'NULL')  + ''' ' +  CHAR(5) + '  
				   ,dbo.gefgChar2Date(''' + dbo.gefgDMY(GETDATE()) + ''')' +  CHAR(5) + ' 
				   ,' + ISNULL(CAST(BpmDelFlg AS NVARCHAR(1000)), 'NULL')  + ' ' +  CHAR(5) + ' 
				   ,' + ISNULL(CAST(BpmDelId AS NVARCHAR(1000)), 'NULL')  + ' ' +  CHAR(5) + ' 
                   ) ' +  CHAR(5) + ' 
        SET IDENTITY_INSERT [dbo].[BpmMas] OFF ' +  CHAR(5) + ' 
        END ' +  CHAR(5) + ' 
        GO ' +  CHAR(5) + ' '+  CHAR(5)
FROM BpmMas A
WHERE NOT EXISTS(SELECT 'X' FROM [SHFL_BPM_UAT]..[BpmMas] B WHERE B.BpmPk = A.BpmPk)


 
