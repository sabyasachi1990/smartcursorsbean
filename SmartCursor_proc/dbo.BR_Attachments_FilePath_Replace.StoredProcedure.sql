USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BR_Attachments_FilePath_Replace]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[BR_Attachments_FilePath_Replace] @companyId bigint,@entityId uniqueidentifier,@oldName nvarchar(MAX),@newName nvarchar(MAX)
AS
If Exists(select Id from Common.EntityDetail where Id=@entityId)
Begin   
	    UPDATE Common.DocRepository 
		set	FilePath=SUBSTRING(FilePath,0, 10) + REPLACE(SUBSTRING(FilePath,10,LEN(FilePath)), @oldName, @newName)
		where ModuleName='BR Cursor' and CompanyId=@companyId and FilePath like Concat('%',@oldName,'%')

		UPDATE Boardroom.GenerateTemplate 
		set	FilePath=SUBSTRING(FilePath,0, 10) + REPLACE(SUBSTRING(FilePath,10,LEN(FilePath)), @oldName, @newName)
		where  FilePath like Concat('%',@oldName,'%') 

		UPDATE Common.Communication
		set	FilePath=SUBSTRING(FilePath,0, 10) + REPLACE(SUBSTRING(FilePath,10,LEN(FilePath)), @oldName, @newName)
		where TemplateId=@entityId and  FilePath like Concat('%',@oldName,'%') 
   
End
GO
