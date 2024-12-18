USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Common].[User_Save_DeleteUserPermission]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create   procedure [Common].[User_Save_DeleteUserPermission](@companyUserId bigint)
As
Begin   
--begin transaction
Begin try

    --#region Old Code
	---- deleting the user permissions
	--delete from Auth.UserPermissionNew where ModuleDetailId in 
	--(
	--   select RPN.ModuleDetailId from Auth.UserRoleNew URN 
	--   join Auth.RolePermissionsNew RPN on RPN.RoleId = URN.RoleId
	--   where URN.CompanyUserId=@companyUserId and URN.Status=4
	--) and CompanyUserId = @companyUserId
	---- deleting the user roles
	--delete from Auth.UserRoleNew where CompanyUserId = @companyUserId and Status=4
    --#endregion

	declare @moduleDetailIds varchar(max) = (select STRING_AGG(cast(RPN.ModuleDetailId as varchar(max)),',') from Auth.UserRoleNew URN 
	   join Auth.RolePermissionsNew RPN on RPN.RoleId = URN.RoleId
	   where URN.CompanyUserId=@companyUserId and URN.Status=4 )

	declare @sql_upn nvarchar(max) = 'Delete from Auth.UserPermissionNew where CompanyUserId = '+cast(@companyUserId as varchar(1000))+' and ModuleDetailId in (' + @moduleDetailIds + ')'

	print '---------IN list---------'
	set statistics time on
	exec (@sql_upn)
	set statistics time off
	print '---------IN list---------'

	Delete from Auth.UserRoleNew where  CompanyUserId = @companyUserId and Status=4 

END try
begin Catch
	--Rollback
end catch
--Commit transaction
END
GO
