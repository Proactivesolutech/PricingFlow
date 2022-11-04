SELECT  N'IF NOT EXISTS(SELECT ''X'' FROM [ShflPgRightsDtls] WHERE PgrdPk='+  CAST(PgrdPk AS NVARCHAR(50)) 
        +N')BEGIN ' +  CHAR(5) + '
        SET IDENTITY_INSERT [dbo].[ShflPgRightsDtls] ON ' +  CHAR(5) + ' 

        INSERT INTO [dbo].[ShflPgRightsDtls]      ' +  CHAR(5) + '(
					[PgrdRolFk], ' +  CHAR(5) + '
					[PgrdPgFk], ' +  CHAR(5) + '
					[PgrdPk], ' +  CHAR(5) + '
					[PgrActDt], ' +  CHAR(5) + '
					[PgrdDelId]) ' +  CHAR(5) + '
             VALUES' +  CHAR(5) + ' 
                  ( '  + ISNULL(CAST(PgrdRolFk AS NVARCHAR(1000)), 'NULL') + ' ' +  CHAR(5) + ' 
					, '  + ISNULL(CAST(PgrdPgFk AS NVARCHAR(1000)), 'NULL') + ' ' +  CHAR(5) + ' 
					, '  + ISNULL(CAST(PgrdPk AS NVARCHAR(1000)), 'NULL') + ' ' +  CHAR(5) + ' 
					,dbo.gefgChar2Date(''' + dbo.gefgDMY(GETDATE()) + ''')' +  CHAR(5) + ' 
					, '  + ISNULL(CAST(PgrdDelId AS NVARCHAR(1000)), 'NULL') + ' ' +  CHAR(5) + ' 
                   ) ' +  CHAR(5) + ' 
        SET IDENTITY_INSERT [dbo].[ShflPgRightsDtls] OFF ' +  CHAR(5) + ' 
        END ' +  CHAR(5) + ' 
        ' +  CHAR(5) + ' '+  CHAR(5)
FROM ShflPgRightsDtls A
WHERE NOT EXISTS(SELECT 'X' FROM [SHFL_BPM_UAT]..[ShflPgRightsDtls] B WHERE B.PgrdPk = A.PgrdPk)