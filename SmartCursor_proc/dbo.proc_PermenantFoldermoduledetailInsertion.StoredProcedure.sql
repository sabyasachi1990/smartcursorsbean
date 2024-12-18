USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[proc_PermenantFoldermoduledetailInsertion]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[proc_PermenantFoldermoduledetailInsertion]
As begin 

 Declare @New_CompanyId bigint;
 BEGIN TRANSACTION
 BEGIN TRY 
   DECLARE PAC CURSOR FOR SELECT c.Id  FROM Common.Company c join Common.CompanyModule Cm on c.Id=Cm.CompanyId where Cm.ModuleId=3 and Cm.Status=1 and C.Id<>0             
   OPEN PAC      
   FETCH NEXT FROM PAC INTO @New_CompanyId
   WHILE (@@FETCH_STATUS=0)      
   BEGIN    
   
   if not exists(select * from Common.ModuleDetail where Heading='Permanent Folder' and GroupName='Audit Cursor' and
 ModuleMasterId = (select Id from Common.ModuleMaster where Name='Doc Cursor') and CompanyId=@New_CompanyId)       
begin
insert into Common.ModuleDetail(Id,ModuleMasterId,GroupName,Heading,Description,LogoId,CssSprite,FontAwesome,Url,
RecOrder,Remarks,Status,PageUrl,CompanyId,PermissionKey,IsPermissionInherited,IsHideTab,SecondryModuleId,IsDisable,
IsPartner,IsMandatory)
values((select max(id) from Common.ModuleDetail)+1,(select Id from Common.ModuleMaster where Name='Doc Cursor' and CompanyId=0),
'Audit Cursor','Permanent Folder',N'',
'1851CBD0-120F-44BC-B5CF-102EA2A4D71F','menu-icons documents','menu-icons documents',
'admin.subcompanies.companies',2278,N'',1,'admin.subcompany.company',@New_CompanyId,
'doc_permanentfolder',0,0,(select Id from Common.ModuleMaster where Name='Audit Cursor' and CompanyId=0),0,0,0)


end


    FETCH NEXT FROM PAC INTO @New_CompanyId      
		   END      
		 CLOSE PAC      
		 DEALLOCATE PAC      
    COMMIT TRANSACTION
     END TRY
	 
	  BEGIN CATCH
           DECLARE
             @ErrorMessage NVARCHAR(4000),
             @ErrorSeverity INT,
             @ErrorState INT;
              SELECT
              @ErrorMessage = ERROR_MESSAGE(),
              @ErrorSeverity = ERROR_SEVERITY(),
              @ErrorState = ERROR_STATE();
              RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
     ROLLBACK TRANSACTION
     END CATCH			       

End
GO
