USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[FW_MODULE_DETAIL_INSERTION]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   Procedure [dbo].[FW_MODULE_DETAIL_INSERTION](@UNIQUE_COMPANY_ID bigint,@NEW_COMPANY_ID bigint, @MODULEID bigint)
AS
BEGIN
--BEGIN TRANSACTION
BEGIN TRY

	declare @temptable table ([Id] [bigint] NOT NULL,    [ModuleMasterId] [bigint] NOT NULL,    [GroupName] [nvarchar](100) NULL,    [Heading] [nvarchar](100) NOT NULL,    [Description] [nvarchar](1000) NULL,    [LogoId] [uniqueidentifier] NULL,    [CssSprite] [nvarchar](50) NULL,    [FontAwesome] [nvarchar](50) NULL,    [Url] [nvarchar](1000) NULL,    [RecOrder] [int] NULL,    [Remarks] [nvarchar](256) NULL,    [Status] [int] NULL,    [PageUrl] [nvarchar](1000) NOT NULL,    [GroupUrl] [nvarchar](100) NULL,    [CompanyId] [bigint] NOT NULL,    [MasterUrl] [nvarchar](50) NULL,    [ParentId] [bigint] NULL,    [PermissionKey] [nvarchar](50) NULL,    [ModuleName] [nvarchar](100) NULL,    [IsPermissionInherited] [bit] NOT NULL,    [IsHideTab] [bit] NOT NULL,    [SecondryModuleId] [bigint] NULL,    [GroupKey] [nvarchar](100) NULL,    [IsDisable] [bit] NOT NULL,    [IsPartner] [bit] NOT NULL,    [IsMandatory] [int] NULL,    [HelpLink] [nvarchar](256) NULL,    [SetupOrder] [int] NULL,    [Cachekeys] [nvarchar](max) NULL,    [CursorName] [nvarchar](500) NULL,    [IsAnalytics] [bit] NULL,    [IsBot] [bit] NULL,    [DashboardURL] [nvarchar](max) NULL,    [SubGroupName] [nvarchar](100) NULL,    [TabLevel] [int] NULL,    [ModuleDetailId] [nvarchar](100) NULL,    [IsHide] [bit] NULL,    [MongoGroupName] [nvarchar](200) NULL,    [IsTabHide] [bit] NULL,    [IsMenuHide] [bit] NULL,[IsHome] [bit] NULL,[IsGridLevelBlade] [bit] NULL,[IsFormLevelBlade] [bit] NULL)

		insert into @temptable  (Id,ModuleMasterId,GroupName,Heading,Description,LogoId,CssSprite,FontAwesome,Url,RecOrder,Remarks,Status,PageUrl,GroupUrl,CompanyId,MasterUrl,ParentId,PermissionKey,ModuleName,IsPermissionInherited,IsHideTab,SecondryModuleId,GroupKey,IsDisable,IsPartner,IsMandatory,HelpLink,SetupOrder,Cachekeys,CursorName,IsAnalytics,IsBot,DashboardURL,SubGroupName,TabLevel,ModuleDetailId,IsHide,MongoGroupName,IsTabHide,IsMenuHide,IsHome, IsGridLevelBlade, IsFormLevelBlade)
		select  (SELECT MAX(Id) FROM Common.ModuleDetail)+ROW_NUMBER() OVER(ORDER BY ID)  AS Id,cmd.ModuleMasterId,cmd.GroupName,cmd.Heading,cmd.Description,cmd.LogoId,cmd.CssSprite,cmd.FontAwesome,cmd.Url,cmd.RecOrder,cmd.Remarks,cmd.Status,cmd.PageUrl,cmd.GroupUrl,@NEW_COMPANY_ID,cmd.MasterUrl,cmd.ParentId,cmd.PermissionKey,cmd.ModuleName,cmd.IsPermissionInherited,cmd.IsHideTab,cmd.SecondryModuleId,cmd.GroupKey,cmd.IsDisable,cmd.IsPartner,cmd.IsMandatory,cmd.HelpLink,cmd.SetupOrder,cmd.Cachekeys,cmd.CursorName,cmd.IsAnalytics,cmd.IsBot,cmd.DashboardURL,cmd.SubGroupName,cmd.TabLevel,cmd.ModuleDetailId,cmd.IsHide,cmd.MongoGroupName,cmd.IsTabHide,cmd.IsMenuHide,cmd.IsHome,cmd.IsGridLevelBlade,cmd.IsFormLevelBlade from Common.ModuleDetail As cmd  where cmd.CompanyId=@UNIQUE_COMPANY_ID and cmd.SecondryModuleId=@MODULEID and cmd.PermissionKey not in (select PermissionKey from Common.ModuleDetail where SecondryModuleId=@MODULEID and CompanyId = @NEW_COMPANY_ID) order by Id;

		insert into Common.ModuleDetail (Id,ModuleMasterId,GroupName,Heading,[Description],LogoId,CssSprite,FontAwesome,[Url],RecOrder,Remarks,[Status],PageUrl,GroupUrl,CompanyId,MasterUrl,ParentId,PermissionKey,ModuleName,IsPermissionInherited,IsHideTab,SecondryModuleId,GroupKey,IsDisable,IsPartner,IsMandatory,HelpLink,SetupOrder,Cachekeys,CursorName,IsAnalytics,IsBot,DashboardURL,SubGroupName,TabLevel,ModuleDetailId,IsHide,MongoGroupName,IsTabHide,IsMenuHide,IsHome,IsGridLevelBlade,IsFormLevelBlade)

		select temp.Id,temp.ModuleMasterId,temp.GroupName,temp.Heading,temp.Description,temp.LogoId,temp.CssSprite,temp.FontAwesome,temp.Url,temp.RecOrder,temp.Remarks,temp.Status,temp.PageUrl,temp.GroupUrl,temp.CompanyId,temp.MasterUrl,
		 (select Id from @temptable where 
		 modulemasterid = (select modulemasterid from Common.ModuleDetail where Id=temp.ParentId and companyid=@UNIQUE_COMPANY_ID) and 
		 coalesce(groupname,'ABCD') in (select coalesce(groupname,'ABCD') from Common.ModuleDetail where Id=temp.ParentId and companyid=@UNIQUE_COMPANY_ID) and 
		 PermissionKey=(select PermissionKey from Common.ModuleDetail where Id=temp.ParentId and companyid=@UNIQUE_COMPANY_ID) and 
		 heading in (select heading from Common.ModuleDetail where Id=temp.ParentId and companyid=@UNIQUE_COMPANY_ID)) as ParentId, temp.PermissionKey,temp.ModuleName,temp.IsPermissionInherited,temp.IsHideTab,temp.SecondryModuleId,temp.GroupKey,temp.IsDisable,temp.IsPartner,temp.IsMandatory,temp.HelpLink,temp.SetupOrder,temp.Cachekeys,temp.CursorName,temp.IsAnalytics,temp.IsBot,temp.DashboardURL,temp.SubGroupName,temp.TabLevel,temp.ModuleDetailId,temp.IsHide,temp.MongoGroupName,temp.IsTabHide,temp.IsMenuHide,temp.IsHome,temp.IsGridLevelBlade,temp.IsFormLevelBlade from @temptable As temp

--COMMIT TRANSACTION
END TRY
BEGIN CATCH
	--ROLLBACK;
	Print 'FAILED!'
	DECLARE      
     @ErrorMessage NVARCHAR(4000),      
     @ErrorSeverity INT,      
     @ErrorState INT;      
SELECT      
     @ErrorMessage = ERROR_MESSAGE(),      
     @ErrorSeverity = ERROR_SEVERITY(),      
     @ErrorState = ERROR_STATE();      
   RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH
END
GO
