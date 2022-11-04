USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[sp_objsearch]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_objsearch]
(
	@Param VARCHAR(MAX)
)
AS
SET NOCOUNT ON
BEGIN
	select name,type,Create_Date,Modify_Date,[Object_Id] from sys.objects where name like '%'+@Param+'%' ORDER BY type DESC,name,Create_Date,Modify_Date
END

GO
