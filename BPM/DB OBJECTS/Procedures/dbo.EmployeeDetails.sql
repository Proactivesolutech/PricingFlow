USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[EmployeeDetails]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[EmployeeDetails]
(
@Action	VARCHAR(1),
@EmpName VARCHAR(25),
@EmpMno INT,
@EmpDOB VARCHAR(20),
@EmpAge INT,
@EmpQ VARCHAR(100),
@EmpSalary NVARCHAR(200)
)
AS

BEGIN

SET NOCOUNT ON;

DECLARE @CHECKID INT


IF @Action = 'A'
	BEGIN
		INSERT INTO EmployeeMas(EmpName,EmpMno,EmpDOB,EmpAge) values(@EmpName,@EmpMno,CONVERT(DATETIME,@EmpDOB,103),@EmpAge)
		SET @CHECKID = SCOPE_IDENTITY()

		INSERT INTO EmployeeDtls (EmpID,EmpQ,EmpSalary) values(@CHECKID,@EmpQ,@EmpSalary)

		SELECT * FROM EmployeeMas

		SELECT * FROM EmployeeDtls
	END

IF @Action = 'S'
	BEGIN
		SELECT ''
	END
END
GO
