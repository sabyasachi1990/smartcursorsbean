USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[Roles]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[Roles](
	[id] [uniqueidentifier] NULL,
	[CompanyId] [bigint] NOT NULL,
	[Role] [nvarchar](50) NOT NULL,
	[UserCreated] [nvarchar](100) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](100) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[IsSystem] [bit] NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[TypeId] [uniqueidentifier] NULL,
	[TaxManualId] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
