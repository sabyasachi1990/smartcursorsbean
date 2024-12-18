USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Common].[GET_USER_PERMISSIONS]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Common].[GET_USER_PERMISSIONS](@COMPANY_ID NVARCHAR(100), @USERNAME NVARCHAR(500),@MODULE_DETAIL_ID NVARCHAR(200),@LOOP_CNT INT, @Heading nvarchar(200))
AS
BEGIN
    DECLARE @PermissionKey nvarchar(100) 
	--DECLARE @Heading nvarchar(200)
	If(@Heading = 'My Claims')
		set @PermissionKey ='hr_myclaims'
	else  If(@Heading = 'My Leaves')
		set @PermissionKey ='hr_employeeselfservicesmyleaves'
	else If(@Heading = 'Manage Claims')
		set @PermissionKey ='hr_mss_manageclaims'
	else  If(@Heading = 'Manage Leaves')
		set @PermissionKey ='hr_mss_manageleaves'
	else  If(@Heading = 'Attendance')
		set @PermissionKey ='hr_attendance'
	else if(@Heading = 'My Calendar')
	    set @PermissionKey='hr_mycalendar'

	DECLARE @ModuleModuleId bigint = (select Id from Common.ModuleMaster where Name='HR Cursor')
	SET @MODULE_DETAIL_ID = (select Id from Common.ModuleDetail where CompanyId=@COMPANY_ID AND Heading=@Heading and PermissionKey=@PermissionKey and SecondryModuleId=@ModuleModuleId and ModuleMasterId= @ModuleModuleId)
    --EXEC COMMON.GET_USER_PERMISSIONS '1', 'ivy.goh@smartcursors.org',646,20
	declare  @temp Table (Heading nvarchar(1000) null, ActionName nvarchar(100), IsAssigned bit)
	declare @cnt nvarchar(10) = -1
	--declare @loopcount int = 5
	If((SELECT PermissionKey FROM Common.ModuleDetail WHERE ID=@MODULE_DETAIL_ID) = 'hr_mycalendar')
	BEGIN
		WHILE @cnt < @LOOP_CNT
		BEGIN
			SET @cnt = @cnt + 1;
			Print @cnt
			declare @MyCalendarQuery nvarchar(max) = 'select JSON_Value(PERMISSIONS,''$.ScreenName'') as Heading, JSON_Value(PERMISSIONS,''$.Tabs[0].Actions['+@cnt+'].Name'') as ActionName, JSON_Value(PERMISSIONS,''$.Tabs[0].Actions['+@cnt+'].Chk'') as IsAssigned from Auth.UserPermissionNew where  ModuleDetailId = '+@MODULE_DETAIL_ID+' AND CompanyUserId = (SELECT ID FROM Common.CompanyUser WHERE CompanyId='+@COMPANY_ID+' AND Username='''+@USERNAME+''') and IsView=1'
			print @MyCalendarQuery
			insert into @temp
			exec(@MyCalendarQuery)
			Print 'Insertion done'
		END
	END
	ELSE
	BEGIN
		WHILE @cnt < @LOOP_CNT
		BEGIN
			SET @cnt = @cnt + 1;
			Print @cnt
			declare @Query nvarchar(max) = 'select JSON_Value(PERMISSIONS,''$.ScreenName'') as Heading, JSON_Value(PERMISSIONS,''$.Tabs[0].Form.Tabs[0].Actions['+@cnt+'].Name'') as ActionName, JSON_Value(PERMISSIONS,''$.Tabs[0].Form.Tabs[0].Actions['+@cnt+'].Chk'') as IsAssigned from Auth.UserPermissionNew where  ModuleDetailId = '+@MODULE_DETAIL_ID+' AND CompanyUserId = (SELECT ID FROM Common.CompanyUser WHERE CompanyId='+@COMPANY_ID+' AND Username='''+@USERNAME+''') and IsView=1'
			print @Query
			insert into @temp
			exec(@Query)
			Print 'Insertion done'
		END
	END
	SELECT * FROM @temp
END
GO
