USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[proc_LeadSheetmoduledetailInsertion]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec proc_LeadSheetmoduledetailInsertion

Create PROCEDURE [dbo].[proc_LeadSheetmoduledetailInsertion]
As begin 

 Declare @New_CompanyId bigint;
 BEGIN TRANSACTION
 BEGIN TRY 
   DECLARE PAC CURSOR FOR SELECT c.Id  FROM Common.Company c join Common.CompanyModule Cm on c.Id=Cm.CompanyId where Cm.ModuleId=3 and Cm.Status=1 and C.Id<>0    
   OPEN PAC      
   FETCH NEXT FROM PAC INTO @New_CompanyId
   WHILE (@@FETCH_STATUS=0)      
   BEGIN    
   
   if not exists(select * from Common.ModuleDetail where Heading='LeadSheets Setup' and GroupName='Summary' and ModuleMasterId = (select Id from Common.ModuleMaster where Name='Audit Cursor') and CompanyId=@New_CompanyId)         
       begin
insert into Common.ModuleDetail(Id,ModuleMasterId,GroupName,Heading,Description,LogoId,CssSprite,FontAwesome,Url,
RecOrder,Remarks,Status,PageUrl,CompanyId,PermissionKey,IsPermissionInherited,IsHideTab,SecondryModuleId,IsDisable,IsPartner,IsMandatory) 
values((select max(id) from Common.ModuleDetail)+1,(select Id from Common.ModuleMaster where Name='Audit Cursor' and CompanyId=0),'Summary','LeadSheets Setup',N'',
'1851CBD0-120F-44BC-B5CF-102EA2A4D71F','menu-icons summary','',
'home.homeengagement.leadsheetsetup',500,N'',1,'LeadSheetSetUp',@New_CompanyId,'Audit_LeadsheetSetup',0,0,(select Id from Common.ModuleMaster where Name='Audit Cursor' and CompanyId=0),0,0,0)

end


Print @New_CompanyId;

BEGIN
   IF NOT EXISTS (SELECT * FROM [Auth].[GridMetaData] 
 WHERE Url='/auditleadsheetsetupgrid' 
  AND [CompanyId] = @New_CompanyId)
   BEGIN
INSERT [Auth].[GridMetaData] ([Id], [ModuleDetailId], [UserName], [Url], [GridMetaData], [CompanyId], [APIMethod], [ActionURL], [TableName], [Class], [Title], [Params], [Options], [StreamName], [ViewModelName], [IsModified],[PopupOptions],[ActionType],[ModuleMasterId])
  VALUES
 (NEWID(), (select Id from  [Common].[ModuleDetail] where [GroupName]='Summary' and [Heading]='LeadSheets Setup' and CompanyId=@New_CompanyId and ModuleMasterId=3), NULL, N'/auditleadsheetsetupgrid',
  N'[{"template":"<div class=\"custom-check text-center\"><label><input type=\"checkbox\" id=\"{{dataItem.Id}}\" ng-checked=\"vm.selection.indexOf(dataItem)>-1\" ng-click=\"vm.toggleSelection(dataItem)\"><span for=\"\"></span</label></div>","width":"50px"},{"field":"Index","title":"Index","template":"<a href=\"\" ng-click=\"vm.getViewMode(dataItem)\">${Index}</a> <a id=\"$index\" tooltip-placement=\"right\" uib-tooltip=\"Mapped Accounts\" ng-if=\"dataItem.IsLock\"><i class=\"fa fa-lock\"></i></a>","filterable":{"cell":{"operator":"contains"}},"width":"109px"},{"field":"LeadSheetName","title":"Leadsheet Name","filterable":{"cell":{"operator":"contains"}},"width":"201px"},{"field":"LeadsheetType","title":"Leadsheet Type","filterable":{"cell":{"operator":"contains"}},"width":"180px"},{"field":"AccountClass","title":"Default Account Class","filterable":{"cell":{"operator":"contains"}},"width":"207px"},{"field":"WorkProgramName","title":"Work Program","filterable":{"cell":{"operator":"contains"}},"width":"150px"},{"field":"FinancialStatementTemplate","title":"Financial Statement Template","filterable":{"cell":{"operator":"contains"}},"width":"252px"},{"field":"Status","title":"Status","filterable":{"cell":{"operator":"contains"}},"width":"110px"}]'
  , @New_CompanyId,  N'{Audit}/api/V2/leadsheetgridk/getallleadsheetsk', N'admin.auditsettings.leadsheetsetup',  N'Audit.LeadSheet', N'itel', N'LeadSheets', N'{"TemplateUrl":"audit_leadsheetsetup.html","Controller":"leadSheetSetupCtrl"}', N'', N'Leadsheet Setup', N'LeadSheetModel', NULL,'{"TemplateUrl":"audit_leadsheetsetup.html","Controller":"leadSheetSetupCtrl"}','popup',NULL)
     END
END;


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
