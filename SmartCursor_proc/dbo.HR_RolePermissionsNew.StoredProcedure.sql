USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_RolePermissionsNew]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE  PROCEDURE [dbo].[HR_RolePermissionsNew](  @companyId bigint)
 as
 declare 
 @id uniqueidentifier
 
 declare RoleNewcursor cursor for select Id from Auth.RoleNew where  ModuleMasterId=8 and CompanyId=@companyId
 
 open RoleNewcursor 
fetch next from RoleNewcursor into @id 

while @@FETCH_STATUS=0 
begin

 declare @permissoin nvarchar(max) = (select top 1 Permissions from auth.RolePermissionsNew  where ModuleDetailId in (select Id from Common.ModuleDetail where Heading='Employees' and PermissionKey='hr_em_employees' and CompanyId=@companyId)  and RoleId=@id)

  declare @payroll nvarchar(max) = (SELECT JSON_QUERY(@permissoin, '$.Tabs[0].Form.Tabs[2]') AS 'Result')
  declare @tabs nvarchar(max) = (SELECT JSON_QUERY(@permissoin, '$.Tabs[0].Form.Tabs[2].Tabs') AS 'Result')
  declare @ps nvarchar(max) = (SELECT JSON_QUERY(@payroll, '$.Tabs[1]') AS 'Result')
  declare @pc nvarchar(max) = (SELECT JSON_QUERY(@payroll, '$.Tabs[0]') AS 'Result')
  declare @pslp nvarchar(max) = (SELECT JSON_QUERY(@payroll, '$.Tabs[2]') AS 'Result')
  declare @replace nvarchar(max) = (SELECT REPLACE(JSON_modify(@permissoin, '$.Tabs[0].Form.Tabs[2].Tabs', CONCAT('[',@ps,',',@pc,',',@pslp,']')),'\"','"') AS 'Result')
  declare @final nvarchar(max) =  (Select replace(@replace, '"[','['))
 declare @finalPermission nvarchar(max) = (Select replace(@final, ']"',']'))


  update Auth.RolePermissionsNew set Permissions= @finalPermission where RoleId=@id and  ModuleDetailId in (select Id from Common.ModuleDetail where Heading='Employees' and PermissionKey='hr_em_employees' and CompanyId=@companyId)

   declare @MyProfilepermissoin nvarchar(max) = (select top 1 Permissions from auth.RolePermissionsNew  where ModuleDetailId in (select Id from Common.ModuleDetail where Heading='My Profile' and PermissionKey='hr_ess_myprofile' and CompanyId=@companyId)  and RoleId=@id)

  declare @Myprofilepayroll nvarchar(max) = (SELECT JSON_QUERY(@MyProfilepermissoin, '$.Tabs[0].Form.Tabs[2]') AS 'Result')
  declare @MyProfiletabs nvarchar(max) = (SELECT JSON_QUERY(@MyProfilepermissoin, '$.Tabs[0].Form.Tabs[2].Tabs') AS 'Result')
  declare @MyProfileps nvarchar(max) = (SELECT JSON_QUERY(@Myprofilepayroll, '$.Tabs[1]') AS 'Result')
  declare @MyProfilepc nvarchar(max) = (SELECT JSON_QUERY(@Myprofilepayroll, '$.Tabs[0]') AS 'Result')
  declare @MyProfilepslp nvarchar(max) = (SELECT JSON_QUERY(@Myprofilepayroll, '$.Tabs[2]') AS 'Result')
  declare @MyProfilereplace nvarchar(max) = (SELECT REPLACE(JSON_modify(@MyProfilepermissoin, '$.Tabs[0].Form.Tabs[2].Tabs', CONCAT('[',@MyProfileps,',',@MyProfilepc,',',@MyProfilepslp,']')),'\"','"') AS 'Result')
  declare @MyProfilefinal nvarchar(max) =  (Select replace(@MyProfilereplace, '"[','['))
 declare @MyProfilefinalPermission nvarchar(max) = (Select replace(@MyProfilefinal, ']"',']'))


  update Auth.RolePermissionsNew set Permissions= @MyProfilefinalPermission where RoleId=@id and  ModuleDetailId in (select Id from Common.ModuleDetail where Heading='My Profile' and PermissionKey='hr_ess_myprofile' and CompanyId=@companyId)








    fetch next from RoleNewcursor into @id 
  end

close RoleNewcursor
deallocate  RoleNewcursor





GO
