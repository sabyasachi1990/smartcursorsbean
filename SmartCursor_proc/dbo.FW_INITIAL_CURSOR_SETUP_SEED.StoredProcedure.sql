USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[FW_INITIAL_CURSOR_SETUP_SEED]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [dbo].[FW_INITIAL_CURSOR_SETUP_SEED] (@UNIQUE_COMPANY_ID BIGINT,@NEW_COMPANY_ID BIGINT, @MODULEID BIGINT)
AS
BEGIN
--BEGIN TRANSACTION
BEGIN TRY
INSERT INTO [Common].[InitialCursorSetup] ([Id], [CompanyId], [ModuleId], [ModuleDetailId], [IsSetUpDone],[MainModuleId],[Status],[MasterModuleId],[IsCommonModule])

    Select * From 
    (
    SELECT ROW_NUMBER() OVER(ORDER BY ICS.ID) + (SELECT MAX(IC.ID)  FROM [Common].[InitialCursorSetup] as IC) As NewId1, @NEW_COMPANY_ID As NewCompanyid, ICS.[ModuleId], (select top 1 Id from Common.ModuleDetail where ISNULL(GroupName,'NULL')=(select ISNULL(GroupName,'NULL') from Common.ModuleDetail where Id=ICS.ModuleDetailId) and ISNULL(Heading,'NULL')=(select ISNULL(Heading,'NULL') from Common.ModuleDetail where Id=ICS.ModuleDetailId)  and ModuleMasterId=(select ModuleMasterId from Common.ModuleDetail where Id=ICS.ModuleDetailId) and ISNULL(PermissionKey,0)=(select ISNULL(PermissionKey,0) from Common.ModuleDetail where Id=ICS.ModuleDetailId) and ISNULL(SecondryModuleId,0)=(select ISNULL(SecondryModuleId,0) from Common.ModuleDetail where Id=ICS.ModuleDetailId) and CompanyId=@NEW_COMPANY_ID) as ModuleDetailid, ICS.[IsSetUpDone] as IsSetUpDone,ICS.[MainModuleId],ICS.[Status],ICS.[MasterModuleId],ICS.[IsCommonModule] 
        FROM Common.InitialCursorSetup ICS
        join Common.ModuleDetail MD on Md.Id = ICS.ModuleDetailId        
        where ICS.Status=1 and MD.Status = 1 and ICS.CompanyId=@UNIQUE_COMPANY_ID and MainModuleId = @MODULEID 
        ) As A
        Where ModuleDetailid not in (select moduledetailId from Common.InitialCursorSetup where CompanyId=@NEW_COMPANY_ID and MainModuleId=@MODULEID) 


		update Common.InitialCursorSetup set IsCommonModule = 1 where CompanyId=@NEW_COMPANY_ID and ModuleDetailId in (select ModuleDetailId from Common.InitialCursorSetup where CompanyId=@UNIQUE_COMPANY_ID and IsCommonModule=1)  

		--COMMIT TRANSACTION
END TRY
BEGIN CATCH
    PRINT 'FAILED..!'
	DECLARE      
     @ErrorMessage NVARCHAR(4000),      
     @ErrorSeverity INT,      
     @ErrorState INT;      
SELECT      
     @ErrorMessage = ERROR_MESSAGE(),      
     @ErrorSeverity = ERROR_SEVERITY(),      
     @ErrorState = ERROR_STATE();      
   RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
	--ROLLBACK;
END CATCH
END
GO
