SELECT  N'IF NOT EXISTS(SELECT ''X'' FROM [BpmFlow] WHERE BfwPk='+  CAST(BfwPk AS NVARCHAR(50)) 
        +N')BEGIN ' +  CHAR(5) + '
        SET IDENTITY_INSERT [dbo].[BpmFlow] ON ' +  CHAR(5) + ' 

        INSERT INTO [dbo].[BpmFlow]      ' +  CHAR(5) + '(
					[BfwBvmFk], ' +  CHAR(5) + '
					[BfwBtbFk], ' +  CHAR(5) + '
					[BfwId], ' +  CHAR(5) + '
					[BfwLabel], ' +  CHAR(5) + '
					[BfwPrtRef], ' +  CHAR(5) + '
					[BfwSubBvmFk], ' +  CHAR(5) + '
					[BfwLaneRef], ' +  CHAR(5) + '
					[BfwPk], ' +  CHAR(5) + '
					[BfwRowId], ' +  CHAR(5) + '
					[BfwCreatedBy], ' +  CHAR(5) + '
					[BfwCreatedDt], ' +  CHAR(5) + '
					[BfwModifiedBy], ' +  CHAR(5) + '
					[BfwModifiedDt], ' +  CHAR(5) + '
					[BfwDelFlg], ' +  CHAR(5) + '
					[BfwDelId]) ' +  CHAR(5) + '
             VALUES' +  CHAR(5) + ' 
                   ( '  + ISNULL(CAST(BfwBvmFk AS NVARCHAR(1000)), 'NULL') + ' ' +  CHAR(5) + ' 
                   ,' + ISNULL(CAST(BfwBtbFk AS NVARCHAR(1000)), 'NULL') + ' ' +  CHAR(5) + ' 
                   ,''' + ISNULL(CAST(BfwId AS NVARCHAR(1000)), 'NULL')  + ''' ' +  CHAR(5) + ' 
				   ,''' + ISNULL(CAST(BfwLabel AS NVARCHAR(1000)), 'NULL')  + ''' ' +  CHAR(5) + ' 
				   ,''' + ISNULL(CAST(BfwPrtRef AS NVARCHAR(1000)), 'NULL')  + ''' ' +  CHAR(5) + ' 
				   ,' + ISNULL(CAST(BfwSubBvmFk AS NVARCHAR(1000)), 'NULL')  + ' ' +  CHAR(5) + ' 
				   ,''' + ISNULL(CAST(BfwLaneRef AS NVARCHAR(1000)), 'NULL')  + ''' ' +  CHAR(5) + ' 
				   ,' + ISNULL(CAST(BfwPk AS NVARCHAR(1000)), 'NULL')  + ' ' +  CHAR(5) + ' 
				   ,''' + ISNULL(CAST(BfwRowId AS NVARCHAR(1000)), 'NULL')  + ''' ' +  CHAR(5) + ' 
				   ,''' + ISNULL(CAST(BfwCreatedBy AS NVARCHAR(1000)), 'NULL')  + ''' ' +  CHAR(5) + ' 
				   ,dbo.gefgChar2Date(''' + dbo.gefgDMY(GETDATE()) + ''')' +  CHAR(5) + ' 
				   ,''' + ISNULL(CAST(BfwModifiedBy AS NVARCHAR(1000)), 'NULL')  + ''' ' +  CHAR(5) + ' 
				   ,dbo.gefgChar2Date(''' + dbo.gefgDMY(GETDATE()) + ''')' +  CHAR(5) + ' 
				   ,' + ISNULL(CAST(BfwDelFlg AS NVARCHAR(1000)), 'NULL')  + ' ' +  CHAR(5) + ' 
				   ,' + ISNULL(CAST(BfwDelId AS NVARCHAR(1000)), 'NULL')  + ' ' +  CHAR(5) + ' 
                   ) ' +  CHAR(5) + ' 
        SET IDENTITY_INSERT [dbo].[BpmFlow] OFF ' +  CHAR(5) + ' 
        END ' +  CHAR(5) + ' 
        GO ' +  CHAR(5) + ' '+  CHAR(5)
FROM BpmFlow A
WHERE NOT EXISTS(SELECT 'X' FROM [SHFL_BPM_UAT]..[BpmFlow] B WHERE B.BfwPk = A.BfwPk)


 
