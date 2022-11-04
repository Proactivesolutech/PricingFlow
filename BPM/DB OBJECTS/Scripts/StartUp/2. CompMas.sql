BEGIN TRAN
DELETE FROM BpmToolBox
	INSERT INTO BpmToolBox(BtbToolNm,BtbRowId,BtbCreatedBy,BtbCreatedDt,BtbModifiedBy,BtbModifiedDt,BtbDelFlg,BtbDelId)

	SELECT  'bpmn:Collaboration' ,NEWID(),'ADMIN',GETDATE(),'ADMIN',GETDATE(),NULL,0
		UNION
	SELECT 'bpmn:Participant', NEWID(),'ADMIN',GETDATE(),'ADMIN',GETDATE(),NULL,0
		UNION
	SELECT  'bpmn:Process', NEWID(),'ADMIN',GETDATE(),'ADMIN',GETDATE(),NULL,0
		UNION
	SELECT  'bpmn:StartEvent', NEWID(),'ADMIN',GETDATE(),'ADMIN',GETDATE(),NULL,0
		UNION
		
	SELECT  'bpmn:Task', NEWID(),'ADMIN',GETDATE(),'ADMIN',GETDATE(),NULL,0
		UNION
	SELECT 'bpmn:SendTask', NEWID(),'ADMIN',GETDATE(),'ADMIN',GETDATE(),NULL,0
		UNION
	SELECT  'bpmn:ReceiveTask', NEWID(),'ADMIN',GETDATE(),'ADMIN',GETDATE(),NULL,0
		UNION
	SELECT  'bpmn:UserTask', NEWID(),'ADMIN',GETDATE(),'ADMIN',GETDATE(),NULL,0
		UNION
	SELECT  'bpmn:ManualTask', NEWID(),'ADMIN',GETDATE(),'ADMIN',GETDATE(),NULL,0
		UNION
	SELECT  'bpmn:BusinessRuleTask', NEWID(),'ADMIN',GETDATE(),'ADMIN',GETDATE(),NULL,0
		UNION
	SELECT  'bpmn:ServiceTask', NEWID(),'ADMIN',GETDATE(),'ADMIN',GETDATE(),NULL,0
		UNION
	SELECT  'bpmn:ServiceTask', NEWID(),'ADMIN',GETDATE(),'ADMIN',GETDATE(),NULL,0
		UNION
	SELECT  'bpmn:CallActivity', NEWID(),'ADMIN',GETDATE(),'ADMIN',GETDATE(),NULL,0
		UNION
	SELECT  'bpmn:SubProcess', NEWID(),'ADMIN',GETDATE(),'ADMIN',GETDATE(),NULL,0
		UNION	
	SELECT  'bpmn:AdHocSubProcess', NEWID(),'ADMIN',GETDATE(),'ADMIN',GETDATE(),NULL,0
		UNION
								
	SELECT 'bpmn:ExclusiveGateway', NEWID(),'ADMIN',GETDATE(),'ADMIN',GETDATE(),NULL,0
		UNION
	SELECT 'bpmn:ParallelGateway', NEWID(),'ADMIN',GETDATE(),'ADMIN',GETDATE(),NULL,0
		UNION
	SELECT 'bpmn:InclusiveGateway', NEWID(),'ADMIN',GETDATE(),'ADMIN',GETDATE(),NULL,0
		UNION	
	SELECT 'bpmn:ComplexGateway', NEWID(),'ADMIN',GETDATE(),'ADMIN',GETDATE(),NULL,0
		UNION
	SELECT 'bpmn:EventBasedGateway', NEWID(),'ADMIN',GETDATE(),'ADMIN',GETDATE(),NULL,0
		UNION			

	SELECT 'bpmn:DataObjectReference' ,NEWID(),'ADMIN',GETDATE(),'ADMIN',GETDATE(),NULL,0
		UNION
		
	SELECT 'bpmn:DataStoreReference' , NEWID(),'ADMIN',GETDATE(),'ADMIN',GETDATE(),NULL,0
		UNION
		
	SELECT 'bpmn:IntermediateCatchEvent', NEWID(),'ADMIN',GETDATE(),'ADMIN',GETDATE(),NULL,0
		UNION
	SELECT 'bpmn:SequenceFlow' , NEWID(),'ADMIN',GETDATE(),'ADMIN',GETDATE(),NULL,0
		UNION	
	SELECT  'bpmn:MessageFlow', NEWID(),'ADMIN',GETDATE(),'ADMIN',GETDATE(),NULL,0
		UNION
	SELECT 'bpmn:EndEvent' ,NEWID(),'ADMIN',GETDATE(),'ADMIN',GETDATE(),NULL,0
		UNION
	SELECT 'bpmn:Lane' ,NEWID(),'ADMIN',GETDATE(),'ADMIN',GETDATE(),NULL,0
	
	SELECT * FROM BpmToolBox
ROLLBACK TRAN