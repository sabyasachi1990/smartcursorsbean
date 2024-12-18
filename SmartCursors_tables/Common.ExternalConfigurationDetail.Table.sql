USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[ExternalConfigurationDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[ExternalConfigurationDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[ExternalConfigurationId] [uniqueidentifier] NOT NULL,
	[TypeId] [uniqueidentifier] NULL,
	[Code] [nvarchar](256) NULL,
	[Name] [nvarchar](256) NULL,
	[Additionalinfo] [nvarchar](max) NULL,
	[Description] [nvarchar](max) NULL,
	[Remarks] [nvarchar](1000) NULL,
	[Recorder] [int] NULL,
	[Status] [int] NULL,
	[Type] [nvarchar](50) NULL,
	[SPOAdminUrl] [nvarchar](500) NULL,
	[ParentSiteUrl] [nvarchar](500) NULL,
	[CertUrl] [nvarchar](2000) NULL,
	[CertPassword] [nvarchar](100) NULL,
	[CertValidity] [datetime] NULL,
	[AdminEmailId] [nvarchar](500) NULL,
	[CertFileName] [nvarchar](200) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
