
BEGIN TRAN
IF NOT EXISTS(SELECT 1 FROM [BpmVersions] WHERE BvmPk=189)
 BEGIN 

        SET IDENTITY_INSERT [dbo].[BpmVersions] ON 

        INSERT INTO [dbo].[BpmVersions] 
                   (BvmBpmFk
				   ,BvmXML					
					,BvmVerNo
					,BvmPublish
					,BvmNotes
					,BvmPk
					,BvmRowId
					,BvmCreatedBy
					,BvmCreatedDt
					,BvmModifiedBy
					,BvmModifiedDt
					,BvmDelId 
					)                            
              VALUES
                   ( 93    
				   ,''              
				    ,4 
                   ,0 
				   ,'' 
				   ,189 
				   ,'6F95F60A-93B9-48A8-A238-3DB788912B9A' 
				   ,'ADMIN' 
				   , GETDATE()  
				   ,'ADMIN' 
				   ,GETDATE()
				   ,0 
                   ) 
        SET IDENTITY_INSERT [dbo].[BpmVersions] OFF 		
        END 
        GO 

IF NOT EXISTS(SELECT 1 FROM [BpmVersions] WHERE BvmPk=190)
 BEGIN 

        SET IDENTITY_INSERT [dbo].[BpmVersions] ON 

        INSERT INTO [dbo].[BpmVersions] 
                   (BvmBpmFk
				   ,BvmXML					
					,BvmVerNo
					,BvmPublish
					,BvmNotes
					,BvmPk
					,BvmRowId
					,BvmCreatedBy
					,BvmCreatedDt
					,BvmModifiedBy
					,BvmModifiedDt
					,BvmDelId 
					)                            
              VALUES
                   ( 93    
				   ,''              
				    ,5 
                   ,0 
				   ,'' 
				   ,190 
				   ,'B70C715D-F643-44E4-BF02-FBB855356FE4' 
				   ,'ADMIN' 
				   , GETDATE()  
				   ,'ADMIN' 
				   ,GETDATE()
				   ,0 
                   ) 
        SET IDENTITY_INSERT [dbo].[BpmVersions] OFF 		
        END 
        GO 

IF NOT EXISTS(SELECT 1 FROM [BpmVersions] WHERE BvmPk=191)
 BEGIN 

        SET IDENTITY_INSERT [dbo].[BpmVersions] ON 

        INSERT INTO [dbo].[BpmVersions] 
                   (BvmBpmFk
				   ,BvmXML					
					,BvmVerNo
					,BvmPublish
					,BvmNotes
					,BvmPk
					,BvmRowId
					,BvmCreatedBy
					,BvmCreatedDt
					,BvmModifiedBy
					,BvmModifiedDt
					,BvmDelId 
					)                            
              VALUES
                   ( 100    
				   ,''              
				    ,7 
                   ,0 
				   ,'' 
				   ,191 
				   ,'B5017DA6-5752-466E-BAF7-B8812BB78510' 
				   ,'ADMIN' 
				   , GETDATE()  
				   ,'ADMIN' 
				   ,GETDATE()
				   ,0 
                   ) 
        SET IDENTITY_INSERT [dbo].[BpmVersions] OFF 		
        END 
        GO 
COMMIT TRAN