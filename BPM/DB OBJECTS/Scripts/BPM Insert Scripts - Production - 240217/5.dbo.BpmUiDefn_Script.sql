BEGIN TRAN
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3334)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14804  
					, 1  
					, ''  
					, ''  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3334  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'REJ'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3335)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14807  
					, 1  
					, ''  
					, ''  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3335  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'END'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3336)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14860  
					, 2  
					, '[{"elem":"input","type":"button","value":"FIS","label":"Target Page -  Field Investigation for Seller","TgtId":"Task_05t7aa0_nq1b"},{"elem":"input","type":"button","value":"PS","label":"Target Page -  OR","TgtId":"ManualTask_1mjr6f6"}]'  
					, ''  
					, 1  
					, ''  
					, ''  
					, ''  
					, 3336  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'SD'  
					, 0  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3337)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14797  
					, 2  
					, '[{"elem":"input","type":"button","value":"CF","label":"Target Page -  Collection Feedback","TgtId":"Task_137ddd3_emvs"},{"elem":"input","type":"button","value":"CO","label":"Target Page -  OR","TgtId":"ManualTask_1fqmge2"}]'  
					, ''  
					, 1  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3337  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'DEC'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3338)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14802  
					, 2  
					, '[{"elem":"input","type":"button","value":"RCUA","label":"Target Page -  RCU Approval","TgtId":"Task_0vl6ftk_nxgi"},{"elem":"input","type":"button","value":"DO","label":"Target Page -  OR","TgtId":"ManualTask_0rkzq78"}]'  
					, ''  
					, 1  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3338  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'APR'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3339)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14803  
					, 2  
					, '[{"elem":"input","type":"button","value":"Approve","label":"Target Page - Sanction Letter Acceptance","TgtId":"Task_1mkiufb"},{"elem":"input","type":"button","value":"Reject","label":"Target Page - Decline","TgtId":"EndEvent_13f820l"}]'  
					, ''  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3339  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'DEC'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3340)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14768  
					, 1  
					, ''  
					, ''  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3340  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'START'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3341)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14792  
					, 1  
					, ''  
					, '../LOS/LosPNI.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3341  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'ATRG'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3342)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14794  
					, 1  
					, ''  
					, '../LOS/field-investigation.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3342  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'FIS'  
					, 0  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3343)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14808  
					, 1  
					, ''  
					, '../LOS/credit-approver.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3343  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'CO'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3344)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14778  
					, 1  
					, ''  
					, '../LOS/technical-verification.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3344  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'TV'  
					, 0  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3345)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14790  
					, 1  
					, ''  
					, '../LOS/Legalverification.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3345  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'LVA'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3346)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14777  
					, 1  
					, ''  
					, '../LOS/document-verification.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3346  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'DV'  
					, 0  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3347)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14770  
					, 1  
					, ''  
					, '../LOS/technical-Manager.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3347  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'TM'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3348)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14805  
					, 1  
					, ''  
					, '../LOS/Disbursement-Officer.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3348  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'DO'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3349)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14781  
					, 1  
					, ''  
					, '../LOS/dedupe.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3349  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'DDP'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3350)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14801  
					, 1  
					, ''  
					, '../LOS/rcucopy.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3350  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'RCUA'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3351)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14789  
					, 1  
					, ''  
					, '../LOS/PostSanctioncopy.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3351  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'PSQC'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3352)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14796  
					, 1  
					, ''  
					, '../LOS/field-investigation.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3352  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'CF'  
					, 0  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3353)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14775  
					, 1  
					, ''  
					, '../LOS/field-investigation.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3353  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'FIR'  
					, 0  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3354)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14779  
					, 1  
					, ''  
					, '../LOS/legal-verification.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3354  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'LV'  
					, 0  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3355)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14787  
					, 1  
					, ''  
					, '../LOS/customer-financials.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3355  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'BC'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3356)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14799  
					, 1  
					, ''  
					, '../LOS/credit-approver_2.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3356  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'CA'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3357)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14780  
					, 1  
					, ''  
					, '../LOS/quick-entry.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3357  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'QDE'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3358)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14769  
					, 1  
					, ''  
					, '../LOS/LegalManager.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3358  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'LM'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3359)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14806  
					, 1  
					, ''  
					, '../LOS/Disbursement-Approver.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3359  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'DA'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3360)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14793  
					, 1  
					, ''  
					, '../LOS/detail-data-entry.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data 
Entry'  
					, 3360  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'DDE'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3361)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14788  
					, 1  
					, ''  
					, '../LOS/post-sanction-qc.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data 
Entry'  
					, 3361  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'PS'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3362)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14776  
					, 1  
					, ''  
					, '../LOS/field-investigation.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data 
Entry'  
					, 3362  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'FIO'  
					, 0  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3363)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14767  
					, 1  
					, ''  
					, '../LOS/scan.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data 
Entry'  
					, 3363  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'DSI'  
					, 0  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3364)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14785  
					, 1  
					, ''  
					, '../LOS/rcu.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data 
Entry'  
					, 3364  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'RCU'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3365)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14772  
					, 1  
					, ''  
					, '../LOS/CourierSend.html'  
					, 0  
					, ''  
					, ''  
					, 'Acceptance of Sanction Letter Rmks'  
					, 3365  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'CS'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3366)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14783  
					, 1  
					, ''  
					, '../LOS/technical-verification-approver.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3366  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'TVA'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3367)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14773  
					, 1  
					, ''  
					, '../LOS/DetailedData.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3367  
					, '6F95F60A-93B9-48A8-A238-3DB788912B9A'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'QCDDE'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3368)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14914  
					, 1  
					, ''  
					, ''  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3368  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'REJ'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3369)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14916  
					, 1  
					, ''  
					, ''  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3369  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'END'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3370)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14920  
					, 2  
					, '[{"elem":"input","type":"button","value":"FIS","label":"Target Page -  Field Investigation for Seller","TgtId":"Task_05t7aa0_nq1b"},{"elem":"input","type":"button","value":"PS","label":"Target Page -  OR","TgtId":"ManualTask_1mjr6f6"}]'  
					, ''  
					, 1  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3370  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'SD'  
					, 0  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3371)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14903  
					, 2  
					, '[{"elem":"input","type":"button","value":"CF","label":"Target Page -  Collection Feedback","TgtId":"Task_137ddd3_emvs"},{"elem":"input","type":"button","value":"CO","label":"Target Page -  OR","TgtId":"ManualTask_1fqmge2"}]'  
					, ''  
					, 1  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3371  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'DEC'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3372)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14905  
					, 2  
					, '[{"elem":"input","type":"button","value":"RCUA","label":"Target Page -  RCU Approval","TgtId":"Task_0vl6ftk_nxgi"},{"elem":"input","type":"button","value":"DO","label":"Target Page -  OR","TgtId":"ManualTask_0rkzq78"}]'  
					, ''  
					, 1  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3372  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'APR'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3373)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14913  
					, 2  
					, '[{"elem":"input","type":"button","value":"Approve","label":"Target Page - Sanction Letter Acceptance","TgtId":"Task_1mkiufb"},{"elem":"input","type":"button","value":"Reject","label":"Target Page - Decline","TgtId":"EndEvent_13f820l"}]'  
					, ''  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3373  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'DEC'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3374)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14879  
					, 1  
					, ''  
					, ''  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3374  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'START'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3375)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14900  
					, 1  
					, ''  
					, '../LOS/LosPNI.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3375  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'ATRG'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3376)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14908  
					, 1  
					, ''  
					, '../LOS/field-investigation.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3376  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'FIS'  
					, 0  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3377)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14917  
					, 1  
					, ''  
					, '../LOS/credit-approver.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3377  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'CO'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3378)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14888  
					, 1  
					, ''  
					, '../LOS/technical-verification.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3378  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'TV'  
					, 0  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3379)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14898  
					, 1  
					, ''  
					, '../LOS/Legalverification.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3379  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'LVA'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3380)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14887  
					, 1  
					, ''  
					, '../LOS/document-verification.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3380  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'DV'  
					, 0  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3381)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14881  
					, 1  
					, ''  
					, '../LOS/technical-Manager.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3381  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'TM'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3382)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14906  
					, 1  
					, ''  
					, '../LOS/Disbursement-Officer.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3382  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'DO'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3383)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14891  
					, 1  
					, ''  
					, '../LOS/dedupe.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3383  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'DDP'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3384)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14919  
					, 1  
					, ''  
					, '../LOS/rcucopy.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3384  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'RCUA'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3385)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14911  
					, 1  
					, ''  
					, '../LOS/PostSanctioncopy.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3385  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'PSQC'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3386)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14902  
					, 1  
					, ''  
					, '../LOS/field-investigation.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3386  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'CF'  
					, 0  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3387)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14885  
					, 1  
					, ''  
					, '../LOS/field-investigation.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3387  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'FIR'  
					, 0  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3388)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14889  
					, 1  
					, ''  
					, '../LOS/legal-verification.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3388  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'LV'  
					, 0  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3389)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14897  
					, 1  
					, ''  
					, '../LOS/customer-financials.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3389  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'BC'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3390)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14912  
					, 1  
					, ''  
					, '../LOS/credit-approver_2.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3390  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'CA'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3391)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14890  
					, 1  
					, ''  
					, '../LOS/quick-entry.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3391  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'QDE'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3392)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14880  
					, 1  
					, ''  
					, '../LOS/LegalManager.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3392  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'LM'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3393)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14915  
					, 1  
					, ''  
					, '../LOS/Disbursement-Approver.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3393  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'DA'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3394)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14901  
					, 1  
					, ''  
					, '../LOS/detail-data-entry.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data 
Entry'  
					, 3394  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'DDE'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3395)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14910  
					, 1  
					, ''  
					, '../LOS/post-sanction-qc.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data 
Entry'  
					, 3395  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'PS'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3396)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14886  
					, 1  
					, ''  
					, '../LOS/field-investigation.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data 
Entry'  
					, 3396  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'FIO'  
					, 0  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3397)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14878  
					, 1  
					, ''  
					, '../LOS/scan.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data 
Entry'  
					, 3397  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'DSI'  
					, 0  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3398)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14895  
					, 1  
					, ''  
					, '../LOS/rcu.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data 
Entry'  
					, 3398  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'RCU'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3399)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14907  
					, 1  
					, ''  
					, '../LOS/CourierSend.html'  
					, 0  
					, ''  
					, ''  
					, 'Acceptance of Sanction Letter Rmks'  
					, 3399  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'CS'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3400)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14893  
					, 1  
					, ''  
					, '../LOS/technical-verification-approver.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3400  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'TVA'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3401)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14883  
					, 1  
					, ''  
					, '../LOS/DetailedData.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3401  
					, 'B70C715D-F643-44E4-BF02-FBB855356FE4'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'QCDDE'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3402)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 15031  
					, 1  
					, ''  
					, ''  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3402  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'DN1'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3403)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 15029  
					, 1  
					, ''  
					, ''  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3403  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'END'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3404)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 15030  
					, 1  
					, ''  
					, ''  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3404  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'DN2'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3405)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 15022  
					, 2  
					, '[{"elem":"input","type":"button","value":"RCUA","label":"Target Page -  RCU Approval","TgtId":"Task_1ww0xr7_ni9o"},{"elem":"input","type":"button","value":"DO","label":"Target Page -  OR","TgtId":"ManualTask_07cl3gh"}]'  
					, ''  
					, 1  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3405  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'RAD'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3406)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 15024  
					, 2  
					, '[{"elem":"input","type":"button","value":"Approve","label":"Target Page -  Agent Triggerence","TgtId":"Task_10ud1ps_twxa"},{"elem":"input","type":"button","value":"Reject","label":"Target Page -  Decline","TgtId":"EndEvent_1x3vt1y"}]'  
					, ''  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3406  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'CAD'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3407)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 15025  
					, 2  
					, '[{"elem":"input","type":"button","value":"Approve","label":"Target Page - Sanction Acceptance Letter","TgtId":"Task_0m44yzx"},{"elem":"input","type":"button","value":"Reject","label":"Target Page - Decline","TgtId":"EndEvent_0gg9rg4"}]'  
					, ''  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3407  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'CAD'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3408)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 15019  
					, 2  
					, '[{"elem":"input","type":"button","value":"CF","label":"Target Page -  Collection Feedback","TgtId":"Task_0m2esie_paik"},{"elem":"input","type":"button","value":"CO","label":"Target Page -  OR","TgtId":"ManualTask_1f4zwou"}]'  
					, ''  
					, 1  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3408  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'LAD'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3409)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 15086  
					, 2  
					, '[{"elem":"input","type":"button","value":"FIS","label":"Target Page -  Field Investigation For Seller","TgtId":"Task_09qaxed_gf9y"},{"elem":"input","type":"button","value":"PS","label":"Target Page -  OR","TgtId":"ManualTask_16r734f"}]'  
					, ''  
					, 1  
					, ''  
					, ''  
					, ''  
					, 3409  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'SD'  
					, 0  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3410)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14990  
					, 1  
					, ''  
					, ''  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3410  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'START'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3411)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 15020  
					, 1  
					, ''  
					, '../LOS/document-verification.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3411  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'DV'  
					, 0  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3412)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 15010  
					, 1  
					, ''  
					, '../LOS/field-investigation.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3412  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'FIS'  
					, 0  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3413)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14993  
					, 1  
					, ''  
					, '../LOS/quick-entry.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3413  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'QDE'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3414)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 15017  
					, 1  
					, ''  
					, '../LOS/field-investigation.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3414  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'CF'  
					, 0  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3415)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14992  
					, 1  
					, ''  
					, '../LOS/Couriersend.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3415  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'SAL1'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3416)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14997  
					, 1  
					, ''  
					, '../LOS/detail-data-entry.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3416  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'DDE'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3417)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 15032  
					, 1  
					, ''  
					, '../LOS/credit-officer1_PNI.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3417  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'CO1'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3418)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 15009  
					, 1  
					, ''  
					, '../LOS/PostSanctioncopy.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3418  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'PSQC'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3419)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 15003  
					, 1  
					, ''  
					, '../LOS/credit-approver1_PNI.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3419  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'CA1'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3420)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 15027  
					, 1  
					, ''  
					, '../LOS/Disbursement-Officer.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3420  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'DO'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3421)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14987  
					, 1  
					, ''  
					, '../LOS/technical-Manager.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3421  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'TM'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3422)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 15000  
					, 1  
					, ''  
					, '../LOS/field-investigation.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3422  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'FIR'  
					, 0  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3423)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14991  
					, 1  
					, ''  
					, '../LOS/CourierSend.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3423  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'SAL2'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3424)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 15026  
					, 1  
					, ''  
					, '../LOS/post-sanction-qc.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3424  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'PS'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3425)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14989  
					, 1  
					, ''  
					, '../LOS/scan.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3425  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'DSI'  
					, 0  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3426)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 15015  
					, 1  
					, ''  
					, '../LOS/credit-approver2_PNI.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3426  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'CA2'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3427)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14994  
					, 1  
					, ''  
					, '../LOS/dedupe.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3427  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'DDP'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3428)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14988  
					, 1  
					, ''  
					, '../LOS/LegalManager.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3428  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'LM'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3429)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 15014  
					, 1  
					, ''  
					, '../LOS/customer-financials.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3429  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'BC'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3430)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 15002  
					, 1  
					, ''  
					, '../LOS/rcu.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3430  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'RCU'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3431)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14998  
					, 1  
					, ''  
					, '../LOS/DetailedData.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3431  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'QCDDE'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3432)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 15001  
					, 1  
					, ''  
					, '../LOS/field-investigation.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3432  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'FIO'  
					, 0  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3433)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 15005  
					, 1  
					, ''  
					, '../LOS/technical-verification.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data 

Entry'  
					, 3433  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'TV'  
					, 0  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3434)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 15008  
					, 1  
					, ''  
					, '../LOS/Legalverification.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data 

Entry'  
					, 3434  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'LVA'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3435)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 15028  
					, 1  
					, ''  
					, '../LOS/Disbursement-Approver.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data 

Entry'  
					, 3435  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'DA'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3436)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 14996  
					, 1  
					, ''  
					, '../LOS/LosPNI.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data 

Entry'  
					, 3436  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'ATRG'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3437)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 15006  
					, 1  
					, ''  
					, '../LOS/legal-verification.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data 

Entry'  
					, 3437  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'LV'  
					, 0  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3438)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 15007  
					, 1  
					, ''  
					, '../LOS/technical-verification-approver.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3438  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'TVA'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3439)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 15021  
					, 1  
					, ''  
					, '../LOS/rcucopy.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3439  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'RCUA'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
IF NOT EXISTS(SELECT 'X' FROM [BpmUiDefn] WHERE BudPk=3440)BEGIN 
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] ON  

        INSERT INTO [dbo].[BpmUiDefn]      (
					[BudBfwFk], 
					[BudDesignTyp], 
					[BudDesignData], 
					[BudURL], 
					[BudDecIsAuto], 
					[BudDecExp], 
					[BudScript], 
					[BudNotes], 
					[BudPk], 
					[BudRowId], 
					[BudCreatedBy], 
					[BudCreatedDt], 
					[BudModifiedBy], 
					[BudModifiedDt], 
					[BudDelFlg], 
					[BudDelId], 
					[BudCd], 
					[BudIsRtnNeed]) 
             VALUES 
                  ( 15033  
					, 1  
					, ''  
					, '../LOS/credit-officer2_PNI.html'  
					, 0  
					, ''  
					, ''  
					, 'QC of Detailed Data Entry'  
					, 3440  
					, 'B5017DA6-5752-466E-BAF7-B8812BB78510'  
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, 'ADMIN'  
					,dbo.gefgChar2Date('23/02/2017') 
					, NULL  
					, 0  
					, 'CO2'  
					, 1  
                   )  
        SET IDENTITY_INSERT [dbo].[BpmUiDefn] OFF  
        END  
         
		COMMIT TRAN