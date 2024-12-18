USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[FW_INITIAL_CURSOR_AND_COMPANY_MODULE_UPDATION]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [dbo].[FW_INITIAL_CURSOR_AND_COMPANY_MODULE_UPDATION](@NEW_COMPANY_ID bigint)
AS
BEGIN
--BEGIN TRANSACTION
BEGIN TRY

	update ICS set ICS.Status=CM.Status from Common.InitialCursorSetup ICS
	join Common.CompanyModule CM on ICS.MainModuleId = CM.ModuleId
	where CM.CompanyId=@NEW_COMPANY_ID and ICS.CompanyId=@NEW_COMPANY_ID and ICS.Status<>0

	update MD set MD.Status=CM.Status from Common.ModuleDetail MD
	join Common.CompanyModule CM on MD.SecondryModuleId = CM.ModuleId
	where CM.CompanyId=@NEW_COMPANY_ID and MD.CompanyId=@NEW_COMPANY_ID and MD.Status!=4

    Update common.moduledetail set Status=2 where companyid=@NEW_COMPANY_ID
    and groupname='Audit Cursor' and Heading='Reporting Templates'

	IF EXISTS (select * from Common.CompanyModule where CompanyId=@NEW_COMPANY_ID and ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and Status=1)
	BEGIN
			
		Update ICS set ICS.Status = CF.Status from Common.InitialCursorSetup ICS    
		join Common.ModuleDetail MD on MD.Id = ICS.ModuleDetailId
		join Common.Feature F on F.GroupKey = MD.GroupKey
		join Common.CompanyFeatures CF on F.Id = CF.FeatureId
		where CF.CompanyId=@NEW_COMPANY_ID and ICS.CompanyId=@NEW_COMPANY_ID and ICS.Status <> 0

	END

	--update CM set CM.SetUpDone=1 from Common.companyModule CM where CM.companyId=@NEW_COMPANY_ID and CM.moduleId in
	--(select distinct ModuleId from Common.InitialCursorSetup where CompanyId=@NEW_COMPANY_ID and IsSetUpDone=1 and Status=1)

	--update CM set CM.SetUpDone=0 from Common.companyModule CM where CM.companyId=@NEW_COMPANY_ID and CM.moduleId in
	--(select distinct ModuleId from Common.InitialCursorSetup where CompanyId=@NEW_COMPANY_ID and IsSetUpDone=0 and Status=1)
	--====================================================
	--Departments
	DECLARE @DEPARTMENT_Count int = (select count(*) from COmmon.InitialCursorSetup where CompanyId=@NEW_COMPANY_ID and ModuleDetailId in (select Id from Common.ModuleDetail where CompanyId=@NEW_COMPANY_ID and Heading= 'Departments' and ModuleMasterId= (select Id from Common.ModuleMaster where Name='Admin Cursor')) and IsSetUpDone=1)

	IF(@DEPARTMENT_Count > 0)
	BEGIN
	Update Common.InitialCursorSetup set IsSetUpDone=1 where CompanyId=@NEW_COMPANY_ID and ModuleDetailId in (select Id from COmmon.ModuleDetail where CompanyId=@NEW_COMPANY_ID and Heading= 'Departments') and IsSetUpDone = 0
	END
	
	--Service Groups
	DECLARE @SERVICE_GROUPS_Count int = (select count(*) from COmmon.InitialCursorSetup where CompanyId=@NEW_COMPANY_ID and ModuleDetailId in (select Id from Common.ModuleDetail where CompanyId=@NEW_COMPANY_ID and Heading= 'Service Groups' and ModuleMasterId= (select Id from Common.ModuleMaster where Name='Admin Cursor')) and IsSetUpDone=1)

	IF(@SERVICE_GROUPS_Count > 0)
	BEGIN
	Update Common.InitialCursorSetup set IsSetUpDone=1 where CompanyId=@NEW_COMPANY_ID and ModuleDetailId in (select Id from COmmon.ModuleDetail where CompanyId=@NEW_COMPANY_ID and Heading= 'Service Groups') and IsSetUpDone = 0
	END

	--Services
	DECLARE @SERVICES_Count int = (select count(*) from COmmon.InitialCursorSetup where CompanyId=@NEW_COMPANY_ID and ModuleDetailId in (select Id from Common.ModuleDetail where CompanyId=@NEW_COMPANY_ID and Heading= 'Services' and ModuleMasterId= (select Id from Common.ModuleMaster where Name='Admin Cursor')) and IsSetUpDone=1)

	IF(@SERVICES_Count > 0)
	BEGIN
	Update Common.InitialCursorSetup set IsSetUpDone=1 where CompanyId=@NEW_COMPANY_ID and ModuleDetailId in (select Id from COmmon.ModuleDetail where CompanyId=@NEW_COMPANY_ID and Heading= 'Services') and IsSetUpDone = 0
	END

	update CM set CM.SetUpDone=1 from Common.companyModule CM where CM.companyId=@NEW_COMPANY_ID and CM.moduleId in
	(select distinct ModuleId from Common.InitialCursorSetup where CompanyId=@NEW_COMPANY_ID and IsSetUpDone=1 and Status=1)

	update CM set CM.SetUpDone=0 from Common.companyModule CM where CM.companyId=@NEW_COMPANY_ID and CM.moduleId in
	(select distinct ModuleId from Common.InitialCursorSetup where CompanyId=@NEW_COMPANY_ID and IsSetUpDone=0 and Status=1)


	--=========================================================================
	--IF EXISTS (select * from Common.CompanyModule where CompanyId=@NEW_COMPANY_ID and ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and Status=1)
	--BEGIN
	--	update MD set status=2 from Common.ModuleDetail MD
	--	where MD.CompanyId=@NEW_COMPANY_ID and MD.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
	--	left join Common.Feature F on cf.FeatureId = F.Id 
	--	where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and cf.Status = 2)

	--	update MD set status=1 from Common.ModuleDetail MD
	--	where MD.CompanyId=@NEW_COMPANY_ID and MD.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
	--	left join Common.Feature F on cf.FeatureId = F.Id 
	--	where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and cf.Status = 1)
		
	--	update ICS set Status=2 from Common.InitialCursorSetup ICS
	--	join Common.ModuleDetail MD on ICS.ModuleDetailId = MD.Id
	--	where ICS.CompanyId=@NEW_COMPANY_ID and MD.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
	--	left join Common.Feature F on cf.FeatureId = F.Id 
	--	where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and cf.Status = 2)

	--	update ICS set Status=1 from Common.InitialCursorSetup ICS
	--	join Common.ModuleDetail MD on ICS.ModuleDetailId = MD.Id
	--	where ICS.CompanyId=@NEW_COMPANY_ID and MD.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
	--	left join Common.Feature F on cf.FeatureId = F.Id 
	--	where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and cf.Status = 1)
	--END
	--======================================================
	IF EXISTS(select * from Common.CompanyModule where CompanyId = @NEW_COMPANY_ID and SetUpDone=0)   
	BEGIN
		update Common.CompanyModule set SetUpDone = 0 where CompanyId=@NEW_COMPANY_ID and ModuleId = (Select Id from Common.ModuleMaster where name ='Admin Cursor')
	END

	IF NOT EXISTS (select * from Common.InitialCursorSetup where CompanyId=@NEW_COMPANY_ID and  MainModuleId in (select ModuleId from Common.CompanyModule where CompanyId=@NEW_COMPANY_ID and Status=1) and Status = 1 and IsSetUpDone=0)
	BEGIN
		update Common.CompanyModule set SetUpDone = 1 where CompanyId=@NEW_COMPANY_ID and ModuleId = (Select Id from Common.ModuleMaster where name ='Admin Cursor')
	END

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
   --ROLLBACK TRANSACTION 
END CATCH
--BEGIN
----COMMIT TRANSACTION
--END
END
GO
