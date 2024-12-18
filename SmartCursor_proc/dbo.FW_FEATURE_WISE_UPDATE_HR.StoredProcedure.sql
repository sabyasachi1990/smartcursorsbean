USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[FW_FEATURE_WISE_UPDATE_HR]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FW_FEATURE_WISE_UPDATE_HR](@NEW_COMPANY_ID bigint, @UNIQUE_COMPANY_ID bigint, @UNIQUE_Id uniqueidentifier)
AS
BEGIN
BEGIN TRY
declare @cnt int = 1
declare @moduledetail_unique_cnt int = (select COUNT(*) as cnt from common.moduledetail where companyId=@UNIQUE_COMPANY_ID and SecondryModuleId=(select Id from Common.ModuleMaster where Name='HR Cursor'))
declare @moduledetail_company_cnt int = (select COUNT(*) as cnt from common.moduledetail where companyId=@NEW_COMPANY_ID and SecondryModuleId=(select Id from Common.ModuleMaster where Name='HR Cursor'))
DECLARE @IN_PROGRESS nvarchar(20) = 'In-Progress'
DECLARE @COMPLETED nvarchar(20) = 'Completed'

while (@cnt > 0)
begin
        if((@cnt = @moduledetail_unique_cnt) OR (@moduledetail_company_cnt = @moduledetail_unique_cnt))
		begin
		   DECLARE @feature_update_Id uniqueidentifier = NEWID()

		   INSERT INTO Common.DetailLog values(@feature_update_Id, @UNIQUE_Id , 'FW_FEATURE_WISE_UPDATE_HR - Seed data Execution Started', GETUTCDATE() , '1.1' , NULL , @IN_PROGRESS )

		   DECLARE @featureMD_Inac_Id uniqueidentifier = NEWID()
   		   INSERT INTO Common.DetailLog values(@featureMD_Inac_Id, @UNIQUE_Id , 'FW_FEATURE_WISE_UPDATE_HR - MD Status inactive', GETUTCDATE() , '1.2' , NULL , @IN_PROGRESS )
			update MD set status=2 from Common.ModuleDetail MD
			where MD.CompanyId=@NEW_COMPANY_ID and MD.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
			left join Common.Feature F on cf.FeatureId = F.Id 
			where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and cf.Status = 2)
			Update Common.DetailLog set Status = @COMPLETED where Id = @featureMD_Inac_Id


		   DECLARE @featureMD_ac_Id uniqueidentifier = NEWID()
   		   INSERT INTO Common.DetailLog values(@featureMD_ac_Id, @UNIQUE_Id , 'FW_FEATURE_WISE_UPDATE_HR - MD Status active', GETUTCDATE() , '1.3' , NULL , @IN_PROGRESS )
			update MD set status=1 from Common.ModuleDetail MD
			where MD.CompanyId=@NEW_COMPANY_ID and MD.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
			left join Common.Feature F on cf.FeatureId = F.Id 
			where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and cf.Status = 1)
			Update Common.DetailLog set Status = @COMPLETED where Id = @featureMD_ac_Id

		
			update ICS set Status=2 from Common.InitialCursorSetup ICS
			join Common.ModuleDetail MD on ICS.ModuleDetailId = MD.Id
			where ICS.CompanyId=@NEW_COMPANY_ID and MD.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
			left join Common.Feature F on cf.FeatureId = F.Id 
			where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and cf.Status = 2)

			update ICS set Status=1 from Common.InitialCursorSetup ICS
			join Common.ModuleDetail MD on ICS.ModuleDetailId = MD.Id
			where ICS.CompanyId=@NEW_COMPANY_ID and MD.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
			left join Common.Feature F on cf.FeatureId = F.Id 
			where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and cf.Status = 1)
			
			Update Common.DetailLog set Status = @COMPLETED where Id = @feature_update_Id

			set @cnt = null
			--break;
		END
		set @cnt = @cnt+1
end
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
end



















GO
