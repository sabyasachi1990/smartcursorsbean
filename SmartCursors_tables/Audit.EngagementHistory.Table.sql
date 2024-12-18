USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[EngagementHistory]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[EngagementHistory](
	[Id] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[SeedDataType] [nvarchar](500) NULL,
	[SeedDataStatus] [nvarchar](max) NULL,
	[Recorder] [int] NULL,
	[CreatedTime] [datetime2](7) NULL,
	[object] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
