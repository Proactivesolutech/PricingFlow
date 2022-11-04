SELECT  N'IF NOT EXISTS(SELECT 1 FROM [BpmVersions] WHERE BvmPk='+  CAST(BvmPk AS VARCHAR(50)) 
        + N' BEGIN ' + CHAR(10) + '
        SET IDENTITY_INSERT [dbo].[BpmVersions] ON ' + CHAR(10) + ' 

        INSERT INTO [dbo].[BpmVersions]      ' + CHAR(10) + ' 
                   (BvmBpmFk  ' + CHAR(10) + ' 
					,BvmXML  ' + CHAR(10) + ' 
					,BvmVerNo  ' + CHAR(10) + ' 
					,BvmPublish  ' + CHAR(10) + ' 
					,BvmNotes  ' + CHAR(10) + ' 
					,BvmPk  ' + CHAR(10) + ' 
					,BvmRowId  ' + CHAR(10) + ' 
					,BvmCreatedBy  ' + CHAR(10) + ' 
					,BvmCreatedDt  ' + CHAR(10) + ' 
					,BvmModifiedBy  ' + CHAR(10) + ' 
					,BvmModifiedDt  ' + CHAR(10) + ' 
					,BvmDelId    ' + CHAR(10) + '                              
             ) VALUES' + CHAR(10) + ' 
                   ( '  + ISNULL(CAST(BvmBpmFk AS VARCHAR(20)), 'NULL') + ' ' + CHAR(10) + ' 
                   ,''' + ISNULL(CAST([BvmXML] AS VARCHAR(MAX)), 'NULL') +''' ' + CHAR(10) + ' 
				    ,' + ISNULL(CAST([BvmVerNo] AS VARCHAR(5)), 'NULL') +' ' + CHAR(10) + ' 
                   ,' + ISNULL(CAST([BvmPublish] AS VARCHAR(5)), 'NULL')  + ' ' + CHAR(10) + ' 
				   ,''' + ISNULL(CAST([BvmNotes] AS VARCHAR(MAX)), 'NULL')  + ' ' + CHAR(10) + ' 
				   ,' + ISNULL(CAST([BvmPk] AS VARCHAR(10)), 'NULL')  + ''' ' + CHAR(10) + ' 
				   ,''' + ISNULL(CAST([BvmRowId] AS VARCHAR(50)), 'NULL')  + ''' ' + CHAR(10) + ' 
				   ,''' + ISNULL(CAST([BvmCreatedBy] AS VARCHAR(50)), 'NULL')  + ''' ' + CHAR(10) + ' 
				   ,''' + ISNULL(CAST([BvmCreatedDt] AS VARCHAR(50)), 'NULL')  + ''' ' + CHAR(10) + ' 
				   ,''' + ISNULL(CAST([BvmModifiedBy] AS VARCHAR(50)), 'NULL')  + ''' ' + CHAR(10) + ' 
				   ,''' + ISNULL(CAST([BvmModifiedDt] AS VARCHAR(50)), 'NULL')  + ''' ' + CHAR(10) + '  
				   ,' + ISNULL(CAST([BvmDelId] AS VARCHAR(5)), 'NULL')  + ' ' + CHAR(10) + ' 
                   ) ' + CHAR(10) + ' 
        SET IDENTITY_INSERT [dbo].[BpmVersions] OFF ' + CHAR(10) + ' 
        END ' + CHAR(10) + ' 
        GO ' + CHAR(10) + ' '+ CHAR(10)
FROM  [SHFL_BPM]..[BpmVersions] B 
WHERE NOT EXISTS(SELECT 'X' FROM BpmVersions A WHERE B.BvmPk = A.BvmPk)


 
