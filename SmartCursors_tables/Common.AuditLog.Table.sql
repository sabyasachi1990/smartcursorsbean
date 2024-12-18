USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[AuditLog]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[AuditLog](
	[Id] [uniqueidentifier] NULL,
	[SourceId] [uniqueidentifier] NULL,
	[DestinationId] [nvarchar](max) NULL,
	[SyncingStatus] [nvarchar](100) NULL,
	[CompanyId] [bigint] NULL,
	[FromScreen] [nvarchar](50) NULL,
	[ToScreen] [nvarchar](50) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[Action] [nvarchar](50) NULL,
	[Priority] [nvarchar](50) NULL,
	[SystemRemarks] [nvarchar](max) NULL,
	[DeveloperRemarks] [nvarchar](max) NULL,
	[ErrorMessage] [nvarchar](max) NULL,
	[PayLoad] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
