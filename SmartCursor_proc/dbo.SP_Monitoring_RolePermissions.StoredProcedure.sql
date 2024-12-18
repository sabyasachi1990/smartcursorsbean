USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_Monitoring_RolePermissions]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [dbo].[SP_Monitoring_RolePermissions]  --Exec [SP_Monitoring_RolePermissions] 
AS
BEGIN 

Declare @PERMISSIONS nvarchar (max)
Declare @Id uniqueidentifier
Declare @RoleId uniqueidentifier
Declare @ModuleDetailId bigint
Declare @PermissionsErrorTable table  (id uniqueidentifier,RoleId uniqueidentifier,ModuleDetailId bigint,[Permissions] nvarchar (max),ErrorMessage Nvarchar(4000))
DECLARE db_cursor CURSOR FOR 
select Id,[PERMISSIONS],RoleId,ModuleDetailId from Auth.RolePermissionsNew-- where id  in ('83CA9C61-7098-4CD7-BF22-5BFFC97B07CA','5DC9F910-FC3F-4E9D-885E-8A271A1D9E39')
OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @Id,  @PERMISSIONS,@RoleId,@ModuleDetailId

WHILE @@FETCH_STATUS = 0  
BEGIN  

BEGIN TRY

  declare @error int  = (select count( [key])  from OPENJSON((select [PERMISSIONS] from Auth.RolePermissionsNew where id =@Id)))

END TRY
BEGIN CATCH
	Declare @ErrorMessage Nvarchar(4000)
	Select @ErrorMessage=error_message();
	  If @ErrorMessage is not null
	  begin 
	  Insert into @PermissionsErrorTable
      select @Id,@RoleId,@ModuleDetailId, @PERMISSIONS,@ErrorMessage
	  end 
END CATCH

FETCH NEXT FROM db_cursor INTO @Id,  @PERMISSIONS,@RoleId,@ModuleDetailId
END 
CLOSE db_cursor  
DEALLOCATE db_cursor

select A.ID,A.[Permissions],B.GroupName,B.Heading,c.Name as 'Company name',b.CompanyId,A.ErrorMessage from @PermissionsErrorTable A
 inner JOIN Common.ModuleDetail B ON B.ID=A.ModuleDetailId
 inner join Common.Company c on c.id=b.CompanyId
END
GO
