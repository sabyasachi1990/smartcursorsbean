USE [SmartCursorSTG]
GO
/****** Object:  Table [Auth].[RoleNew]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Auth].[RoleNew](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Name] [nvarchar](100) NULL,
	[ModuleMasterId] [bigint] NULL,
	[Status] [int] NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[IsSystem] [bit] NULL,
	[BackgroundColor] [nvarchar](50) NULL,
	[CursorIcon] [nvarchar](50) NULL,
	[Remarks] [nvarchar](1000) NULL,
	[SubscriptionId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_RoleNew] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Auth].[RoleNew]  WITH CHECK ADD  CONSTRAINT [FK_RoleNew_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Auth].[RoleNew] CHECK CONSTRAINT [FK_RoleNew_Company]
GO
ALTER TABLE [Auth].[RoleNew]  WITH CHECK ADD  CONSTRAINT [FK_RoleNew_ModuleMaster] FOREIGN KEY([ModuleMasterId])
REFERENCES [Common].[ModuleMaster] ([Id])
GO
ALTER TABLE [Auth].[RoleNew] CHECK CONSTRAINT [FK_RoleNew_ModuleMaster]
GO
ALTER TABLE [Auth].[RoleNew]  WITH CHECK ADD  CONSTRAINT [FK_RoleNew_Subscription] FOREIGN KEY([SubscriptionId])
REFERENCES [License].[Subscription] ([Id])
GO
ALTER TABLE [Auth].[RoleNew] CHECK CONSTRAINT [FK_RoleNew_Subscription]
GO
