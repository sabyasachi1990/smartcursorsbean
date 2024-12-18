USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[TaxMenuMaster]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[TaxMenuMaster](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ModuleDetailId] [bigint] NOT NULL,
	[GroupName] [nvarchar](100) NULL,
	[PermissionKey] [nvarchar](100) NULL,
	[CssSprite] [nvarchar](100) NULL,
	[FontAwesome] [nvarchar](100) NULL,
	[Url] [nvarchar](100) NULL,
	[IsDuplicate] [bit] NULL,
	[IsSystem] [bit] NULL,
	[IsAllowTemplate] [bit] NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NOT NULL,
 CONSTRAINT [PK_TaxMenuMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[TaxMenuMaster]  WITH CHECK ADD  CONSTRAINT [FK_TaxMenuMaster_ModuleDetail] FOREIGN KEY([ModuleDetailId])
REFERENCES [Common].[ModuleDetail] ([Id])
GO
ALTER TABLE [Tax].[TaxMenuMaster] CHECK CONSTRAINT [FK_TaxMenuMaster_ModuleDetail]
GO
